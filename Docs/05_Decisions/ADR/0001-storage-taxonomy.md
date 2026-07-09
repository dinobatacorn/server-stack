# ADR 0001: Storage Taxonomy And `/mnt/core` Source Of Truth

Status: Accepted
Date: 2026-07-09

## Context

The homelab needs rebuildable services without risking service state, documents, backups, or shared user data. Earlier layouts mixed deployment files, app state, and bulk media concepts.

## Decision

`/mnt/core` is the authoritative location for operational state. It contains deployment definitions, appdata, configs, databases, backups, exports, documentation, and shared operational data.

`/media` is reserved for bulk media content: movies, television, music, books, ROMs, downloads, and transcode/cache content.

Use these responsibilities:

- `/mnt/core/services`: service deployment definitions.
- `/mnt/core/appdata`: persistent application state.
- `/mnt/core/data`: shared user or operational data.
- `/mnt/core/config`: host-level configuration.
- `/mnt/core/backups`: backups and dumps.
- `/mnt/core/docs`: operational documentation.
- `/mnt/core/exports`: manual exports and migrations.

## Consequences

New services have a predictable home for deployment, state, shared data, and backups. Bulk media can be rebuilt or re-imported without becoming the only copy of critical service state.

Legacy `/mnt/core/stacks` remains a migration target and should not receive new service definitions.

## Alternatives Considered

- Store app state beside each Compose file. Rejected because it blurs deployment definitions and persistent state.
- Store app state under `/media`. Rejected because media storage is bulk content, not application truth.
