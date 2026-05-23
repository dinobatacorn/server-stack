# Ops Vault Start Here

Status: Current
Last reviewed: 2026-05-23
Source docs:
- Server Plan 21.05.26.md
- Media Stack Stabilization 23.05.26.md
- to-do list 17.05.26.md
- Archive_Plan 05.05.26.txt
Next action: Use the media stabilization runbook as the active gate before expanding the stack.

## Purpose

This vault is the operational memory for the homelab and media ecosystem. It should answer four questions quickly:

- What exists?
- What depends on what?
- What is safe to change next?
- What must be backed up before changes?

## Where To Begin

- Architecture overview: [Homelab Overview](01_Architecture/Homelab%20Overview.md)
- Storage rules: [Storage Contracts](01_Architecture/Storage%20Contracts.md)
- Service relationships: [Service Map](01_Architecture/Service%20Map.md)
- VPN validation: [VPN External Access Validation](02_Runbooks/VPN%20External%20Access%20Validation.md)
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

The immediate work is VPN validation, because the WireGuard port has been forwarded and should now be externally reachable. Prove remote access first, then resume media-node stabilization.

1. Validate WireGuard from outside the LAN using [VPN External Access Validation](02_Runbooks/VPN%20External%20Access%20Validation.md).
2. Document the forwarded UDP port, router target, WireGuard LXC IP, tunnel subnet, and tested client.
3. Fix only VPN-related blockers needed for reliable remote access.
4. Once VPN access passes, create a dated media-node checkpoint under `/mnt/core/exports/media-stabilization/`.
5. Resume media stabilization: reboot/mount validation, UID/GID audit, controlled acquisition/import/playback tests, and restore proof.

## Archive Policy

Raw source files are preserved under `_archive/raw-2026-05/`. Do not edit archived files. Extract enduring facts into canonical Markdown docs, then leave raw exports as evidence.
