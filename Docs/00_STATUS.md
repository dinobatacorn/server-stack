# Homelab Status

Status: Current
Last reviewed: 2026-10-04
Source docs:
- Current State of the Homelab (July 2026)
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
- User-provided Baserow deployment summary, 2026-07-10
- Syncthing Recovery and Architecture Update, 2026-07-25
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
- Fleet Update Reports, 2026-09-28 through 2026-09-30
- MediaCenter maintenance record, 2026-10-04
- Canonical architecture, runbook, inventory, and backlog documents in this repository
Next action: Capture AtlasOS post-update inventory when ready; confirm RustDesk LXC 103's router reservation and VPN route; continue guarded fleet-automation planning; rotate the exposed MediaCenter WireGuard private key with peer configuration coordinated; investigate the extra `192.168.0.0/24` AllowedIPs entry separately.

## How To Read This Status

- **Settled architecture** describes design decisions and intended structure.
- **Deployed state** records what is actually running and verified now.
- **Next milestones** lists work that has not yet been completed.

## 2026-09-29 Maintenance State

The dated [2026-09-28 fleet report](06_Operations/Update%20Reports/2026-09-28.md) records PVE, Pi-hole, WireGuard, VM100, MediaCenter, and RustDesk LXC 103 maintenance. The [2026-09-29 report](06_Operations/Update%20Reports/2026-09-29.md) records endpoint checks and remaining gaps.

- **PVE:** Updated and reboot-validated on 2026-09-28. On 2026-09-29, a PVE host/config snapshot and a fresh VM100 backup were validated. Guest backup scheduling/retention remains undefined.
- **RustDesk Server:** Runs in unprivileged Debian LXC 103 at `192.168.0.189`; `hbbs`, `hbbr`, and API/UI were active, and the user confirmed API login. A Cloudflare DNS-only A record to the RFC1918 address was shown in a user screenshot. No WAN forwards were added. The owner reports pointing clients to the server during maintenance and multiple successful sessions, most recently phone-to-desktop after connecting the phone to the network. The specific LAN or WireGuard path is unstated; router DHCP reservation and VPN route remain unverified. See [RustDesk Server Maintenance](02_Runbooks/RustDesk%20Server%20Maintenance.md).
- **VM100:** Debian and Docker platform packages updated; active Compose projects were pulled/recreated and checked. NPM was verified at `2.16.0`; all five containers were running and Baserow/PostgreSQL were healthy.
- **MediaCenter:** Debian updated and rebooted to `6.12.107+deb13-amd64`. Six media containers were refreshed, app-data archive validated, and all six local web-port checks passed after restart. Root is at 95% use with about 11 GB available; do not pull more images until storage is reviewed. The owner reports Jellyfin's full-library scan completed successfully.
- **LockBox:** The 2026-09-29 post inventory records Garuda Linux kernel `7.2.7-zen1-1-zen`, zero pending repository updates, and root Btrfs at 77% use. The pre inventory recorded kernel `7.1.4-zen1-1-zen` and the dependency conflict. The post snapshot confirms current state, but no package transaction log was supplied; exact package changes are not verified. Snapper pre-update snapshot `260` was confirmed before the update.
- **Nobara:** Pre/post local records identify Nobara 44; post-check found no package updates or failed units, with kernel `7.2.6-201.nobara.fc44.x86_64` unchanged. The transaction log and reboot status were not captured, so exact update and reboot outcomes remain unverified.
- **AtlasOS:** Screenshots show Sunshine's Virtual HID driver unlicensed and ViGEmBus `1.21.442.0` installed; Sunshine reports fallback to ViGEmBus. The owner prefers leaving the current Sunshine configuration as-is. AtlasOS post-update inventory remains pending; no further Sunshine driver change is planned.
- **Proxy DNS:** User observed that all proxy hostnames returned “server not found” with VPN off; direct NPM access at `192.168.0.125:81` worked, and enabling VPN restored hostname access. This is recorded as a client DNS-path issue; the router/DHCP DNS configuration has not been verified.

