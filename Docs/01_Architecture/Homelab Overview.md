# Homelab Overview

Status: Current
Last reviewed: 2026-07-10
Source docs:
- Server Plan 21.05.26.md
- Archive_Plan 05.05.26.txt
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
- User-provided Baserow deployment summary, 2026-07-10
Next action: Create or update diagrams after the service dependency chart is stable.

Reference: [IP, Port, And Proxy Assignments](IP%20Port%20Proxy%20Assignments.md) records documented IPs, ports, proxy hostnames, and open assignment gaps.

## Architecture Summary

The environment is split into a workstation, a Proxmox infrastructure host, and a dedicated media node. The important architectural split is two application domains: VM100 is the core services platform, and the media node is a specialized media appliance. The guiding rule is simple: service state belongs on persistent storage, while replaceable media and cache data belong on bulk storage.

```text
                    Proxmox
                       |
        +--------------+--------------+
        |                             |
   VM100 Core Services           Media Node
        |                             |
 Infrastructure               Media Ecosystem
 Knowledge                    Acquisition
 Utilities                    Consumption
 Security                     Discovery
 Automation                   Reading
 Monitoring                   Preservation
```

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

## VM100 Core Services Platform

Host: `services`

Purpose:

- Infrastructure
- Knowledge
- Utilities
- Security
- Automation
- Monitoring
- Personal cloud services

Deployed containers:

- Nginx Proxy Manager
- Syncthing
- iSponsorBlockTV
- Baserow

The following groups describe the intended service architecture. Consult [Homelab Status](../00_STATUS.md) for what is running.

Core:

- Nginx Proxy Manager
- Homepage

Security:

- Authelia
- Vaultwarden
- CrowdSec, if later justified

Knowledge:

- Obsidian LiveSync, if self-hosted
- Baserow
- Paperless-ngx
- Nextcloud
- AnythingLLM

Automation:

- n8n

Utilities:

- Syncthing
- RustDesk
- iSponsorBlockTV

Monitoring:

- Uptime Kuma
- Grafana
- Prometheus
- Node Exporter
- cAdvisor, if useful

Backup:

- Restic

## Dedicated Media Node

Host: `media`

Purpose:

- Acquisition
- Organization
- Playback
- Archival
- Future emulator/media-serving workloads

Known hardware and current storage notes:

- CPU: Intel i7-9700K
- GPU: Intel UHD 630 and NVIDIA GTX 1060 3GB
- Storage visible in July 9 snapshot: 232GB system disk and 1.8TB disk.
- `/mnt/core` mounted from `192.168.0.75:/mnt/core`.
- `/media` exists but was not shown as a separate mount in the July 9 `df` output.
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

Current caution: verify the media node's `/media` backing device before large imports or normalization work. The July 9 inventory shows the root filesystem at 89% used and does not show `/media` as its own mounted filesystem.

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
