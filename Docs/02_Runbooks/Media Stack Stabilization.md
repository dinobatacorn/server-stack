# Media Stack Stabilization

Status: Completed baseline; retained as a validation runbook
Last reviewed: 2026-07-25
Source docs:
- Media Stack Stabilization 23.05.26.md
- Server Plan 21.05.26.md
- to-do list 17.05.26.md
- medianode-output_09072026.txt
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
Next action: Confirm `/media` backing storage, verify display-blanking persistence, then create a fresh known-good checkpoint before risky changes.

## Purpose

Stabilize the existing media core before adding more services. This phase is stabilization, not expansion.

Core doctrine:

- Persistent data is sacred.
- Containers are disposable.
- Prefer clean redeploys over in-place patching.
- Prefer simple, inspectable layouts over clever automation.
- Recovery must be proven, not assumed.
- Documentation is infrastructure.

## Known-Good Checkpoint

Before risky changes, create a dated checkpoint under `/mnt/core/exports/media-stabilization/`.

Capture:

- Current `hostname`.
- `findmnt -T /mnt/core` and `findmnt -T /media`.
- Compose files, compose project names, and `.env` files.
- Config directories for qBittorrent, Prowlarr, Sonarr, Radarr, Jellyfin, and Kodi.
- Container inventory, images, restart policies, bind mounts, and networks.
- Host mount output and filesystem/device layout.
- UID/GID mappings for the media user, media group, service users, and container users.
- qBittorrent category/path configuration.
- Sonarr/Radarr root folders, download clients, quality profiles, import settings, and recycle-bin settings.
- Prowlarr working indexers and app sync settings.
- Jellyfin library paths, users, hardware acceleration settings, playback logs, and transcoding logs.
- Sample successful import logs, if any exist.
- Backup job configuration and latest successful backup timestamp.
- Restore verification timestamp, once available.

Stop if a checkpoint cannot be created.

## Phase 1: Base Host And Mounts

Goal: the media node survives reboot and exposes expected storage before applications do useful work.

MediaCenter appliance policy as of 2026-07-25:

- `sleep.target`, `suspend.target`, `hibernate.target`, and `hybrid-sleep.target` are masked.
- Automatic system sleep, suspend, hibernate, and hybrid sleep are intentionally blocked.
- Manual shutdown and reboot remain available.
- The July 25 approximately 15:20 reboot was manually initiated during troubleshooting and should not be treated as an unexplained spontaneous reboot.

Validate:

- `/mnt/core` is mounted as NFSv4 from `192.168.0.75:/mnt/core` before Docker-dependent service state is needed.
- `/media` is mounted or otherwise backed by the intended media storage before acquisition/playback containers start.
- Docker starts after required mounts are available.
- Containers with restart policies recover cleanly after reboot.
- Disk capacity is visible for root, `/mnt/core`, and `/media`.
- SMART visibility exists for internal disks, with USB limitations documented.

Pass condition: after one reboot, `/mnt/core`, `/media`, Docker, and existing media containers recover without manual intervention.

July 25 boot-order validation:

```text
/mnt/core mounted:             16:25:58
docker.service began starting: 16:25:58
docker.service active:         16:26:01
```

The NFS filesystem was available before Docker workloads used it. Do not confuse earlier `docker.socket` activation with `docker.service` startup.

Mountpoint safety: do not rely on the existence of `/mnt/core`; verify with `findmnt -T /mnt/core`. MediaCenter previously created a ghost local `/mnt/core/services` tree while NFS was absent. That ghost tree was backed up to `/var/backups/mediacenter/core-ghost-2026-07-25.tar.gz`, validated, and removed before the real NFS tree was restored.

July 9 note: `/mnt/core` is mounted from `192.168.0.75:/mnt/core`, but the captured `df` output does not show `/media` as a separate filesystem. Root is 89% used and `sda` is visible without a mountpoint. Resolve this before large imports or downloads.

## Phase 2: Permissions And UID/GID

Goal: services can read and write expected paths through a shared media ownership strategy.

Validate:

- Shared media UID/GID strategy exists for qBittorrent, Sonarr, Radarr, Jellyfin, and future media services unless isolation is intentional.
- Container `PUID`, `PGID`, `user`, and bind mounts match the intended ownership model.
- qBittorrent-created files are readable by Sonarr/Radarr.
- Sonarr/Radarr-imported files are readable by Jellyfin and Kodi.
- Jellyfin writes only to app state and cache/transcode paths unless library writes are intentionally allowed.

