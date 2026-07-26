# Backup And Restore

Status: Draft
Last reviewed: 2026-07-25
Source docs:
- Server Plan 21.05.26.md
- to-do list 17.05.26.md
- Media Stack Stabilization 23.05.26.md
- Syncthing Recovery and Architecture Update, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
Next action: Document current Restic configuration, retain July 25 validated recovery material, and perform one temporary restore test.

## Purpose

Backups should prove rebuildability. A backup is not trusted until at least one restore has been tested to a temporary location.

## Backup Priorities

Back up first:

- Compose files.
- `.env` files.
- Service configs.
- Service databases.
- Operational docs.
- Checkpoint exports.

Media-node priority:

- qBittorrent config and category state.
- Prowlarr config/database.
- Sonarr config/database.
- Radarr config/database.
- Seerr config/database before any crash-loop redeploy or destructive repair.
- Jellyfin config/database/metadata.
- Kodi config if it is part of the media workflow.

Core infrastructure priority:

- Proxmox config notes and VM/LXC inventory.
- Core Services Docker VM compose stacks.
- Restic configuration and retention policy.
- Auth, proxy, DNS, and VPN service configuration.
- Syncthing configuration and synced critical folders under `/mnt/core/data/sync`.

Knowledge/database priority:

- Baserow PostgreSQL dumps before Baserow/PostgreSQL updates.
- Validate Baserow dumps with `pg_restore --list` before recreating containers.

## MediaCenter Ghost `/mnt/core` Backup

Validated backup:

```text
/var/backups/mediacenter/core-ghost-2026-07-25.tar.gz
```

This archive was created after Docker was stopped and before deleting the accidentally local MediaCenter `/mnt/core/services` tree that existed beneath the NFS mountpoint.

The backup was tested before the ghost source was removed.

Retain it until the media stack has remained healthy long enough that rollback material is no longer required.

## Baserow Update Backup

Validated PostgreSQL dump:

```text
/mnt/core/backups/baserow/2026-07-25/baserow.dump
```

Observed size:

```text
12 MB
```

Validation:

```text
pg_restore --list exited 0
Database: baserow
Format: CUSTOM
PostgreSQL source version: 16.14
pg_dump version: 16.14
TOC entries: 19,757
```

Retain this dump according to the backup-retention policy.

## Syncthing Recovery Artifacts

Validated temporary rescue:

```text
/var/backups/syncthing-rescue/overlay-direct
```

This copy was created from the Syncthing container writable layer after stopping Syncthing and was independently SHA-256 verified against the source OverlayFS data on 2026-07-25.

Invalid archive:

```text
/var/backups/syncthing-rescue/misplaced-data-2026-07-25.tar.gz
```

The tar/gzip archive failed validation with an unexpected EOF and must not be treated as a usable backup.

Retain the validated `overlay-direct` rescue and old Docker OverlayFS evidence until the restored Syncthing deployment has operated normally for several days and peer synchronization is verified healthy.

## Non-Priorities

Do not treat these as irreplaceable:

- `/media/cache`
- Transcode directories
- Temporary work directories
- Recycle bins after retention expires

Do not use a full media-library backup as a substitute for application config/database backups.

## Manual Restore Test

1. Verify the target filesystem with `findmnt -T`, especially for `/mnt/core`.
2. Select one service with meaningful state, such as Baserow, Sonarr, Radarr, Prowlarr, Seerr, or Jellyfin.
3. Restore its config/database backup to a temporary location.
4. Confirm the restored files are readable and complete enough to rebuild the service.
5. Record the service name, backup source, restore location, timestamp, and result.
6. Do not proceed with destructive cleanup until at least one restore has passed.

## Current Gaps

- Restic framework is in progress.
- Automatic database dumps are not yet documented as complete.
- Backup retention policies need to be finalized.
- Full and partial restore workflows still need tests.
- Backup integrity validation needs to be documented.
