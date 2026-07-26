# Architecture Decisions

Status: Current
Last reviewed: 2026-07-25
Source docs:
- Archive_Plan 05.05.26.txt
- Server Plan 21.05.26.md
- Media Stack Stabilization 23.05.26.md
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
- Syncthing Recovery and Architecture Update, 2026-07-25
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
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
- [ADR 0016: Docker Networking Strategy](ADR/0016-docker-networking-strategy.md)
- [ADR 0018: Docker Container Paths Must Match Container Mounts](ADR/0018-container-visible-paths-for-docker.md)
- [ADR 0019: Shared Storage Requires Workload Ownership And Mount Verification](ADR/0019-shared-storage-workload-ownership-and-mount-verification.md)

Proposed ADRs:

- [ADR 0017: Public Onboarding And Member Maintenance Portals](ADR/0017-public-onboarding-and-member-maintenance-portals.md)

## Persistent Data Is Sacred

Decision: containers are disposable, but service data is not.

Implications:

- Configs, databases, compose stacks, exports, backups, and operational docs belong under `/mnt/core`.
- Docker applications must use container-visible bind mount paths in their own configuration.
- Docker writable layers are not persistent storage and must not be the only location for service data.
- Rebuildability is preferred over patching unclear legacy service state.
- Backup and restore procedures are part of the infrastructure, not optional housekeeping.

## Container-Visible Paths

Decision: Docker service configuration must use paths visible inside the container, not host paths, unless the host path is explicitly bind-mounted at the same location.

Implications:

- Compose bind mounts and application-level folder settings must be reviewed together.
- Runbooks should document host paths and container paths for persistent data.
- Syncthing uses `/sync/github`, `/sync/obsidian`, and `/sync/school` inside the container, backed by `/mnt/core/data/sync/...` on the host.
- The failed `misplaced-data-2026-07-25.tar.gz` archive is not a valid backup.
- The validated `/var/backups/syncthing-rescue/overlay-direct` rescue remains temporary incident evidence until peer synchronization is confirmed healthy.

## Shared Storage Ownership And Mount Verification

Decision: shared `/mnt/core` visibility does not define workload ownership, and mountpoint directory existence does not prove the expected NFS filesystem is mounted.

Implications:

- Verify `hostname` before running host-specific Docker/Compose operations.
- Verify `/mnt/core` with `findmnt -T /mnt/core` before container startup, recreation, restore, or destructive operations involving critical data.
- Workload ownership must be documented separately from Compose file location.
- Media stack Compose files visible from VM100 still belong to MediaCenter.
- Syncthing Compose files visible from MediaCenter still belong to VM100 `services`.
- Docker socket activation must not be confused with Docker workloads starting.

## VPN-First Access

Decision: services should be internal-first and exposed through VPN unless there is a clear reason otherwise.

Implications:

- WireGuard is the remote access entrypoint.
- WireGuard is operational; applications remain internal unless explicitly approved for exposure.
- Reverse proxy is useful where needed, but public exposure should be minimized.
- Router limitations should shape the design instead of forcing brittle workarounds.

## Docker Networking Strategy

Decision: use a shared Docker bridge network named `proxy` for services that must be reachable by Nginx Proxy Manager or other user-facing infrastructure. Use a single wildcard Let's Encrypt certificate for `*.dustynest.com` unless a service has a specific technical requirement for its own certificate.

Implications:

- Reverse proxy rules should prefer container names on the `proxy` network over VM IP addresses when both containers share that network.
- Compose-created default networks remain acceptable for private stack-internal communication.
- The `proxy` network supplements project-specific networks; it does not replace isolation between tightly coupled internal services.
- Nginx Proxy Manager owns wildcard certificate renewal for `*.dustynest.com`.
- New Proxy Hosts should use functional subdomains such as `db.dustynest.com`, `cloud.dustynest.com`, `media.dustynest.com`, or `requests.dustynest.com`.
- New user-facing deployments should join `proxy` from the outset.
- Existing services can be migrated opportunistically during routine maintenance.

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
- `/storage` is the doctrine-level bulk/media data category.
- `/media` is the active media-node implementation path for libraries, downloads, and cache.
- Critical operational state must not exist only on media disks.

## Application Domain Split

Decision: treat VM100 and the media node as separate application domains.

