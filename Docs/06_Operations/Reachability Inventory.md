# Reachability Inventory

Status: In progress
Last reviewed: 2026-09-29

## Status Meanings

- `ready`: SSH works non-interactively with the dedicated Codex key.
- `reachable but limited`: Host responded but needs follow-up before maintenance automation.
- `credentials needed`: Host is reachable, but key/password/login is not ready.
- `offline`: Host did not respond during this pass.
- `offline or DNS missing`: Alias did not resolve or the device name is not currently visible.
- `reachable but ssh refused`: Hostname resolved or answered, but normal SSH is not available on port 22.
- `not suitable for SSH`: Device should stay out of SSH-based maintenance unless requirements change.
- `manual/local`: device was maintained or inventoried at its local console; remote access is not verified.

## Inventory

| Alias | Device | HostName/IP | Expected user | Role | SSH status | Sudo/admin status | Update method | Codex remote capable | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `pve` | Proxmox host | `192.168.0.75` | `root` | infrastructure | ready by direct IP with dedicated key; `pve` alias absent | root shell | `apt` / Proxmox | yes by direct SSH | Updated and reboot-validated 2026-09-28; 2026-09-29 host/config snapshots and a fresh VM100 backup validated. RustDesk Server is isolated in LXC 103 rather than installed on PVE. |
| `pihole` | Pi-hole LXC | `192.168.0.120` | `root` | DNS | maintained through PVE `pct exec`; direct SSH still needs host-key verification | unknown | `apt` / Pi-hole updater | no | Debian packages updated 2026-09-28; FTL active, DNS query passed, post snapshot saved. Set up direct SSH only if needed. |
| `wireguard` | WireGuard LXC | `192.168.0.110` | `root` | VPN | maintained through PVE `pct exec`; direct SSH still needs host-key verification | unknown | `apt` | no | Debian packages updated 2026-09-28; `wg0` active, UDP 51820 listening, post snapshot saved. Set up direct SSH only if needed. |
| `rustdesk` | RustDesk Server LXC 103 | `192.168.0.189` (DHCP) | `root` | RustDesk ID/rendezvous and relay | managed through PVE `pct exec`; SSH not enabled/tested | root in guest | Community Scripts update function / `apt` | no | `hbbs`, `hbbr`, and API active; persistent state is under `/mnt/core/appdata/security`. User confirmed API UI password set and successful login. Screenshot shows a DNS A record to `192.168.0.189`; router DHCP reservation and VPN route remain unverified. No WAN port forwards were added. |
| `services` | VM100 Core Services | `192.168.0.125` | `raven` | Docker/core services | maintained through PVE QEMU guest agent; direct SSH still needs host-key verification | unknown | `apt`, Docker Compose | yes by PVE guest agent | OS and five active containers refreshed 2026-09-28; NPM 2.16.0, all containers running, Baserow/PostgreSQL healthy. Fresh VM/database/NPM backups validated. |
| `infra-proxy` (retired) | VM200 | `192.168.0.131` (historical) | `raven` | Retired VM | Not applicable; VM reported destroyed 2026-09-30 | Not applicable | Not applicable | no | Owner reports partner moved to Super Productivity and an older comprehensive backup exists; backup contents and restoreability are unverified. |
| `media` | MediaCenter | `192.168.0.143` | `mediacenter` | media host | ready by direct IP with dedicated key; live host key matched saved record | sudo group, password required; Docker group | `apt`, Docker Compose | yes by direct SSH | Debian/kernel updated and rebooted; post snapshot/appdata archive validated; all six containers restarted and ports responded. Root is 95% used (11 GB free); complete library scan and review storage before further image pulls. |
| `ravenstower` | Linux tower / Nobara boot | `RavensTower` | `raven` | endpoint | manual/local; SSH not tested | local owner | `nobara-sync`, Flatpak separately | no | 2026-09-29 pre/post records; verify actual package transaction and reboot outcome before automated maintenance. |
| `lockbox` | Partner's LockBox | `LockBox` | `dustinl` | gaming endpoint | reachable but SSH refused; manual/local | local owner | `garuda-update`; Flatpak separately | no | 2026-09-29 post inventory reports kernel `7.2.7-zen1-1-zen` and 0 pending repo updates. Review `mirrorlist.pacnew`; transaction log and post-Snapper list were not captured. |
| `steamdeck` | Steam Deck | `steamdeck` | `deck` | endpoint | offline or DNS missing | unknown | SteamOS / Discover / flatpak as applicable | no | Confirm current hostname/IP and whether SSH is enabled. |
| `ravenssteamdeck` | Steam Deck | `RavensSteamDeck` | `deck` | endpoint | reachable but ssh refused | unknown | SteamOS / Discover / flatpak as applicable | no | Enable SSH only if remote maintenance is worth it. |
| `atlasos-ravenst` | Windows tower / AtlasOS boot | `ATLASOS-RAVENST` | `raven` | endpoint | manual/local; SSH not tested | admin at local console | Windows Update / winget | no | Owner prefers leaving Sunshine as configured; AtlasOS post-update inventory remains pending. |
| `laptop-f96a9ft3` | Windows laptop | `LAPTOP-F96A9FT3` | `raven` | endpoint | reachable but ssh refused | admin unknown | Windows Update / winget | no | Current Codex host; SSH server optional. |

