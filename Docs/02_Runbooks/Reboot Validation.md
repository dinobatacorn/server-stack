# Reboot Validation

Status: Draft
Last reviewed: 2026-05-23
Source docs:
- Media Stack Stabilization 23.05.26.md
- to-do list 17.05.26.md
Next action: Run this once on the media node after a checkpoint exists.

## Purpose

Validate that required mounts, Docker, and containers recover without manual intervention after reboot.

## Before Reboot

Record:

- Current `/mnt/core` and `/media` mount state.
- Device mapping for root, `/mnt/core`, and `/media`.
- Docker container list, restart policies, bind mounts, and networks.
- Running media services and their expected URLs or ports.
- Current backup/checkpoint location.

Do not reboot as a validation step until a checkpoint exists.

## After Reboot

Validate:

- `/mnt/core` is mounted.
- `/media` is mounted.
- Docker is running.
- qBittorrent, Prowlarr, Sonarr, Radarr, Jellyfin, and Kodi-related services recover as expected.
- Containers did not start with empty replacement config directories.
- Disk usage is visible for root, `/mnt/core`, and `/media`.
- Logs do not show repeated restart loops.

## Pass Condition

The media node passes reboot validation when `/mnt/core`, `/media`, Docker, and existing media containers recover without manual intervention and without path substitution.

## Failure Handling

If a service starts before a required mount is available, stop expansion and fix startup ordering before troubleshooting application behavior.
