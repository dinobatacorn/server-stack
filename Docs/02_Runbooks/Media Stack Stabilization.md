# Media Stack Stabilization

Status: Completed baseline; retained as a validation runbook
Last reviewed: 2026-07-09
Source docs:
- Media Stack Stabilization 23.05.26.md
- Server Plan 21.05.26.md
- to-do list 17.05.26.md
- medianode-output_09072026.txt
Next action: Confirm `/media` backing storage, then use these checks for regression testing and create a fresh known-good checkpoint before risky changes.

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

Validate:

- `/mnt/core` is mounted before Docker-dependent service state is needed.
- `/media` is mounted or otherwise backed by the intended media storage before acquisition/playback containers start.
- Docker starts after required mounts are available.
- Containers with restart policies recover cleanly after reboot.
- Disk capacity is visible for root, `/mnt/core`, and `/media`.
- SMART visibility exists for internal disks, with USB limitations documented.

Pass condition: after one reboot, `/mnt/core`, `/media`, Docker, and existing media containers recover without manual intervention.

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
- Persistent state stays under `/mnt/core/services/media/serving/jellyfin`.
- Replaceable transcodes/cache use `/media/cache/transcode` or another documented `/media/cache` subpath.
- Direct play works for a known-good file.
- Intel QuickSync transcoding works before GTX 1060 optimization.

Kodi:

- Kodi can play from the same stabilized library paths or through Jellyfin integration.
- Living-room UX work waits until playback paths are stable.
- Emulator launching stays deferred.

Pass condition: direct play and Intel QuickSync transcoding both succeed for controlled samples.

## Phase 5: Backups And Restore

Back up:

- Compose files and `.env` files.
- qBittorrent config/category state.
- Prowlarr, Sonarr, Radarr, and Jellyfin config/databases.
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
- Backup job status and latest successful run.
- Jellyfin direct play/transcode status.
- qBittorrent category/download location behavior.
- Sonarr/Radarr import result and hardlink/copy behavior.

Pass condition: an operator can answer "is the media stack healthy?" from documented checks.

## Baseline Result And Continued Use

As of 2026-07-09, the core qBittorrent, Prowlarr, Sonarr, Radarr, Jellyfin, Kodi, and Seerr pipeline is operational. The original expansion gate has been satisfied, but `/media` backing storage should be confirmed before larger expansion work.

Retain this runbook for regression checks, rebuild validation, permission audits, backup testing, and controlled changes to legacy media paths. Current expansion priorities are tracked in [Media Backlog](../04_Backlog/Media%20Backlog.md).
