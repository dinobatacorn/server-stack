# Service Map

Status: Current
Last reviewed: 2026-05-23
Source docs:
- Server Plan 21.05.26.md
- to-do list 17.05.26.md
- Media Stack Stabilization 23.05.26.md
Next action: Convert this into a dependency diagram after stabilization checks are complete.

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
- The WireGuard UDP port is now forwarded externally; validate remote access before relying on it for administration.
- Core Services Docker VM depends on storage mounts and Docker startup.
- Home Assistant OS VM depends on Proxmox VM startup and its own backup plan.

## Core Docker VM Services

Current or planned service groups:

- Infrastructure/security: Nginx Proxy Manager, Authelia, Vaultwarden, Homepage, Restic.
- Productivity/knowledge: Paperless-ngx, AnythingLLM, n8n, Baserow, Nextcloud.
- Utilities: RustDesk, iSponsorBlockTV.

Operational rule: persistent app state and databases belong under `/mnt/core`, not bulk media storage.

## Media Node Core

Active stabilization services:

- qBittorrent
- Prowlarr
- Sonarr
- Radarr
- Jellyfin
- Kodi

Core media flow:

```text
Prowlarr -> Sonarr/Radarr search
Sonarr/Radarr -> qBittorrent download client
qBittorrent -> /media/downloads
Sonarr/Radarr -> /media/library
Jellyfin/Kodi -> /media/library playback
```

## Expansion Services

Allowed only after the stabilization runbook passes:

- Bazarr after Sonarr/Radarr imports and Jellyfin playback are stable.
- Overseerr after request flow can safely target stable Sonarr/Radarr profiles and root folders.

Blocked for now:

- Lidarr and Readarr until music/books layouts are finalized.
- Kavita, Audiobookshelf, and Calibre/Calibre-Web until reading/audiobook layouts and backups are finalized.
- RetroArch and standalone emulators until core media and backups are stable.
- Recyclarr and automated quality management until manual profiles are proven.
- Tdarr and GTX 1060 optimization until direct play and Intel QuickSync are stable.
