# Media Node Inventory

Status: Current
Last reviewed: 2026-11-25
Source docs:
- media_2026-05-17_12-44-07.json
- MediaCenter-Archetecture 17.05.26.txt
- Media Stack Stabilization 23.05.26.md
- medianode-output_09072026.txt
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
- Fleet Update Reports, 2026-09-28 through 2026-09-30
- User-provided MediaCenter BIOS/baseboard dmidecode excerpt, 2026-07-26
- MediaCenter hidden media cleanup and Docker mount protection handoff, 2026-11-25
- Fleet post-collection JSON, `scripts/output/2026-11-25/post/media_post_2026-11-25_12-24-45.json`; summarized in [2026-11-25 Fleet Update Report](../06_Operations/Update%20Reports/2026-11-25.md)
Next action: Functionally verify all six media services and verify Docker mount-guard behavior on reboot and failed mounts; collector confirms the mounts and containers were present at its post capture.

## Host

- Hostname: `media`
- Primary user: `mediacenter`
- OS: Debian GNU/Linux 13 Trixie
- Kernel observed in the 2026-11-25 post capture: `6.12.118+deb13-amd64`.
- Latest host inventory timestamp: `2026-11-25T12:24:45-06:00` (post capture; see fleet report).
- Earlier inventory timestamp: `2026-05-17T12:44:07-05:00`
- Role: dedicated living-room media node, Jellyfin playback host, and media services host.

## Hardware

- CPU: Intel Core i7-9700K, 8 cores, 8 threads, x86_64
- Memory: 15 GB
- GPU: Intel UHD Graphics 630
- GPU: NVIDIA GeForce GTX 1060 3GB

Firmware and baseboard:

- BIOS vendor: American Megatrends Inc.
- BIOS version: `1401`
- BIOS release date: 2019-11-26
- Baseboard: ASUSTeK COMPUTER INC. ROG STRIX Z390-F GAMING, version `Rev 1.xx`

Storage from the older May inventory:

| Device | Model | Size | Type |
| --- | --- | --- | --- |
| `sda` | Samsung SSD 840 Series | 232 GB | SSD |
| `sdb` | WDC WD20EFAX-68FB5N0 | 1863 GB | HDD |
| `sdc` | Expansion HDD | 4657 GB | HDD |

Historical storage from the July 9 snapshot (later mount verification and cleanup supersede its open questions):

| Device or mount | Size | Mountpoint | Note |
| --- | ---: | --- | --- |
| `/dev/sdb2` | 216 GB | `/` | Root filesystem, 89% used |
| `/dev/sdb1` | 975 MB | `/boot/efi` | EFI partition |
| `192.168.0.75:/mnt/core` | 916 GB | `/mnt/core` | NFS mount from Proxmox host |
| `sda` | 1.8 TB | none shown | Present but not mounted in captured `lsblk` output |

Historical July 9 storage notes (superseded by the 2026-11-25 verification below):

- `/media` exists and contains the intended taxonomy, but it is not shown as a separate filesystem in the July 9 `df` output.
- The root filesystem is already 89% used.
- Confirm whether `sda` should back `/media` before large downloads, imports, or external-drive normalization.

Historical post-image-refresh check, 2026-09-29: `/dev/sdb2` was 216 GB total, 195 GB used, 11 GB available (95%). This was the pre-cleanup state, not the latest documented measurement. After the 2026-11-25 hidden-file cleanup, root use was 36 GB (18%). The Debian/package and Docker image update/reboot outcomes after this measurement are pending.

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

## 2026-11-25 Storage Incident and Startup Guard

Current figures reported after cleanup: `/dev/sdb2` root filesystem, 216 GB total, 36 GB used, 169 GB available (18%); `/dev/sda1` mounted at `/media`, ext4, 1.8 TB; `/mnt/core` is NFSv4 from `192.168.0.75:/mnt/core`.