Raw endpoint inventories are ignored under `scripts/output/`; keep them private and do not commit them. Commit only reviewed summaries without secrets or unnecessary personal/network detail.

## Settled Architecture

- Containers are disposable; persistent data is sacred.
- Rebuildability is preferred over patching unclear state.
- Access policy: every service except WireGuard is restricted to the home LAN or WireGuard-connected clients. No service is intended to be reachable from the public internet. A future public portal is the only planned exception and is not yet deployed.
- Services remain modular; Kubernetes and HA are out of scope without a demonstrated need.
- User-facing Docker services should join the shared `proxy` bridge network for reverse proxy access and internal service discovery.
- Nginx Proxy Manager uses the shared wildcard `*.dustynest.com` certificate for routine service Proxy Hosts.
- The homelab is split into two application domains: VM100 for core services and the media node for media workloads.
- VM100 is the core services platform for infrastructure, knowledge, utilities, security, automation, and monitoring.
- The media node is a specialized appliance for acquisition, organization, discovery, serving, playback, reading, and preservation.
- `/mnt/core` is authoritative for deployment definitions, application state, configs, backups, exports, documentation, and shared operational data.
- `/storage` is the doctrine-level bulk/media data category; the current MediaCenter media paths are exposed under `/media`.
- Docker applications must use paths visible inside their containers; host paths are valid inside an app only when explicitly mounted at the same location.
- Shared `/mnt/core` visibility does not define workload ownership; verify `hostname` before manipulating Compose workloads.
- Verify `/mnt/core` with `findmnt -T /mnt/core`, not by directory existence or `ls`.
- `/mnt/core/services` contains how services are deployed.
- `/mnt/core/appdata` contains persistent application state.
- `/mnt/core/data` contains shared user or operational data.
- `/mnt/core/config` contains host-level configuration.
- `/mnt/core/backups` contains backups and exports.
- `/media` contains the media node's libraries, downloads, cache, ROMs, books, audiobooks, and music.
- Compose stacks should live under `/mnt/core/services/`, grouped into `core`, `knowledge`, `utilities`, `security`, `automation`, `monitoring`, and optional shared `media` definitions.
- Legacy `/mnt/core/stacks` directories still exist and should be retired into `/mnt/core/services` over time.
- Obsidian is the planned primary authoring environment; GitHub is the canonical version-controlled repository.
- Architecture decisions are captured as ADRs under [ADR](05_Decisions/ADR/README.md).

## Deployed State

Infrastructure:

- Proxmox host `pve`, Debian 13 / Proxmox VE 9.2.4, at `192.168.0.75`.
- Pi-hole LXC at `192.168.0.120`.
- WireGuard LXC at `192.168.0.110` with working split tunneling.
- VM100 `services`, Debian 13 Core Services Docker host at `192.168.0.125`.
- Home Assistant OS VM.
- Dedicated Debian 13 media node with established media taxonomy.

Operational VM100 containers:

- `syncthing`, image `lscr.io/linuxserver/syncthing:latest`, Syncthing v2.1.2 / LinuxServer v2.1.2-ls226.
- `baserow`, image `baserow/baserow:latest`, healthy.
- `baserow-postgres`, image `postgres:16`, healthy.
- `npm`, image `jc21/nginx-proxy-manager:latest`.
- `isponsorblocktv`, image `ghcr.io/dmunozv04/isponsorblocktv:latest`.

All VM100 containers were running with restart count 0 after the 2026-07-25 maintenance.

VM100 layout notes:

