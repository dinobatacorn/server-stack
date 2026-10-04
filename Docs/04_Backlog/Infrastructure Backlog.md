# Infrastructure Backlog

Status: Current
Last reviewed: 2026-09-29
Source docs:
- to-do list 17.05.26.md
- Server Plan 21.05.26.md
- pve-output_09072026.txt
- vm100-output_09072026.txt
- User-provided Baserow deployment summary, 2026-07-10
- Syncthing Recovery and Architecture Update, 2026-07-25
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
- Fleet Update Reports, 2026-09-28 through 2026-09-30
Next action: Verify RustDesk LXC 103's router reservation and VPN route; define per-host prerequisites for guarded maintenance automation.

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
- Verify the DHCP reservation and WireGuard route for RustDesk LXC 103; the owner reports successful client sessions.
- Configure and verify LAN DNS for the Windows desktop; VPN currently restores proxy-hostname resolution when the VPN is on.
- Review MediaCenter root storage before any further Docker image pull; the owner reports the Jellyfin library scan completed successfully.
- Capture AtlasOS post-update inventory when ready, leaving Sunshine's current configuration unchanged; record Nobara transaction/reboot uncertainty and inspect LockBox `mirrorlist.pacnew`.
- Verify the contents/date and restoreability of the older VM200 backup if recovery is needed; VM200 was reported destroyed on 2026-09-30.

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
- PVE, Pi-hole, WireGuard, VM100, and MediaCenter maintenance/update passes recorded for 2026-09-28/29; PVE config archive, guest backups, database/appdata archives, and post inventories are detailed in the fleet reports.
- RustDesk Server deployed in unprivileged PVE LXC 103 with persistent server/API appdata under `/mnt/core/appdata/security`; API UI login confirmed. No WAN port forwards were added.
- LockBox post inventory recorded after the Garuda update sequence; Nobara pre/post maintenance records captured. AtlasOS remains pending reboot and post verification.
- Linux inventory collector now handles DNF `check-update` exit 100 and Pacman `checkupdates` exit 2 while preserving pending output and surfacing other errors.

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

- RustDesk server is deployed in PVE LXC 103. The owner reports pointing clients to it during maintenance and multiple successful sessions, including a recent phone-to-desktop test.
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
- A separate PVE game-services VM for Archipelago/Minecraft/Palworld. See [Game Services VM Plan](../01_Architecture/Game%20Services%20VM%20Plan.md). This is conceptual only; no VM has been created, router forwarding has not been approved, and any no-VPN ingress would require an explicit policy exception to ADR 0002.
