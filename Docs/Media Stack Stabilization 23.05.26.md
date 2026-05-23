# Media Stack Stabilization Runbook

Date: 2026-05-23

Applies to: dedicated media node `media`, Debian 13 Trixie

Purpose: stabilize the existing media core before adding more services.

---

# Operating Doctrine

This phase is stabilization, not expansion.

Core rules:

* Persistent data is sacred.
* Containers are disposable.
* Prefer clean redeploys over in-place patching.
* Prefer simple, inspectable layouts over clever automation.
* Recovery must be proven, not assumed.
* Documentation is infrastructure.

Operational priorities:

1. Prove base host, mounts, Docker startup, and visibility.
2. Normalize permissions and UID/GID behavior.
3. Stabilize acquisition and import behavior.
4. Stabilize playback and transcoding.
5. Validate backups and observability.
6. Add new services only after the core stack is boring.

---

# Current State

Known from the current docs and media inventory:

* Host: Debian 13 Trixie media node.
* CPU: Intel i7-9700K.
* GPUs: Intel UHD 630 and NVIDIA GTX 1060 3GB.
* Storage: 232GB SSD, 2TB HDD, 5TB HDD.
* Existing operational roots: `/mnt/core` and `/media`.
* Broader architecture docs still use `/storage` as the abstract bulk-storage category.
* The captured inventory shows sensors, but no SMART records. Treat SMART visibility as an unresolved base-system gap.

Service state:

* Partial: Debian media host, `/mnt/core`, `/media`.
* Partial: qBittorrent, Prowlarr, Sonarr, Radarr, Jellyfin, Kodi.
* Planned after stabilization: Bazarr, Overseerr, Lidarr, Readarr.
* Planned after layout decisions: Kavita, Audiobookshelf, Calibre or Calibre-Web.
* Deferred: RetroArch, standalone emulators, Kodi emulator launching.
* Deferred: Recyclarr, Tdarr, GTX 1060 transcoding optimization, automated quality management.

Transitional conditions that are tolerated for now:

* Duplicate directory structures.
* Partially normalized naming.
* Mixed metadata quality.
* Legacy media overlap.
* Incomplete library categorization.

These conditions should be documented and reduced gradually. Do not correct them with large destructive migrations.

---

# Path Contracts

Use these contracts when reviewing compose files, service settings, and future runbooks.

| Path | Role | Rule |
| --- | --- | --- |
| `/mnt/core/services/media/...` | Service configs, databases, compose stacks, app state | Source of truth for service persistence |
| `/media/library/...` | Final organized media libraries | Served by Jellyfin/Kodi and used as Arr root folders |
| `/media/downloads/...` | Acquisition downloads and manual ingest | Written by qBittorrent and read by import tools |
| `/media/cache/...` | Replaceable cache, transcodes, temporary work areas, recycle bins | Do not store irreplaceable state here |
| `/media/books`, `/media/audiobooks`, `/media/music` | Future reading and music libraries | Do not expand until layouts are finalized |
| `/media/roms` | Future emulator content | Deferred until media core is stable |
| `/media/mediacenter/Storage` | Legacy overlap from prior layout | Inventory only; no moves or deletes until backups and imports are proven |
| `/storage` | Architecture-level bulk-storage concept | Do not treat as the live media-node path unless a future migration explicitly creates it |

Container path contract:

* Services that cooperate on imports should see the same logical paths.
* qBittorrent download paths and Sonarr/Radarr root folders must be on the same filesystem/device from inside the relevant containers when hardlinks are expected.
* If source and destination are on different filesystems/devices, expect copy behavior.
* Do not hide path problems with container-specific permission workarounds.

Recommended active media layout:

```text
/media
+-- downloads/
|   +-- incomplete/
|   +-- complete/
|   +-- manual/
|   +-- unsorted/
+-- library/
|   +-- movies/
|   +-- tv/
|   +-- anime/
|   +-- music/
|   +-- youtube/
|   +-- home-videos/
+-- cache/
|   +-- metadata/
|   +-- recycle/
|   +-- tmp/
|   +-- transcode/
+-- books/
+-- audiobooks/
+-- roms/
```

---

# Known-Good Checkpoint

Before risky changes, create a dated checkpoint under `/mnt/core/exports/media-stabilization/`.

Capture:

* Compose files and compose project names.
* `.env` files.
* Service config directories for qBittorrent, Prowlarr, Sonarr, Radarr, Jellyfin, and Kodi.
* Container inventory, images, restart policies, bind mounts, and networks.
* Host mount output and filesystem/device layout.
* UID/GID mappings for the media user, media group, service users, and container users.
* Representative qBittorrent category/path configuration.
* Representative Sonarr/Radarr root folders, download clients, quality profiles, import settings, and recycle-bin settings.
* Representative Prowlarr working indexers and app sync settings.
* Representative Jellyfin library paths, users, hardware acceleration settings, playback logs, and transcoding logs.
* Sample successful import logs before changing import behavior.
* Backup job configuration and the latest successful backup timestamp.
* Last restore verification timestamp, once available.

