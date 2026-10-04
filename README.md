# Ops Vault Start Here

Status: Current
Last reviewed: 2026-09-30
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
- Fleet Update Reports, 2026-09-28 through 2026-09-30

Next action: Capture AtlasOS post-update inventory when ready; confirm RustDesk LXC 103's router reservation and VPN route; use the staged fleet runbook to prepare future update automation.

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
- LockBox maintenance: [LockBox Maintenance](Docs/02_Runbooks/LockBox%20Maintenance.md)
- Nobara maintenance: [Nobara Maintenance](Docs/02_Runbooks/Nobara%20Maintenance.md)
- RustDesk server maintenance: [RustDesk Server Maintenance](Docs/02_Runbooks/RustDesk%20Server%20Maintenance.md)
- Docker and Compose safety: [Docker Compose Operations](Docs/02_Runbooks/Docker%20Compose%20Operations.md)
- VPN validation: [VPN External Access Validation](Docs/02_Runbooks/VPN%20External%20Access%20Validation.md)
- Windows desktop DNS: [Windows Desktop DNS](Docs/02_Runbooks/Windows%20Desktop%20DNS.md)
- Current media gate: [Media Stack Stabilization](Docs/02_Runbooks/Media%20Stack%20Stabilization.md)
- Main node facts: [Main Node Inventory](Docs/03_Inventories/Main%20Node%20Inventory.md)
- Media host facts: [Media Node Inventory](Docs/03_Inventories/Media%20Node%20Inventory.md)
- Active work list: [Infrastructure Backlog](Docs/04_Backlog/Infrastructure%20Backlog.md) and [Media Backlog](Docs/04_Backlog/Media%20Backlog.md)
- Codex/SSH setup: [Codex And SSH Setup](Docs/06_Operations/Codex%20And%20SSH%20Setup.md)
- Fleet update runbook: [Fleet Update Runbook](Docs/06_Operations/Fleet%20Update%20Runbook.md)
- Reachability inventory: [Reachability Inventory](Docs/06_Operations/Reachability%20Inventory.md)
- Current update report: [Fleet Update Report 2026-09-30](Docs/06_Operations/Update%20Reports/2026-09-30.md)
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

PVE, its guests, the VM100 and MediaCenter workloads, and RustDesk Server LXC 103 were maintained and recorded across 2026-09-28 through 2026-09-30. LockBox's Garuda update is reflected in a post inventory; Nobara has pre/post inventories; AtlasOS post-update inventory remains pending. The owner reports leaving Sunshine's current driver configuration in place, pointing RustDesk clients at the self-hosted server during maintenance, and completing Jellyfin's scan successfully. See the dated fleet reports before using older inventory exports.

1. Capture AtlasOS post-update inventory when the owner is ready; leave Sunshine's current driver configuration unchanged.
2. Confirm the DHCP reservation and VPN route for RustDesk LXC 103; successful client sessions are reported.
4. Resolve VM200's stale CD-ROM APT source and verify partner Affine use before any update or service change.
5. Record update evidence for LockBox and Nobara in the 2026-09-29 report; keep raw device captures private and ignored.
6. Normalize VM100 definitions from `/mnt/core/stacks` into `/mnt/core/services`; preserve app state under `/mnt/core/appdata`.
7. Continue backup/restore validation, UID/GID work, dormant Vaultwarden review, and guarded maintenance automation planning.
8. Conceptualize a separate PVE game-services VM for Archipelago/Minecraft/Palworld; see [Game Services VM Plan](Docs/01_Architecture/Game%20Services%20VM%20Plan.md). No VM or public game-service ingress is approved or deployed. Any no-VPN access would be an explicit exception to the current LAN/WireGuard-only policy.

## Archive Policy

Raw source files are preserved under `Docs/_archive/raw-2026-05/`. Do not edit archived files. Extract enduring facts into canonical Markdown docs, then leave raw exports as evidence.
