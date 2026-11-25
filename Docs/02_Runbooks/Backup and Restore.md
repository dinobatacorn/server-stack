# Backup And Restore

Status: Draft
Last reviewed: 2026-11-25
Source docs:
- Server Plan 21.05.26.md
- to-do list 17.05.26.md
- Media Stack Stabilization 23.05.26.md
- Syncthing Recovery and Architecture Update, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
- Baserow PostgreSQL 16 to 17 migration handoff, 2026-11-24/25
- Fleet Inventory Scripts Development Checkpoint, 2026-11-25
- Proxmox Backup and Fleet Inventory Cleanup handoff, 2026-11-25
Next action: Finish the inventory quarantine reconciliation and peer-convergence check; verify current backup jobs target the documented recovery folders; establish and test scheduled PostgreSQL 17 backups.

## Purpose

Backups should prove rebuildability. A backup is not trusted until at least one restore has been tested to a temporary location.

## Backup Priorities

Backup archives can contain complete service databases, user data, API credentials, SSH keys, and RustDesk identity keys. Keep the backup directory restricted and set sensitive archive files to mode `600`; do not leave guest archives readable by every local account. The PVE `vzdump` files in `/mnt/core/backups/snapshots/dump/` were restricted to root-only access on 2026-09-29.

The `/mnt/core/backups` tree is on PVE infrastructure storage. A copy there is useful for guest or service recovery but is not an offsite or independent-host copy. Record that limitation until an offsite backup is configured and validated.

## Recovery Backup Layout (Verified 2026-11-25)

Proxmox storage ID `snapshots` remains configured at `/mnt/core/backups/snapshots` with content type `backup`, `prune-backups keep-all=1`, and `shared 0`. The storage configuration was inspected and not changed during the cleanup. Proxmox VM and LXC archives belong under:

```text
/mnt/core/backups/snapshots/dump/
```

On 2026-11-25, `pvesm list snapshots --content backup` reported 13 recognized archives (CT101: 2, CT102: 2, CT103: 3, VM100: 5, VM200: 1), occupying about 55 GB. The dated directories were removed from the storage root, leaving `dump/`. Do not rename or delete the Proxmox storage definition `snapshots` based on its name; it is active backup storage. This cleanup did not validate restores or create a new backup policy.

Application and host recovery archives are organized outside Proxmox vzdump storage:

```text
/mnt/core/backups/<service>/<date>/
```

The 2026-11-25 relocation placed RustDesk archives in `rustdesk/2026-09-28/` and `rustdesk/2026-10-23/`, Nginx Proxy Manager data in `npm/2026-09-28/`, PVE host configuration archives in `pve/2026-09-29/` and `pve/2026-10-23/`, Baserow's October 23 dump in `baserow/2026-10-23/`, and VM100 shared appdata in `services/2026-10-23/`. The dated Baserow file is `/mnt/core/backups/baserow/2026-10-23/baserow_pg_dump_2026-10-23.sql.zst`; the VM100 archive is `/mnt/core/backups/services/2026-10-23/vm100_shared_appdata_2026-10-23.tar.zst`. Nine September 28 MediaCenter maintenance artifacts were moved to `/mnt/core/backups/media/2026-09-28/pre/`. These are relocations of existing archives, not evidence that scheduled jobs now write to those locations.

The reorganization details and unresolved inventory quarantine are recorded in [Backup and Inventory Layout Cleanup, 2026-11-25](../06_Operations/Maintenance%20History/2026-11-25-backup-and-inventory-layout-cleanup.md).

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

- Production Baserow PostgreSQL 17 is reported in PVE CT104; its data directory is `/mnt/core/appdata/postgresql` on PVE. Verify the guest ID against a current PVE inventory before maintenance.
- Create and validate a fresh custom-format PostgreSQL 17 dump before database or application migrations; use `pg_restore --list`.
- A successful archive listing is an integrity check, not a restore test. Keep database and Baserow media recovery coordinated.

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

## Baserow PostgreSQL 17 Cutover Artifacts

Validated cutover inputs from 2026-11-25:

```text
/mnt/core/backups/baserow/2026-11-25/baserow-cutover.dump
/mnt/core/backups/baserow/2026-11-25/baserow-media-cutover.tar.gz
```

The custom database dump passed `pg_restore --list`; the media archive passed `tar -tzf`. Production restore returned exit code 0 and the application was functionally verified against CT104. These are cutover recovery artifacts, not evidence of a recurring PostgreSQL 17 backup schedule. No independent backup configuration or restore drill for the new production database is yet documented. Retain both until a separate PostgreSQL 17 backup and restore procedure is established and tested. The prior PostgreSQL 16 directory is a divergent historical snapshot, not a synchronized standby. Full details are in the [migration record](../06_Operations/Incidents/2026-11-24-baserow-postgresql-migration.md).

## September 2026 Fleet Recovery Artifacts

The dated [2026-09-28 fleet report](../06_Operations/Update%20Reports/2026-09-28.md) records the PVE/guest archives and RustDesk LXC backup; the [2026-09-29 follow-up](../06_Operations/Update%20Reports/2026-09-29.md) records the endpoint outcomes.

- PVE host/cluster config archive: relocated to `/mnt/core/backups/pve/2026-09-29/`; `zstd -t` passed before relocation.
- Fresh VM100 snapshot-mode backup: `/mnt/core/backups/snapshots/dump/vzdump-qemu-100-2026_09_29-10_39_11.vma.zst`; guest-agent freeze/thaw and backup log succeeded; `zstd -t` passed.
- RustDesk CT 103: PVE `vzdump` archives were validated, but they do not include its `/mnt/core/appdata/security/rustdesk-server` and `rustdesk-api` bind mounts. A separate appdata archive passed `zstd -t` and was relocated to `/mnt/core/backups/rustdesk/2026-09-28/`.
- MediaCenter: pre-image and post-image appdata archives were made with the Compose project stopped and passed `zstd -t`; the post-image archive remains under `/mnt/core/backups/media/2026-09-29/post/`.
- These copies are on the PVE `/mnt/core` SSD. They are not offsite or independent-host copies. No restore drill was performed, and scheduled PVE guest backup retention has not been defined.

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
- Scheduled PostgreSQL 17 database dumps, retention, independent copies, and a tested restore are pending; do not assume automation exists.
- Backup retention policies need to be finalized.
- Full and partial restore workflows still need tests.
- Backup integrity validation needs to be documented.