- Active state exists under `/mnt/core/appdata/core/npm`, `/mnt/core/appdata/utilities/isponsorblocktv`, `/mnt/core/data/sync`, and `/mnt/core/appdata/knowledge/baserow`.
- Syncthing compose lives at `/mnt/core/services/syncthing/compose.yml`.
- Syncthing maps `/mnt/core/data/sync/config` to `/config` and `/mnt/core/data/sync` to `/sync`.
- Syncthing's active folders are `/sync/github`, `/sync/obsidian`, and `/sync/school`, backed by `/mnt/core/data/sync/...`.
- `SirBranteSaves` is obsolete and should be removed from Syncthing rather than repaired.
- Active service definitions exist under both `/mnt/core/services` and legacy `/mnt/core/stacks`.
- Current normalization target is `/mnt/core/services` for deployment definitions and `/mnt/core/appdata` for persistent app state.
- VM100 `/mnt/core` was verified as NFSv4 from `192.168.0.75:/mnt/core`, mounted read-write.
- Final observed VM100 storage: root 63 GB total, 15 GB used, 46 GB available; `/mnt/core` 916 GB total, 11 GB used, 859 GB available.

Operational knowledge services:

- Baserow is deployed on VM100 at `/mnt/core/services/knowledge/baserow`, proxied as `db.dustynest.com`, and uses persistent bind mounts under `/mnt/core/appdata/knowledge/baserow`.
- A Baserow PostgreSQL dump was created before the July 25 update at `/mnt/core/backups/baserow/2026-07-25/baserow.dump`, approximately 12 MB, and validated with `pg_restore --list`.
- Baserow/PostgreSQL were updated and remained healthy; PostgreSQL used the existing database directory and Baserow completed `157/157` template sync tasks.
- Baserow pgvector support is currently missing from the `postgres:16` image; this is an optional capability/future decision, not a current outage.

Operational media services:

- qBittorrent, Prowlarr, Sonarr, Radarr, Jellyfin, and Seerr are running after the MediaCenter `/mnt/core` mount repair and media-stack update.
- Seerr returned successfully with restart count 0, logged `Server ready on port 5055`, and HTTP returned the expected `307 -> /login`.
- Jellyfin is fully configured and running with established libraries, verified imports, and playback.
- Kodi is installed with Arctic Fuse 3 and serves as the living-room frontend to Jellyfin.
- A Bluetooth DualShock 4 is verified working for Kodi navigation; see [MediaCenter maintenance record, 2026-10-04](02_Runbooks/MediaCenter%20Maintenance%202026-10-04.md).
- MediaCenter internal DNS and WireGuard IPv4 routing were repaired on 2026-10-04. NetworkManager is authoritative for `wg0`; its verified configuration keeps Wi-Fi/LAN as the default route and uses WireGuard as a split tunnel. The exposed private key still requires rotation, and the extra `192.168.0.0/24` AllowedIPs entry needs separate investigation; see the dated maintenance record.
- RustDesk 1.4.9 is enabled and active as a native Debian package on `media`, with unattended permanent-password access configured.
- Onboard is installed as the emergency on-screen keyboard for local mouse-only operation.

Media node storage notes:

- `/mnt/core` is an NFSv4 mount from `192.168.0.75:/mnt/core`.
- A local ghost `/mnt/core/services` tree was discovered under the mountpoint after Docker had run while the real NFS mount was absent.
- The ghost tree was backed up to `/var/backups/mediacenter/core-ghost-2026-07-25.tar.gz`, the backup was tested, and the local ghost source was removed only after validation.
- Real `/mnt/core/services/media` became visible again after the NFS mount was restored; observed size was approximately 238 MB.
- `/media` taxonomy exists, but the July 9 `df` output does not show `/media` as a separate mount.
- The media node root filesystem is 89% used in the July 9 snapshot.
- A 1.8 TB disk is visible as `sda` but is not shown mounted in the July 9 `lsblk` output.
- Confirm `/media` backing storage before large imports, downloads, or external-drive normalization.

Media node appliance notes:

