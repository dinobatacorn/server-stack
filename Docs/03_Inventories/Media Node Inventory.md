# Media Node Inventory

Status: Current
Last reviewed: 2026-05-23
Source docs:
- media_2026-05-17_12-44-07.json
- MediaCenter-Archetecture 17.05.26.txt
- Media Stack Stabilization 23.05.26.md
Next action: Add live mount/device mapping for `/mnt/core` and `/media`.

## Host

- Hostname: `media`
- OS: Debian GNU/Linux 13 Trixie
- Kernel at export: `6.12.88+deb13-amd64`
- Inventory timestamp: `2026-05-17T12:44:07-05:00`

## Hardware

- CPU: Intel Core i7-9700K, 8 cores, 8 threads, x86_64
- Memory: 15 GB
- GPU: Intel UHD Graphics 630
- GPU: NVIDIA GeForce GTX 1060 3GB

Storage from inventory:

| Device | Model | Size | Type |
| --- | --- | --- | --- |
| `sda` | Samsung SSD 840 Series | 232 GB | SSD |
| `sdb` | WDC WD20EFAX-68FB5N0 | 1863 GB | HDD |
| `sdc` | Expansion HDD | 4657 GB | HDD |

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
- `/media/books`
- `/media/audiobooks`
- `/media/roms`

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

This snapshot shows some future-service directories already exist. Directory presence does not mean the service is approved for expansion; use the stabilization gate before enabling or relying on them.

## Active Media Services

Stabilization scope:

- qBittorrent
- Prowlarr
- Sonarr
- Radarr
- Jellyfin
- Kodi

Planned after stabilization:

- Bazarr
- Overseerr
- Lidarr
- Readarr
- Kavita
- Audiobookshelf
- Calibre or Calibre-Web
- Emulator stack
