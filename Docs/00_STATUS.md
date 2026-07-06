# Homelab Status

Status: Current
Last reviewed: 2026-07-06
Source docs:
- Current State of the Homelab (July 2026)
- Canonical architecture, runbook, inventory, and backlog documents in this repository
Next action: Expand the operational media ecosystem with music and reading services.

## How To Read This Status

- **Settled architecture** describes design decisions and intended structure.
- **Deployed state** records what is actually running and verified now.
- **Next milestones** lists work that has not yet been completed.

## Settled Architecture

- Containers are disposable; persistent data is sacred.
- Rebuildability is preferred over patching unclear state.
- Access is VPN-first and services are internal-first.
- Services remain modular; Kubernetes and HA are out of scope without a demonstrated need.
- `/mnt/core` is authoritative for compose files, configs, databases, backups, exports, documentation, and operational state.
- `/media` contains the media node's libraries, downloads, cache, ROMs, books, audiobooks, and music.
- Compose stacks live under `/mnt/core/services/`, grouped into `core`, `media`, `knowledge`, `utilities`, and `monitoring`.
- Obsidian is the planned primary authoring environment; GitHub is the canonical version-controlled repository.

## Deployed State

Infrastructure:

- Proxmox host.
- Pi-hole LXC at `192.168.0.120`.
- WireGuard LXC with working split tunneling.
- Core Services Docker VM.
- Home Assistant OS VM.
- Dedicated Debian 13 media node and established media taxonomy.

Operational media services:

- qBittorrent and Prowlarr are configured.
- Sonarr is fully configured; downloads, imports, and Jellyfin notifications were verified with *Firefly* and *Galavant*.
- Radarr is fully configured and connected to Prowlarr, qBittorrent, Jellyfin, and Seerr.
- Jellyfin is fully configured with established libraries, verified imports, and playback.
- Kodi is installed with Arctic Fuse 3 and serves as the living-room frontend to Jellyfin.
- Seerr is fully configured as the primary request interface and is connected to Jellyfin, Sonarr, and Radarr.

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

1. Deploy Lidarr.
2. Deploy Bazarr.
3. Deploy Readarr.
4. Deploy Audiobookshelf.
5. Deploy Kavita.

After core deployment:

- Integrate SoulSync for music discovery; Lidarr remains the music acquisition service.
- Polish Kodi after the remaining ecosystem is deployed.
- Import and normalize the external media drive.
- Configure automated backups.
- Build the Homepage administrative dashboard.

Longer term:

- Restore the ROM collection and emulator/preservation layer.
- Deploy the knowledge ecosystem: Obsidian, Nextcloud, Paperless-ngx, Baserow, AnythingLLM, and n8n.
- Deploy monitoring, including Uptime Kuma, Grafana, Prometheus, SMART, disk, and backup alerts.
- Deploy Vaultwarden and Authelia.
- Validate backups and disaster recovery.

## DNS Constraint

The router must retain ISP DNS. Pi-hole provides local `*.dustynest.com` records to VPN clients and explicitly configured LAN clients. The Windows desktop Wi-Fi adapter uses Pi-hole directly because Windows may prefer Wi-Fi DNS over WireGuard DNS while the VPN is connected. See [Windows Desktop DNS](02_Runbooks/Windows%20Desktop%20DNS.md).

## Maturity

| Area | Status |
| --- | ---: |
| Infrastructure | 95% |
| Networking | 95% |
| Storage architecture | 100% |
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
