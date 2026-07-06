# Architecture Decisions

Status: Current
Last reviewed: 2026-07-06
Source docs:
- Archive_Plan 05.05.26.txt
- Server Plan 21.05.26.md
- Media Stack Stabilization 23.05.26.md
Next action: Add dates and rationale when new architecture decisions are made.

## Persistent Data Is Sacred

Decision: containers are disposable, but service data is not.

Implications:

- Configs, databases, compose stacks, exports, backups, and operational docs belong under `/mnt/core`.
- Rebuildability is preferred over patching unclear legacy service state.
- Backup and restore procedures are part of the infrastructure, not optional housekeeping.

## VPN-First Access

Decision: services should be internal-first and exposed through VPN unless there is a clear reason otherwise.

Implications:

- WireGuard is the remote access entrypoint.
- WireGuard is operational; applications remain internal unless explicitly approved for exposure.
- Reverse proxy is useful where needed, but public exposure should be minimized.
- Router limitations should shape the design instead of forcing brittle workarounds.

## Client DNS Under Router Constraints

Decision: clients that require local records must use Pi-hole directly when adapter precedence makes WireGuard DNS unreliable.

Implications:

- The router remains on ISP DNS because its DNS configuration cannot be changed.
- Pi-hole at `192.168.0.120` is authoritative for local `*.dustynest.com` records.
- The Windows desktop Wi-Fi adapter uses `192.168.0.120` as its DNS server.
- A successful `nslookup` against Pi-hole does not prove normal Windows applications are using Pi-hole; validate through the system resolver as documented in the runbook.

## Storage Separation

Decision: separate persistent infrastructure storage from replaceable media/bulk storage.

Implications:

- `/mnt/core` is the source of truth.
- `/media` is the active media-node bulk layout.
- `/storage` remains historical or architecture-level language unless recreated by an explicit future migration.
- Critical operational state must not exist only on media disks.

## Stabilize Before Expanding

Decision: prove each ecosystem layer before expanding it. The original core-media stabilization gate was satisfied by 2026-07-06.

Implications:

- qBittorrent, Prowlarr, Sonarr, Radarr, Jellyfin, Kodi, and Seerr form the operational media core.
- Seerr is the primary request interface; routine users should rarely need Sonarr or Radarr directly.
- Lidarr, Bazarr, Readarr, Audiobookshelf, and Kavita are the immediate expansion scope.
- SoulSync will complement Lidarr: SoulSync supports discovery while Lidarr handles acquisition.
- Emulator work remains later than the current music and reading expansion.

## Media Frontend And Backend

Decision: Jellyfin is the central media backend and Kodi is the living-room frontend.

Implications:

- Kodi uses Arctic Fuse 3.
- Kodi UI polishing waits until the remaining ecosystem is deployed.
- Jellyfin remains responsible for the central libraries and media serving.

## Knowledge Authoring

Decision: Obsidian replaces AFFiNE as the primary technical knowledge environment, while GitHub remains the canonical version-controlled repository.

## Documentation Is Infrastructure

Decision: operational docs should be treated as part of the system.

Implications:

- Raw exports are preserved, but canonical Markdown docs should hold the usable truth.
- Every canonical doc should state status, last reviewed date, source docs, and next action.
- The docs should support future rebuilds, not just describe past conversations.
