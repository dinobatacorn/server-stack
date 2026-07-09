# Media Node Inventory

Status: Current
Last reviewed: 2026-07-09
Source docs:
- media_2026-05-17_12-44-07.json
- MediaCenter-Archetecture 17.05.26.txt
- Media Stack Stabilization 23.05.26.md
- medianode-output_09072026.txt
Next action: Confirm and document the backing device for `/media`; the July 9 snapshot does not show it as a separate mount.

## Host

- Hostname: `media`
- OS: Debian GNU/Linux 13 Trixie
- Kernel at export: `6.12.88+deb13-amd64`
- Current inventory timestamp: `2026-07-09`
- Earlier inventory timestamp: `2026-05-17T12:44:07-05:00`

## Hardware

- CPU: Intel Core i7-9700K, 8 cores, 8 threads, x86_64
- Memory: 15 GB
- GPU: Intel UHD Graphics 630
- GPU: NVIDIA GeForce GTX 1060 3GB

Storage from the older May inventory:

| Device | Model | Size | Type |
| --- | --- | --- | --- |
| `sda` | Samsung SSD 840 Series | 232 GB | SSD |
| `sdb` | WDC WD20EFAX-68FB5N0 | 1863 GB | HDD |
| `sdc` | Expansion HDD | 4657 GB | HDD |

Storage from the July 9 snapshot:

| Device or mount | Size | Mountpoint | Note |
| --- | ---: | --- | --- |
| `/dev/sdb2` | 216 GB | `/` | Root filesystem, 89% used |
| `/dev/sdb1` | 975 MB | `/boot/efi` | EFI partition |
| `192.168.0.75:/mnt/core` | 916 GB | `/mnt/core` | NFS mount from Proxmox host |
| `sda` | 1.8 TB | none shown | Present but not mounted in captured `lsblk` output |

Current storage concern:

- `/media` exists and contains the intended taxonomy, but it is not shown as a separate filesystem in the July 9 `df` output.
- The root filesystem is already 89% used.
- Confirm whether `sda` should back `/media` before large downloads, imports, or external-drive normalization.

## Health Visibility

- Sensor data exists in the export.
- SMART records are empty in the export.
- Treat SMART visibility as unresolved until each disk is checked and documented.

## Active Path Snapshot

Observed or planned media-node paths:

- `/mnt/core/services/media`
- `/media/downloads/incomplete`
- `/media/downloads/complete`
- `/media/downloads/manual`
- `/media/downloads/unsorted`
- `/media/library/movies`
- `/media/library/tv`
- `/media/library/anime`
- `/media/library/music`
- `/media/library/youtube`
- `/media/library/home-videos`
- `/media/cache/metadata`
- `/media/cache/tmp`
- `/media/cache/transcode`
- `/media/library/books`
- `/media/library/audiobooks`
- `/media/library/roms`
- `/media/library/podcasts`

Legacy overlap:

- `/media/mediacenter/Storage`

Do not move or delete legacy overlap until backups, imports, and restore tests are proven.

## Service Persistence Snapshot

Captured under `/mnt/core/services/media`:

- `acquisition/bazarr`
- `acquisition/lidarr`
- `acquisition/overseerr`
- `acquisition/prowlarr`
- `acquisition/qbittorrent`
- `acquisition/radarr`
- `acquisition/readarr`
- `acquisition/sonarr`
- `compose/core/docker-compose.yml`
- `monitoring/backups`
- `monitoring/compose`
- `monitoring/logs`
- `monitoring/scripts`
- `processing/recyclarr`
- `processing/tdarr`
- `reading/audiobookshelf`
- `reading/calibre`
- `reading/kavita`
- `serving/jellyfin`
- `serving/kodi`

Directory presence alone does not prove a service is running; the deployed-state list below is authoritative. `overseerr` is present as a legacy or prior directory name, while the current running request service is `seerr`.

## Deployed Media Services

Configured and operational:

- qBittorrent container, up 3 days at July 9 capture, ports `8080` and `6881`.
- Prowlarr container, up 3 days, port `9696`.
- Sonarr container, up 3 days, port `8989`.
- Radarr container, up 3 days, port `7878`.
- Jellyfin container, up 3 days, port `8096`.
- Seerr container, up 3 days, port `5055`.
- Kodi native application, not a Docker container.

Verified behavior:

- Sonarr downloads, imports, and Jellyfin notifications work; *Firefly* and *Galavant* were successful tests.
- Radarr is connected to Prowlarr, qBittorrent, Jellyfin, and Seerr.
- Jellyfin library import and playback work.
- Kodi uses Arctic Fuse 3 as the living-room frontend; Jellyfin is the backend.
- Seerr drives the proven request-to-playback pipeline.

## Docker State

Networks:

- `bridge`
- `host`
- `media`
- `none`

Docker volumes:

- No named Docker volumes were present in the July 9 snapshot.

Running media containers use bind mounts under `/mnt/core/services/media` and `/media` rather than named Docker volumes.

## Next Milestones

Immediate:

- Bazarr
- Lidarr
- Readarr
- Kavita
- Audiobookshelf

Later:

- SoulSync
- Calibre or Calibre-Web
- Emulator stack
