# Ops Vault Start Here

Status: Current
Last reviewed: 2026-07-25
Canonical entrypoint: this file

Source docs:
- Server Plan 21.05.26.md
- Media Stack Stabilization 23.05.26.md
- to-do list 17.05.26.md
- Archive_Plan 05.05.26.txt
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
- Syncthing Recovery and Architecture Update, 2026-07-25
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25

Next action: Remove obsolete Syncthing `SirBranteSaves`, verify MediaCenter display-blanking persistence, and continue planned service normalization/automation work.

## Purpose

This vault is the operational memory for the homelab and media ecosystem. It should answer four questions quickly:

- What exists?
- What depends on what?
- What is safe to change next?
- What must be backed up before changes?

## Where To Begin

- Current state: [Homelab Status](Docs/00_STATUS.md)
- Architecture overview: [Homelab Overview](Docs/01_Architecture/Homelab%20Overview.md)
- Storage rules: [Storage Contracts](Docs/01_Architecture/Storage%20Contracts.md)
- Service relationships: [Service Map](Docs/01_Architecture/Service%20Map.md)
- IP, port, and proxy assignments: [IP, Port, And Proxy Assignments](Docs/01_Architecture/IP%20Port%20Proxy%20Assignments.md)
- Reverse proxy standard: [Nginx Proxy Manager](Docs/02_Runbooks/Nginx%20Proxy%20Manager.md)
- Baserow deployment: [Baserow](Docs/02_Runbooks/Baserow.md)
- Syncthing deployment and recovery: [Syncthing](Docs/02_Runbooks/Syncthing.md)
- MediaCenter maintenance: [MediaCenter Maintenance](Docs/02_Runbooks/MediaCenter%20Maintenance.md)
- Docker and Compose safety: [Docker Compose Operations](Docs/02_Runbooks/Docker%20Compose%20Operations.md)
- VPN validation: [VPN External Access Validation](Docs/02_Runbooks/VPN%20External%20Access%20Validation.md)
- Windows desktop DNS: [Windows Desktop DNS](Docs/02_Runbooks/Windows%20Desktop%20DNS.md)
- Current media gate: [Media Stack Stabilization](Docs/02_Runbooks/Media%20Stack%20Stabilization.md)
- Main node facts: [Main Node Inventory](Docs/03_Inventories/Main%20Node%20Inventory.md)
- Media host facts: [Media Node Inventory](Docs/03_Inventories/Media%20Node%20Inventory.md)
- Active work list: [Infrastructure Backlog](Docs/04_Backlog/Infrastructure%20Backlog.md) and [Media Backlog](Docs/04_Backlog/Media%20Backlog.md)
- Long-term decisions: [Architecture Decisions](Docs/05_Decisions/Architecture%20Decisions.md)
- Architecture Decision Records: [ADR Index](Docs/05_Decisions/ADR/README.md)

## Operating Doctrine

- Persistent data is sacred.
- Containers are disposable.
- Prefer rebuildability over patching.
- Prefer VPN-first and internal-first access.
- Use Nginx Proxy Manager with the shared `proxy` Docker network and wildcard `*.dustynest.com` certificate for user-facing services.
- Treat VM100 and the media node as separate application domains, not competing replacements.
- Do not add services while base storage, backups, imports, and playback are unstable.
- Documentation is infrastructure.
- Capture architecture-changing decisions as ADRs with context, consequences, and alternatives.

## Current Priority

The foundation, WireGuard, VM100 core services platform, Syncthing recovery, and MediaCenter media stack are operational after the 2026-07-25 maintenance work. The project is now in the stabilization-to-expansion phase.

1. Observe the repaired Syncthing deployment and verify peer synchronization remains healthy.
2. Remove obsolete Syncthing `SirBranteSaves`.
3. Verify MediaCenter X11 screensaver/DPMS disablement survives logout and reboot.
4. Keep the validated Syncthing rescue and Baserow dump until retention/rollback requirements are met.
5. Normalize VM100 service definitions from legacy `/mnt/core/stacks` into `/mnt/core/services`.
6. Keep persistent application state under `/mnt/core/appdata`.
7. Plan UID/GID migrations for Syncthing and Nginx Proxy Manager instead of changing them casually.
8. Decide whether Baserow should use PostgreSQL with pgvector support.
9. Review dormant Vaultwarden before any future deployment.
10. Build guarded n8n maintenance/update automation.

## Archive Policy

Raw source files are preserved under `Docs/_archive/raw-2026-05/`. Do not edit archived files. Extract enduring facts into canonical Markdown docs, then leave raw exports as evidence.