Approximately 161 GB of media files were found under the active `/media` mountpoint on the root filesystem. The hidden completed downloads and library files were compared with the mounted media filesystem using rsync dry-run size/mtime comparisons; no full checksums were taken. The owner accepted that limitation, approved deletion, and the hidden files were removed after verifying the underlying filesystem. Root use fell from 197 GB (97%) to 36 GB (18%). The active media filesystem was not deleted. The cause of the hidden copies remains undetermined.

Docker’s systemd override now requires and orders both `/mnt/core` and `/media` mounts before startup and checks each with `/usr/bin/mountpoint -q`. The override was reloaded and recognized; both checks passed during the session. It does not check source/device or writeability, stop already-running containers after mount loss, or prevent manual writes beneath mountpoints. Failed-mount behavior has not been tested.

The 2026-11-25 post capture reported zero pending apt updates, root at 20% used, `/media` as a mounted filesystem, `/mnt/core` as NFSv4, and all six expected containers running. Host uptime was about 22 minutes at capture; this supports that the host had recently booted, but does not identify the cause or validate service functionality. The Docker startup mount guard's failed-mount behavior remains untested. See [incident record](../06_Operations/Incidents/2026-11-25-mediacenter-hidden-media-cleanup.md) and [fleet report](../06_Operations/Update%20Reports/2026-11-25.md).

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
- Verified 2026-09-28: RustDesk `1.4.9` is active; its client config sets `rendezvous_server` to `rs-ny.rustdesk.com:21116`. No `relay_server` entry appeared in the searched RustDesk config paths.
- Self-hosted RustDesk Server now runs separately in PVE LXC 103. The owner reports migrating clients and successful sessions, including a recent phone-to-desktop test after the phone joined the network. The specific LAN or WireGuard path was not stated.
- The official RustDesk releases page marked `1.4.9` Latest and `1.5.0` Pre-release on 2026-09-28; the stable client was left on `1.4.9`.
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

Historical 2026-09-28 image refresh:

- All six active media containers were pulled and recreated after verifying `/mnt/core` as the expected NFSv4 mount and `/media` as ext4.
- Jellyfin is now on the LinuxServer image reporting Jellyfin `12.1.0`. Its pre-update plugin/config tree is archived at `/mnt/core/backups/media/2026-09-28/pre/media-appdata-before-image-refresh.tar.zst` (220 MB; archive integrity passed).
- Jellyfin Enhanced was replaced with the maintainer's verified 12.0 ABI build `12.9.0.0`; startup logs no longer report a build/host mismatch. The owner reports the full library scan completed successfully after this major upgrade.
- At the time of the September image refresh, `/` was 96% used with 11 GB available. A post-update snapshot is saved at `/mnt/core/backups/media/2026-09-28/post/media-docker-post-update.txt`. The image-pull gate blocked further refreshes while root use exceeded 95%; the 2026-11-25 cleanup later reduced documented root use to 18%. Keep prior images through their rollback window and verify post-update reboot state before another maintenance pass.

### 2026-09-29 Recovery Snapshot (Historical)

- Historical 2026-09-29 host inventory: valid JSON, mode `600`; it recorded a disconnected RustDesk clipboard FUSE path warning, which was left untouched. Fleet JSON inventories were later moved out of Proxmox backup storage into `scripts/output/`; final mapping of each migrated file has not been reconciled.
- Current app-data archive: `/mnt/core/backups/media/2026-09-29/post/media-appdata-after-image-refresh.tar.zst`, 232 MB, mode `600`; created with all six media containers stopped, `zstd -t` passed, and the archive contains the active Compose file.
- After the archive, all six containers were running and local ports returned Jellyfin `302`, Sonarr `200`, Radarr `200`, qBittorrent `200`, Prowlarr `200`, and Seerr `307`.
- Root filesystem was 95% used with 11 GB available at the time. The 2026-11-25 cleanup later reduced documented root use to 18%; updates and reboot checks after that cleanup are pending.
- The pre-update archive at `/mnt/core/backups/media/2026-09-28/pre/media-appdata-before-image-refresh.tar.zst` remains the rollback point for the previous image/plugin state and passed `zstd -t` again on 2026-09-29.
- All six expected local service ports responded after the refresh; each container restart count was 0 at verification.

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
