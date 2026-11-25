# MediaCenter Hidden Media Cleanup and Docker Mount Protection

**Date:** 2026-11-25  
**Host:** `media` (MediaCenter), Debian 13  
**Status:** Cleanup completed; Docker startup guard configured; Debian update and post-update reboot verification pending  
**Scope:** Documentation record from the owner-provided maintenance handoff.

## Storage layout and discovery

| Mount | Backing source | Role |
|---|---|---|
| `/` | `/dev/sdb2`, ext4, 216 GB | OS and Docker |
| `/media` | `/dev/sda1`, ext4, 1.8 TB | Libraries, downloads, media cache |
| `/mnt/core` | `192.168.0.75:/mnt/core`, NFSv4 | Persistent application configuration and databases |

The six media applications share `/mnt/core/services/media/compose/core`: Jellyfin, Sonarr, Radarr, Prowlarr, qBittorrent, and Seerr. Their configuration uses `/mnt/core/services/media/...` and bulk media uses `/media/...`; each is configured `restart: unless-stopped`.

During investigation, `df` showed root at 197 GB used (97%) and only 8.1 GB free, while `/media` and `/mnt/core` were mounted. `du -xhd1 /` accounted for about 36 GB. `lsof +L1` did not find ordinary deleted files explaining the gap; large .NET `memfd:doublemapper` mappings were not evidence of equivalent disk use. A temporary bind mount of `/` at `/run/root-inspect` exposed the root filesystem beneath `/media`: about 161 GB, comprising approximately 80 GB in downloads and 82 GB in the library. The hidden `/mnt/core` directory there was only 4 KB.

**Confirmed:** approximately 161 GB of bulk media had been written under the root filesystem beneath the active `/media` mount.

## Duplicate comparison and cleanup

Read-only rsync dry runs compared hidden media with the mounted media disk. Completed downloads had 75 entries, 62 regular files, 84,864,961,505 bytes of regular-file content, and zero regular files requiring transfer. The library comparison had 247 entries, 216 regular files, 87,424,379,415 bytes, and zero regular files requiring transfer. After the owner removed some media from the active library, a repeat comparison identified `movies/The Prince of Egypt (1998)/`, about 32.3 GB including artwork. The owner intentionally removed this title from the active library and accepted deleting its hidden duplicate.

The comparisons used size and modification time; no full checksum comparison was performed. The owner accepted this limitation before deletion.

Before removing hidden completed downloads and library content, `findmnt -T` verified `/run/root-inspect` was backed by `/dev/sdb2`, not `/dev/sda1`. The user confirmed the interactive deletion. The mounted media disk was not deleted or unmounted. The temporary inspection mount was then unmounted and removed.

| Measure | Before | After |
|---|---:|---:|
| Root used | 197 GB | 36 GB |
| Root utilization | 97% | 18% |
| Root available | 8.1 GB | 169 GB |

Approximately 161 GB was recovered. The final reported root figures round to 36 GB used and 169 GB available on a 216 GB filesystem.

## Cause investigation

During the observed boot, systemd logged that `/media` was not empty when the mount occurred. The same journal showed `/media` mounting completed before `docker.service` began. An existing Docker override dated July 28 already required `/mnt/core` and `/media` mounts and ordered Docker after them. Searches of `/etc/cron*` and `/etc/systemd/system` found no obvious scheduled media-copy job. The matching file sizes and modification times allow a historical copy/sync scenario, but do not prove it.

**Root cause is undetermined.** Do not document the possible initial write-while-unmounted and later copy sequence, or any Kodi/Jellyfin role, as established fact.

## Docker startup guard

Before editing, the existing override was backed up to `/etc/systemd/system/docker.service.d/override.conf.bak`. The applied configuration is:

```ini
[Unit]
RequiresMountsFor=/mnt/core /media
After=mnt-core.mount media.mount

[Service]
ExecStartPre=/usr/bin/mountpoint -q /media
ExecStartPre=/usr/bin/mountpoint -q /mnt/core
```

After `systemctl daemon-reload`, `systemctl show` displayed both mount checks and the required mount paths; both `mountpoint` checks passed. Docker was not restarted during the change.

A central guard was used because all six media services are in one Compose project, use `restart: unless-stopped`, and use short bind-mount syntax, which may create absent host directories. Disabling path creation alone would not detect an unmounted `/media` where underlying directories already exist.

Guard limits: it checks that paths are mountpoints, not the backing device/NFS source or writeability. It does not stop already-running containers when a mount disappears, and it does not prevent a user from manually writing under a mountpoint on root. No dedicated media Compose startup service was found. Failed-mount behavior has not been tested.

## Pending updates and verification

At handoff, the Debian update had started after cleanup; over 200 packages were reported upgradable. Completion was not provided. Docker/image updates and reboot results are also pending. Previously observed Debian 13, kernel `6.12.107+deb13-amd64`, Docker Engine `29.8.1`, and six running containers are historical pre-update observations.

After updates, verify a successful reboot with `/media` on `/dev/sda1`, `/mnt/core` from `192.168.0.75:/mnt/core`, Docker active, and all six media containers healthy and functioning. Do not mark the failed-mount guard test complete until separately observed.

## Related documentation

- [MediaCenter Maintenance](../../02_Runbooks/MediaCenter%20Maintenance.md)
- [Media Node Inventory](../../03_Inventories/Media%20Node%20Inventory.md)
- [Storage Contracts](../../01_Architecture/Storage%20Contracts.md)
- [Homelab Status](../../00_STATUS.md)
