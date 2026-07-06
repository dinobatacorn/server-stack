# Homelab Overview

Status: Current
Last reviewed: 2026-07-06
Source docs:
- Server Plan 21.05.26.md
- Archive_Plan 05.05.26.txt
Next action: Create or update diagrams after the service dependency chart is stable.

## Architecture Summary

The environment is split into a workstation, a Proxmox infrastructure host, and a dedicated media node. The guiding rule is simple: service state belongs on persistent storage, while replaceable media and cache data belong on bulk storage.

## Main Workstation

Purpose:

- Daily workstation
- Development
- Gaming
- Administrative access
- Documentation authoring
- Media management

Known operating systems:

- Nobara Linux
- AtlasOS Windows 11

## Proxmox Infrastructure Host

Role: primary infrastructure hypervisor.

Responsibilities:

- Core infrastructure services
- Internal networking
- VM and LXC hosting
- Persistent storage access
- Service orchestration

Known layout:

- LXC 101: Pi-hole for DNS filtering and local DNS management.
- LXC 102: WireGuard for the operational VPN entrypoint and secure remote access.
- VM 100: Core Services Docker Host.
- VM 104: Home Assistant OS.

## Core Services Docker Host Planned Architecture

The following groups describe the intended service architecture, not the current deployment status. Consult [Homelab Status](../00_STATUS.md) for what is running.

Infrastructure and security services:

- Nginx Proxy Manager
- Authelia
- Vaultwarden
- Homepage
- Restic

Productivity and knowledge services:

- Paperless-ngx
- AnythingLLM
- n8n
- Baserow
- Nextcloud

Utilities:

- RustDesk
- iSponsorBlockTV

## Dedicated Media Node

Host: `media`

Purpose:

- Acquisition
- Organization
- Playback
- Archival
- Future emulator/media-serving workloads

Known hardware:

- CPU: Intel i7-9700K
- GPU: Intel UHD 630 and NVIDIA GTX 1060 3GB
- Storage: 232GB SSD, 2TB HDD, 5TB HDD
- OS: Debian GNU/Linux 13 Trixie

Deployed media services:

- qBittorrent
- Prowlarr
- Sonarr
- Radarr
- Jellyfin
- Kodi with Arctic Fuse 3
- Seerr

The Seerr-to-Sonarr/Radarr-to-qBittorrent-to-Jellyfin-to-Kodi pipeline is operational. Music, reading, and preservation services remain expansion milestones.

## Rebuild Order

1. Network
2. Storage mounts
3. Core infrastructure
4. Applications

Do not troubleshoot applications before confirming their network and storage dependencies are present.

## DNS And Remote Access

- The router must retain ISP DNS and cannot provide homelab DNS to LAN clients.
- Pi-hole at `192.168.0.120` owns local DNS records, including `*.dustynest.com` names.
- WireGuard is operational and remains the preferred remote-access path.
- The AtlasOS Windows desktop uses Pi-hole directly on its Wi-Fi adapter. Windows can otherwise prefer the Wi-Fi adapter's ISP DNS over WireGuard DNS, even while the tunnel is connected.
- See [Windows Desktop DNS](../02_Runbooks/Windows%20Desktop%20DNS.md) for configuration and validation.
