# MediaCenter Maintenance

Status: Current maintenance record
Last reviewed: 2026-09-30
Source docs:
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
- Media Node Inventory.md
- Media Stack Stabilization.md
Next action: Review root storage before image pulls, confirm `/media` backing storage, and check a migrated RustDesk client connection.

## Purpose

This runbook records the 2026-07-25 MediaCenter maintenance session and the current living-room appliance policy.

Host:

```text
hostname: media
user: mediacenter
OS: Debian 13 Trixie
role: dedicated living-room media node, Jellyfin playback host, and media services host
```

## Session Goals

1. Make MediaCenter remotely manageable from the laptop without TV-side approval.
2. Add a usable local input fallback because MediaCenter normally has only a Bluetooth mouse.
3. Investigate apparent sleep or display shutdown behavior.
4. Ensure the machine cannot automatically suspend or hibernate.
5. Fix display blanking during active Jellyfin/Firefox playback.
6. Identify unrelated health issues encountered during troubleshooting.

Additional work later in the same maintenance window:

7. Repair MediaCenter `/mnt/core` mount safety after discovering a local ghost tree.
8. Confirm media-stack update procedure and restore Seerr.
9. Reboot-test mount ordering before Docker workloads.

## RustDesk

Initial state discovered:

- RustDesk was already installed as a native Debian package.
- Package: `rustdesk 1.4.8 amd64`.
- Binary: `/usr/bin/rustdesk`.
- systemd unit: `/usr/lib/systemd/system/rustdesk.service`.
- Service state: enabled and active.
- Logs: `~/.local/share/logs/RustDesk/`.

RustDesk was not installed through Flatpak or Snap. Flatpak itself is not installed.

APT reported:

```text
Installed: 1.4.8
Candidate: 1.4.8
100 /var/lib/dpkg/status
```

Therefore RustDesk was a manually installed `.deb` with no configured APT repository supplying updates.

The official RustDesk GitHub release API was queried during the maintenance session, and the latest available package at the time was:

```text
rustdesk-1.4.9-x86_64.deb
```

RustDesk was upgraded with the official 1.4.9 `.deb`.

Verification:

```text
rustdesk --version -> 1.4.9
systemctl is-enabled rustdesk -> enabled
systemctl is-active rustdesk -> active
```

Permanent-password unattended access was configured through the GUI.

Current RustDesk state:

- RustDesk 1.4.9.
- Native Debian package.
- systemd enabled and active.
- Laptop can remotely administer MediaCenter without local approval at the TV.
- RustDesk's keep-screen-awake behavior for incoming sessions is enabled/useful.
- IP whitelisting was considered and intentionally deferred.

## Local Input Fallback

Problem: RustDesk security/configuration changes sometimes require sudo or local authentication, but MediaCenter normally has only a Bluetooth mouse and no physical keyboard.

Installed:

```text
onboard
```

Onboard provides an on-screen keyboard usable with the Bluetooth mouse.

It was used successfully to authenticate locally and finish configuring RustDesk permanent-password access.

Onboard should remain installed as the local emergency keyboard/input method.

## Tool Audit

Confirmed installed or available:

- `curl`
- `git`
- `htop`
- `btop`
- `nano`
- `vim`
- `jq`
- `wget`
- `unzip`
- `rustdesk`

Flatpak is not installed. This is not currently a problem.

## SMART And PATH Note

During tool audit, `smartctl` initially appeared missing from:

```bash
command -v smartctl
```

However, `smartmontools` was already installed at the newest Debian package version.

Binary:

```text
/usr/sbin/smartctl
```

Verification:

```text
sudo smartctl --version -> smartctl 7.4
```

Reason it appeared missing: the `mediacenter` interactive SSH PATH currently contains:

```text
/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
```

It does not include:

```text
/usr/sbin
```

No package fix was required. Use `sudo smartctl ...`.

## System Sleep Policy

Desired appliance policy:

- MediaCenter must remain available continuously.
- Automatic suspend: no.
- Automatic hibernate: no.
- Automatic hybrid sleep: no.
- SSH, Docker, Jellyfin, and RustDesk should remain reachable.
- Manual shutdown and reboot remain available.

Applied:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

Verification:

```text
systemctl is-enabled sleep.target suspend.target hibernate.target hybrid-sleep.target
masked
masked
masked
masked
```

This is intentional permanent appliance behavior unless requirements change.

To reverse:

