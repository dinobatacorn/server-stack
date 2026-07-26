# ADR 0015: Syncthing And Nextcloud Coexistence

Status: Accepted
Date: 2026-07-09

## Context

Syncthing is already deployed on VM100, and Nextcloud has re-entered the planned platform. They can overlap unless their responsibilities are explicit.

## Decision

Use Syncthing for actively edited files where direct peer-to-peer synchronization is valuable, such as Obsidian vaults, development projects, and active writing.

Use Nextcloud for user-facing storage, mobile access, sharing, WebDAV, collaboration, photo uploads, and browser-based file access.

Syncthing's canonical deployment runs on VM100 `services`.

Current Syncthing path contract:

| Host / NFS path | Container / Syncthing path |
| --- | --- |
| `/mnt/core/data/sync/github` | `/sync/github` |
| `/mnt/core/data/sync/obsidian` | `/sync/obsidian` |
| `/mnt/core/data/sync/school` | `/sync/school` |
| `/mnt/core/data/sync/config` | `/config` |

`SirBranteSaves` is obsolete and should be removed from Syncthing configuration.

## Consequences

Both services can coexist without competing, as long as they do not become two sources of truth for the same dataset.

Syncthing must be configured with container-visible paths. Docker writable layers are not a valid persistence location for synced data.

## Alternatives Considered

- Use only Syncthing. Rejected because it does not provide the same user-facing cloud interface.
- Use only Nextcloud. Rejected because actively edited peer-to-peer workflows may still benefit from Syncthing.
