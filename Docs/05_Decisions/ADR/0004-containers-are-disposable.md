# ADR 0004: Containers Are Disposable

Status: Accepted
Date: 2026-07-09

## Context

The homelab should survive container rebuilds, image updates, and service redeployments without losing critical state.

## Decision

Never rely on a container filesystem for persistent data. Persistent storage should be bind-mounted from `/mnt/core`.

Docker named volumes are avoided unless a compelling reason is documented.

Application configuration must also use the container-visible bind mount paths. A host path such as `/mnt/core/data/...` is not safe inside a container unless it is explicitly mounted there.

The 2026-07-25 Syncthing recovery confirmed why this matters: folder paths that referenced unmounted host paths caused data to land in Docker OverlayFS rather than on persistent `/mnt/core` storage.

The 2026-07-25 MediaCenter repair confirmed a related host-level risk: if NFS-backed `/mnt/core` is absent, Docker workloads can write to a local directory underneath the mountpoint. Verify the backing filesystem before starting or repairing containers that depend on `/mnt/core`.

## Consequences

Containers can be replaced, rebuilt, or moved with less risk. Backup scope is easier to define because persistent state lives outside containers.

Destructive cleanup should stop writers, identify the actual filesystem, create and validate a backup, and only then delete or recreate data.

## Alternatives Considered

- Use container-local filesystems. Rejected because state loss becomes too easy.
- Use Docker named volumes by default. Rejected because they hide state from the standard storage taxonomy.
