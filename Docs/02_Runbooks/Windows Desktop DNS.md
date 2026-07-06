# Windows Desktop DNS

Status: Current
Last reviewed: 2026-07-06
Source docs:
- Homelab Status Overview (July 2026)
- Windows desktop DNS resolution finding, 2026-07-06
Next action: Revalidate local name resolution after Windows network, Wi-Fi driver, or Pi-hole changes.

## Purpose

Ensure the AtlasOS Windows desktop resolves local `*.dustynest.com` records consistently on the home LAN and while WireGuard is connected.

## Known Constraint And Failure Mode

- The router must use ISP DNS and cannot be changed.
- Pi-hole is `192.168.0.120` and provides local DNS records.
- Windows may prefer the Wi-Fi adapter's DNS over the WireGuard adapter's DNS while the VPN is connected.
- An explicit `nslookup` against Pi-hole can succeed while browsers and other applications still fail because the normal Windows resolver selected ISP DNS.

## Required Configuration

Configure the desktop's Wi-Fi adapter to use Pi-hole directly:

1. Open **Settings > Network & internet > Wi-Fi**.
2. Open the connected network's properties.
3. Edit **DNS server assignment**.
4. Select **Manual**, enable IPv4, and set **Preferred DNS** to `192.168.0.120`.
5. Save the change, then reconnect Wi-Fi or flush the resolver cache.

PowerShell cache reset:

```powershell
Clear-DnsClientCache
```

## Validation

Use a real local hostname in place of `<host>.dustynest.com`:

```powershell
Get-DnsClientServerAddress -InterfaceAlias 'Wi-Fi' -AddressFamily IPv4
Resolve-DnsName <host>.dustynest.com
```

Pass criteria:

- The Wi-Fi adapter lists `192.168.0.120` as its IPv4 DNS server.
- `Resolve-DnsName` returns the expected internal address without specifying a DNS server.
- The local service opens by hostname in a browser.
- Resolution still works after reconnecting Wi-Fi and toggling WireGuard.

## Troubleshooting

- Compare the system resolver with an explicit Pi-hole query: `Resolve-DnsName <host>.dustynest.com -Server 192.168.0.120`.
- If the explicit query works but the default query fails, inspect all adapter DNS assignments with `Get-DnsClientServerAddress`.
- Confirm the desktop can reach `192.168.0.120` and that Pi-hole contains the expected local record.
- Do not treat `nslookup` success alone as proof that browsers and other applications use the correct DNS path.