```bash
sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

## `/mnt/core` Mount Safety

Critical mount:

```text
192.168.0.75:/mnt/core -> /mnt/core
Filesystem: NFSv4
```

Failure mode discovered: Docker could operate while the real NFS-backed `/mnt/core` filesystem was absent. Because `/mnt/core` still existed locally as a mountpoint directory, applications could write into the underlying local filesystem. When the real NFS mount returned, those local files were hidden beneath it.

This produced a local ghost tree:

```text
/mnt/core/services
```

Recovery performed:

1. Docker was stopped before destructive cleanup.
2. The accidentally local MediaCenter data was identified.
3. A backup was created:

```text
/var/backups/mediacenter/core-ghost-2026-07-25.tar.gz
```

4. The backup was tested before deleting the source.
5. The ghost local `/mnt/core/services` tree was removed only after backup validation.
6. The actual `/mnt/core` NFS filesystem was restored.
7. The real media configuration tree became visible again:

```text
/mnt/core/services/media
```

Observed size:

```text
approximately 238 MB
```

8. Docker was restarted.

Operational rule:

```bash
findmnt -T /mnt/core
```

Do not use the existence of `/mnt/core` or successful `ls` output as proof that the NFS filesystem is mounted.

Before destructive cleanup involving a mountpoint, identify the actual mounted filesystem first.

## Boot-Order Verification

MediaCenter was reboot-tested after the `/mnt/core` repair.

Observed timing:

```text
/mnt/core mounted:             16:25:58
docker.service began starting: 16:25:58
docker.service active:         16:26:01
```

The critical NFS filesystem was available before Docker workloads actually began using it.

Important distinction: `docker.socket` may become active earlier and should not by itself be interpreted as evidence that Docker workloads started before `/mnt/core`.

## Media Compose Update

Canonical media Compose deployment:

```text
/mnt/core/services/media
```

Normal update procedure:

```bash
cd /mnt/core/services/media
docker compose pull
docker compose up -d
docker compose ps
```

After the repair and update, these services were running with zero restart counts:

```text
Jellyfin
Prowlarr
qBittorrent
Radarr
Sonarr
Seerr
```

LinuxServer containers were recreated during the update. Seerr did not require recreation during that particular update because its existing image/container state was already current.

Seerr reported:

```text
Server ready on port 5055
```

HTTP produced the expected:

```text
307 -> /login
```

## Jellyfin Storage

Verified important Jellyfin mappings:

```text
/mnt/core/services/media/serving/jellyfin -> /config
/media/library                            -> /media
/media/cache/transcode                    -> /transcode
```

Critical Jellyfin configuration therefore resides under `/mnt/core`; media and transcoding data use the media-storage filesystem.

Current media library categories include:

```text
/media/library/movies
/media/library/tv
/media/library/anime
/media/library/books
/media/library/youtube
/media/library/home-videos
/media/library/music
/media/library/audiobooks
/media/library/podcasts
/media/library/roms
```

Confirmed existing movie directory:

```text
/media/library/movies/The Prince of Egypt (1998)
```

## XFCE Power Manager Observations

XFCE is running on the graphical session.

Detected:

```text
xfce4-power-manager
```

Observed XFCE power-manager settings before system sleep targets were masked:

```text
/xfce4-power-manager/dpms-on-ac-off                 60
/xfce4-power-manager/dpms-on-ac-sleep               60
/xfce4-power-manager/lock-screen-suspend-hibernate  false
/xfce4-power-manager/power-button-action            3
```

System sleep targets were available as normal static systemd targets before masking.

## July 25 Reboot Investigation

Journal boots showed:

```text
previous boot: 2026-07-10 10:23:20 through 2026-07-25 15:20:16
current boot:  began 2026-07-25 15:20:36
```

There were no normal suspend or hibernate messages at the previous boot boundary.

Important clarification: the July 25 approximately 15:20 reboot was manually initiated during troubleshooting because MediaCenter had become unreachable/unresponsive beforehand.

Do not document the July 25 reboot itself as an unexplained spontaneous reboot.

There had also been a power surge around July 10, which may explain the July 10 boot boundary, but that connection has not been verified.

## Display Blanking Policy

Separate problem discovered after system sleep was disabled:

While actively watching a musical through Jellyfin in Firefox, the physical MediaCenter display went dark approximately 25 minutes into playback. The video continued playing while the display was off.

Therefore:

- The computer had not suspended.
- Jellyfin playback had not stopped.
- Display blanking/power management was independently shutting off the display during active media playback.

This is unacceptable for MediaCenter's living-room playback role.

Live X11 state before modification:

```text
Screen Saver:
  timeout: 600
  cycle: 600

DPMS:
  Standby: 3600
  Suspend: 0
  Off: 3600
  DPMS is Enabled
```

Temporary diagnostic change applied to graphical display `:0`:

```bash
DISPLAY=:0 XAUTHORITY=/home/mediacenter/.Xauthority xset s off
DISPLAY=:0 XAUTHORITY=/home/mediacenter/.Xauthority xset -dpms
```

Verified afterward:

```text
Screen Saver:
  timeout: 0

