# Machine Inventory Index

Status: Current
Last reviewed: 2026-09-29
Source docs:
- ATLASOS-RAVENST_2026-05-02_19-44-33.json
- LAPTOP-F96A9FT3_2026-05-02_14-27-04.json
- LockBox_2026-05-02_14-52-09.json
- RavensSteamDeck_2026-05-02_15-27-41.json
- RavensTower_2026-05-02_14-08-39.json
- media_2026-05-17_12-44-07.json
- steamdeck_2026-05-02_15-21-29.json
- pve-output_09072026.txt
- vm100-output_09072026.txt
- User-provided Proxmox and MediaCenter BIOS/baseboard dmidecode excerpts, 2026-07-26
- User-provided and collector-generated 2026-09-28/29 maintenance summaries; raw endpoint inventories remain ignored under `scripts/output/`
- Fleet Update Reports, 2026-09-28 through 2026-09-30
Next action: Replace stale May raw exports only after fresh reviewed captures are deliberately archived; continue to use dated reports for maintenance state.

## Inventory Exports

| Hostname | OS | Timestamp | Known purpose |
| --- | --- | --- | --- |
| `ATLASOS-RAVENST` | Microsoft Windows 11 Home | `2026-05-02T19:44:35.5477225-05:00` | Main workstation Windows side |
| `LAPTOP-F96A9FT3` | Microsoft Windows 11 Home | `2026-05-02T14:27:19.5884949-05:00` | Undocumented |
| `LockBox` | Garuda Linux | `2026-05-02T14:52:09-05:00` | Undocumented |
| `RavensSteamDeck` | SteamOS | `2026-05-02T15:27:42-05:00` | Steam Deck / gaming endpoint |
| `RavensTower` | Nobara Linux 43 KDE Plasma Desktop Edition | `2026-05-02T14:08:39-05:00` | Main workstation Linux side |
| `media` | Debian GNU/Linux 13 Trixie | `2026-05-17T12:44:07-05:00` | Dedicated media node |
| `pve` | Debian GNU/Linux 13 / Proxmox VE 9.2.4 | `2026-07-09T11:00:12-05:00` | Proxmox infrastructure host |
| `services` | Debian GNU/Linux 13 Trixie | `2026-07-09T16:16:39Z` | VM100 core services Docker host |
| `steamdeck` | SteamOS | `2026-05-02T15:21:29-05:00` | Steam Deck / gaming endpoint |

These raw exports are historical. The following 2026-09-28/29 maintenance observations supersede them for current OS/update state; detailed evidence and limits are in the [fleet reports](../06_Operations/Update%20Reports/).

| Host / device | Latest captured state | Current maintenance evidence | Open limits |
| --- | --- | --- | --- |
| `pve` | Proxmox VE 9.2.20; kernel `7.0.14-19-pve` | Updated/reboot-validated; 2026-09-29 host/config snapshot and fresh VM100 backup validated. | Guest-backup retention and scheduling not set. |
| Pi-hole LXC 101 | Debian 13; FTL v6.5 | 106 packages updated; DNS query and service checks passed. | Direct SSH remains unconfigured. |
| WireGuard LXC 102 | Debian 13, PVE host kernel | 110 packages updated, one package installed; `wg0` active and UDP 51820 listening. | Several peers had no recent handshake; investigate with owners as needed. |
| RustDesk Server LXC 103 | Debian 13, `192.168.0.189` | `hbbs`, `hbbr`, API/UI active; LAN UI login confirmed; state bind-mounted under `/mnt/core/appdata/security`. Owner reports client migration and successful sessions, including phone-to-desktop. | Router DHCP reservation and VPN route remain unverified; no WAN forwarding. |
| VM100 `services` | Debian 13, `192.168.0.125` | OS/Docker packages and images refreshed; NPM `2.16.0`; all five containers running, Baserow/PostgreSQL healthy. | Direct SSH access and automated PVE backup schedule remain open. |
| VM200 `infra-proxy` | Debian 13, `192.168.0.131` | Guest agent package installed; PVE reports no configured QEMU guest agent. | Host-key/key access and possible partner Affine use unresolved; no guest update. |
| `media` | Debian 13; kernel `6.12.107+deb13-amd64` | OS rebooted; six containers refreshed/restarted; all local web ports passed; post appdata archive validated. Owner reports Jellyfin scan completed. | Root 95% used; `/media` backing check pending. |
| `ATLASOS-RAVENST` | Windows 11 Home, build `10.0.26200` | 2026-09-29 pre inventories; ViGEmBus 1.22.0 installer run twice per owner report. Owner prefers leaving Sunshine as configured. | Post-update inventory pending; no further Sunshine driver change planned. |
| `RavensTower` | Nobara Linux 44 KDE; kernel `7.2.6-201.nobara.fc44.x86_64` | 2026-09-29 local pre/post records; post check reports no package updates and no failed units. | Exact transaction, Flatpak update, and reboot outcomes not recorded; SSH not tested. |
| `LockBox` | Partner's Garuda Linux; kernel `7.2.7-zen1-1-zen` | 2026-09-29 pre/post inventory; post check reports zero pending repository updates; Snapper pre snapshot 260 verified. | Package transaction log and post-Snapper listing absent; SSH unavailable; inspect `mirrorlist.pacnew`. |

The AtlasOS and Nobara records refer to separate boot environments on the same physical workstation; never claim one capture describes both. LockBox is a separate partner-owned gaming device and remains owner-present/manual for updates.

## Firmware And Baseboard Addenda

| Hostname | BIOS vendor | BIOS version | BIOS release date | Baseboard |
| --- | --- | --- | --- | --- |
| `pve` | Intel Corp. | `SE5C600.86B.02.04.0003.102320141138` | 2014-10-23 | Intel Corporation S2600CP, version `G50768-511` |
| `media` | American Megatrends Inc. | `1401` | 2019-11-26 | ASUSTeK COMPUTER INC. ROG STRIX Z390-F GAMING, version `Rev 1.xx` |

## Raw Export Policy

Raw JSON exports are preserved in `_archive/raw-2026-05/`. Keep canonical operational summaries in Markdown and use raw JSON only as evidence or for re-extraction.
