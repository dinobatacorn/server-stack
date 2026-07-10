# ADR 0009: Knowledge Ecosystem Roles

Status: Accepted
Date: 2026-07-09

## Context

AFFiNE, Obsidian, Nextcloud, Paperless, Baserow, AnythingLLM, and n8n overlap unless each has a clear responsibility.

## Decision

Assign one primary role to each knowledge-platform service:

- Obsidian: personal thinking, notes, and long-form writing.
- GitHub documentation: canonical infrastructure docs, ADRs, runbooks, and recovery docs.
- Paperless-ngx: document archive, OCR, and retrieval.
- Baserow: structured relational information such as theatre, convention scheduling, inventories, collections, and operational databases.
- AnythingLLM: AI interface to selected knowledge sources.
- Nextcloud: user files, mobile access, sharing, WebDAV, collaboration, photo uploads, and user-facing file browsing.
- n8n: automation glue.

## Consequences

The knowledge stack becomes a set of cooperating tools instead of competing places to put the same thing.

Baserow separates operational metadata from user data:

- The Admin Workspace answers how the homelab works.
- The Personal Workspace answers what the homelab is being used to do.

## Baserow Workspace Strategy

### Admin Workspace

Purpose: operational management of the homelab itself.

The Admin Workspace is effectively part of the infrastructure.

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

Passwords themselves remain in Vaultwarden.

### Personal Workspace

Purpose: day-to-day personal data and planning.

Examples include theatre attendance, convention planning, personal inventories, collections, media tracking, project management, reading lists, and writing projects.

This workspace is independent of server administration.

### Future Shared Workspaces

Future shared workspaces may include DustyNest Operations, OVFF, Household, Research, and Volunteer Projects.

Each shared workspace should have its own permissions.

## Alternatives Considered

- Use one monolithic knowledge app. Rejected because the use cases are meaningfully different.
- Treat Baserow as a miscellaneous utility. Rejected because structured data is becoming foundational.
