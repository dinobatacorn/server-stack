# Architecture Decisions

Status: Current
Last reviewed: 2026-05-23
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
- The WireGuard UDP port has been forwarded externally; the next step is validation from outside the LAN, not exposing apps directly.
- Reverse proxy is useful where needed, but public exposure should be minimized.
- Router limitations should shape the design instead of forcing brittle workarounds.

## Storage Separation

Decision: separate persistent infrastructure storage from replaceable media/bulk storage.

Implications:

- `/mnt/core` is the source of truth.
- `/media` is the active media-node bulk layout.
- `/storage` remains historical or architecture-level language unless recreated by an explicit future migration.
- Critical operational state must not exist only on media disks.

## Stabilize Before Expanding

Decision: the media node must pass stabilization before adding more services.

Implications:

- qBittorrent, Prowlarr, Sonarr, Radarr, Jellyfin, and Kodi are the active stabilization scope.
- Bazarr and Overseerr wait until import and playback behavior is proven.
- Lidarr, Readarr, books, audiobooks, music, and emulator work wait for layout and backup decisions.

## Documentation Is Infrastructure

Decision: operational docs should be treated as part of the system.

Implications:

- Raw exports are preserved, but canonical Markdown docs should hold the usable truth.
- Every canonical doc should state status, last reviewed date, source docs, and next action.
- The docs should support future rebuilds, not just describe past conversations.
