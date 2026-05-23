# Infrastructure Backlog

Status: Current
Last reviewed: 2026-05-23
Source docs:
- to-do list 17.05.26.md
- Server Plan 21.05.26.md
Next action: Finish documentation consolidation and dependency mapping before broad service expansion.

## Active Blockers

- Validate WireGuard external access after router port forwarding.
- Document the forwarded VPN UDP port, router target, WireGuard LXC IP, endpoint, and tested client.
- Consolidate operational documentation.
- Finalize dependency mapping between services.
- Verify DNS reliability across reboots.
- Verify VPN remote access workflows.
- Verify `/mnt/core` permissions consistency.
- Audit UID/GID mappings.
- Document ownership standards.
- Configure and verify backup retention policies.
- Test full and partial restore workflows.

## Core Infrastructure

Completed:

- VPN-first philosophy established.
- WireGuard port forwarding completed at the router.
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

- Decide long-term wiki/knowledge platform.
- Create operational documentation vault.
- Create inventory pages.
- Create rebuild procedures.
- Create troubleshooting docs.
- Create backup/recovery docs.

## Deferred

- Monitoring/dashboard stack.
- Disk alerts.
- SMART alerts.
- Backup failure alerts.
- New machine bootstrap procedure.
- Disaster recovery checklist.
