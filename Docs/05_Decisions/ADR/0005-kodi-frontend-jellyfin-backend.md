# ADR 0005: Kodi Frontend And Jellyfin Backend

Status: Accepted
Date: 2026-07-09

## Context

The media stack needs a clear split between library serving and living-room experience.

## Decision

Jellyfin is the central media backend and server. Kodi is the primary couch/living-room frontend and user experience.

When Jellyfin is used directly in Firefox on MediaCenter, active playback must also remain visible. X11 screensaver and DPMS display blanking should not interrupt living-room playback.

## Consequences

Jellyfin should focus on libraries, metadata, serving, integrations, and playback backend behavior. Kodi can be polished as the actual living-room interface without forcing Jellyfin to be the primary couch UI.

MediaCenter display blanking is a graphical-session issue, not the same as system suspend. Disabling system sleep does not by itself prevent the physical display from powering down.

## Alternatives Considered

- Use Jellyfin UI as the primary living-room interface. Rejected because Kodi provides the desired couch experience.
- Treat Kodi as optional afterthought. Rejected because it is the intentional frontend.
