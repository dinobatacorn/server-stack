# Infrastructure Backlog

Status: Current
Last reviewed: 2026-07-10
Source docs:
- to-do list 17.05.26.md
- Server Plan 21.05.26.md
- pve-output_09072026.txt
- vm100-output_09072026.txt
- User-provided Baserow deployment summary, 2026-07-10
Next action: Organize Baserow workspaces and permissions, then harden backups and documentation while media ecosystem expansion continues.

## Active Blockers

- Consolidate operational documentation.
- Finalize dependency mapping between services.
- Revalidate Windows Wi-Fi DNS after material Windows, adapter, or Pi-hole changes.
- Verify `/mnt/core` permissions consistency.
- Retire legacy VM100 `/mnt/core/stacks` definitions into `/mnt/core/services`.
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
- VM100 currently running Nginx Proxy Manager, Syncthing, and iSponsorBlockTV.
- Home Assistant OS VM deployed.
- iSponsorBlockTV deployed.
- Nginx Proxy Manager deployed.
- SSL/certificate strategy documented.
- Syncthing deployed.
- Baserow deployed on VM100 with PostgreSQL, bind-mounted persistence, reverse proxy, wildcard TLS, and restart persistence validation.

In progress:

- Proxmox backup strategy for PVE configs.
- VM/LXC inventory documentation.
- Scheduled snapshots.
- Static IP and internal DNS naming conventions.
- Compose stack reorganization.
- Homepage deployment or redeployment.
- Bind mount normalization.
- Environment variable handling.
- Compose deployment conventions.
- Update workflow documentation.

## Service Backlog

Infrastructure/security:

- Homepage
- Authelia
- Vaultwarden
- CrowdSec, if later justified
- Restic integration

Productivity/knowledge:

- Paperless-ngx
- AnythingLLM
- n8n
- Nextcloud

Baserow follow-up:

- Create a personal non-administrator account.
- Organize workspaces and permissions.
- Migrate relevant databases from the hosted Baserow instance.
- Add routine PostgreSQL dumps to the backup workflow.

Utilities:

- RustDesk
- Confirm whether Syncthing belongs permanently on VM100 or should also exist on selected clients.

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
