# ADR 0008: Reading Is Separate From Video

Status: Accepted
Date: 2026-07-09

## Context

Books, comics, manga, PDFs, and audiobooks do not fit cleanly into a video-server model.

## Decision

Use purpose-built reading services instead of forcing reading into Jellyfin:

- Kavita for ebooks, manga, and comics.
- Audiobookshelf for audiobooks.
- Calibre or Calibre-Web after evaluation.
- Readarr for book acquisition.

## Consequences

Reading gets interfaces optimized for the content type. Jellyfin remains the video/music media backend rather than a catch-all.

## Alternatives Considered

- Put books into Jellyfin. Rejected because it weakens the user experience and blurs service responsibilities.
