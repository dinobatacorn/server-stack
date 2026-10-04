param(
    [string]$ConfigPath = "$env:USERPROFILE\.ssh\config",
    [string[]]$Hosts = @("pve","pihole","wireguard","services","media","ravenstower","lockbox","steamdeck","ravenssteamdeck","atlasos-ravenst","laptop-f96a9ft3"),
    [int]$TimeoutSec = 5,
    [string]$Output = ""
)

$results = foreach ($hostAlias in $Hosts) {
    $args = @("-F", $ConfigPath, "-o", "BatchMode=yes", "-o", "ConnectTimeout=$TimeoutSec", $hostAlias, "echo codex-ssh-ok")
    $started = Get-Date
    $outputText = ""
    $exitCode = $null
    try {
        $outputText = & ssh @args 2>&1 | Out-String
        $exitCode = $LASTEXITCODE
    } catch {
        $outputText = $_.Exception.Message
        $exitCode = 255
    }
    $status = if ($exitCode -eq 0 -and $outputText -match "codex-ssh-ok") { "ready" }
        elseif ($outputText -match "Permission denied|publickey|password|keyboard-interactive") { "credentials needed" }
        elseif ($outputText -match "Host key verification failed|authenticity of host") { "reachable but limited" }
        elseif ($outputText -match "Could not resolve|Name or service not known|No such host") { "offline or DNS missing" }
        elseif ($outputText -match "Connection timed out|Operation timed out|No route to host|Network is unreachable") { "offline" }
        elseif ($outputText -match "Connection refused") { "reachable but ssh refused" }
        else { "reachable but limited" }
    [pscustomobject]@{
        alias = $hostAlias
        status = $status
        exit_code = $exitCode
        checked_at = $started.ToString("o")
        note = ($outputText.Trim() -replace "\s+", " ")
    }
}

if ($Output) {
    $parent = Split-Path -Parent $Output
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $results | ConvertTo-Json -Depth 4 | Out-File -Encoding UTF8 $Output
}

$results | Format-Table -AutoSize