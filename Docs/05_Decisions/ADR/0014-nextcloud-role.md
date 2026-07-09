# ADR 0014: Nextcloud Role

Status: Accepted
Date: 2026-07-09

## Context

Nextcloud originally seemed redundant with Obsidian, Baserow, and Syncthing. Its role became clearer as the knowledge platform matured.

## Decision

Nextcloud is planned as the user-facing file platform.

Responsibilities:

- General file storage.
- Mobile access.
- File sharing.
- WebDAV.
- Collaborative files.
- Photo uploads.
- User-facing file browser.

Nextcloud is not the authoritative source for application data.

## Consequences

Nextcloud can coexist with Obsidian, Baserow, Paperless, AnythingLLM, and n8n because it has a distinct responsibility.

## Alternatives Considered

- Drop Nextcloud as redundant. Rejected because user-facing file access remains a separate need.
- Make Nextcloud the source of truth for all application data. Rejected because `/mnt/core` remains the operational source of truth.
