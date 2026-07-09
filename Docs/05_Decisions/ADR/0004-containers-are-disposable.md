# ADR 0004: Containers Are Disposable

Status: Accepted
Date: 2026-07-09

## Context

The homelab should survive container rebuilds, image updates, and service redeployments without losing critical state.

## Decision

Never rely on a container filesystem for persistent data. Persistent storage should be bind-mounted from `/mnt/core`.

Docker named volumes are avoided unless a compelling reason is documented.

## Consequences

Containers can be replaced, rebuilt, or moved with less risk. Backup scope is easier to define because persistent state lives outside containers.

## Alternatives Considered

- Use container-local filesystems. Rejected because state loss becomes too easy.
- Use Docker named volumes by default. Rejected because they hide state from the standard storage taxonomy.
