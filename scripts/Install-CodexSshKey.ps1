param(
    [Parameter(Mandatory = $true)]
    [string]$HostAlias,

    [string]$PublicKeyPath = "$env:USERPROFILE\.ssh\id_ed25519_codex_homelab.pub"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $PublicKeyPath)) {
    throw "Public key not found: $PublicKeyPath"
}

$publicKey = (Get-Content -LiteralPath $PublicKeyPath -Raw).Trim()
if (-not $publicKey.StartsWith("ssh-")) {
    throw "Public key file does not look like an SSH public key: $PublicKeyPath"
}

$remoteScript = @'
set -eu
umask 077
mkdir -p "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
tmp_key="$(mktemp)"
cat > "$tmp_key"
if ! grep -qxF -f "$tmp_key" "$HOME/.ssh/authorized_keys"; then
  cat "$tmp_key" >> "$HOME/.ssh/authorized_keys"
fi
rm -f "$tmp_key"
chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/authorized_keys"
echo codex-key-installed
'@

Write-Host "Installing Codex SSH public key on $HostAlias."
Write-Host "If prompted, enter the password for the remote account."
$publicKey | ssh $HostAlias $remoteScript
