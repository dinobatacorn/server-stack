# Baserow PostgreSQL 16 to 17 Migration

**Date:** 2026-11-24 to 2026-11-25  
**Status:** Production cutover verified; backup hardening and legacy cleanup pending  
**Scope:** Documentation record from the owner-provided migration handoff.

## Topology change

Baserow remains a Docker application on VM100 (`services`, `192.168.0.125`). Its PostgreSQL database moved from the Compose-managed PostgreSQL 16 container to PostgreSQL 17.12 in unprivileged Debian 13 Proxmox LXC 104 (`postgresql`, `192.168.0.139`, TCP 5432). Production database and role are both `baserow`.

PVE stores PostgreSQL files at `/mnt/core/appdata/postgresql`, bind-mounted into CT104 as `/var/lib/postgresql/17/main`. The ownership mapping was verified as UID/GID `988:988` inside CT104 to `100988:100988` on PVE; LXC protection was restored after configuration. Baserow application media remains at `/mnt/core/appdata/knowledge/baserow/media`. VM100 mounts `/mnt/core` from PVE over NFSv4.

Baserow uses `192.168.0.139:5432` and `BASEROW_DB_PASSWORD` in the protected VM100 `.env`. No secret values belong in this repository. The reported PostgreSQL HBA rule permits role `baserow` from `192.168.0.0/24` using SCRAM. Review narrowing the source to VM100 after confirming connection routing. Adminer 5.2.1 is available at `http://192.168.0.139/adminer`.

## Migration evidence

- Initial PostgreSQL 16 custom-format dump was restored to `baserow_migration_test`. The first single-transaction restore failed from lock-tracking shared memory pressure; `pg_restore --no-owner --no-acl --exit-on-error --transaction-size=500` succeeded.
- The test restore held 2,386 public tables and 906 Baserow logical tables; aggregate row counts matched the source at verification time.
- Baserow image update applied migration `baserow_premium.0033_aggregation_group_by_mode` to production after that initial dump, so that older dump was not used for cutover.
- Baserow was stopped for final backups. `/mnt/core/backups/baserow/2026-11-25/baserow-cutover.dump` passed `pg_restore --list`; `/mnt/core/backups/baserow/2026-11-25/baserow-media-cutover.tar.gz` passed `tar -tzf`.
- Final restore to an empty production database returned exit code 0 using `pg_restore --no-owner --no-acl --role=baserow --exit-on-error --transaction-size=500`.
- Production verification found 2,386 public tables, 906 Baserow logical tables, all public tables owned by `baserow`, and the required premium migration present.
- Baserow website loaded. With PostgreSQL 16 stopped, the user created a new table and verified it in a private browser window. This functionally demonstrated independence from the old database. No active-traffic PostgreSQL connection snapshot was captured.

## Recovery and pending work

The old PostgreSQL 16 data at `/mnt/core/appdata/knowledge/baserow/postgres` is a preserved historical snapshot, not a synchronized standby. Writes after cutover exist only on PostgreSQL 17; restarting PostgreSQL 16 is not a lossless rollback. Retain the old data, validated cutover dump and media archive, and at least one pre-migration config backup until PostgreSQL 17 has its own tested backup process.

Pending: establish scheduled PostgreSQL 17 dumps on persistent `/mnt/core`, validate each archive, define retention, arrange an independent copy where available, test a temporary restore, remove the obsolete PostgreSQL 16 Compose service after validating the project, and verify Baserow through Docker restart and VM100 reboot while CT104 is available. Remove temporary migration artifacts only after final inspection and recovery needs review.

## Related documentation

- [Baserow runbook](../../02_Runbooks/Baserow.md)
- [Backup and Restore](../../02_Runbooks/Backup%20and%20Restore.md)
- [Service Map](../../01_Architecture/Service%20Map.md)
- [Main Node Inventory](../../03_Inventories/Main%20Node%20Inventory.md)
