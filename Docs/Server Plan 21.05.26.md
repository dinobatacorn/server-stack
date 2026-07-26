# Server Plan

# Core Philosophy

* Containers are disposable
* Persistent data is sacred
* Prefer rebuildability over patching
* VPN-first access model
* Avoid unnecessary complexity
* Documentation is infrastructure

---

# Infrastructure Overview

## Main Workstation

Dual-purpose desktop workstation.

### Operating Systems

* Nobara Linux
* AtlasOS Windows 11

### Purpose

* Daily workstation
* Development
* Gaming
* Administrative access
* Documentation authoring
* Media management

---

# Infrastructure Cluster

## Proxmox VE Host

Primary infrastructure hypervisor.

### Responsibilities

* Core infrastructure services
* Internal networking
* Service orchestration
* Persistent storage access
* VM/LXC hosting

---

# Proxmox Layout

## LXC Containers

### LXC 101 → Pi-hole

Purpose:

* Primary DNS filtering
* Local DNS management

### LXC 102 → WireGuard

Purpose:

* VPN entrypoint
* Secure remote access
* Internal-first service exposure

---

## Virtual Machines

### VM 100 → Core Services Docker Host

Primary Docker workload VM.

### Services

#### Infrastructure / Security

* Nginx Proxy Manager
* Authelia
* Vaultwarden
* Homepage
* Restic

#### Productivity / Knowledge

* Paperless-ngx
* AnythingLLM
* n8n
* Baserow
* Nextcloud

#### Utility Services

* RustDesk
* iSponsorBlockTV

---

### VM 104 → Home Assistant OS

Purpose:

* Home automation
* Smart device orchestration

---

# Dedicated Media Node

## Host

Debian 13 (Trixie)

### Purpose

Dedicated media ecosystem node handling:

* acquisition
* organization
* playback
* archival
* emulator stack
* media-serving workloads

---

## Media Node Hardware

### CPU

* Intel i7-9700K

### GPU

* Intel UHD 630
* NVIDIA GTX 1060 3GB

### Storage

* 232GB SSD
* 2TB HDD
* 5TB HDD

---

# Media Ecosystem

## Acquisition Stack

* qBittorrent
* Prowlarr
* Sonarr
* Radarr
* Lidarr
* Readarr
* Bazarr
* Overseerr

## Media Serving

* Jellyfin
* Kodi

## Reading / Archival

* Kavita
* Audiobookshelf
* Calibre / Calibre-Web

## Emulator / ROM Stack

* RetroArch
* Standalone emulators
* ROM archival
* Save-state preservation

---

# Storage Architecture

## Guiding Rule

Critical operational state must NEVER exist solely on bulk media storage.

---

# Persistent Infrastructure Storage

## `/mnt/core`

Source of truth for:

* configs
* databases
* compose stacks
* exports
* backups
* operational data

### Structure

```text
/mnt/core
├── services/
├── data/
├── config/
├── backups/
├── logs/
└── tmp/
```

---

## `/mnt/core/services`

Application/service persistence layer.

### Categories

```text
services/
├── core/
├── media/
├── knowledge/
├── utilities/
└── monitoring/
```

---

## `/mnt/core/data`

Human-owned, tool-agnostic data.

### Structure

```text
data/
├── knowledge/
├── writing/
├── shared/
├── documents/
└── exports/
```

---

# Bulk Media Storage

## `/storage`

Replaceable media + ingest storage.

### Structure

```text
/storage
├── library/
├── ingest/
├── archive/
├── backups/
└── scratch/
```

---

## `/storage/library`

Final organized media.

### Categories

```text
library/
├── movies/
├── tv/
├── anime/
├── music/
├── youtube/
└── home-videos/
```

---

## `/storage/ingest`

Incoming acquisition pipeline.

### Structure

```text
ingest/
├── torrents/
│   ├── incomplete/
│   └── complete/
├── manual/
└── unsorted/
```

---

# Media Node Local Layout

## `/media`

Media-node-local organization layer.

```text
/media
├── library/
├── downloads/
├── books/
├── audiobooks/
├── roms/
├── cache/
└── music/
```

---

# Networking Philosophy

## Access Model

* VPN-first
* Internal-first services
* Minimize public exposure
* Reverse proxy only where necessary

## Rebuild Order

1. Network
2. Storage mounts
3. Core infrastructure
4. Applications

---

# Documentation Philosophy

The infrastructure documentation is treated as operational memory.

Documentation should include:

* dependency relationships
* rebuild procedures
* service maps
* storage layouts
* backup procedures
* architecture diagrams

Future rebuildability is a core design requirement.