Checkpoint rules:

* Do not delete or move legacy media before a checkpoint exists.
* Do not run broad recursive ownership changes before recording current ownership.
* Do not change import behavior before recording one known successful import path, if one exists.
* If a checkpoint cannot be created, stop and fix backup/export visibility first.

---

# Stop Conditions

Stop expansion immediately if any stabilization step causes:

* Duplicate imports.
* Unexpected moves or deletes.
* Metadata corruption.
* Permission regressions.
* Broken playback paths.
* Failed Jellyfin library scans caused by path changes.
* qBittorrent downloads landing outside documented paths.
* Sonarr/Radarr imports using unexpected root folders.
* Repeated manual intervention for routine acquisition/import.

Repeated manual fixes are a system-design smell. Treat them as unclear ownership, missing observability, missing automation boundaries, or an architectural mismatch.

---

# Stabilization Phases

## 1. Base Host and Mounts

Goal: the media node survives reboot and exposes the expected storage before applications start doing useful work.

Validate:

* `/mnt/core` is mounted before Docker-dependent service state is needed.
* `/media` is mounted before acquisition/playback containers start.
* Docker starts after the required mounts are available.
* Containers with restart policies recover cleanly after reboot.
* The host can report disk capacity for root, `/mnt/core`, and `/media`.
* SMART visibility is available for internal disks, and USB disk limitations are documented.

Required outputs:

* Document mount relationships.
* Document which physical devices back `/mnt/core` and `/media`.
* Document whether SMART works per disk.
* Document the automatic update policy.

Pass condition:

* After one reboot, `/mnt/core`, `/media`, Docker, and existing media containers recover without manual intervention.

## 2. Permissions and UID/GID Audit

Goal: services can read and write the expected paths through a shared media ownership strategy.

Validate:

* A shared media UID/GID strategy exists for qBittorrent, Sonarr, Radarr, Jellyfin, and future media services unless a service has a clear isolation reason.
* Container `PUID`, `PGID`, `user`, and bind-mount settings match the intended ownership model.
* Files created by qBittorrent are readable by Sonarr/Radarr.
* Files imported by Sonarr/Radarr are readable by Jellyfin and Kodi.
* Jellyfin can write only to its app state and cache/transcode paths, not arbitrary library locations unless explicitly intended.

Rules:

* Prefer filesystem-level ownership and group inheritance.
* Avoid one-off container-specific fixes that hide inconsistent ownership.
* Do not run broad recursive `chown` or permission changes until a checkpoint exists and a sample path audit is recorded.

Pass condition:

* A controlled download/import/playback test completes without manual permission fixes.

## 3. Acquisition Core

Goal: qBittorrent, Prowlarr, Sonarr, and Radarr behave predictably before adding more acquisition services.

### qBittorrent

Validate:

* Incomplete downloads land under `/media/downloads/incomplete`.
* Completed downloads land under `/media/downloads/complete`.
* Categories are documented and match Sonarr/Radarr expectations.
* If categories are missing, use lower-case category names: `movies`, `tv`, `anime`, and `manual`.
* Category save paths stay under `/media/downloads/complete`.
* Automatic cleanup rules do not delete content that Sonarr/Radarr still need for seeding or hardlink verification.
* New downloads inherit the intended owner/group.

Pass condition:

* A controlled test download lands in the expected incomplete and complete paths with the expected ownership.

### Prowlarr

Validate:

* Working indexers are known and documented.
* Broken or dead indexers are removed or disabled.
* Prowlarr app sync targets only the stabilized apps for this phase.
* Rebuild-safe configuration notes exist for indexers and app connections.

Pass condition:

* Sonarr and Radarr can search through Prowlarr without repeated manual indexer fixes.

### Sonarr and Radarr

Validate:

* Radarr root folder: `/media/library/movies`.
* Sonarr root folders: `/media/library/tv` and, if used, `/media/library/anime`.
* Download client mappings match the qBittorrent paths visible inside the containers.
* Quality profiles are intentionally selected and documented.
* Import behavior is deterministic for a controlled sample.
* Recycle-bin behavior is enabled and points under `/media/cache/recycle/sonarr` and `/media/cache/recycle/radarr`, unless explicitly disabled and documented.
* Hardlinks work when source and destination are same-device from the container perspective.
* Cross-device imports are expected to copy, not hardlink.

Pass condition:

