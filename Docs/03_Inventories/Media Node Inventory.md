# Media Node Inventory

Status: Current
Last reviewed: 2026-07-25
Source docs:
- media_2026-05-17_12-44-07.json
- MediaCenter-Archetecture 17.05.26.txt
- Media Stack Stabilization 23.05.26.md
- medianode-output_09072026.txt
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
Next action: Verify X11 display policy persistence and confirm the backing device for `/media`.

## Host

- Hostname: `media`
- Primary user: `mediacenter`
- OS: Debian GNU/Linux 13 Trixie
- Kernel at export: `6.12.88+deb13-amd64`
- Current inventory timestamp: `2026-07-09`
- Earlier inventory timestamp: `2026-05-17T12:44:07-05:00`
- Role: dedicated living-room media node, Jellyfin playback host, and media services host.

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

Current critical NFS mount:

```text
192.168.0.75:/mnt/core -> /mnt/core
Filesystem: NFSv4
```

Before Docker maintenance, verify with:

```bash
findmnt -T /mnt/core
```

Do not trust the existence of `/mnt/core` as proof that NFS is mounted.

## Health Visibility

- Sensor data exists in the export.
- SMART records are empty in the export.
- `smartmontools` is installed and `sudo smartctl --version` reports smartctl 7.4.
- `smartctl` lives at `/usr/sbin/smartctl`; the `mediacenter` SSH PATH does not include `/usr/sbin`, so `command -v smartctl` can appear empty.
- Use `sudo smartctl ...` and document per-disk results.

## Remote And Local Access

RustDesk:

- Installed as a native Debian package, not Flatpak or Snap.
- Upgraded on 2026-07-25 from 1.4.8 to 1.4.9 using the official `.deb`.
- Binary: `/usr/bin/rustdesk`.
- systemd unit: `/usr/lib/systemd/system/rustdesk.service`.
- Service state after maintenance: enabled and active.
- Permanent-password unattended access configured through the GUI.
- Laptop can remotely administer MediaCenter without requiring local approval at the TV.
- IP whitelisting was considered and deferred.

Local fallback:

- `onboard` is installed.
- Bluetooth mouse plus Onboard provides an emergency on-screen keyboard for sudo/local authentication.

Tool audit, 2026-07-25:

- Available: `curl`, `git`, `htop`, `btop`, `nano`, `vim`, `jq`, `wget`, `unzip`, `rustdesk`.
- Flatpak is not installed and is not currently required.

## Power And Display Policy

System sleep policy:

- `sleep.target` masked.
- `suspend.target` masked.
- `hibernate.target` masked.
- `hybrid-sleep.target` masked.
- Manual shutdown/reboot remains available.

This is intentional appliance behavior so SSH, Docker, Jellyfin, and RustDesk remain reachable.

Display policy:

- X11 screensaver disabled in the live session with `xset s off`.
- DPMS disabled in the live session with `xset -dpms`.
- Jellyfin/Firefox playback no longer blanked the display during the follow-up test.
- Persistence across logout/reboot still needs verification or configuration.

Layer distinction:

- systemd masks prevent the computer from sleeping.
- X11 screensaver/DPMS configuration prevents the display from blanking or powering down.

Reboot note:

- The July 25 approximately 15:20 reboot was manually initiated during troubleshooting after MediaCenter became unreachable.
- Do not treat that reboot as an unexplained spontaneous reboot.
- A July 10 power surge may explain the July 10 boot boundary, but that has not been verified.

Boot-order verification after repair:

```text
/mnt/core mounted:             16:25:58
docker.service began starting: 16:25:58
docker.service active:         16:26:01
```

`docker.socket` may become active earlier and should not be treated as evidence that Docker workloads started before `/mnt/core`.

## Mount Repair History

Failure mode discovered on 2026-07-25: Docker had operated while the real NFS-backed `/mnt/core` filesystem was absent, causing a local ghost `/mnt/core/services` tree to be written underneath the mountpoint.

Recovery:

- Docker stopped before destructive cleanup.
- Ghost local data identified.
- Backup created and tested:

```text
/var/backups/mediacenter/core-ghost-2026-07-25.tar.gz
```

- Ghost local `/mnt/core/services` tree removed only after backup validation.
- Real NFS-backed `/mnt/core` restored.
- Real media configuration tree visible at `/mnt/core/services/media`, approximately 238 MB.
- Docker restarted.

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

Canonical media Compose deployment:

```text
/mnt/core/services/media
```

Confirmed update procedure:

```bash
cd /mnt/core/services/media
docker compose pull
docker compose up -d
docker compose ps
```

## Deployed Media Services

Configured and operational after July 25 mount repair and update:

- qBittorrent container, ports `8080` and `6881`, restart count 0.
- Prowlarr container, port `9696`, restart count 0.
- Sonarr container, port `8989`, restart count 0.
- Radarr container, port `7878`, restart count 0.
- Jellyfin container, port `8096`, restart count 0.
- Seerr container, port `5055`, restart count 0.
- Kodi native application, not a Docker container.

Verified behavior:

- Sonarr downloads, imports, and Jellyfin notifications work; *Firefly* and *Galavant* were successful tests.
- Radarr is connected to Prowlarr, qBittorrent, Jellyfin, and Seerr.
- Jellyfin library import and playback work.
- Kodi uses Arctic Fuse 3 as the living-room frontend; Jellyfin is the backend.
- Seerr reported `Server ready on port 5055`.
- Seerr HTTP returned the expected `307 -> /login`.

Jellyfin verified mounts:

```text
/mnt/core/services/media/serving/jellyfin -> /config
/media/library                            -> /media
/media/cache/transcode                    -> /transcode
```

Confirmed existing movie directory:

```text
/media/library/movies/The Prince of Egypt (1998)
```

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
