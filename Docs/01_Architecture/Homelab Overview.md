# Homelab Overview

Status: Current
Last reviewed: 2026-05-23
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
- LXC 102: WireGuard for VPN entrypoint and secure remote access. Its UDP port is now forwarded and needs external validation.
- VM 100: Core Services Docker Host.
- VM 104: Home Assistant OS.

## Core Services Docker Host

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

## Rebuild Order

1. Network
2. Storage mounts
3. Core infrastructure
4. Applications

Do not troubleshoot applications before confirming their network and storage dependencies are present.
