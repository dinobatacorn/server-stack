# Infrastructure Rebuild + Ecosystem TODO

Legend:

* [ ] Not started
* [-] In progress
* [x] Complete
* [~] Needs decision/research

---

# Phase 0 — Architecture + Planning

## Global Architecture

* [x] Establish VPN-first philosophy
* [x] Separate persistent vs bulk storage
* [x] Standardize `/mnt/core` as source of truth
* [x] Standardize `/storage` for bulk media only
* [x] Define rebuild-order philosophy
* [x] Establish disposable-container philosophy
* [-] Consolidate operational documentation
* [-] Finalize dependency mapping between services
* [ ] Create architecture diagrams
* [ ] Create service dependency chart
* [ ] Create recovery runbooks

---

# Main Infrastructure Node (Proxmox Cluster)

## Phase 1 — Core Infrastructure

### Proxmox

* [x] Deploy Proxmox host
* [ ] Verify backup strategy for PVE configs
* [ ] Document VM/LXC inventory
* [ ] Configure scheduled snapshots
* [ ] Configure UPS handling if applicable

### Networking

* [x] Deploy Pi-hole LXC
* [x] Deploy WireGuard LXC
* [-] Verify DNS reliability across reboots
* [-] Verify VPN remote access workflows
* [ ] Document internal DNS mappings
* [ ] Standardize static IP assignments
* [ ] Create internal service naming convention

---

## Phase 2 — Core Storage

### `/mnt/core`

* [x] Establish persistent storage taxonomy
* [x] Create services directory structure
* [x] Create data directory structure
* [x] Create config directory structure
* [x] Create backups structure
* [ ] Verify permissions consistency
* [ ] Audit UID/GID mappings
* [ ] Document ownership standards

### Backups

* [-] Configure restic framework
* [ ] Configure automatic database dumps
* [ ] Configure backup retention policies
* [ ] Test full restore workflow
* [ ] Test partial restore workflow
* [ ] Verify backup integrity validation

---

## Phase 3 — Core Services Docker VM

### Foundation

* [x] Deploy Docker VM
* [-] Reorganize compose stacks
* [-] Normalize bind mount structure
* [ ] Standardize environment variable handling
* [ ] Create compose deployment conventions
* [ ] Create update workflow documentation

### Infrastructure / Security

* [x] Nginx Proxy Manager
* [x] Homepage
* [ ] Authelia
* [ ] Vaultwarden
* [ ] Restic integration
* [ ] SSL/certificate strategy documentation

### Productivity / Knowledge

* [ ] Paperless-ngx
* [ ] AnythingLLM
* [ ] n8n
* [ ] Baserow
* [ ] Nextcloud

### Utilities

* [ ] RustDesk
* [x] iSponsorBlockTV

### Knowledge Architecture

* [~] Decide long-term wiki/knowledge platform
* [ ] Create operational documentation vault
* [ ] Create infrastructure inventory pages
* [ ] Create rebuild procedures
* [ ] Create troubleshooting documentation
* [ ] Create backup/recovery documentation

---

## Phase 4 — Home Assistant

* [x] Deploy HAOS VM
* [ ] Configure backups
* [ ] Configure remote access strategy
* [ ] Document device inventory
* [ ] Separate experimental vs production automations

---

# Dedicated Media Node

Operational runbook: [Media Stack Stabilization 23.05.26.md](Media%20Stack%20Stabilization%2023.05.26.md)

Use the runbook as the gate for media-node changes. Stabilize mounts, permissions, acquisition, playback, backups, and visibility before adding services.

## Phase 1 — Base System

### Debian Host

* [x] Install Debian 13
* [x] Configure SSH
* [x] Configure Docker
* [x] Configure persistent mounts
* [x] Mount `/mnt/core`
* [x] Establish `/media` taxonomy
* [-] Verify reboot persistence
* [ ] Document mount relationships
* [ ] Verify SMART monitoring
* [ ] Configure automatic updates policy

### Filesystem Validation

* [x] Create:

  * `/media/library`
  * `/media/downloads`
  * `/media/books`
  * `/media/audiobooks`
  * `/media/roms`
  * `/media/cache`
