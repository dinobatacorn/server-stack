# ADR 0006: Seerr Request Workflow

Status: Accepted
Date: 2026-07-09

## Context

Directly using Sonarr and Radarr for routine requests exposes too much operational detail to day-to-day users.

## Decision

Seerr is the primary request interface.

Normal workflow:

```text
Search -> Request -> Automation -> Watch
```

Operational flow:

```text
Seerr -> Sonarr/Radarr -> Prowlarr -> qBittorrent -> Import -> Jellyfin -> Kodi
```

## Consequences

Sonarr and Radarr become configuration and automation tools, not routine user interfaces. This simplifies normal media use.

Operational note: during 2026-07-25 maintenance, Seerr was found in a crash/restart loop with `exitCode=1` and more than 21,000 restarts observed. After the MediaCenter `/mnt/core` mount repair and media-stack restart, Seerr returned with restart count 0, reported `Server ready on port 5055`, and HTTP returned `307 -> /login`.

## Alternatives Considered

- Use Sonarr and Radarr directly. Rejected for routine use because it exposes too many implementation details.
