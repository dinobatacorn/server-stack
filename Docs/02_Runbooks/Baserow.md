# Baserow

Status: Completed and operational
Last reviewed: 2026-07-25
Source docs:
- User-provided Baserow deployment summary, 2026-07-10
- Homelab Documentation Update Handoff, 2026-07-25
- ADR 0009: Knowledge Ecosystem Roles
- ADR 0016: Docker Networking Strategy
- Nginx Proxy Manager.md
Next action: Create a personal non-administrator account, organize workspaces and permissions, then decide whether pgvector support is needed.

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

VM: VM100, Platform Services.

Service definition:

```text
/mnt/core/services/knowledge/baserow/
```

Contains:

- `docker-compose.yml`.
- `.env`.

Persistent data:

```text
/mnt/core/appdata/knowledge/baserow/
```

Contains:

```text
postgres/
media/
redis/   reserved if used later
```

Application state resides under `/mnt/core`. No Docker named volumes are used.

Bind mounts:

```text
/mnt/core/appdata/knowledge/baserow/media    -> /baserow/data
/mnt/core/appdata/knowledge/baserow/postgres -> /var/lib/postgresql/data
```

Current images:

```text
baserow/baserow:latest
postgres:16
```

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
PostgreSQL
```

## Docker Networking

Baserow joins the shared Docker `proxy` network.

The internal PostgreSQL connection remains on the Compose-managed network.

This follows the Docker networking strategy:

- Internal service communication remains isolated.
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

The current `postgres:16` image does not provide pgvector, so PostgreSQL logged:

```text
extension "vector" is not available
```

Baserow also reported assistant knowledge-base synchronization was skipped because `BASEROW_EMBEDDINGS_API_URL` was not configured and/or PostgreSQL did not provide pgvector.

The core Baserow deployment remained healthy. Treat pgvector as an optional missing capability and future architecture decision, not a current outage.

Do not change the PostgreSQL image merely to eliminate the warning without first planning and backing up the database migration.

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
