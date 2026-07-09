# Homelab Status

Status: Current
Last reviewed: 2026-07-09
Source docs:
- Current State of the Homelab (July 2026)
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
- Canonical architecture, runbook, inventory, and backlog documents in this repository
Next action: Normalize VM100 service layout while expanding the operational media ecosystem with music and reading services.

## How To Read This Status

- **Settled architecture** describes design decisions and intended structure.
- **Deployed state** records what is actually running and verified now.
- **Next milestones** lists work that has not yet been completed.

## Settled Architecture

- Containers are disposable; persistent data is sacred.
- Rebuildability is preferred over patching unclear state.
- Access is VPN-first and services are internal-first.
- Services remain modular; Kubernetes and HA are out of scope without a demonstrated need.
- The homelab is split into two application domains: VM100 for core services and the media node for media workloads.
- VM100 is the core services platform for infrastructure, knowledge, utilities, security, automation, and monitoring.
- The media node is a specialized appliance for acquisition, organization, discovery, serving, playback, reading, and preservation.
- `/mnt/core` is authoritative for deployment definitions, application state, configs, backups, exports, documentation, and shared operational data.
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

- Nginx Proxy Manager.
- Syncthing.
- iSponsorBlockTV.

VM100 layout notes:

- Active state exists under `/mnt/core/appdata/core/npm`, `/mnt/core/appdata/utilities/isponsorblocktv`, and `/mnt/core/data/sync`.
- Active service definitions exist under both `/mnt/core/services` and legacy `/mnt/core/stacks`.
- Current normalization target is `/mnt/core/services` for deployment definitions and `/mnt/core/appdata` for persistent app state.

Operational media services:

- qBittorrent and Prowlarr are configured and running.
- Sonarr is fully configured and running; downloads, imports, and Jellyfin notifications were verified with *Firefly* and *Galavant*.
- Radarr is fully configured and running, connected to Prowlarr, qBittorrent, Jellyfin, and Seerr.
- Jellyfin is fully configured and running with established libraries, verified imports, and playback.
- Kodi is installed with Arctic Fuse 3 and serves as the living-room frontend to Jellyfin.
- Seerr is fully configured and running as the primary request interface and is connected to Jellyfin, Sonarr, and Radarr.

Media node storage notes:

- `/mnt/core` is mounted from `192.168.0.75:/mnt/core`.
- `/media` taxonomy exists, but the July 9 `df` output does not show `/media` as a separate mount.
- The media node root filesystem is 89% used in the July 9 snapshot.
- A 1.8 TB disk is visible as `sda` but is not shown mounted in the July 9 `lsblk` output.
- Confirm `/media` backing storage before large imports, downloads, or external-drive normalization.

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

1. Normalize VM100 deployment definitions from `/mnt/core/stacks` to `/mnt/core/services`.
2. Deploy Lidarr.
3. Deploy Bazarr.
4. Deploy Readarr.
5. Deploy Audiobookshelf.
6. Deploy Kavita.

After core deployment:

- Integrate SoulSync for music discovery; Lidarr remains the music acquisition service.
- Polish Kodi after the remaining ecosystem is deployed.
- Import and normalize the external media drive.
- Configure automated backups.
- Build the Homepage administrative dashboard.

Longer term:

- Restore the ROM collection and emulator/preservation layer.
- Deploy the VM100 knowledge ecosystem: Obsidian LiveSync if self-hosted, Nextcloud, Paperless-ngx, Baserow, AnythingLLM, and n8n.
- Deploy monitoring, including Uptime Kuma, Grafana, Prometheus, SMART, disk, and backup alerts.
- Deploy Vaultwarden, Authelia, and optional CrowdSec.
- Validate backups and disaster recovery.
- Maintain per-session ADR updates when architecture decisions are accepted.

## DNS Constraint

The router must retain ISP DNS. Pi-hole provides local `*.dustynest.com` records to VPN clients and explicitly configured LAN clients. The Windows desktop Wi-Fi adapter uses Pi-hole directly because Windows may prefer Wi-Fi DNS over WireGuard DNS while the VPN is connected. See [Windows Desktop DNS](02_Runbooks/Windows%20Desktop%20DNS.md).

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
| Knowledge ecosystem | Planned |
| Security | Partial |
| Monitoring | Planned |
| Home automation | Base deployed |
| Documentation | In progress |

The project is now in the ecosystem-expansion phase: the foundation and core media pipeline work, while music, reading, knowledge, automation, monitoring, and user-experience layers remain to be added.