* One controlled movie import and one controlled TV/anime import land in the correct library paths without duplicates, unexpected moves, or manual permission fixes.

## 4. Playback Core

Goal: Jellyfin and Kodi can consume stabilized libraries without path surprises.

### Jellyfin

Validate:

* Libraries point to `/media/library/movies`, `/media/library/tv`, `/media/library/anime`, `/media/library/music`, and `/media/library/home-videos` as applicable.
* Jellyfin persistent state stays under `/mnt/core/services/media/serving/jellyfin`.
* Replaceable transcodes/cache use `/media/cache/transcode` or another documented `/media/cache` subpath.
* Metadata providers are configured intentionally.
* Users are configured intentionally.
* Direct play works for a known-good file.
* Intel QuickSync transcoding works before any GTX 1060 optimization is attempted.

Pass condition:

* Direct play and Intel QuickSync transcoding both succeed for controlled samples, and the operator can confirm transcode status without digging through unrelated logs.

### Kodi

Validate:

* Kodi can play from the same stabilized library paths or through the Jellyfin integration.
* Living-room UX work is allowed only after playback paths are stable.
* Emulator launching stays deferred.

Pass condition:

* Kodi playback works without creating alternate media paths or duplicate library assumptions.

## 5. Backups and Restore

Goal: service state can be restored before the ecosystem grows.

Backup priorities:

* Compose files.
* `.env` files.
* qBittorrent config and category state.
* Prowlarr config/database.
* Sonarr config/database.
* Radarr config/database.
* Jellyfin config/database/metadata.
* Kodi configuration where it is part of the media-node workflow.
* Operational docs and checkpoint exports.

Rules:

* Do not treat `/media/cache` as irreplaceable.
* Do not rely on full media-library backup as a substitute for service config/database backup.
* Validate restores to a temporary location before trusting a backup strategy.
* Record restore verification timestamps.

Pass condition:

* At least one service config/database restore is tested to a temporary location and verified usable.

## 6. Observability

Goal: normal health checks are visible without ad hoc log digging.

Required visibility:

* SMART status or documented SMART limitation per disk.
* Disk usage for root, `/mnt/core`, and `/media`.
* Docker container state and restart counts.
* Backup job status and latest successful run.
* Jellyfin direct play/transcode status.
* qBittorrent download location and category behavior.
* Sonarr/Radarr import result and hardlink/copy behavior.

Pass condition:

* An operator can answer "is the media stack healthy?" from documented checks, not memory.

## 7. Expansion Eligibility

Only expand when all prior phase pass conditions are met.

Allowed next additions:

* Bazarr after Sonarr/Radarr imports and Jellyfin playback are stable.
* Overseerr after request flow can safely target stable Sonarr/Radarr profiles and root folders.

Still blocked:

* Lidarr and Readarr until music/books layouts are finalized.
* Kavita, Audiobookshelf, and Calibre/Calibre-Web until reading/audiobook layouts and backups are finalized.
* Emulator work until core media and backups are stable.
* Recyclarr and automated quality management until manual profiles are proven.
* Tdarr and GTX 1060 optimization until direct play and Intel QuickSync are stable.

Expansion pass condition:

* Normal acquisition, import, playback, backup checks, and visibility checks require no manual intervention for the controlled test set.

---

# Validation Matrix

| Test | Method | Pass Criteria |
| --- | --- | --- |
| Reboot persistence | Reboot after checkpoint, then verify mounts, Docker, and containers | `/mnt/core`, `/media`, Docker, and media containers recover cleanly |
| Permissions | Controlled download, import, and playback path write/read checks | qBittorrent, Sonarr/Radarr, Jellyfin, and Kodi work without manual permission fixes |
| Hardlinks/imports | Controlled import where source and destination are same-device from inside containers | Hardlinks occur where expected; cross-device copies are documented |
| Import behavior | Controlled movie and TV/anime imports | Correct root folders, no duplicates, no unexpected moves/deletes |
| Playback | Jellyfin direct play and transcode samples | Direct play succeeds; Intel QuickSync transcode succeeds |
| Backup/restore | Restore one service config/database to a temporary location | Restored data is readable and plausibly usable |
| Visibility | Run documented health checks | SMART/disk/container/backup/transcode status are checkable without ad hoc digging |

---

# Stable Core Definition

The media core is stable only when:

* Reboot persistence is verified.
* Imports are deterministic.
* Hardlinks work correctly where expected.
* Copy behavior is expected and documented where hardlinks are impossible.
* Permissions remain consistent.
* Direct play and Intel QuickSync transcoding succeed reliably.
* Backups are tested through at least one restore.
* SMART, disk, container, backup, and transcode visibility checks exist.
* Routine acquisition/import/playback requires no manual intervention.

Until this definition is met, do not expand the ecosystem.
