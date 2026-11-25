# Backup and Inventory Layout Cleanup

**Date:** 2026-11-25  
**Status:** Main filesystem reorganization completed; inventory reconciliation and peer convergence remain unverified  
**Scope:** Documentation record from the owner-provided handoff. This was a filesystem reorganization, not a backup-policy redesign or restore test.

## Recovery backup layout

PVE `/etc/pve/storage.cfg` was inspected and still defines:

```ini
dir: snapshots
        path /mnt/core/backups/snapshots
        content backup
        prune-backups keep-all=1
        shared 0
```

The Proxmox storage ID is `snapshots`; its configuration was not changed. Proxmox VM/LXC archives now reside in `/mnt/core/backups/snapshots/dump/`. The dated directories were removed from the storage root, leaving `dump/`. `pvesm list snapshots --content backup` reported 13 recognized archives: CT101 (2), CT102 (2), CT103 (3), VM100 (5), VM200 (1), about 55 GB total. The prior `/mnt/core/backups/snapshots/` tree had zero JSON files after inventory migration.

Seven application/host recovery archive moves completed:

| Content | Destination |
|---|---|
| RustDesk appdata, September 28 | `/mnt/core/backups/rustdesk/2026-09-28/` |
| RustDesk appdata, October 23 | `/mnt/core/backups/rustdesk/2026-10-23/` |
| Nginx Proxy Manager appdata | `/mnt/core/backups/npm/2026-09-28/` |
| PVE host configuration, September 29 | `/mnt/core/backups/pve/2026-09-29/` |
| PVE host configuration, October 23 | `/mnt/core/backups/pve/2026-10-23/` |
| Baserow PostgreSQL dump, October 23 | `/mnt/core/backups/baserow/2026-10-23/baserow_pg_dump_2026-10-23.sql.zst` |
| VM100 shared appdata, October 23 | `/mnt/core/backups/services/2026-10-23/vm100_shared_appdata_2026-10-23.tar.zst` |

All seven moves returned successful `renamed` confirmations. Nine September 28 MediaCenter maintenance and diagnostic files moved from the PVE backup tree to `/mnt/core/backups/media/2026-09-28/pre/`. These are not fleet inventory JSON files.

These moves preserve historical recovery material. They do not prove that current backup jobs target the new folders, that the archives are off-host, or that restores work. The VM200 backup count is historical; VM200 was later reported destroyed and that archive has not been identified as the owner's separate older comprehensive backup.

## Fleet inventory output

The standard collector output root is the repository's `scripts/output/`, located at `/mnt/core/data/sync/github/server-stack/scripts/output/` in the PVE repository copy. The expected structure is:

```text
scripts/output/YYYY-MM-DD/pre/HOST_pre_YYYY-MM-DD_HH-MM-SS.json
scripts/output/YYYY-MM-DD/post/HOST_post_YYYY-MM-DD_HH-MM-SS.json
```

Collectors also support a `snapshot` phase. Hostname is in the filename; do not add a redundant hostname directory. The existing `.gitignore` excludes `scripts/output/`. This tree is synchronized through Syncthing according to the handoff, so treat the JSON as private operational data. Git exclusion and Syncthing replication are not backup or restore validation.

The migration initially confirmed 43 JSON files (about 1.5 MB) in the new output tree. The previous synchronized output had grown to about 55 GB after recovery archives were accidentally copied there. Redundant non-JSON backup copies were removed from that output location only; originals under `/mnt/core/backups/` were preserved. The previous 56-JSON output tree (about 45 MB) was moved to `/mnt/core/backups/inventory-quarantine-2026-11-25/`, then a new output tree was created and the 43 JSON inventories were migrated. These counts are checkpoints from the migration, not a verified final count.

Absolute inventory paths in older dated fleet reports record where files were captured at that time. The migration handoff does not provide a fully reconciled mapping from every old path to its present file, so those historical path strings should not be treated as confirmation that a given JSON is still at that path or was successfully copied into the new tree.

The quarantine comparison found 12 JSON records absent from the new output, including AtlasOS and LockBox captures and one incomplete AtlasOS capture. A command was prepared to copy complete date/phase-organized records, excluding the incomplete capture and nonstandard paths, but its execution was not confirmed. Filename matches may conceal different file contents because no checksum reconciliation was confirmed. Do not claim the remaining records were recovered or the quarantine removed.

Syncthing was resumed after the cleanup. AtlasOS was offline at that point and had an older copy; peer convergence and the current AtlasOS copy are unverified. Do not describe Syncthing as still paused.

## Collector behavior and verified limits

The checkpoint reported these existing script states; the scripts were inspected for current behavior but not changed as part of this documentation update:

- `scripts/collect_linux.sh` embeds version `2026-09-29.3`. Its default output is `scripts/output/YYYY-MM-DD/PHASE/HOST_PHASE_TIMESTAMP.json`; `--output-base` and `--output-file` can override it. Its JSON fields are checked before writing, but it writes directly to the final filename, not through an atomic temporary-file rename. Linux syntax and a PVE runtime capture were reported validated.
- `scripts/collect_update_baseline.sh` defaults to `scripts/output`, accepts `pre`, `post`, and `snapshot`, and invokes the Linux collector through `bash`. Its syntax and launch through a successful PVE collection were reported validated.
- `scripts/collect_windows.ps1` embeds version `2026-09-29.1`. Its default output follows the same date/phase/hostname/timestamp pattern; `-OutputBase` and `-Output` override the defaults. Laptop collection and winget parsing were reported validated; AtlasOS collection was not tested. JSON is written directly to the final path, with no atomic rename step.
- Windows HWiNFO command-line collection is blocked by a licensing dialog requiring HWiNFO64 Pro. The inspected script has no opt-in `-EnableHWiNFO` switch; it still attempts HWiNFO unless `-SkipHWiNFO` is supplied. It writes its temporary XML under the system temp directory, skips parsing when HWiNFO is skipped, and removes the temporary report it created. The handoff reports that JSON collection and temporary-file cleanup worked despite the HWiNFO timeout.
- Libre Hardware Monitor is not integrated. Its program and library were explored, but runtime sensor compatibility, permissions, and integration remain untested; exploration was intentionally paused.

The handoff reports an earlier PVE `/tmp` incident caused by an abandoned LXC creation process filling a 16 GB tmpfs. The process was terminated with user confirmation; `/tmp` then showed 16 GB available and 36 KB used. That incident was resolved and is not an inventory collector defect.

## Remaining work

- Reconcile the 12 quarantined records using content verification, not filenames alone; determine the final output count and whether the quarantine can be retired.
- Verify Syncthing peer convergence, including AtlasOS after it reconnects.
- Confirm current collection wrappers use the standard output root; collection scripts have defaults for Linux and Windows as described above.
- Verify whether backup jobs write to the new application-specific recovery directories.
- Keep recovery backup testing and inventory synchronization as separate tasks; no restore test was part of this filesystem cleanup.
