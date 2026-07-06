# Service Map

Status: Current
Last reviewed: 2026-07-06
Source docs:
- Server Plan 21.05.26.md
- to-do list 17.05.26.md
- Media Stack Stabilization 23.05.26.md
Next action: Add music and reading services to the proven media pipeline as they are deployed.

## Infrastructure Dependencies

Rebuild and validation order:

1. Network and DNS
2. VPN access
3. Storage mounts
4. Docker hosts and container runtime
5. Core services
6. Application services
7. Media expansion services

## Proxmox Services

- Pi-hole LXC depends on Proxmox networking and stable host startup.
- WireGuard LXC depends on Proxmox networking and is the VPN-first access entrypoint.
- WireGuard is operational and is the preferred remote administration path.
- VPN and selected LAN clients depend on Pi-hole (`192.168.0.120`) for local `*.dustynest.com` resolution.
- The Windows desktop Wi-Fi adapter uses Pi-hole directly because Windows may prefer that adapter's DNS over WireGuard DNS.
- Core Services Docker VM depends on storage mounts and Docker startup.
- Home Assistant OS VM depends on Proxmox VM startup and its own backup plan.

## Core Docker VM Planned Architecture

These groups describe the intended architecture; they do not imply every service is deployed:

- Infrastructure/security: Nginx Proxy Manager, Authelia, Vaultwarden, Homepage, Restic.
- Productivity/knowledge: Paperless-ngx, AnythingLLM, n8n, Baserow, Nextcloud.
- Utilities: RustDesk, iSponsorBlockTV.

Operational rule: persistent app state and databases belong under `/mnt/core`, not bulk media storage.

## Media Node Deployed State

Configured and operational:

- qBittorrent
- Prowlarr
- Sonarr
- Radarr
- Jellyfin
- Kodi
- Seerr

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