## Test Result

### PVE Pass: 2026-09-28

Direct key-based SSH succeeded with the dedicated `codex-pve-runtime-2026-09` key after its public half was installed on PVE and its fingerprint was confirmed. PVE was updated to `pve-manager 9.2.20` and rebooted into `7.0.14-19-pve`. The Proxmox management services, VM100, VM200, Pi-hole LXC, and WireGuard LXC recovered. Pi-hole DNS answered a query; WireGuard `wg0` was active with recent peer handshakes. See [Fleet Update Report 2026-09-28](Update%20Reports/2026-09-28.md) for snapshot, backup, package, and reboot validation details.

PVE has no RustDesk package or service. RustDesk Server is installed in unprivileged LXC 103; persistent server and API state are stored under `/mnt/core/appdata/security` on PVE. See the fleet update report for port checks, backup details, and remaining client setup.

### Pi-hole LXC 101 Pass: 2026-09-28

Updated 106 Debian packages through the PVE host. No packages remain upgradable. Pi-hole FTL (`v6.5`) is active, and a DNS query to `192.168.0.120` returned A records. Pre/post snapshots are stored under `/mnt/core/backups/snapshots/2026-09-28/{pre,post}/pihole/`; the pre-update LXC archive also passed `zstd -t`. Direct SSH was not configured or tested; maintenance used PVE's `pct` access. See [Fleet Update Report 2026-09-28](Update%20Reports/2026-09-28.md).

### WireGuard LXC 102 Pass: 2026-09-28

Updated 110 Debian packages and installed one package through PVE. No packages remain upgradable. The WireGuard unit is active and UDP 51820 is listening. Two peers had recent handshakes; five had no recorded handshake at the check. Pre/post snapshots and a validated pre-update LXC archive are on `/mnt/core/backups/snapshots/`. Direct SSH remains unconfigured; maintenance used PVE's `pct` access. See [Fleet Update Report 2026-09-28](Update%20Reports/2026-09-28.md).

### VM100 Core Services Pass: 2026-09-28

Updated six Docker platform packages and refreshed images for Baserow, Nginx Proxy Manager, iSponsorBlockTV, and Syncthing. Created and validated a fresh Baserow PostgreSQL dump before recreating projects. All five containers were running afterward; Baserow and PostgreSQL were healthy; the Baserow HTTPS endpoint returned HTTP 302. Zero Debian updates remain. Pre/post snapshots and the VM backup are on `/mnt/core/backups/`. Maintenance used the PVE QEMU guest agent; direct SSH host-key verification is still pending. See [Fleet Update Report 2026-09-28](Update%20Reports/2026-09-28.md).

### VM200 Guest Access Check: 2026-09-28

User-provided console checks identify VM200 as Debian GNU/Linux 13 (trixie), hostname `infra-proxy`, IPv4 `192.168.0.131`, with console user `raven`. SSH service is active; SSH key access and host-key trust have not yet been verified. `qemu-guest-agent` is inactive. User reports VM200 has a backup of VM100 from a previous setup and thinks their partner may still use Affine; verify workload and use before making changes.

### VM200 Read-Only Check: 2026-09-29

PVE reports VM200 running at `192.168.0.131`; its QEMU configuration has no `agent` setting, and `qm guest cmd 200 ping` returns “No QEMU guest agent configured.” TCP 22 accepts connections from PVE. The 2026-09-28 snapshot-mode VM backup remains present and its file mode is `600`. No guest login, update, restart, or workload change was performed; host-key verification, key access, and partner Affine use remain unresolved.

### VM200 Retirement: 2026-09-30

