# Backup And Restore

Status: Draft
Last reviewed: 2026-07-06
Source docs:
- Server Plan 21.05.26.md
- to-do list 17.05.26.md
- Media Stack Stabilization 23.05.26.md
Next action: Document current Restic configuration and perform one temporary restore test.

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
- Jellyfin config/database/metadata.
- Kodi config if it is part of the media workflow.

Core infrastructure priority:

- Proxmox config notes and VM/LXC inventory.
- Core Services Docker VM compose stacks.
- Restic configuration and retention policy.
- Auth, proxy, DNS, and VPN service configuration.

## Non-Priorities

Do not treat these as irreplaceable:

- `/media/cache`
- Transcode directories
- Temporary work directories
- Recycle bins after retention expires

Do not use a full media-library backup as a substitute for application config/database backups.

## Manual Restore Test

1. Select one service with meaningful state, such as Sonarr, Radarr, Prowlarr, or Jellyfin.
2. Restore its config/database backup to a temporary location.
3. Confirm the restored files are readable and complete enough to rebuild the service.
4. Record the service name, backup source, restore location, timestamp, and result.
5. Do not proceed with destructive cleanup until at least one restore has passed.

## Current Gaps

- Restic framework is in progress.
- Automatic database dumps are not yet documented as complete.
- Backup retention policies need to be finalized.
- Full and partial restore workflows still need tests.
- Backup integrity validation needs to be documented.