- `sleep.target`, `suspend.target`, `hibernate.target`, and `hybrid-sleep.target` are masked so the computer does not automatically sleep.
- X11 screensaver and DPMS are disabled in the current live session to prevent display blanking during Jellyfin/Firefox playback.
- Verify whether the X11 `xset s off` and `xset -dpms` changes persist across logout and reboot.
- The July 25 approximately 15:20 reboot was manually initiated during troubleshooting and should not be treated as an unexplained spontaneous reboot.
- Later boot-order verification showed `/mnt/core` mounted at 16:25:58, `docker.service` began starting at 16:25:58, and `docker.service` became active at 16:26:01. The critical NFS mount was available before Docker workloads used it.
- `docker.socket` may become active earlier than `docker.service`; socket activation alone is not evidence that Docker workloads started before `/mnt/core`.

Proven workflow:

```text
Seerr
  -> Sonarr / Radarr
  -> Prowlarr
  -> Indexer
  -> qBittorrent
  -> Import
  -> Jellyfin
  -> Kodi
```

## Next Milestones

Immediate:

1. Capture AtlasOS post-update inventory when ready; leave Sunshine's current driver configuration unchanged.
2. Confirm the DHCP reservation and VPN route for RustDesk LXC 103; successful client sessions are reported.
3. Review MediaCenter disk usage before any more image pulls; root is currently recorded at 95% used.
4. Confirm LAN DNS on the Windows desktop; proxy hostnames currently have only been verified while VPN is on.
5. Resolve VM200's stale CD-ROM APT source and verify partner Affine use before guest maintenance.
6. Review LockBox's `mirrorlist.pacnew`; keep its 2026-09-29 raw snapshots private and note that the update transaction log was not captured.
7. Remove obsolete `SirBranteSaves` from Syncthing and verify display-blanking persistence.
8. Retain validated recovery material and define backup retention/restore checks.
9. Normalize VM100 definitions from `/mnt/core/stacks` to `/mnt/core/services` and continue planned service expansion only after storage and backup gates.

After core deployment:

- Integrate SoulSync for music discovery; Lidarr remains the music acquisition service.
- Polish Kodi after the remaining ecosystem is deployed.
- Import and normalize the external media drive.
- Configure automated backups.
- Build the Homepage administrative dashboard.

Longer term:

- Restore the ROM collection and emulator/preservation layer.
- Continue the VM100 knowledge ecosystem: Obsidian LiveSync if self-hosted, Nextcloud, Paperless-ngx, AnythingLLM, and n8n.
- Deploy monitoring, including Uptime Kuma, Grafana, Prometheus, SMART, disk, and backup alerts.
- Deploy Vaultwarden, Authelia, and optional CrowdSec.
- Validate backups and disaster recovery.
- Build guarded n8n maintenance automation with host, mount, backup, health, restart-count, and rollback checks.
- Maintain per-session ADR updates when architecture decisions are accepted.

## DNS Constraint

The router must retain ISP DNS. Pi-hole provides local `*.dustynest.com` records to VPN clients and explicitly configured LAN clients. A LAN client should not need WireGuard to reach a LAN service, but its DNS must resolve the local record through Pi-hole. The Windows desktop's Wi-Fi adapter was previously configured to use Pi-hole, but on 2026-09-29 the user observed that all proxy hostnames failed to resolve while VPN was off and worked when VPN was enabled. The current adapter/router DNS configuration was not rechecked; confirm it before assuming LAN hostname access works. Direct NPM UI access at `192.168.0.125:81` worked during the report. See [Windows Desktop DNS](02_Runbooks/Windows%20Desktop%20DNS.md).

## Maturity

| Area | Status |
| --- | ---: |
| Infrastructure | 95% |
| Networking | 95% |
| Storage architecture | 100% |
| VM100 core services | Partial |
| Media acquisition | 75% |
| Media consumption | 70% |
| Music ecosystem | 10% |
| Reading ecosystem | 0% |
| Knowledge ecosystem | Partial |
| Security | Partial |
| Monitoring | Planned |
| Home automation | Base deployed |
| Documentation | In progress |

The project is now in the ecosystem-expansion phase: the foundation and core media pipeline work, while music, reading, knowledge, automation, monitoring, and user-experience layers remain to be added.
