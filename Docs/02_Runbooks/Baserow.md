# Baserow

Status: Production cutover verified; operational hardening in progress
Last reviewed: 2026-11-25
Source docs:
- User-provided Baserow deployment summary, 2026-07-10
- Baserow PostgreSQL 16 to 17 migration handoff, 2026-11-24/25
- Homelab Documentation Update Handoff, 2026-07-25
- ADR 0009: Knowledge Ecosystem Roles
- ADR 0016: Docker Networking Strategy
- Nginx Proxy Manager.md
Next action: Establish scheduled PostgreSQL 17 backups with retention and a tested restore; remove the obsolete PostgreSQL 16 Compose service after validating the active project; then verify restart and VM100 reboot behavior.

## Purpose

Baserow is the primary platform for structured relational data within the homelab.

Examples:

- Homelab inventory.
- Theatre attendance database.
- Convention planning.
- Collections.
- Operational tracking.
- Custom databases.

Baserow is a foundational knowledge service rather than a miscellaneous utility. Use it when information is inherently relational or benefits from database structure rather than free-form documents.

## Deployment Location

Application VM: VM100 (`services`).
Database guest: CT104 per the migration handoff, unprivileged Debian 13 (`postgresql`, `192.168.0.139`); the numeric ID conflicts with an older VM104 assignment and needs current PVE verification.
Production PostgreSQL: 17.12, database `baserow`, role `baserow`, port `5432`.

Service definition:

```text
/mnt/core/services/knowledge/baserow/
```

Contains:

- `docker-compose.yml`.
- `.env`.

Baserow application media persists at `/mnt/core/appdata/knowledge/baserow/media` on PVE and is mounted into the application as `/baserow/data`. PostgreSQL 17 data persists on PVE at `/mnt/core/appdata/postgresql`, bind-mounted into CT104 at `/var/lib/postgresql/17/main`, per the migration handoff. VM100 continues to mount `/mnt/core` over NFSv4. The CT104 identifier conflicts with an older plan assigning VM104 to Home Assistant OS; confirm the guest IDs from current PVE inventory.

The old PostgreSQL 16 data remains at `/mnt/core/appdata/knowledge/baserow/postgres` as a historical recovery copy. It is not production and is not synchronized with PostgreSQL 17. Do not present it as a current standby or lossless rollback.

## Architecture

```text
Client
    |
Pi-hole
    |
Nginx Proxy Manager
    |
proxy Docker network
    |
Baserow
    |
PostgreSQL 17.12 (CT104)
```

## Docker Networking

Baserow joins the shared Docker `proxy` network.

Baserow connects over the private network to `192.168.0.139:5432`; PostgreSQL runs independently of the VM100 Compose project. The application password is supplied through `BASEROW_DB_PASSWORD` in the protected Compose `.env`; never copy secrets here. The reported PostgreSQL host authentication rule allows the `baserow` role from `192.168.0.0/24` with SCRAM. Narrowing it to the actual VM100 source address is a security follow-up.

This follows the Docker networking strategy:

- PostgreSQL is outside the Compose network and is reached over the private network; it is not exposed through the reverse proxy.
- User-facing services join the shared `proxy` network.
- Reverse proxy uses Docker DNS instead of host IPs whenever possible.

## DNS

Hostname:

```text
db.dustynest.com
```

Local resolution is provided through Pi-hole.

External HTTPS is handled through Nginx Proxy Manager.

## TLS

Baserow uses the existing wildcard Let's Encrypt certificate:

```text
*.dustynest.com
```

No dedicated certificate was issued.

## Reverse Proxy

Nginx Proxy Manager configuration:

- Domain: `db.dustynest.com`.
- HTTPS enabled.
- Wildcard certificate.
- Forward destination: Baserow container.
- Reverse proxy verified operational.

## Validation Performed

Deployment validation:

- PostgreSQL initialization.
- Baserow startup.
- HTTPS access.
- Administrator account creation.
- Workspace creation.
- Table creation.
- Data persistence after restart.

Persistence was confirmed by restarting the stack and verifying previously created data remained intact.

July 25 update validation:

- PostgreSQL dump created before update: `/mnt/core/backups/baserow/2026-07-25/baserow.dump`.
- Dump size: approximately 12 MB.
- Dump validation: `pg_restore --list` exited 0.
- Archive metadata: database `baserow`, custom format, PostgreSQL source version 16.14, pg_dump version 16.14, 19,757 TOC entries.
- Images were pulled and containers recreated only after backup validation.
- Final state: `baserow` healthy, restart count 0.
- Final state: `baserow-postgres` healthy, restart count 0.
- PostgreSQL recognized the existing database directory and skipped initialization.
- Baserow completed startup migrations/tasks and synchronized `157/157` templates.

