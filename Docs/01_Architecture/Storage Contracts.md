# Storage Contracts

Status: Current
Last reviewed: 2026-07-09
Source docs:
- Server Plan 21.05.26.md
- Media Stack Stabilization 23.05.26.md
- MediaCenter-Archetecture 17.05.26.txt
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
Next action: Normalize legacy `/mnt/core/stacks` service definitions into `/mnt/core/services`.

## Hard Rule

Critical operational state must never exist only on bulk media storage.

## `/mnt/core`

Role: persistent infrastructure storage and source of truth.

Use for:

- Service deployment definitions
- Persistent application state
- Host-level configs
- Databases
- Exports
- Backups
- Operational docs
- Human-owned data that must survive service rebuilds

Expected structure:

```text
/mnt/core
+-- services/
+-- appdata/
+-- data/
+-- config/
+-- backups/
+-- docs/
+-- exports/
```

Responsibilities:

- `/mnt/core/services`: how services are deployed, including Compose files, deployment definitions, and service scripts.
- `/mnt/core/appdata`: persistent application state, including configs, databases, uploads, and service-owned storage.
- `/mnt/core/data`: shared user or operational data that multiple services may access.
- `/mnt/core/config`: host-level configuration, such as WireGuard config or certificates.
- `/mnt/core/backups`: backups, dumps, snapshots, and restore inputs.
- `/mnt/core/docs`: checked-out operational documentation.
- `/mnt/core/exports`: manual exports, migrations, and one-time extraction output.

Service deployment definitions should live under `/mnt/core/services`, grouped by category:

```text
services/
+-- core/
+-- knowledge/
+-- utilities/
+-- security/
+-- automation/
+-- monitoring/
+-- media/
```

Persistent application state should mirror those categories under `/mnt/core/appdata` where practical:

```text
appdata/
+-- core/
+-- knowledge/
+-- utilities/
+-- security/
+-- automation/
+-- monitoring/
```

Legacy note: `/mnt/core/stacks` exists on VM100 and currently holds some Compose projects. Retire it gradually into `/mnt/core/services`; do not create new service definitions under `stacks`.

## `/media`

Role: active media-node storage layout.

Current July 9 note: `/media` exists on the media node, but the captured `df` output does not show it as a separate mount. The media node root filesystem is 89% used, and a 1.8 TB disk is visible but not mounted in the captured `lsblk` output. Confirm the backing device before large imports or downloads.

Use for:

- Organized media libraries
- Acquisition downloads
- Replaceable cache and transcodes
- Future books, audiobooks, music, and ROM content after layouts are finalized

Recommended active layout:

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

## Media Path Contracts

- `/mnt/core/services/media/...`: media service deployment definitions or compose definitions shared with the media node.
- `/mnt/core/appdata/media/...`: persistent media application state if a media service stores state on `/mnt/core`.
- `/media/library/...`: final organized libraries served by Jellyfin/Kodi and used as Arr root folders.
- `/media/downloads/...`: acquisition downloads and manual ingest.
- `/media/cache/...`: replaceable cache, transcodes, temporary work areas, and recycle bins.
- `/media/library/books`, `/media/library/audiobooks`, `/media/library/music`: future reading and music libraries; do not expand until layouts are finalized.
- `/media/library/roms`: future emulator content; deferred until the media core is stable.
- `/media/mediacenter/Storage`: legacy overlap from prior layout; inventory only until backups and imports are proven.

Current-state exception: media service config and database state currently lives under `/mnt/core/services/media/...`. The long-term `/mnt/core` normalization principle separates deployment definitions under `services` from app state under `appdata`, but do not move working media service state until a checkpoint and restore plan exist.

## `/storage`

Status: historical or architecture-level bulk-storage concept.

The older docs use `/storage` for replaceable media and ingest storage. On the current media node, treat `/media` as the active path unless a future migration explicitly creates or restores `/storage`.

## Container Path Rule

Services that cooperate on imports must see the same logical paths. qBittorrent download paths and Sonarr/Radarr root folders must be on the same filesystem/device from inside containers when hardlinks are expected. If source and destination are on different devices, expect copy behavior and document it.