Do not run broad recursive `chown` or permission changes until a checkpoint and sample path audit exist.

Pass condition: a controlled download/import/playback test completes without manual permission fixes.

## Phase 3: Acquisition Core

qBittorrent:

- Incomplete downloads land under `/media/downloads/incomplete`.
- Completed downloads land under `/media/downloads/complete`.
- Categories use lower-case names such as `movies`, `tv`, `anime`, and `manual`.
- Category save paths stay under `/media/downloads/complete`.
- Cleanup rules do not delete content needed for seeding or hardlink verification.

Prowlarr:

- Working indexers are known and documented.
- Broken or dead indexers are removed or disabled.
- App sync targets only stabilized apps.

Sonarr/Radarr:

- Radarr root folder: `/media/library/movies`.
- Sonarr root folders: `/media/library/tv` and optionally `/media/library/anime`.
- Download client mappings match qBittorrent paths visible inside containers.
- Quality profiles and import behavior are intentionally selected and documented.
- Recycle bins point under `/media/cache/recycle/sonarr` and `/media/cache/recycle/radarr`, unless disabled and documented.
- Hardlinks work where source and destination are same-device from the container perspective.

Pass condition: one controlled movie import and one controlled TV/anime import land in correct library paths without duplicates, unexpected moves, or permission fixes.

## Phase 4: Playback Core

Jellyfin:

- Libraries point to `/media/library/movies`, `/media/library/tv`, `/media/library/anime`, `/media/library/music`, and `/media/library/home-videos` as applicable.
- Persistent state stays under `/mnt/core/services/media/serving/jellyfin -> /config`.
- Media library is mounted as `/media/library -> /media`.
- Replaceable transcodes/cache use `/media/cache/transcode -> /transcode`.
- Direct play works for a known-good file.
- Intel QuickSync transcoding works before GTX 1060 optimization.
- Active Jellyfin/Firefox playback does not trigger X11 screensaver blanking or DPMS display power-off.

Kodi:

- Kodi can play from the same stabilized library paths or through Jellyfin integration.
- Living-room UX work waits until playback paths are stable.
- Emulator launching stays deferred.

Pass condition: direct play and Intel QuickSync transcoding both succeed for controlled samples.

July 25 display note: after disabling X11 screensaver and DPMS in the live graphical session with `xset s off` and `xset -dpms`, Jellyfin/Firefox playback continued without the display going dark. Verify whether this survives logout and reboot; if not, make it persistent for the `mediacenter` X11 session.

## Phase 5: Backups And Restore

Back up:

- Compose files and `.env` files.
- qBittorrent config/category state.
- Prowlarr, Sonarr, Radarr, Seerr, and Jellyfin config/databases.
- Kodi configuration where part of the workflow.
- Operational docs and checkpoint exports.

Rules:

- Do not treat `/media/cache` as irreplaceable.
- Do not rely on full media-library backup as a substitute for service config/database backup.
- Validate restores to a temporary location before trusting the strategy.

Pass condition: at least one service config/database restore is tested to a temporary location and verified readable.

## Phase 6: Observability

Required visibility:

- SMART status or documented SMART limitation per disk.
- Disk usage for root, `/mnt/core`, and `/media`.
- Docker container state and restart counts.
- Restart loops, especially Seerr `exitCode=1` or repeated restarts.
- Backup job status and latest successful run.
- Jellyfin direct play/transcode status.
- qBittorrent category/download location behavior.
- Sonarr/Radarr import result and hardlink/copy behavior.

Pass condition: an operator can answer "is the media stack healthy?" from documented checks.

## Baseline Result And Continued Use

As of 2026-07-09, the core qBittorrent, Prowlarr, Sonarr, Radarr, Jellyfin, Kodi, and Seerr pipeline was operational. The original expansion gate was satisfied, but `/media` backing storage still needed confirmation before larger expansion work.

During 2026-07-25 maintenance, Seerr was found in a crash/restart loop with `exitCode=1` and more than 21,000 restarts. After the `/mnt/core` mount repair and media-stack restart, Seerr returned successfully with restart count 0, reported `Server ready on port 5055`, and HTTP returned `307 -> /login`.

Normal media-stack update procedure:

```bash
cd /mnt/core/services/media
docker compose pull
docker compose up -d
docker compose ps
```

Retain this runbook for regression checks, rebuild validation, permission audits, backup testing, and controlled changes to legacy media paths. Current expansion priorities are tracked in [Media Backlog](../04_Backlog/Media%20Backlog.md).
