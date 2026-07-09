# Media Backlog

Status: Current
Last reviewed: 2026-07-09
Source docs:
- Media Stack Stabilization 23.05.26.md
- Current State of the Homelab (July 2026)
- medianode-output_09072026.txt
Next action: Confirm `/media` backing storage, then deploy Lidarr, Bazarr, Readarr, Audiobookshelf, and Kavita.

## Completed Foundation

- Debian 13, SSH, Docker, and persistent mounts configured.
- `/mnt/core` mounted and `/media` taxonomy created.
- qBittorrent and Prowlarr configured.
- Sonarr fully configured; downloads, imports, and Jellyfin notifications verified with *Firefly* and *Galavant*.
- Radarr fully configured and connected to Prowlarr, qBittorrent, Jellyfin, and Seerr.
- Jellyfin libraries, imports, and playback verified.
- Kodi installed with Arctic Fuse 3 as the living-room frontend to Jellyfin.
- Seerr fully configured as the primary request interface.
- End-to-end Seerr-to-Kodi media workflow proven operational.

## Immediate Deployment

- Confirm `/media` is backed by the intended media disk before large downloads or imports.
- Deploy Lidarr for music acquisition.
- Deploy Bazarr for subtitles.
- Deploy Readarr for book acquisition.
- Deploy Audiobookshelf for audiobooks.
- Deploy Kavita for ebooks, manga, and comics.

## After Core Deployment

- Integrate SoulSync for music discovery alongside Lidarr.
- Polish the Kodi interface.
- Import and normalize the external media drive.
- Configure automated media-service backups.
- Add media services to Homepage.

## Operational Hardening

- Create a current known-good checkpoint.
- Verify reboot persistence.
- Document live mount and device relationships, especially `/media`.
- Mount or otherwise account for the visible 1.8 TB disk if it is intended to hold media content.
- Verify SMART monitoring.
- Document automatic-update policy.
- Confirm and document shared UID/GID behavior.
- Test at least one service restore.

## Reading And Archival Decisions

- Evaluate whether Calibre or Calibre-Web adds value alongside Kavita.
- Keep optimized interfaces for ebooks, manga/comics, and audiobooks rather than forcing all formats into Jellyfin.
- Finalize music, book, audiobook, and archival naming conventions.

## Emulator And Preservation Layer

- Restore ROM collections and BIOS files.
- Configure RetroArch and required standalone emulators.
- Configure controller mappings, shaders, metadata, screenshots, and save-state backups.
- Integrate emulator launching into Kodi.

## Optional Future Work

- Recyclarr and automated quality management.
- Tdarr and GTX 1060 transcoding optimization.
- Preserve subtitles, artwork, NFO files, and watched-state metadata during migrations.