* [-] Clean duplicate/legacy directory overlap
* [ ] Finalize archival layout
* [ ] Verify free-space monitoring

---

## Phase 2 — Acquisition Stack

### qBittorrent

* [x] Deploy qBittorrent
* [-] Finalize category strategy
* [-] Verify completed/incomplete behavior
* [ ] Configure automatic cleanup rules
* [ ] Verify permission inheritance

### Prowlarr

* [x] Deploy Prowlarr
* [-] Configure working indexers
* [ ] Remove broken/dead indexers
* [ ] Export/rebuild-safe configuration documentation

### Sonarr / Radarr

* [x] Sonarr
* [x] Radarr
* [ ] Configure root folder mappings
* [ ] Configure quality profiles
* [ ] Configure import behavior
* [ ] Configure recycle bin behavior

### Remaining Acquisition Services

Expansion is blocked until Sonarr, Radarr, and Jellyfin pass the stabilization runbook checks.

* [ ] Lidarr
* [ ] Readarr
* [ ] Bazarr
* [ ] Overseerr

---

## Phase 3 — Media Consumption

### Jellyfin

* [x] Deploy Jellyfin
* [ ] Configure Intel QuickSync
* [ ] Decide GTX 1060 transcoding role
* [ ] Configure libraries:

  * Movies
  * TV
  * Anime
  * Music
  * Home Videos
* [ ] Configure metadata providers
* [ ] Configure users
* [ ] Test playback/transcoding

### Kodi

* [-] Local playback usage functional
* [ ] Configure Jellyfin integration
* [ ] Configure polished living-room UX
* [ ] Configure emulator launching
* [ ] Configure controller support

### Reading Ecosystem

Expansion is blocked until books, audiobooks, and music layouts are finalized and covered by backups.

* [ ] Kavita
* [ ] Audiobookshelf
* [ ] Calibre / Calibre-Web

---

## Phase 4 — Emulator + ROM Layer

* [ ] Restore ROM collections
* [ ] Restore BIOS files
* [ ] Configure RetroArch
* [ ] Configure standalone emulators
* [ ] Configure controller mappings
* [ ] Configure shader packs
* [ ] Configure save-state backup strategy
* [ ] Configure metadata scraping
* [ ] Integrate emulator launching into Kodi

---

## Phase 5 — Data Migration

### Media

* [-] Organize existing movie library
* [-] Organize TV/anime library
* [ ] Organize music library
* [ ] Organize audiobook library
* [ ] Normalize naming conventions
* [ ] Import into Sonarr/Radarr

### Books / Manga

* [ ] Import ebook collections
* [ ] Clean metadata
* [ ] Configure canonical library management
* [ ] Verify Kavita ingestion

### Preservation

* [ ] Preserve subtitles
* [ ] Preserve artwork
* [ ] Preserve NFO files
* [ ] Preserve watched-state metadata where possible

---

## Phase 6 — Media Node Backup + Recovery

* [ ] Complete media stack stabilization runbook validation
* [ ] Configure metadata backups
* [ ] Configure Jellyfin backup strategy
* [ ] Configure emulator save backups
* [ ] Configure external HDD replication
* [ ] Test restore workflows
* [ ] Document media-node rebuild procedure

---

# Final Stabilization

## Cleanup

* [ ] Remove unused containers
* [ ] Remove deprecated compose stacks
* [ ] Remove obsolete directories
* [ ] Audit permissions globally
* [ ] Verify reboot survivability

## Monitoring

* [ ] Deploy monitoring/dashboard stack
* [ ] Configure disk alerts
* [ ] Configure SMART alerts
* [ ] Configure backup failure alerts

## Documentation

* [ ] Export final compose backups
* [ ] Snapshot stable-state configs
* [ ] Finalize operational documentation
* [ ] Create “new machine bootstrap” procedure
* [ ] Create disaster recovery checklist

## Future / Optional

* [~] Recyclarr
* [~] Tdarr
* [~] GPU transcoding optimization
* [~] Automated media quality management
* [~] Custom dashboard ecosystem
