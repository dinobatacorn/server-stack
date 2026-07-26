# Storage Contracts

Status: Current
Last reviewed: 2026-07-25
Source docs:
- Server Plan 21.05.26.md
- Media Stack Stabilization 23.05.26.md
- MediaCenter-Archetecture 17.05.26.txt
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
- Syncthing Recovery and Architecture Update, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
Next action: Normalize legacy `/mnt/core/stacks` service definitions into `/mnt/core/services` and document workload ownership for shared Compose files.

## Hard Rule

Critical operational state must never exist only on bulk media storage.

Do not treat a directory existing at a mountpoint as proof that the intended filesystem is mounted. Verify critical filesystems with `findmnt -T`.

## `/mnt/core`

Role: persistent infrastructure storage and source of truth.

Expected backing filesystem where mounted on VM100 and MediaCenter:

```text
192.168.0.75:/mnt/core -> /mnt/core
Filesystem: NFSv4
```

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

## Mountpoint Safety

Failure mode discovered on MediaCenter, 2026-07-25: Docker could operate while the real `/mnt/core` NFS filesystem was absent. Because `/mnt/core` still existed locally as a mountpoint directory, applications could write into the underlying local filesystem. When NFS later returned, those local files became hidden beneath the real mount.

Recovery created and validated:

```text
/var/backups/mediacenter/core-ghost-2026-07-25.tar.gz
```

The ghost local `/mnt/core/services` tree was removed only after Docker was stopped and the backup was tested. The real NFS-backed media configuration tree then became visible again at:

```text
/mnt/core/services/media
```

Operational checks:

```bash
findmnt -T /mnt/core
findmnt -T /mnt/core/path/to/data
```

Do not use successful `ls /mnt/core` output as mount verification. Before destructive cleanup involving a mountpoint, identify the actual mounted filesystem first.

## Docker Bind Mount And Container Path Rules

Docker applications must be configured with paths visible from inside their containers.

A host path such as `/mnt/core/data/...` is valid inside application configuration only if that same path is explicitly mounted into the container at that same location. Otherwise, the application must use the container path from the Compose bind mount.

Persistent application data must land on documented bind mounts under `/mnt/core`. Docker writable layers are never acceptable storage for persistent state.

Document persistent container mounts as:

```text
host source -> container destination
```

Do not document only the host path. A host pathname does not automatically exist at the same pathname inside a container.

For Syncthing:

| Host / NFS path | Container / Syncthing path |
| --- | --- |
| `/mnt/core/data/sync/github` | `/sync/github` |
| `/mnt/core/data/sync/obsidian` | `/sync/obsidian` |
| `/mnt/core/data/sync/school` | `/sync/school` |
| `/mnt/core/data/sync/config` | `/config` |

Syncthing's Compose file is:

```text
/mnt/core/services/syncthing/compose.yml
```

Its persistent mounts are:

```text
/mnt/core/data/sync/config -> /config
/mnt/core/data/sync        -> /sync
```

`SirBranteSaves` is obsolete and should be removed from Syncthing configuration. Do not create an empty persistent directory merely to silence that folder error.

Recovery note: `/var/backups/syncthing-rescue/misplaced-data-2026-07-25.tar.gz` is invalid and must not be treated as a usable backup. The validated temporary rescue is `/var/backups/syncthing-rescue/overlay-direct`; retain it, along with old OverlayFS evidence, until Syncthing has been observed stable and peer synchronization has been verified.

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

Status: architecture-level bulk/media storage category.

The fundamental storage split remains:

```text
/mnt/core = critical persistent application state
/storage  = bulk/media data
```

On the current MediaCenter deployment, the active media service paths are exposed under `/media`. Treat `/media` as the current implementation path for bulk libraries, downloads, and cache unless a future migration explicitly creates or restores `/storage`.

Critical configuration, databases, application state, and important synchronized documents must not exist solely on `/storage` or `/media`.

## Container Path Rule

Services that cooperate on imports must see the same logical paths. qBittorrent download paths and Sonarr/Radarr root folders must be on the same filesystem/device from inside containers when hardlinks are expected. If source and destination are on different devices, expect copy behavior and document it.
