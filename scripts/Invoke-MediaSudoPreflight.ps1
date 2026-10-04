param(
    [switch]$UpdateOsIfSafe,
    [switch]$SafeCleanup,
    [string]$HostAlias = "media",
    [string]$RemoteScript = "/tmp/codex-media-sudo-preflight.sh"
)

$ErrorActionPreference = "Stop"

$localScript = Join-Path $PSScriptRoot "media_sudo_preflight.sh"
if (-not (Test-Path -LiteralPath $localScript)) {
    throw "Missing local script: $localScript"
}

$remoteArgs = @()
if ($UpdateOsIfSafe) {
    $remoteArgs += "--update-os-if-safe"
} else {
    $remoteArgs += "--preflight"
}

if ($SafeCleanup) {
    $remoteArgs += "--safe-cleanup"
}

Write-Host "Copying MediaCenter sudo preflight script to $HostAlias..."
scp $localScript "${HostAlias}:$RemoteScript"

Write-Host "Running MediaCenter sudo preflight on $HostAlias."
Write-Host "If prompted, enter the MediaCenter sudo password."
$argText = $remoteArgs -join " "
ssh -tt $HostAlias "sudo bash $RemoteScript $argText"
