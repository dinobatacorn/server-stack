# Infrastructure Backlog

Status: Current
Last reviewed: 2026-07-25
Source docs:
- to-do list 17.05.26.md
- Server Plan 21.05.26.md
- pve-output_09072026.txt
- vm100-output_09072026.txt
- User-provided Baserow deployment summary, 2026-07-10
- Syncthing Recovery and Architecture Update, 2026-07-25
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
Next action: Remove obsolete Syncthing folder, retain validated recovery material, and plan guarded maintenance automation.

## Active Blockers

- Consolidate operational documentation.
- Finalize dependency mapping between services.
- Revalidate Windows Wi-Fi DNS after material Windows, adapter, or Pi-hole changes.
- Verify `/mnt/core` permissions consistency.
- Retire legacy VM100 `/mnt/core/stacks` definitions into `/mnt/core/services`.
- Observe Syncthing recovery for several days and verify peer synchronization before cleanup.
- Retain `/var/backups/syncthing-rescue/overlay-direct` and old OverlayFS evidence until the Syncthing recovery is confirmed stable.
- Retain `/var/backups/mediacenter/core-ghost-2026-07-25.tar.gz` until MediaCenter rollback requirements have passed.
- Retain `/mnt/core/backups/baserow/2026-07-25/baserow.dump` according to backup-retention policy.
- Remove obsolete `SirBranteSaves` from Syncthing configuration.
- Audit UID/GID mappings, including Syncthing's current `PUID=0`/`PGID=0` and NPM's UID/GID 0 deployment.
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
- Syncthing recovered on 2026-07-25 after container-path misconfiguration; data was restored to `/mnt/core/data/sync`, checksum-verified, and reconfigured to `/sync/...` container paths.
- Baserow deployed on VM100 with PostgreSQL, bind-mounted persistence, reverse proxy, wildcard TLS, and restart persistence validation.
- VM100 containers updated on 2026-07-25; `syncthing`, `baserow`, `baserow-postgres`, `npm`, and `isponsorblocktv` were running with restart count 0.
- MediaCenter `/mnt/core` ghost tree repaired and media stack restored with zero restart counts.

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
- Guarded n8n maintenance automation design.

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
- Decide whether to use PostgreSQL with pgvector support for optional assistant/embedding functionality.

Utilities:

- RustDesk
- Keep the canonical Syncthing deployment on VM100 `services`; selected clients remain Syncthing peers, not alternate server deployments.
- Migrate Syncthing from root `PUID=0` / `PGID=0` to an unprivileged UID/GID after recovery stability is confirmed.

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
- Docker image pruning from the July 25 update window until rollback requirements have passed.
- Vaultwarden redeployment until its relative `./data:/data` persistence is reviewed and normalized.
