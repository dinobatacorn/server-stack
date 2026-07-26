# Syncthing

Status: Recovered and operational
Last reviewed: 2026-07-25
Source docs:
- Syncthing Recovery and Architecture Update, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
- ADR 0015: Syncthing And Nextcloud Coexistence
- ADR 0018: Docker Container Paths Must Match Container Mounts
Next action: Remove obsolete `SirBranteSaves`, observe peer synchronization for several days, then retire recovery artifacts only after the restored environment is confirmed healthy.

## Purpose

Syncthing is the peer-to-peer sync service for actively edited files such as Obsidian vaults, development projects, and school/work material.

`/mnt/core` remains the persistent source of truth for Syncthing data and configuration. Docker writable layers are never acceptable storage for persistent Syncthing data.

## Canonical Deployment

Active host:

```text
services
```

The canonical Syncthing deployment belongs on VM100, not MediaCenter. MediaCenter may access the same `/mnt/core` NFS source, but Docker runtime state and OverlayFS layers are host-local.

Before running host-specific Docker/Compose operations, verify:

```bash
hostname
findmnt -T /mnt/core
```

Shared Compose files being visible from a machine does not mean that machine owns the workload.

On the services VM, `/mnt/core` is an NFSv4 mount from:

```text
192.168.0.75:/mnt/core
```

Compose file:

```text
/mnt/core/services/syncthing/compose.yml
```

Persistent configuration:

```text
/mnt/core/data/sync/config
```

Active version after recovery:

```text
Image: lscr.io/linuxserver/syncthing:latest
Linuxserver.io version: v2.1.2-ls226
Syncthing v2.1.2 "Hafnium Hornet"
```

## Bind Mounts

The Syncthing container mounts only these persistent host paths:

```text
/mnt/core/data/sync/config -> /config
/mnt/core/data/sync        -> /sync
```

Therefore Syncthing folder paths must use `/sync/...` inside the Syncthing UI/configuration.

Host paths such as `/mnt/core/data/...` must not be used inside Syncthing unless the same host path is explicitly mounted inside the container at that exact location.

## Folder Path Contract

| Host / NFS path | Container / Syncthing path |
| --- | --- |
| `/mnt/core/data/sync/github` | `/sync/github` |
| `/mnt/core/data/sync/obsidian` | `/sync/obsidian` |
| `/mnt/core/data/sync/school` | `/sync/school` |
| `/mnt/core/data/sync/config` | `/config` |

Current important folders:

```text
Github   -> /sync/github
Obsidian -> /sync/obsidian
school   -> /sync/school
```

`SirBranteSaves` is obsolete. Remove it from Syncthing configuration instead of creating a placeholder directory.

## Current Known-Good State

Final observed state on 2026-07-25:

```text
Running
0 container restarts
Github scan complete
Obsidian scan complete
school scan complete
No recent ERR/WRN messages
```

Configured peers observed during recovery included:

```text
AtlasOS
SteamDeck
Laptop
```

Inside the container, restored data was visible at:

```text
/sync/github   126M
/sync/obsidian 15M
/sync/school   1.6G
```

Expected file counts:

```text
github:   5078
obsidian: 38
school:   1298
```

## Recovery Record: 2026-07-25

Syncthing had been configured with host paths from inside the container:

```text
Obsidian: /mnt/core/data/sync/obsidian
Github:   /mnt/core/data/sync/github
school:   /mnt/core/data/school
```

Because `/mnt/core` was not mounted inside the container, Syncthing wrote data into the container's writable OverlayFS layer.

The relevant writable layer was:

```text
/var/lib/docker/overlay2/1b5ecfa701c26f8999c6c9479cde1549b5d76e1ba046f994270d2373b536c860/diff
```

Misplaced data existed beneath:

```text
mnt/core/data/sync/github
mnt/core/data/sync/obsidian
mnt/core/data/school
```

Approximate source sizes and file counts:

