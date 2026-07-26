# Reboot Validation

Status: Draft
Last reviewed: 2026-07-25
Source docs:
- Media Stack Stabilization 23.05.26.md
- to-do list 17.05.26.md
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
Next action: Verify MediaCenter X11 display-blanking disablement persists across reboot after a checkpoint exists.

## Purpose

Validate that required mounts, Docker, and containers recover without manual intervention after reboot.

MediaCenter note: the July 25 approximately 15:20 reboot was manually initiated during troubleshooting because the host had become unreachable/unresponsive. Do not treat that reboot itself as an unexplained spontaneous reboot.

## Before Reboot

Record:

- Current `/mnt/core` and `/media` mount state.
- `findmnt -T /mnt/core` output, not merely `ls /mnt/core`.
- Device mapping for root, `/mnt/core`, and `/media`.
- Docker container list, restart policies, bind mounts, and networks.
- Running media services and their expected URLs or ports.
- Current backup/checkpoint location.
- Current `systemctl is-enabled sleep.target suspend.target hibernate.target hybrid-sleep.target` state.
- Current X11 screensaver and DPMS state from `xset q` in the `mediacenter` graphical session.

Do not reboot as a validation step until a checkpoint exists.

## After Reboot

Validate:

- `/mnt/core` is mounted.
- `/mnt/core` is backed by `192.168.0.75:/mnt/core` over NFSv4.
- `/media` is mounted.
- Docker is running.
- qBittorrent, Prowlarr, Sonarr, Radarr, Jellyfin, and Kodi-related services recover as expected.
- Containers did not start with empty replacement config directories.
- Disk usage is visible for root, `/mnt/core`, and `/media`.
- Logs do not show repeated restart loops.
- Sleep, suspend, hibernate, and hybrid sleep targets remain masked if the appliance always-on policy still applies.
- X11 screensaver timeout remains `0` and DPMS remains disabled if the no-display-blanking policy has been made persistent.
- RustDesk remains enabled and active.
- Seerr is not in a repeated `exitCode=1` restart loop.

Known July 25 boot-order result:

```text
/mnt/core mounted:             16:25:58
docker.service began starting: 16:25:58
docker.service active:         16:26:01
```

The Docker socket may activate earlier than `docker.service`. Do not interpret `docker.socket` alone as proof that Docker workloads started before `/mnt/core`.

## Pass Condition

The media node passes reboot validation when `/mnt/core`, `/media`, Docker, and existing media containers recover without manual intervention and without path substitution.

For living-room playback readiness, the node also passes only when active Jellyfin/Firefox playback does not blank the physical display due to X11 screensaver or DPMS behavior.

## Failure Handling

If a service starts before a required mount is available, stop expansion and fix startup ordering before troubleshooting application behavior.
