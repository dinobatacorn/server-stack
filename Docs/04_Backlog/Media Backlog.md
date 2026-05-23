# Media Backlog

Status: Current
Last reviewed: 2026-05-23
Source docs:
- to-do list 17.05.26.md
- Media Stack Stabilization 23.05.26.md
Next action: Complete media stack stabilization before adding remaining media services.

## Active Blockers

- Create known-good checkpoint.
- Verify reboot persistence.
- Document mount relationships.
- Verify SMART monitoring.
- Configure automatic updates policy.
- Verify permissions and UID/GID behavior.
- Verify qBittorrent completed/incomplete/category behavior.
- Configure Sonarr/Radarr root folders, profiles, import behavior, and recycle bins.
- Test Jellyfin direct play and Intel QuickSync transcoding.
- Test at least one backup restore.

## Completed Or Partially Complete

Completed:

- Debian 13 installed.
- SSH configured.
- Docker configured.
- Persistent mounts configured.
- `/mnt/core` mounted.
- `/media` taxonomy established.
- qBittorrent deployed.
- Prowlarr deployed.
- Sonarr deployed.
- Radarr deployed.
- Jellyfin deployed.

In progress:

- Reboot persistence validation.
- Duplicate/legacy directory overlap cleanup.
- qBittorrent category strategy.
- qBittorrent completed/incomplete behavior.
- Prowlarr working indexers.
- Kodi local playback.
- Existing movie/TV/anime organization.

## Expansion Blocked Until Stabilization Passes

Acquisition:

- Lidarr
- Readarr
- Bazarr
- Overseerr

Reading and archival:

- Kavita
- Audiobookshelf
- Calibre or Calibre-Web

Emulator and ROM layer:

- Restore ROM collections.
- Restore BIOS files.
- Configure RetroArch.
- Configure standalone emulators.
- Configure controller mappings.
- Configure shader packs.
- Configure save-state backups.
- Configure metadata scraping.
- Integrate emulator launching into Kodi.

Optional/future:

- Recyclarr
- Tdarr
- GTX 1060 transcoding optimization
- Automated media quality management
- Custom dashboard ecosystem

## Data Migration

Do only after backups and imports are proven:

- Finalize archival layout.
- Organize music library.
- Organize audiobook library.
- Normalize naming conventions.
- Import existing media into Sonarr/Radarr.
- Preserve subtitles, artwork, NFO files, and watched-state metadata where possible.
