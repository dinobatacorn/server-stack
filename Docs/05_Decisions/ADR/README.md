# Architecture Decision Records

Status: Current
Last reviewed: 2026-07-25
Source docs:
- Architecture Decisions.md
- July 2026 Homelab Checkpoint
- pve-output_09072026.txt
- vm100-output_09072026.txt
- medianode-output_09072026.txt
- Syncthing Recovery and Architecture Update, 2026-07-25
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
Next action: Add a new ADR whenever a decision changes architecture, recovery strategy, service responsibility, or source-of-truth ownership.

## Purpose

ADRs capture decisions as they happen so the documentation preserves not only what was chosen, but why it was chosen.

Each ADR should answer:

- Context: what problem or pressure led to the decision?
- Decision: what was chosen?
- Consequences: what becomes easier, harder, safer, or riskier?
- Alternatives considered: what was intentionally not chosen?

## Accepted ADRs

| ADR | Decision |
| --- | --- |
| [0001](0001-storage-taxonomy.md) | Storage taxonomy and `/mnt/core` source of truth |
| [0002](0002-vpn-first-networking.md) | VPN-first networking |
| [0003](0003-platform-vs-media-node.md) | Platform services node vs media node |
| [0004](0004-containers-are-disposable.md) | Containers are disposable |
| [0005](0005-kodi-frontend-jellyfin-backend.md) | Kodi frontend and Jellyfin backend |
| [0006](0006-seerr-request-workflow.md) | Seerr request workflow |
| [0007](0007-music-ecosystem.md) | Music deserves its own ecosystem |
| [0008](0008-reading-is-separate-from-video.md) | Reading is separate from video |
| [0009](0009-knowledge-ecosystem-roles.md) | Knowledge ecosystem roles |
| [0010](0010-documentation-as-operational-memory.md) | Documentation as operational memory |
| [0011](0011-provenance-principle.md) | Provenance principle |
| [0012](0012-codex-chatgpt-working-model.md) | Codex and ChatGPT working model |
| [0013](0013-rebuild-automate-document.md) | Rebuild, automate, document |
| [0014](0014-nextcloud-role.md) | Nextcloud role |
| [0015](0015-syncthing-and-nextcloud.md) | Syncthing and Nextcloud coexistence |
| [0016](0016-docker-networking-strategy.md) | Docker networking strategy |
| [0018](0018-container-visible-paths-for-docker.md) | Docker container paths must match container mounts |
| [0019](0019-shared-storage-workload-ownership-and-mount-verification.md) | Shared storage requires workload ownership and mount verification |

## Proposed ADRs

| ADR | Decision |
| --- | --- |
| [0017](0017-public-onboarding-and-member-maintenance-portals.md) | Public onboarding portal and member maintenance portal |

## Open Decisions

Track unresolved questions separately from accepted architecture:

- Authentication scope: which services require Authelia and MFA?
- Portal architecture: public onboarding portal and member maintenance portal are proposed in ADR 0017.
- Monitoring stack: final alerting strategy, retained metrics, and dashboard responsibilities.
- Backup policy: retention, off-site strategy, restore cadence, and ownership.
- Knowledge ecosystem: final AFFiNE archival/decommissioning role relative to Obsidian.
- Platform organization: migration plan from `/mnt/core/stacks` to `/mnt/core/services`.
- Media storage: confirm the backing device for `/media` before large imports or downloads.
