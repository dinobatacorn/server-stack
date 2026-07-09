# Architecture Decisions

Status: Current
Last reviewed: 2026-07-09
Source docs:
- Archive_Plan 05.05.26.txt
- Server Plan 21.05.26.md
- Media Stack Stabilization 23.05.26.md
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
- ADR records in `ADR/`
Next action: Keep this page as the readable rollup; add or update individual ADRs when decisions change.

## ADR Index

Accepted decisions now live as individual Architecture Decision Records under [ADR](ADR/README.md). This page is the readable rollup.

Current ADRs:

- [ADR 0001: Storage Taxonomy And `/mnt/core` Source Of Truth](ADR/0001-storage-taxonomy.md)
- [ADR 0002: VPN-First Networking](ADR/0002-vpn-first-networking.md)
- [ADR 0003: Platform Services Node Vs Media Node](ADR/0003-platform-vs-media-node.md)
- [ADR 0004: Containers Are Disposable](ADR/0004-containers-are-disposable.md)
- [ADR 0005: Kodi Frontend And Jellyfin Backend](ADR/0005-kodi-frontend-jellyfin-backend.md)
- [ADR 0006: Seerr Request Workflow](ADR/0006-seerr-request-workflow.md)
- [ADR 0007: Music Deserves Its Own Ecosystem](ADR/0007-music-ecosystem.md)
- [ADR 0008: Reading Is Separate From Video](ADR/0008-reading-is-separate-from-video.md)
- [ADR 0009: Knowledge Ecosystem Roles](ADR/0009-knowledge-ecosystem-roles.md)
- [ADR 0010: Documentation As Operational Memory](ADR/0010-documentation-as-operational-memory.md)
- [ADR 0011: Provenance Principle](ADR/0011-provenance-principle.md)
- [ADR 0012: Codex And ChatGPT Working Model](ADR/0012-codex-chatgpt-working-model.md)
- [ADR 0013: Rebuild, Automate, Document](ADR/0013-rebuild-automate-document.md)
- [ADR 0014: Nextcloud Role](ADR/0014-nextcloud-role.md)
- [ADR 0015: Syncthing And Nextcloud Coexistence](ADR/0015-syncthing-and-nextcloud.md)

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

## Application Domain Split

Decision: treat VM100 and the media node as separate application domains.

Implications:

- VM100 remains the core services platform; it should not be eliminated just because the media node exists.
- VM100 owns infrastructure, identity/security, knowledge, utilities, automation, monitoring, personal cloud services, and backup orchestration.
- The media node owns acquisition, organization, discovery, serving, playback, reading, and preservation workloads.
- Media services should not drift back into VM100 unless there is a deliberate reason.

## Core Directory Semantics

Decision: normalize `/mnt/core` by responsibility rather than by ad hoc stack history.

Implications:

- `/mnt/core/services` contains service deployment definitions.
- `/mnt/core/appdata` contains persistent application state.
- `/mnt/core/data` contains shared user or operational data.
- `/mnt/core/config` contains host-level configuration.
- `/mnt/core/backups` contains backups and dumps.
- `/media` is exclusively bulk media content.
- `/mnt/core/stacks` is legacy and should be retired into `/mnt/core/services` over time.

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

## Open Decisions

These are not accepted architecture yet. Track them separately until the decision and rationale are clear:

- Authentication: scope of Authelia integration and which services require SSO/MFA.
- Monitoring: final monitoring stack, alerting strategy, and metrics retention.
- Backup: retention policy, off-site backup strategy, and restore testing cadence.
- Knowledge ecosystem: final AFFiNE archival or decommissioning role relative to Obsidian.
- Platform organization: exact migration plan from `/mnt/core/stacks` to `/mnt/core/services`.
- Media storage: confirm the backing device for `/media` before large imports or downloads.
