# Homelab Overview

Status: Current
Last reviewed: 2026-09-29
Source docs:
- Server Plan 21.05.26.md
- Archive_Plan 05.05.26.txt
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
- User-provided Baserow deployment summary, 2026-07-10
- Syncthing Recovery and Architecture Update, 2026-07-25
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
- Fleet Update Reports, 2026-09-28 through 2026-09-30
Next action: Confirm RustDesk LXC 103's DHCP reservation and VPN route; finish MediaCenter checks and keep the proposed game-services VM in planning until storage and network access are approved.

Reference: [IP, Port, And Proxy Assignments](IP%20Port%20Proxy%20Assignments.md) records documented IPs, ports, proxy hostnames, and open assignment gaps.

## Architecture Summary

The environment is split into a workstation, a Proxmox infrastructure host, and a dedicated media node. The important architectural split is two application domains: VM100 is the core services platform, and the media node is a specialized media appliance. The guiding rule is simple: service state belongs on persistent storage, while replaceable media and cache data belong on bulk storage. Docker applications must use container-visible paths for mounted persistent data, and shared `/mnt/core` visibility does not define workload ownership.

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
- LXC 103: RustDesk Server (`hbbs`, `hbbr`, API/UI); private persistent state on `/mnt/core/appdata/security`.
- VM 100: Core Services Docker Host.
- VM 200: `infra-proxy` was destroyed per owner report on 2026-09-30 after the partner moved to Super Productivity. An older comprehensive backup is reported to exist; restoreability is unverified. See [Main Node Inventory](../03_Inventories/Main%20Node%20Inventory.md).
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
- Syncthing, with `/mnt/core/data/sync` mounted as `/sync`
- iSponsorBlockTV
- Baserow
- Baserow PostgreSQL

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
- Remote living-room administration through RustDesk

Known hardware and current storage notes:

- CPU: Intel i7-9700K
- GPU: Intel UHD 630 and NVIDIA GTX 1060 3GB
- Storage visible in July 9 snapshot: 232GB system disk and 1.8TB disk.
- `/mnt/core` is an NFSv4 mount from `192.168.0.75:/mnt/core`; verify with `findmnt -T /mnt/core`.
- `/media` exists but was not shown as a separate mount in the July 9 `df` output.
- OS: Debian GNU/Linux 13 Trixie
- Kernel after the 2026-09-29 reboot: `6.12.107+deb13-amd64`.

Deployed media services:

- qBittorrent
- Prowlarr
- Sonarr
- Radarr
- Jellyfin
- Kodi with Arctic Fuse 3
- Seerr
- RustDesk client 1.4.9, native Debian package. The owner reports pointing clients to LXC 103 and multiple successful sessions, including a recent phone-to-desktop test after the phone joined the network.

The Seerr-to-Sonarr/Radarr-to-qBittorrent-to-Jellyfin-to-Kodi pipeline was proven during the July 9 baseline and restored during the July 25 MediaCenter mount repair. Seerr reported `Server ready on port 5055` and HTTP returned `307 -> /login` after repair. Music, reading, and preservation services remain expansion milestones.

Current caution: verify the media node's `/media` backing device before large imports or normalization work. The July 9 inventory shows the root filesystem at 89% used and does not show `/media` as its own mounted filesystem.

Mount caution: MediaCenter previously wrote a local ghost `/mnt/core/services` tree while NFS was absent. Do not rely on the existence of `/mnt/core`; verify the mounted filesystem before Docker or cleanup operations.

Living-room appliance policy: MediaCenter should remain reachable over SSH, Docker, Jellyfin, and RustDesk. System sleep and hibernate targets are masked. X11 screensaver/DPMS blanking is disabled in the live session and should be made persistent if it does not survive reboot.

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
- RustDesk Server LXC 103 is also intended for LAN/WireGuard-only access; no WAN port forwards were added. Its router DHCP reservation and VPN route are not verified.
- User observation on 2026-09-29: proxy hostnames returned “server not found” from the Windows desktop when VPN was off; direct NPM UI access at `192.168.0.125:81` worked, and turning VPN on restored hostname access. The desktop's LAN DNS path still needs verification if LAN-only hostname use is expected.
- The AtlasOS Windows desktop uses Pi-hole directly on its Wi-Fi adapter. Windows can otherwise prefer the Wi-Fi adapter's ISP DNS over WireGuard DNS, even while the tunnel is connected.
- See [Windows Desktop DNS](../02_Runbooks/Windows%20Desktop%20DNS.md) for configuration and validation.
