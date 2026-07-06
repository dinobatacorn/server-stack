# Ops Vault Start Here

Status: Current
Last reviewed: 2026-07-06
Source docs:
- Server Plan 21.05.26.md
- Media Stack Stabilization 23.05.26.md
- to-do list 17.05.26.md
- Archive_Plan 05.05.26.txt
Next action: Expand the proven media core with music and reading services.

## Purpose

This vault is the operational memory for the homelab and media ecosystem. It should answer four questions quickly:

- What exists?
- What depends on what?
- What is safe to change next?
- What must be backed up before changes?

## Where To Begin

- Current state: [Homelab Status](00_STATUS.md)
- Architecture overview: [Homelab Overview](01_Architecture/Homelab%20Overview.md)
- Storage rules: [Storage Contracts](01_Architecture/Storage%20Contracts.md)
- Service relationships: [Service Map](01_Architecture/Service%20Map.md)
- VPN validation: [VPN External Access Validation](02_Runbooks/VPN%20External%20Access%20Validation.md)
- Windows desktop DNS: [Windows Desktop DNS](02_Runbooks/Windows%20Desktop%20DNS.md)
- Current media gate: [Media Stack Stabilization](02_Runbooks/Media%20Stack%20Stabilization.md)
- Media host facts: [Media Node Inventory](03_Inventories/Media%20Node%20Inventory.md)
- Active work list: [Infrastructure Backlog](04_Backlog/Infrastructure%20Backlog.md) and [Media Backlog](04_Backlog/Media%20Backlog.md)
- Long-term decisions: [Architecture Decisions](05_Decisions/Architecture%20Decisions.md)

## Operating Doctrine

- Persistent data is sacred.
- Containers are disposable.
- Prefer rebuildability over patching.
- Prefer VPN-first and internal-first access.
- Do not add services while base storage, backups, imports, and playback are unstable.
- Documentation is infrastructure.

## Current Priority

The foundation, WireGuard, and core media request-to-playback pipeline are operational. The project is now in the ecosystem-expansion phase.

1. Deploy Lidarr and Bazarr.
2. Deploy Readarr, Audiobookshelf, and Kavita.
3. Integrate SoulSync, then polish Kodi.
4. Import and normalize the external media drive.
5. Automate backups and build the Homepage dashboard.

## Archive Policy

Raw source files are preserved under `_archive/raw-2026-05/`. Do not edit archived files. Extract enduring facts into canonical Markdown docs, then leave raw exports as evidence.