DPMS:
  DPMS is Disabled
```

The stored standby/off timeout values can still appear in `xset q`, but they are inactive while DPMS is disabled.

Result: Jellyfin/Firefox playback continued normally and the display no longer went dark during the subsequent test period.

Conclusion: X11 screensaver/DPMS behavior was responsible for the unwanted display blanking.

Important follow-up: the `xset` changes were applied as a live-session diagnostic change. Verify whether they survive logout and reboot. If not, make the equivalent of `xset s off` and `xset -dpms` apply automatically to the MediaCenter X11 graphical session at login/startup.

Desired permanent graphical policy:

- Do not automatically blank the display because of user inactivity.
- Do not automatically DPMS-power-off the display.
- Active video must remain visible regardless of mouse/keyboard inactivity.
- The TV itself can handle its own display, input, and power behavior.
- System suspend/hibernate remains separately blocked through systemd masks.

Do not confuse these layers:

1. systemd masks prevent the computer from sleeping.
2. `xset`/X11 configuration prevents the display from blanking or powering down.

## Seerr Health History

During journal inspection, Seerr was found in a severe crash/restart loop.

Observed container:

```text
seerr
```

Example state:

```text
exitCode=1
restartPolicy="{unless-stopped 0}"
restartCount=21712
```

It appeared to be crashing and restarting approximately once per minute.

This was resolved later in the maintenance window after the `/mnt/core` ghost tree was backed up and removed, the real NFS-backed `/mnt/core` tree was restored, and the media stack was restarted from its canonical `/mnt/core/services/media` deployment.

Do not assume the July 10 power surge caused the Seerr failure without diagnosis. The user noted a power surge around July 10 and later found Seerr down, but causality is unverified.

If Seerr enters this state again:

1. Inspect container state.
2. Inspect recent and startup logs.
3. Verify config/database persistence.
4. Verify mounts and permissions.
5. Identify the `exitCode=1` cause.
6. Preserve `/mnt/core` persistent data before any destructive or redeploy action.
7. Prefer clean redeploy after preserving and validating data if container state itself is damaged.

## Current End State

RustDesk:

- 1.4.9.
- Native Debian package.
- systemd enabled and active.
- Permanent-password unattended access configured.
- Laptop can administer MediaCenter without local approval.

Local accessibility:

- Onboard installed.
- Bluetooth mouse plus Onboard provides keyboard fallback.

System power:

- `sleep.target` masked.
- `suspend.target` masked.
- `hibernate.target` masked.
- `hybrid-sleep.target` masked.

Display:

- X screensaver disabled in the live session.
- DPMS disabled in the live session.
- Jellyfin/Firefox playback test appears successful after disabling them.
- Persistence across reboot/login still needs explicit verification or configuration.

Media stack:

- Jellyfin, Prowlarr, qBittorrent, Radarr, Sonarr, and Seerr running.
- Restart counts 0 after repair/update.
- Seerr ready on port 5055 and HTTP returns `307 -> /login`.

Known outstanding issue:

- X11 screensaver/DPMS persistence across reboot/login still needs explicit verification or configuration.

## 2026-09-28/29 Fleet Maintenance Addendum

- Debian packages were updated; the user subsequently ran `apt-get dist-upgrade` and rebooted. The running kernel was verified as `6.12.107+deb13-amd64`.
- Docker images were refreshed separately for Jellyfin, Sonarr, Radarr, qBittorrent, Prowlarr, and Seerr. The six containers were restarted and each configured local web port returned its expected response: Jellyfin `302`, Sonarr `200`, Radarr `200`, qBittorrent `200`, Prowlarr `200`, and Seerr `307`.
- Jellyfin moved to the 12.x major line. Jellyfin Enhanced was replaced with the compatible 12 ABI build `12.9.0.0`. The owner reports that the full library scan completed and the service appears good; no scan log was supplied.
- Root storage after image refresh was 216 GB total, 195 GB used, 11 GB available (95%). A consistent 232 MB appdata archive was created with the Compose project stopped and passed `zstd -t`; this and other recovery archives are on PVE's `/mnt/core`, not offsite. Do not pull further images until root storage is reviewed and the old-image rollback window is cleared.
- A post-reboot host inventory and post-image appdata archive are summarized in [Fleet Update Report 2026-09-28](../06_Operations/Update%20Reports/2026-09-28.md). The package preflight did not update Docker images; the OS and image workflows remain separate steps.
- Self-hosted RustDesk Server is in PVE LXC 103. MediaCenter's last inspected RustDesk client configuration showing `rs-ny.rustdesk.com:21116` predates the owner's report of client migration and successful sessions; see [RustDesk Server Maintenance](RustDesk%20Server%20Maintenance.md).
