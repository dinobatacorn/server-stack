# Service Map

Status: Current
Last reviewed: 2026-07-25
Source docs:
- Server Plan 21.05.26.md
- to-do list 17.05.26.md
- Media Stack Stabilization 23.05.26.md
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
- User-provided Baserow deployment summary, 2026-07-10
- Syncthing Recovery and Architecture Update, 2026-07-25
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
Next action: Remove obsolete Syncthing folder, verify MediaCenter display-blanking persistence, then continue Baserow organization and media/knowledge-service expansion.

Reference: [IP, Port, And Proxy Assignments](IP%20Port%20Proxy%20Assignments.md) records documented IPs, service ports, proxy hostnames, and open assignment gaps.

## Infrastructure Dependencies

Rebuild and validation order:

1. Network and DNS
2. VPN access
3. Storage mounts
4. Docker hosts and container runtime
5. VM100 core services
6. Media-node services
7. Application expansion services

## Proxmox Services

- Pi-hole LXC depends on Proxmox networking and stable host startup.
- WireGuard LXC depends on Proxmox networking and is the VPN-first access entrypoint.
- WireGuard is operational and is the preferred remote administration path.
- VPN and selected LAN clients depend on Pi-hole (`192.168.0.120`) for local `*.dustynest.com` resolution.
- The Windows desktop Wi-Fi adapter uses Pi-hole directly because Windows may prefer that adapter's DNS over WireGuard DNS.
- VM100 Core Services Docker host depends on `/mnt/core`, Docker startup, and Pi-hole DNS.
- Home Assistant OS VM depends on Proxmox VM startup and its own backup plan.

## Application Domains

VM100 is the core services platform. It owns infrastructure, knowledge, utilities, security, automation, monitoring, personal-cloud services, and backup orchestration.

The media node is the media appliance. It owns acquisition, processing, discovery, serving, playback, reading, and preservation workloads.

Do not migrate VM100 away merely because the media node exists. They are separate domains.

Shared `/mnt/core` visibility does not imply workload ownership. Before running `docker compose up`, `down`, `pull`, or other host-specific operations against Compose files on shared storage, verify the current host with `hostname`.

## VM100 Core Services

Currently running after 2026-07-25 maintenance:

- `syncthing`
- `baserow`
- `baserow-postgres`
- `npm`
- `isponsorblocktv`

All were running with restart count 0 at final verification.

Planned or pending groups:

- Core: Homepage.
- Security: Vaultwarden, Authelia, optional CrowdSec.
- Knowledge: Obsidian LiveSync if self-hosted, Paperless-ngx, Nextcloud, AnythingLLM.
- Automation: n8n.
- Monitoring: Uptime Kuma, Grafana, Prometheus, Node Exporter, optional cAdvisor.
- Backup: Restic.

Operational rule: persistent app state and databases belong under `/mnt/core`, not bulk media storage.

Docker path rule: application configuration must use paths visible inside the container. Host paths are valid inside the application only if they are explicitly mounted at the same path.

Syncthing deployment:

```text
Host:    services
Compose: /mnt/core/services/syncthing/compose.yml
Config:  /mnt/core/data/sync/config -> /config
Data:    /mnt/core/data/sync        -> /sync
Version: Syncthing v2.1.2
```

Syncthing folder paths:

```text
Github   /mnt/core/data/sync/github   -> /sync/github
Obsidian /mnt/core/data/sync/obsidian -> /sync/obsidian
school   /mnt/core/data/sync/school   -> /sync/school
```

The canonical Syncthing runtime belongs on VM100 `services`, not MediaCenter. `SirBranteSaves` is obsolete and should be removed from configuration.

Baserow deployment path:

```text
Client -> Pi-hole -> Nginx Proxy Manager -> proxy Docker network -> Baserow -> PostgreSQL
```

Baserow/PostgreSQL persistent mounts:

```text
/mnt/core/appdata/knowledge/baserow/media    -> /baserow/data
/mnt/core/appdata/knowledge/baserow/postgres -> /var/lib/postgresql/data
```

Nginx Proxy Manager persistent mounts:

```text
/mnt/core/appdata/core/npm/data        -> /data
/mnt/core/appdata/core/npm/letsencrypt -> /etc/letsencrypt
```

NPM currently uses `/data/database.sqlite`.

## Media Node Deployed State

Configured and operational after the 2026-07-25 mount repair and media-stack update:

- qBittorrent, exposed on `8080` and `6881`.
- Prowlarr, exposed on `9696`.
- Sonarr, exposed on `8989`.
- Radarr, exposed on `7878`.
- Jellyfin, exposed on `8096`.
- Seerr, exposed on `5055`, returned successfully after the `/mnt/core` repair and reported `Server ready on port 5055`; HTTP returned `307 -> /login`.
- Kodi, native living-room frontend rather than a Docker container.
- RustDesk 1.4.9, native Debian package, enabled and active for unattended remote administration.
- Onboard, installed as local on-screen keyboard fallback.

MediaCenter appliance policy:

- System sleep, suspend, hibernate, and hybrid sleep are masked through systemd.
- X11 screensaver and DPMS are disabled in the current live graphical session to prevent display blanking during Jellyfin/Firefox playback.
- Verify X11 display policy persistence across logout and reboot.
- `/mnt/core` is an NFSv4 mount from `192.168.0.75:/mnt/core`; verify with `findmnt -T /mnt/core` before starting or recreating containers.
- Boot-order verification showed `/mnt/core` mounted before `docker.service` became active. Do not confuse earlier `docker.socket` activation with Docker workloads starting.

Proven media flow:

```text
Seerr -> Sonarr/Radarr request
Sonarr/Radarr -> Prowlarr indexer search
Sonarr/Radarr -> qBittorrent download
qBittorrent -> /media/downloads
Sonarr/Radarr -> /media/library import
Jellyfin -> library scan and serving
Kodi -> Jellyfin-backed living-room playback
```

## Next Media Milestones

Immediate deployment:

- Lidarr for music acquisition.
- Bazarr for subtitles.
- Readarr for books.
- Audiobookshelf for audiobooks.
- Kavita for ebooks, manga, and comics.

After core deployment:

- SoulSync for music discovery alongside Lidarr.
- Kodi UI customization.
- External media drive import and normalization.
- Automated backups.

Longer-term planned architecture:

- Calibre or Calibre-Web after evaluation.
- RetroArch, standalone emulators, preservation assets, and Kodi launcher integration.
- Recyclarr and Tdarr if their operational value justifies them.

## Current Media-Node Storage Caution

The July 9 media-node snapshot showed `/mnt/core` mounted from the Proxmox host and the `/media` taxonomy present, but it did not show `/media` as a separate mounted filesystem. The root filesystem was 89% used and a 1.8 TB disk appeared as `sda` without a mountpoint in the captured `lsblk` output.

Before large downloads, imports, or external-drive normalization, confirm where `/media` is physically backed and whether the 1.8 TB disk should be mounted there.
