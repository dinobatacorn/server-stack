# ADR 0007: Music Deserves Its Own Ecosystem

Status: Accepted
Date: 2026-07-09

## Context

Music is not just another media type to download. Discovery, acquisition, management, and listening have different workflows.

## Decision

Treat music as its own ecosystem:

```text
Discovery -> Acquire -> Manage -> Listen
```

SoulSync supports discovery. Lidarr handles acquisition and library management.

## Consequences

SoulSync remains important even though Lidarr is planned. The music workflow can mature separately from movies and television.

## Alternatives Considered

- Use Lidarr alone for all music needs. Rejected because discovery and acquisition are distinct jobs.