Owner reports VM200 was destroyed after the partner moved to Super Productivity. The owner reports a somewhat old but comprehensive backup exists. Its contents, date, and restoreability have not been independently verified; the 2026-09-28 snapshot-mode backup noted above is historical evidence and should not be assumed to be the same backup without checking.

### RustDesk Server LXC 103: 2026-09-28

Community Scripts created an unprivileged Debian 13 container named `rustdeskserver` at DHCP address `192.168.0.189`. `hbbs`, `hbbr`, and `rustdesk-api` are active, and the admin UI returned HTTP 302 from both PVE and the Windows LAN client. Server and API state are bind-mounted from `/mnt/core/appdata/security`; the RustDesk private identity key is mode `600` inside the guest. A CT backup and a separate appdata archive both passed `zstd -t`. No WAN port forwards were added. User-provided screenshot shows a DNS A record to this IP; verify router reservation for MAC `BC:24:11:7F:0E:7E`, then configure/test a pilot client before broad client changes.

### MediaCenter Pass: 2026-09-28

Direct SSH works with the dedicated key after its public half was installed. RustDesk 1.4.9 is active, and its client config records rendezvous server `rs-ny.rustdesk.com:21116`; a `relay_server` entry was not found in the searched config paths. Seven Debian packages were upgraded through the sudo preflight. All six expected containers and local web-port checks passed afterward. The user then completed the full upgrade and rebooted; `uname -r` returned `6.12.107+deb13-amd64`. Capture a post-reboot snapshot and service checks. See [Fleet Update Report 2026-09-28](Update%20Reports/2026-09-28.md).

### Owner Follow-up: 2026-09-30

The owner reports migrating RustDesk clients to LXC 103 and having multiple successful sessions, including a phone-to-desktop session after connecting the phone to the network. The specific LAN or WireGuard path for that phone session was not stated. The owner also reports the Jellyfin scan completed and prefers leaving Sunshine configured as-is. See [Fleet Update Report 2026-09-30](Update%20Reports/2026-09-30.md).

### Endpoint Checks: 2026-09-29

- LockBox was maintained locally. Its post inventory was written successfully with collector version `2026-09-29.3`; it records Garuda kernel `7.2.7-zen1-1-zen` and zero pending repository updates. The prior runbook bug was `checkupdates` status `2` (“no updates available”) causing `set -e` to stop before writing. SSH is still not available.
- Nobara pre/post records were captured while Nobara was booted. The post record reports no package updates and no failed units; SSH was not tested.
- AtlasOS has pre inventories only. The owner prefers leaving Sunshine as configured; capture the post-update inventory when ready.
- Do not turn these owner-present endpoint checks into unattended updates until device identity, recovery, admin access, and post-update workflows are defined.

Non-interactive test run: 2026-09-01 16:30 America/Chicago.

Core hosts are reachable enough to hit SSH. `pve` is ready: the Codex key works non-interactively for `root`. `media` is ready: the Codex key works non-interactively for `mediacenter`, Windows already trusts `192.168.0.143`, and the `media` alias uses `HostKeyAlias 192.168.0.143`. `pihole`, `wireguard`, and `services` are still blocked at host-key trust.

Proxmox web UI is reachable from the current Windows host at `https://192.168.0.75:8006`, so the preferred bootstrap path is Proxmox web shell first.

A follow-up host-key scan also reached the same core hosts, but this Windows OpenSSH 9.5p2 `ssh-keyscan` failed against the Debian OpenSSH 10.0p2 servers with unsupported key exchange `sntrup761x25519-sha512@openssh.com`. Treat this as a local scan-tool limitation, not a server outage. Use interactive `ssh <alias>` plus console fingerprint verification instead of blindly writing `known_hosts`.

Endpoint results are mixed: some aliases do not resolve yet, and some devices answer but are not running normal SSH on port 22.

## Next Pass

1. Use `pve` as the bootstrap point to verify fingerprints and install the Codex key for LXC 101 `pihole`, LXC 102 `wireguard`, and VM100 `services` where appropriate.
2. Keep MediaCenter in read-only/pre-update mode until its backup and sudo plan are explicit.
3. Confirm usernames, especially `services` and any endpoint that is not `root`, `mediacenter`, or `deck`.
4. Re-run `scripts\Test-HomelabSsh.ps1` until each reachable device is either `ready` or intentionally marked pending.
5. Configure full Codex remote-host support only after ordinary `ssh <alias>` works.