Implications:

- VM100 remains the core services platform; it should not be eliminated just because the media node exists.
- VM100 owns infrastructure, identity/security, knowledge, utilities, automation, monitoring, personal cloud services, and backup orchestration.
- The media node owns acquisition, organization, discovery, serving, playback, reading, and preservation workloads.
- The media node is also a living-room appliance and should not automatically suspend or hibernate.
- MediaCenter remote administration is provided by RustDesk; Onboard is retained as a local mouse-driven keyboard fallback.
- Media services should not drift back into VM100 unless there is a deliberate reason.
- Compose definitions visible from shared `/mnt/core` must not be deployed from the wrong host.

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

- qBittorrent, Prowlarr, Sonarr, Radarr, Jellyfin, Kodi, and Seerr form the intended media core and were proven in the July 9 baseline.
- Seerr is the primary request interface; routine users should rarely need Sonarr or Radarr directly.
- During July 25 maintenance, Seerr was restored after MediaCenter `/mnt/core` mount repair and media-stack restart; it reported ready on port 5055 with restart count 0.
- Lidarr, Bazarr, Readarr, Audiobookshelf, and Kavita are the immediate expansion scope.
- SoulSync will complement Lidarr: SoulSync supports discovery while Lidarr handles acquisition.
- Emulator work remains later than the current music and reading expansion.

## Media Frontend And Backend

Decision: Jellyfin is the central media backend and Kodi is the living-room frontend.

Implications:

- Kodi uses Arctic Fuse 3.
- Kodi UI polishing waits until the remaining ecosystem is deployed.
- Jellyfin remains responsible for the central libraries and media serving.
- MediaCenter must keep active Jellyfin/Firefox playback visible; X11 screensaver and DPMS blanking should be disabled separately from system sleep policy.

## Knowledge Authoring

Decision: Obsidian replaces AFFiNE as the primary technical knowledge environment, while GitHub remains the canonical version-controlled repository.

## Baserow Structured Data

Decision: Baserow is the canonical home for structured relational data in the knowledge ecosystem.

Implications:

- The Admin Workspace tracks operational metadata such as infrastructure inventory, service registry, backup management, architecture, SSL/domains, and credential references.
- The Personal Workspace tracks day-to-day personal data such as theatre attendance, convention planning, collections, media tracking, projects, reading lists, and writing projects.
- Credentials may be referenced by name and Vaultwarden location, but passwords remain in Vaultwarden.
- Future shared workspaces should have explicit permissions and stay separate from server administration data.

## Proposed Portal Architecture

Proposal: create a public onboarding portal and a VPN-only member maintenance portal.

Implications if accepted:

- The public onboarding portal becomes the only intentionally public-facing front door.
- Internal services remain VPN-first and are not exposed through the public portal.
- The member maintenance portal serves authenticated users already connected through WireGuard, optionally with Authelia or equivalent identity management.
- Baserow becomes the canonical metadata source for portal service listings, announcements, downloads, categories, and access-request records.
- n8n may later automate synchronization between Baserow, generated portal content, access-request handling, and WireGuard peer metadata.

## Documentation Is Infrastructure

Decision: operational docs should be treated as part of the system.

Implications:

- Raw exports are preserved, but canonical Markdown docs should hold the usable truth.
- Every canonical doc should state status, last reviewed date, source docs, and next action.
- The docs should support future rebuilds, not just describe past conversations.

## Open Decisions

These are not accepted architecture yet. Track them separately until the decision and rationale are clear:

- Authentication: scope of Authelia integration and which services require SSO/MFA.
- Portal architecture: public onboarding portal and member maintenance portal remain proposed until ADR 0017 is accepted or rejected.
- Monitoring: final monitoring stack, alerting strategy, and metrics retention.
- Backup: retention policy, off-site backup strategy, and restore testing cadence.
- Knowledge ecosystem: final AFFiNE archival or decommissioning role relative to Obsidian.
- Platform organization: exact migration plan from `/mnt/core/stacks` to `/mnt/core/services`.
- Media storage: confirm the backing device for `/media` before large imports or downloads.
- Baserow pgvector: decide whether assistant/embedding functionality justifies a PostgreSQL image/build change.
- Update automation: design guarded n8n updates with host, mount, backup, validation, and rollback gates.
