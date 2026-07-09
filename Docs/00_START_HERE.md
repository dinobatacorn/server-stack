# Ops Vault Start Here

Status: Current
Last reviewed: 2026-07-09
Source docs:
- Server Plan 21.05.26.md
- Media Stack Stabilization 23.05.26.md
- to-do list 17.05.26.md
- Archive_Plan 05.05.26.txt
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
Next action: Normalize the main-node service layout while expanding the proven media core with music and reading services.

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
- Main node facts: [Main Node Inventory](03_Inventories/Main%20Node%20Inventory.md)
- Media host facts: [Media Node Inventory](03_Inventories/Media%20Node%20Inventory.md)
- Active work list: [Infrastructure Backlog](04_Backlog/Infrastructure%20Backlog.md) and [Media Backlog](04_Backlog/Media%20Backlog.md)
- Long-term decisions: [Architecture Decisions](05_Decisions/Architecture%20Decisions.md)
- Architecture Decision Records: [ADR Index](05_Decisions/ADR/README.md)

## Operating Doctrine

- Persistent data is sacred.
- Containers are disposable.
- Prefer rebuildability over patching.
- Prefer VPN-first and internal-first access.
- Treat VM100 and the media node as separate application domains, not competing replacements.
- Do not add services while base storage, backups, imports, and playback are unstable.
- Documentation is infrastructure.
- Capture architecture-changing decisions as ADRs with context, consequences, and alternatives.

## Current Priority

The foundation, WireGuard, VM100 core services platform, and core media request-to-playback pipeline are operational. The project is now in the ecosystem-expansion phase.

1. Normalize VM100 service definitions from legacy `/mnt/core/stacks` into `/mnt/core/services`.
2. Keep persistent application state under `/mnt/core/appdata`.
3. Deploy Lidarr and Bazarr on the media node.
4. Deploy Readarr, Audiobookshelf, and Kavita on the media node.
5. Integrate SoulSync, then polish Kodi.
6. Import and normalize the external media drive.
7. Automate backups and build the Homepage dashboard.

## Archive Policy

Raw source files are preserved under `_archive/raw-2026-05/`. Do not edit archived files. Extract enduring facts into canonical Markdown docs, then leave raw exports as evidence.