| Folder | Size | Files |
| --- | ---: | ---: |
| `github` | 126M | 5078 |
| `obsidian` | 15M | 38 |
| `school` | 1.6G | 1298 |

A previously observed large `Legally Blonde The Musical [MTV Production 2007].mp4` was no longer present in the OverlayFS data by the time recovery was performed. It was handled separately and is not part of this Syncthing recovery.

## Invalid Archive

The first tar/gzip rescue attempt produced:

```text
/var/backups/syncthing-rescue/misplaced-data-2026-07-25.tar.gz
```

Validation failed with:

```text
gzip: stdin: unexpected end of file
tar: Unexpected EOF in archive
tar: Error is not recoverable
```

This archive is invalid and must not be treated as a usable backup.

## Validated Rescue

Syncthing was stopped before directly copying the writable layer.

The validated rescue copy is:

```text
/var/backups/syncthing-rescue/overlay-direct/github
/var/backups/syncthing-rescue/overlay-direct/obsidian
/var/backups/syncthing-rescue/overlay-direct/school
```

SHA-256 manifests were generated independently for source and rescue copies.

Verification result:

```text
github: MATCH
obsidian: MATCH
school: MATCH
```

File counts also matched exactly:

```text
github     source=5078  rescue=5078
obsidian   source=38    rescue=38
school     source=1298  rescue=1298
```

Retain `/var/backups/syncthing-rescue/overlay-direct` until the restored Syncthing environment has operated normally for several days and peer synchronization has been verified.

Do not clean up the old Docker OverlayFS or rescue artifacts until the recovery is confirmed stable and the rescue is no longer required.

## Restoration

Persistent destination directories were created on `/mnt/core`:

```text
/mnt/core/data/sync/github
/mnt/core/data/sync/obsidian
/mnt/core/data/sync/school
```

The rescued data was restored there and verified byte-for-byte against the validated rescue copy.

Restored sizes:

```text
126M  /mnt/core/data/sync/github
15M   /mnt/core/data/sync/obsidian
1.6G  /mnt/core/data/sync/school
```

Restored file counts:

```text
github:   5078
obsidian: 38
school:   1298
```

SHA-256 comparison between the validated rescue and restored NFS data returned:

```text
github: MATCH
obsidian: MATCH
school: MATCH
```

## Configuration Repair

Configuration backup made before modification:

```text
/mnt/core/data/sync/config/config.xml.pre-path-fix-2026-07-25
```

Active configuration:

```text
/mnt/core/data/sync/config/config.xml
```

Path changes:

| Folder | Before | After |
| --- | --- | --- |
| Obsidian | `/mnt/core/data/sync/obsidian` | `/sync/obsidian` |
| Github | `/mnt/core/data/sync/github` | `/sync/github` |
| school | `/mnt/core/data/school` | `/sync/school` |

A subsequent search found no remaining configured folder paths beginning with `/mnt/core`.

The empty `<folder>` entry under `<defaults>` in `config.xml` is a Syncthing defaults template, not an actual configured sync folder.

## Version Note

The services VM initially restarted from a locally cached LinuxServer image containing Syncthing v2.1.1.

Because the same persistent config had briefly been opened by v2.1.2 on MediaCenter, logs reported a downgrade:

```text
Detected upgrade (from=v2.1.2 to=v2.1.1)
```

The current image was then explicitly pulled and restarted:

```bash
docker compose pull
docker compose up -d
```

The active version is now v2.1.2, and startup reported:

```text
Detected upgrade (from=v2.1.1 to=v2.1.2)
```

The QUIC receive-buffer informational message was observed later but was not associated with synchronization failure.

## Technical Debt

Syncthing currently runs as:

```text
PUID=0
PGID=0
```

This predates the recovery and was intentionally not changed during the incident to avoid introducing a permissions variable while restoring data.

After the recovered system is confirmed stable, migrate Syncthing to an unprivileged UID/GID and verify permissions on `/mnt/core/data/sync`.
