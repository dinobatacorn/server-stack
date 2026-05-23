# Storage Contracts

Status: Current
Last reviewed: 2026-05-23
Source docs:
- Server Plan 21.05.26.md
- Media Stack Stabilization 23.05.26.md
- MediaCenter-Archetecture 17.05.26.txt
Next action: Document which physical devices back `/mnt/core` and `/media` on the media node.

## Hard Rule

Critical operational state must never exist only on bulk media storage.

## `/mnt/core`

Role: persistent infrastructure storage and source of truth.

Use for:

- Compose stacks
- Service configs
- Databases
- Exports
- Backups
- Operational docs
- Human-owned data that must survive service rebuilds

Expected structure:

```text
/mnt/core
+-- services/
+-- data/
+-- config/
+-- backups/
+-- logs/
+-- tmp/
```

Service persistence should live under `/mnt/core/services`, grouped by category:

```text
services/
+-- core/
+-- media/
+-- knowledge/
+-- utilities/
+-- monitoring/
```

## `/media`

Role: active media-node storage layout.

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

- `/mnt/core/services/media/...`: service configs, databases, compose stacks, and app state.
- `/media/library/...`: final organized libraries served by Jellyfin/Kodi and used as Arr root folders.
- `/media/downloads/...`: acquisition downloads and manual ingest.
- `/media/cache/...`: replaceable cache, transcodes, temporary work areas, and recycle bins.
- `/media/books`, `/media/audiobooks`, `/media/music`: future reading and music libraries; do not expand until layouts are finalized.
- `/media/roms`: future emulator content; deferred until the media core is stable.
- `/media/mediacenter/Storage`: legacy overlap from prior layout; inventory only until backups and imports are proven.

## `/storage`

Status: historical or architecture-level bulk-storage concept.

The older docs use `/storage` for replaceable media and ingest storage. On the current media node, treat `/media` as the active path unless a future migration explicitly creates or restores `/storage`.

## Container Path Rule

Services that cooperate on imports must see the same logical paths. qBittorrent download paths and Sonarr/Radarr root folders must be on the same filesystem/device from inside containers when hardlinks are expected. If source and destination are on different devices, expect copy behavior and document it.
