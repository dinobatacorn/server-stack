param(
    [string]$Output = "",
    [string]$OutputBase = "",
    [string]$Role = "windows-endpoint",
    [string]$Phase = "snapshot",
    [string]$HWiNFOPath = "",
    [string]$HWiNFOReport = "",
    [int]$HWiNFOTimeoutSec = 10,
    [switch]$SkipHWiNFO
)

$ErrorActionPreference = "Continue"
$ScriptVersion = "2026-09-29.1"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

if (-not $Output) {
    if (-not $OutputBase) { $OutputBase = Join-Path $ScriptDir "output" }
    $hostname = $env:COMPUTERNAME
    $runDate = (Get-Date).ToString("yyyy-MM-dd")
    $ts = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
    $outDir = Join-Path $OutputBase (Join-Path $runDate (Join-Path $Phase $hostname))
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    $Output = Join-Path $outDir "$hostname`_$Phase`_$ts.json"
}

$outParent = Split-Path -Parent $Output
if ($outParent) { New-Item -ItemType Directory -Path $outParent -Force | Out-Null }

if (-not $HWiNFOPath) { $HWiNFOPath = Join-Path $RepoRoot "tools\HWiNFO64.exe" }
if (-not $HWiNFOReport) { $HWiNFOReport = Join-Path $outParent "hwinfo.xml" }

$warnings = New-Object System.Collections.Generic.List[string]

if (-not $SkipHWiNFO) {
    if (Test-Path $HWiNFOPath) {
        try {
            $proc = Start-Process -FilePath $HWiNFOPath -ArgumentList "-r","-x",$HWiNFOReport -WindowStyle Hidden -PassThru
            if (-not $proc.WaitForExit($HWiNFOTimeoutSec * 1000)) {
                $proc.Kill()
                $warnings.Add("HWiNFO timed out after $HWiNFOTimeoutSec seconds")
            }
        } catch {
            $warnings.Add("HWiNFO failed: $($_.Exception.Message)")
        }
    } else {
        $warnings.Add("HWiNFO not found at $HWiNFOPath")
    }
}

function Get-CimSafe {
    param([string]$ClassName)
    try { Get-CimInstance $ClassName } catch { $warnings.Add("CIM $ClassName failed: $($_.Exception.Message)"); @() }
}

$timestamp = (Get-Date).ToString("o")
$osInfo = Get-CimSafe Win32_OperatingSystem | Select-Object -First 1
$cpuInfo = @(Get-CimSafe Win32_Processor)
$cs = Get-CimSafe Win32_ComputerSystem | Select-Object -First 1

$cpu = @{
    model = if ($cpuInfo -and $cpuInfo[0].Name) { $cpuInfo[0].Name.Trim() } else { "unknown" }
    cores = [int](($cpuInfo | Measure-Object NumberOfCores -Sum).Sum)
    threads = [int](($cpuInfo | Measure-Object NumberOfLogicalProcessors -Sum).Sum)
    architecture = if ($env:PROCESSOR_ARCHITECTURE) { $env:PROCESSOR_ARCHITECTURE } else { "unknown" }
}

$memory = @{
    total_gb = if ($cs.TotalPhysicalMemory) { [int][math]::Floor($cs.TotalPhysicalMemory / 1GB) } else { 0 }
}

$gpu = @(Get-CimSafe Win32_VideoController |
    Where-Object { $_.Name } |
    Select-Object -ExpandProperty Name -Unique |
    Sort-Object |
    ForEach-Object { @{ model = $_.Trim() } })

$storage = @(Get-CimSafe Win32_DiskDrive |
    Sort-Object DeviceID |
    ForEach-Object {
        $type = "unknown"
        if ($_.Model -match "NVMe") { $type = "nvme" }
        elseif ($_.MediaType -match "SSD") { $type = "ssd" }
        elseif ($_.MediaType -match "HDD") { $type = "hdd" }
        @{ name = $_.DeviceID; model = if ($_.Model) { $_.Model.Trim() } else { "unknown" }; size_gb = if ($_.Size) { [int][math]::Floor($_.Size / 1GB) } else { 0 }; type = $type }
    })

$volumes = @(Get-Volume -ErrorAction SilentlyContinue | Sort-Object DriveLetter,FileSystemLabel | ForEach-Object {
    @{ drive = if ($_.DriveLetter) { "$($_.DriveLetter):" } else { "" }; label = $_.FileSystemLabel; filesystem = $_.FileSystem; size_gb = if ($_.Size) { [int][math]::Floor($_.Size / 1GB) } else { 0 }; free_gb = if ($_.SizeRemaining) { [int][math]::Floor($_.SizeRemaining / 1GB) } else { 0 }; health = "$($_.HealthStatus)" }
})

