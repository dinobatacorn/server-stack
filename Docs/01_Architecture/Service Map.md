# Service Map

Status: Current
Last reviewed: 2026-07-09
Source docs:
- Server Plan 21.05.26.md
- to-do list 17.05.26.md
- Media Stack Stabilization 23.05.26.md
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
Next action: Normalize VM100 service definitions, then add music and reading services to the proven media pipeline as they are deployed.

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

## VM100 Core Services

Currently running:

- Nginx Proxy Manager
- Syncthing
- iSponsorBlockTV

Planned or pending groups:

- Core: Homepage.
- Security: Vaultwarden, Authelia, optional CrowdSec.
- Knowledge: Obsidian LiveSync if self-hosted, Paperless-ngx, Nextcloud, Baserow, AnythingLLM.
- Automation: n8n.
- Monitoring: Uptime Kuma, Grafana, Prometheus, Node Exporter, optional cAdvisor.
- Backup: Restic.

Operational rule: persistent app state and databases belong under `/mnt/core`, not bulk media storage.

## Media Node Deployed State

Configured and operational:

- qBittorrent, exposed on `8080` and `6881`.
- Prowlarr, exposed on `9696`.
- Sonarr, exposed on `8989`.
- Radarr, exposed on `7878`.
- Jellyfin, exposed on `8096`.
- Seerr, exposed on `5055`.
- Kodi, native living-room frontend rather than a Docker container.

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

The July 9 media-node snapshot shows `/mnt/core` mounted from the Proxmox host and the `/media` taxonomy present, but it does not show `/media` as a separate mounted filesystem. The root filesystem is 89% used and a 1.8 TB disk appears as `sda` without a mountpoint in the captured `lsblk` output.

Before large downloads, imports, or external-drive normalization, confirm where `/media` is physically backed and whether the 1.8 TB disk should be mounted there.
