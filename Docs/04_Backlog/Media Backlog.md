# Media Backlog

Status: Current
Last reviewed: 2026-10-04
Source docs:
- Media Stack Stabilization 23.05.26.md
- Current State of the Homelab (July 2026)
- medianode-output_09072026.txt
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
- MediaCenter maintenance record, 2026-10-04
Next action: Rotate the exposed WireGuard private key with the peer configuration coordinated; investigate the extra `192.168.0.0/24` AllowedIPs entry separately.

## Completed Foundation

- Debian 13, SSH, Docker, and persistent mounts configured.
- `/mnt/core` mounted and `/media` taxonomy created.
- qBittorrent and Prowlarr configured.
- Sonarr fully configured; downloads, imports, and Jellyfin notifications verified with *Firefly* and *Galavant*.
- Radarr fully configured and connected to Prowlarr, qBittorrent, Jellyfin, and Seerr.
- Jellyfin libraries, imports, and playback verified.
- Kodi installed with Arctic Fuse 3 as the living-room frontend to Jellyfin.
- Seerr was fully configured as the primary request interface during the July 9 baseline.
- End-to-end Seerr-to-Kodi media workflow was proven operational during the July 9 baseline.
- MediaCenter `/mnt/core` ghost local tree was backed up, validated, and removed; real NFS-backed `/mnt/core/services/media` restored.
- Jellyfin, Prowlarr, qBittorrent, Radarr, Sonarr, and Seerr returned successfully with zero restart counts.
- Seerr reported `Server ready on port 5055` and HTTP returned `307 -> /login`.
- RustDesk upgraded to 1.4.9, enabled, active, and configured for unattended access from the laptop.
- RustDesk Server now runs separately in PVE LXC 103. The owner reports pointing clients to it during maintenance and multiple successful sessions, including phone-to-desktop. MediaCenter's earlier public-server config predates that report. See [RustDesk Server Maintenance](../02_Runbooks/RustDesk%20Server%20Maintenance.md) and the [2026-09-30 fleet report](../06_Operations/Update%20Reports/2026-09-30.md).
- The owner reports that Jellyfin's full library scan completed successfully after the 12.x update.
- Onboard installed as local on-screen keyboard fallback.
- System sleep, suspend, hibernate, and hybrid sleep targets masked for always-on appliance behavior.
- X11 screensaver and DPMS disabled in the live session after Jellyfin/Firefox display blanking was confirmed.
- DualShock 4 verified working over Bluetooth for Kodi navigation; see [MediaCenter maintenance record, 2026-10-04](../02_Runbooks/MediaCenter%20Maintenance%202026-10-04.md).
- MediaCenter WireGuard IPv4, route, and internal DNS repair verified; NetworkManager remains authoritative for `wg0`. See the dated maintenance record for diagnosis and expected split-tunnel settings.

## Immediate Repair Or Verification

- Rotate the exposed MediaCenter WireGuard private key and coordinate the change with the peer configuration. Do not put the key in repository documentation.
- Investigate the source and intended purpose of the extra `192.168.0.0/24` WireGuard AllowedIPs entry before changing the working configuration.
- Verify `xset s off` and `xset -dpms` persist across MediaCenter logout and reboot; make them autostart for the X11 session if needed.
- Retain `/var/backups/mediacenter/core-ghost-2026-07-25.tar.gz` until rollback requirements have passed.
- Continue verifying media-stack restart counts after the mount repair.

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
- Verify `/mnt/core` with `findmnt -T /mnt/core` before media-stack maintenance.
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