$network = @()
$adapters = @(Get-CimSafe Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -eq $true -and $_.MACAddress } | Sort-Object Name)
$configs = @(Get-CimSafe Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled })
foreach ($adapter in $adapters) {
    $config = $configs | Where-Object { $_.InterfaceIndex -eq $adapter.InterfaceIndex } | Select-Object -First 1
    $addresses = @()
    if ($config -and $config.IPAddress) { $addresses = @($config.IPAddress | Where-Object { $_ -match '^\d+\.' } | Sort-Object -Unique) }
    $network += @{ name = if ($adapter.Name) { $adapter.Name.Trim() } else { "unknown" }; mac = $adapter.MACAddress; state = if ($adapter.NetEnabled) { "up" } else { "down" }; type = if ($adapter.AdapterType) { $adapter.AdapterType } else { "unknown" }; addresses = $addresses }
}

$uptimeSeconds = if ($osInfo.LastBootUpTime) { [int]((Get-Date) - $osInfo.LastBootUpTime).TotalSeconds } else { 0 }
$pci = @(Get-CimSafe Win32_PnPEntity | Where-Object { $_.Name -and $_.PNPClass -ne "System" } | Sort-Object Name | Select-Object -First 250 | ForEach-Object { @{ raw = $_.Name } })
$usb = @(Get-CimSafe Win32_USBControllerDevice | Select-Object -First 250 | ForEach-Object { @{ raw = $_.Dependent } })
$dmi = @{ raw = if ($cs) { (($cs.Manufacturer, $cs.Model) -join " ").Trim() } else { "unknown" } }
$hwinfoSensors = @{}
$hwinfoBoard = $null

if (Test-Path $HWiNFOReport) {
    try {
        [xml]$xml = Get-Content $HWiNFOReport
        if ($xml.HWiNFO64.Sensors.Sensor) {
            foreach ($s in $xml.HWiNFO64.Sensors.Sensor) {
                if ($s.Name -and $s.Value) { $hwinfoSensors[$s.Name.Trim()] = $s.Value.Trim() }
            }
        }
        if ($xml.HWiNFO64.System.BaseBoard) {
            $hwinfoBoard = @{ raw = (($xml.HWiNFO64.System.BaseBoard.Manufacturer, $xml.HWiNFO64.System.BaseBoard.Product) -join " ").Trim() }
        }
    } catch {
        $warnings.Add("Failed to parse HWiNFO XML: $($_.Exception.Message)")
    }
}

$wingetUpdates = @()
if (Get-Command winget -ErrorAction SilentlyContinue) {
    try { $wingetUpdates = @(winget upgrade --accept-source-agreements 2>$null | Select-Object -Skip 1) } catch { $warnings.Add("winget upgrade listing failed: $($_.Exception.Message)") }
} else {
    $warnings.Add("winget not found")
}

$data = [ordered]@{
    meta = [ordered]@{ schema = "fleet-windows-v1"; script_version = $ScriptVersion; role = $Role; phase = $Phase; hostname = $env:COMPUTERNAME; os = if ($osInfo.Caption) { $osInfo.Caption } else { "unknown" }; kernel = if ($osInfo.Version) { $osInfo.Version } else { "unknown" }; timestamp = $timestamp }
    hardware = [ordered]@{ cpu = $cpu; memory = $memory; gpu = $gpu; storage = $storage; motherboard = if ($hwinfoBoard) { $hwinfoBoard } else { $dmi } }
    system = [ordered]@{ uptime_seconds = $uptimeSeconds; loadavg = @{ "1m" = 0; "5m" = 0; "15m" = 0 }; volumes = $volumes; package_manager = "winget"; pending_updates = @{ items = $wingetUpdates; count = $wingetUpdates.Count } }
    peripherals = [ordered]@{ pci = $pci; usb = $usb }
    network = $network
    health = [ordered]@{ smart = @(); sensors = if ($hwinfoSensors.Count -gt 0) { $hwinfoSensors } else { @{} }; warnings = @($warnings) }
}

$data | ConvertTo-Json -Depth 8 | Out-File -Encoding UTF8 $Output
Write-Host "Saved: $Output"
