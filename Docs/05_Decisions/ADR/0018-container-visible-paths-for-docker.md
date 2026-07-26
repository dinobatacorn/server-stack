# ADR 0018: Docker Container Paths Must Match Container Mounts

Status: Accepted
Date: 2026-07-25

## Context

Syncthing was configured with folder paths such as `/mnt/core/data/sync/github` from inside the Docker container. The container did not mount `/mnt/core` at that path; it mounted `/mnt/core/data/sync/config` as `/config` and `/mnt/core/data/sync` as `/sync`.

Because the configured paths were host paths rather than container-visible paths, Syncthing wrote data into the container's writable OverlayFS layer instead of the intended persistent NFS-backed `/mnt/core` tree.

The data was recovered, independently checksum-verified, restored to `/mnt/core`, and Syncthing was reconfigured to use `/sync/...` paths.

## Decision

Docker application configuration must use paths as visible inside the container.

Host filesystem paths may be used inside an application's configuration only when those host paths are explicitly mounted into the container at the same path.

Persistent Docker service data must land on documented bind mounts under `/mnt/core`, not in Docker writable layers.

Persistent mount documentation must include both sides:

```text
host source -> container destination
```

For Syncthing:

| Host / NFS path | Container / Syncthing path |
| --- | --- |
| `/mnt/core/data/sync/github` | `/sync/github` |
| `/mnt/core/data/sync/obsidian` | `/sync/obsidian` |
| `/mnt/core/data/sync/school` | `/sync/school` |
| `/mnt/core/data/sync/config` | `/config` |

## Consequences

Compose files and application-level folder settings must be reviewed together. A bind mount is not enough by itself; the application must also reference the mounted path it can actually see.

Recovery work should treat Docker writable layers as ephemeral incident evidence, never as acceptable long-term storage.

Runbooks for Docker services should document both host paths and container paths whenever persistent data is involved.

This rule does not replace host and mount verification. For workloads on shared `/mnt/core`, also confirm the canonical host and actual mounted filesystem before running Docker operations.

## Alternatives Considered

- Configure applications with host paths for readability. Rejected because containers do not automatically see host paths.
- Mount the full host `/mnt/core` tree into every container. Rejected because it broadens access unnecessarily and weakens service isolation.
- Rely on Docker writable layers temporarily. Rejected because containers are disposable and writable layers are not part of the backup or rebuild contract.

## Related Decisions

- [ADR 0001: Storage Taxonomy And `/mnt/core` Source Of Truth](0001-storage-taxonomy.md)
- [ADR 0004: Containers Are Disposable](0004-containers-are-disposable.md)
- [ADR 0015: Syncthing And Nextcloud Coexistence](0015-syncthing-and-nextcloud.md)
- [ADR 0019: Shared Storage Requires Workload Ownership And Mount Verification](0019-shared-storage-workload-ownership-and-mount-verification.md)
