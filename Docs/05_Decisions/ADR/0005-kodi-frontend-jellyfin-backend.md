# ADR 0005: Kodi Frontend And Jellyfin Backend

Status: Accepted
Date: 2026-07-09

## Context

The media stack needs a clear split between library serving and living-room experience.

## Decision

Jellyfin is the central media backend and server. Kodi is the primary couch/living-room frontend and user experience.

## Consequences

Jellyfin should focus on libraries, metadata, serving, integrations, and playback backend behavior. Kodi can be polished as the actual living-room interface without forcing Jellyfin to be the primary couch UI.

## Alternatives Considered

- Use Jellyfin UI as the primary living-room interface. Rejected because Kodi provides the desired couch experience.
- Treat Kodi as optional afterthought. Rejected because it is the intentional frontend.
