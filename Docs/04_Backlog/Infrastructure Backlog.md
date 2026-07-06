# Infrastructure Backlog

Status: Current
Last reviewed: 2026-07-06
Source docs:
- to-do list 17.05.26.md
- Server Plan 21.05.26.md
Next action: Harden backups and documentation while media ecosystem expansion continues.

## Active Blockers

- Consolidate operational documentation.
- Finalize dependency mapping between services.
- Revalidate Windows Wi-Fi DNS after material Windows, adapter, or Pi-hole changes.
- Verify `/mnt/core` permissions consistency.
- Audit UID/GID mappings.
- Document ownership standards.
- Configure and verify backup retention policies.
- Test full and partial restore workflows.

## Core Infrastructure

Completed:

- VPN-first philosophy established.
- WireGuard port forwarding completed at the router.
- WireGuard restored and operational with split tunneling.
- Windows desktop Wi-Fi configured to use Pi-hole (`192.168.0.120`) directly.
- Persistent vs bulk storage separation established.
- `/mnt/core` standardized as source of truth.
- Rebuild-order and disposable-container philosophy established.
- Pi-hole LXC deployed.
- WireGuard LXC deployed.
- Docker VM deployed.
- Home Assistant OS VM deployed.
- Homepage deployed.
- iSponsorBlockTV deployed.

In progress:

- Proxmox backup strategy for PVE configs.
- VM/LXC inventory documentation.
- Scheduled snapshots.
- Static IP and internal DNS naming conventions.
- Compose stack reorganization.
- Bind mount normalization.
- Environment variable handling.
- Compose deployment conventions.
- Update workflow documentation.

## Service Backlog

Infrastructure/security:

- Authelia
- Vaultwarden
- Restic integration
- SSL/certificate strategy documentation

Productivity/knowledge:

- Paperless-ngx
- AnythingLLM
- n8n
- Baserow
- Nextcloud

Utilities:

- RustDesk

Knowledge architecture:

- Establish Obsidian as the primary technical authoring environment.
- Keep GitHub as the canonical version-controlled documentation repository.
- Create inventory pages.
- Create rebuild procedures.
- Create troubleshooting docs.
- Create backup/recovery docs.

## Deferred

- Complete the Homepage administrative dashboard.
- Deploy Uptime Kuma, Grafana, and Prometheus.
- Disk alerts.
- SMART alerts.
- Backup failure alerts.
- New machine bootstrap procedure.
- Disaster recovery checklist.