## pgvector Note

Baserow attempted:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

The historical `postgres:16` image did not provide pgvector, so PostgreSQL logged:

```text
extension "vector" is not available
```

Baserow also reported assistant knowledge-base synchronization was skipped because `BASEROW_EMBEDDINGS_API_URL` was not configured and/or PostgreSQL did not provide pgvector.

The core Baserow deployment remained healthy. Treat pgvector as an optional missing capability and future architecture decision, not a current outage.

The production server is now PostgreSQL 17.12 on CT104. Whether to enable pgvector remains a separate future decision; plan and back up any extension/image change.

## PostgreSQL 17 Migration and Recovery State

The 2026-11-24/25 migration used a validated custom-format dump and media archive, restored production with `pg_restore --transaction-size=500`, and verified table counts, ownership, the required Baserow migration, application access, and a table creation while the old PostgreSQL 16 container was stopped. See the [full migration record](../06_Operations/Incidents/2026-11-24-baserow-postgresql-migration.md) for commands and evidence.

Still pending:

- Establish scheduled PostgreSQL 17 dumps on persistent `/mnt/core` storage, archive validation, retention, and an independent copy where available.
- Perform a temporary restore test against the new backup procedure.
- Remove the obsolete PostgreSQL 16 service from Compose and validate the project configuration without restarting it inadvertently.
- Verify Baserow survives Docker restart and VM100 reboot while CT104 is available.
- Review whether PostgreSQL network access can be narrowed from the full private subnet to VM100.

The November 25 cutover dump and media archive remain essential recovery material until the new backup path is established and tested.

## Operational Standard Established

This deployment establishes the standard pattern for future platform services:

1. Create `/mnt/core/services/...`.
2. Create `/mnt/core/appdata/...`.
3. Use bind mounts exclusively.
4. Join the shared `proxy` network.
5. Add the Pi-hole local DNS record.
6. Publish through Nginx Proxy Manager.
7. Use the wildcard `*.dustynest.com` certificate.
8. Validate persistence before production use.

Reuse this workflow for future deployments such as Paperless-ngx, Nextcloud, Homepage, Vaultwarden, and AnythingLLM.

## Workspace Strategy

### Admin Workspace

Purpose: operational management of the homelab itself.

This workspace is part of the infrastructure.

Ownership:

- Owned by the Administrator account.
- Personal account invited as an editor or another appropriate role.
- Other users generally should not have access.

Example databases:

- Infrastructure Inventory: Physical Devices, Virtual Machines, LXCs, Docker Hosts, Network Equipment, Storage Devices, and UPS.
- Service Registry: Services, URLs, Reverse Proxy Hosts, DNS Records, Ports, and Docker Networks.
- Backup Management: Backup Jobs, Restore Tests, Snapshot Schedule, and Retention Policies.
- Architecture: ADR Index, Service Dependencies, Planned Services, and Decommissioned Services.
- SSL / Domains: Certificates, Subdomains, and Wildcard Usage.
- Credentials Inventory: Credential Name, Stored In, Rotation Date, and Notes.

Do not store passwords in Baserow. Passwords remain in Vaultwarden.

### Personal Workspace

Purpose: day-to-day personal data and planning.

Examples:

- Theatre attendance.
- Convention planning.
- Personal inventories.
- Collections.
- Media tracking.
- Project management.
- Reading lists.
- Writing projects.

This workspace is independent of server administration.

### Future Shared Workspaces

Future collaboration workspaces may include:

- DustyNest Operations.
- OVFF.
- Household.
- Research.
- Volunteer Projects.

Each shared workspace should have its own permissions.

## Canonical Role

| Service | Canonical Responsibility |
| --- | --- |
| GitHub documentation | Infrastructure documentation, ADRs, runbooks |
| Obsidian | Personal knowledge, notes, writing |
| Baserow | Structured relational data |
| Paperless-ngx | Long-term document archive |
| Nextcloud | User-facing file storage and synchronization |
| AnythingLLM | AI interface over selected knowledge sources |

## Future Work

Immediate tasks:

- Create a personal non-administrator account for day-to-day use.
- Organize workspaces and permissions.
- Migrate relevant databases from the hosted Baserow instance.
- Begin populating core operational databases, such as homelab inventory, theatre attendance, and convention planning.

Longer-term enhancements:

- Integrate with n8n for automation.
- Add routine PostgreSQL dumps to the backup workflow.
- Configure Authelia protection if and when single sign-on is adopted.
