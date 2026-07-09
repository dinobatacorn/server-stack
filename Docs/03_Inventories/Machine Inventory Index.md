# Machine Inventory Index

Status: Current
Last reviewed: 2026-07-09
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
Next action: Keep Proxmox, VM100, and media inventories current as service deployment changes.

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

## Raw Export Policy

Raw JSON exports are preserved in `_archive/raw-2026-05/`. Keep canonical operational summaries in Markdown and use raw JSON only as evidence or for re-extraction.
