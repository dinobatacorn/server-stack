# ADR 0015: Syncthing And Nextcloud Coexistence

Status: Accepted
Date: 2026-07-09

## Context

Syncthing is already deployed on VM100, and Nextcloud has re-entered the planned platform. They can overlap unless their responsibilities are explicit.

## Decision

Use Syncthing for actively edited files where direct peer-to-peer synchronization is valuable, such as Obsidian vaults, development projects, and active writing.

Use Nextcloud for user-facing storage, mobile access, sharing, WebDAV, collaboration, photo uploads, and browser-based file access.

## Consequences

Both services can coexist without competing, as long as they do not become two sources of truth for the same dataset.

## Alternatives Considered

- Use only Syncthing. Rejected because it does not provide the same user-facing cloud interface.
- Use only Nextcloud. Rejected because actively edited peer-to-peer workflows may still benefit from Syncthing.
