# Nobara Maintenance

Status: Draft
Last reviewed: 2026-09-29

## Scope And Known Starting Point

This procedure is for the Nobara installation on the dual-boot workstation identified in the inventory as `RavensTower`. The 2026-05-02 capture is historical; 2026-09-29 local pre/post records identify Nobara Linux 44 KDE. Confirm the hostname and OS from Nobara before every pass. Do not run Nobara steps while booted into AtlasOS.

The May capture lists two internal NVMe drives (Crucial T500 1 TB and Kingston NV2 500 GB), two HDDs (Seagate Expansion 5 TB and ST2000LM007 2 TB), and a LaCie USB drive. It does not establish current partitions, mounts, backup contents, or which drive contains Nobara. Identify the current root and backup targets before writing anything.

Latest observed result, 2026-09-29: pre/post records show kernel `7.2.6-201.nobara.fc44.x86_64` unchanged, no failed systemd units, and the post updater check reports no package updates with startup checks passed. RustDesk Flatpak `1.4.9` is listed in both application inventories. No transaction log, Flatpak update result, or explicit reboot evidence was captured; do not infer the exact packages changed or reboot status. See the [2026-09-29 fleet report](../06_Operations/Update%20Reports/2026-09-29.md).

## 1. Save A Private Pre-Update Record

Open a terminal while Nobara is running. This self-contained block creates a private text record under your home directory; it does not require the AtlasOS repository. It records identity, storage layout, active mounts, network addresses, failed systemd units, and available Nobara update checks.

```bash
umask 077
out="$HOME/nobara-maintenance"
mkdir -p -m 700 "$out"
pre="$out/RavensTower_pre_$(date +%F_%H-%M-%S).txt"
{
  echo '## Captured'; date --iso-8601=seconds
  echo '## Host and OS'; hostnamectl --static; cat /etc/os-release; uname -r
  echo '## Network'; ip -br address
  echo '## Block devices'; lsblk -o NAME,MODEL,SIZE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS
  echo '## Root and boot mounts'; findmnt -T /; findmnt /boot 2>&1 || true; findmnt /boot/efi 2>&1 || true
  echo '## Disk space'; df -hT
  echo '## Failed units'; systemctl --failed --no-pager
  echo '## Nobara update check'; nobara-sync check-repos && nobara-sync check-updates
  echo '## Flatpak applications'; flatpak list --app --columns=application,version 2>&1 || true
} 2>&1 | tee "$pre"
chmod 600 "$pre"
printf '\nPre-update record: %s\n' "$pre"
```

Review the file for private network or device details before copying it. Keep the only copy private; if you want it off this workstation, first identify and verify the intended separate backup drive by its label, UUID, and mount point. Do not assume a USB disk or `/mnt/core` is mounted. This text record is not a backup or recovery image.

If this repository happens to be available on a mounted data drive and includes `scripts/collect_linux.sh`, you may also run:

```bash
bash ./scripts/collect_linux.sh --role linux-endpoint --phase pre --output-base "$HOME/nobara-maintenance"
```

The standalone record above remains the primary step and does not depend on the repository being available.

## 2. Confirm A Recovery Path

Review the pre-record's `lsblk`, `findmnt`, and `df` sections. Confirm the root filesystem, boot partitions, free space, and the physical disk holding `/`. Confirm that irreplaceable personal files have a recent copy on separate storage and that you know how to select the AtlasOS boot entry if the update reboots the system.

Check for an existing Snapper configuration and snapshots:

```bash
findmnt -no SOURCE,FSTYPE,OPTIONS /
command -v snapper || true
sudo snapper list-configs
```

Only if root is Btrfs and `snapper list-configs` shows a configuration for `/`, use that configuration name below (the example uses `root`) to list snapshots, create a named pre-update snapshot, and verify it appears:

```bash
sudo snapper -c root list
sudo snapper -c root create --type single --description "Nobara pre-update $(date -Iseconds)"
sudo snapper -c root list
```

If there is no root snapshot configuration, do not install/configure Snapper or alter partitioning as part of this maintenance pass. A Btrfs filesystem alone does not prove a working snapshot/recovery setup. If no usable recovery path exists for personal files, pause the update and arrange a separate backup first. A same-disk filesystem snapshot is not an independent backup.

## 3. Update Nobara

Use Nobara's **Update System** application / **DNF App Center** and choose **Select All and Update** after reviewing the proposed items. Alternatively, run Nobara's updater from a terminal:

```bash
nobara-sync
```

Do not prepend `sudo`; the updater handles elevation. Do not use plain `dnf update` as the routine update method. Nobara documents that its updater handles repository checks, package synchronization, and Nobara-specific update steps. If the updater reports errors, stop and preserve its log at `~/.local/share/nobara-updater/nobara-sync.log`; do not try `repair`, `distro-sync`, or other recovery commands as routine updates.

Flatpak applications are a separate update channel. If you want to update them during this pass, enable the updater's Flatpak option or review and run:

```bash
flatpak update
```

Snap packages, if any are installed, are also separate. Check `command -v snap`; only if present and snaps are in use, review and run `sudo snap refresh`.

Record the updater's final success message or error. Reboot Nobara when its updater requests it or after a kernel/graphics stack update, once you are ready to check the system afterward. Do not power off during the package transaction.

## 4. Verify After Reboot And Save A Post Record

Boot Nobara again first. Confirm the desktop, network, audio, AMD graphics, Steam, and usual game/controller workflow. Run:

```bash
hostnamectl --static
cat /etc/os-release
uname -r
ip -br address
findmnt -T /
df -hT
systemctl --failed --no-pager
nobara-sync check-repos && nobara-sync check-updates
flatpak list --app --columns=application,version 2>/dev/null || true
```

If any hardware or desktop problem appears, stop and record the exact symptom and recent boot errors with `journalctl -p 3 -b --no-pager -n 100`; do not proceed to boot AtlasOS until the Nobara result is understood.

After validation, append the post-state to a separate owner-only file:

```bash
umask 077
post="$HOME/nobara-maintenance/RavensTower_post_$(date +%F_%H-%M-%S).txt"
{
  echo '## Captured'; date --iso-8601=seconds
  echo '## Host and OS'; hostnamectl --static; cat /etc/os-release; uname -r
  echo '## Network'; ip -br address
  echo '## Storage'; lsblk -o NAME,MODEL,SIZE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS; findmnt -T /; df -hT
  echo '## Failed units'; systemctl --failed --no-pager
  echo '## Nobara update check'; nobara-sync check-repos && nobara-sync check-updates
  echo '## Flatpak applications'; flatpak list --app --columns=application,version 2>&1 || true
} 2>&1 | tee "$post"
chmod 600 "$post"
printf '\nPost-update record: %s\n' "$post"
```

If no updates were available and no state changed, record that result instead of making a redundant post file. When back in AtlasOS, transfer only reviewed records to the repository or verified backup location; do not commit raw private inventory output.

## 5. Resume Fleet Work In AtlasOS

After the Nobara pass, boot AtlasOS, open this project, and continue the desktop checks. The owner prefers leaving Sunshine's current driver configuration unchanged. Capture a Windows post-update inventory when ready; Sunshine driver changes and controller testing are not part of the remaining work unless the owner later requests them.

Capture a Windows post inventory with:

```powershell
.\scripts\collect_windows.ps1 -Role atlasos -Phase post -SkipHWiNFO -OutputBase .\scripts\output
```

Then run `winget upgrade` to review remaining known updates. Reconcile the Nobara and AtlasOS records in the dated fleet update report, including actual update results, reboot status, and any deferred work.

## References

- [Nobara Project Wiki: Updating Nobara](https://wiki.nobaraproject.org/en/general-usage/troubleshooting/update-system)
- [Nobara Project Wiki: Updating troubleshooting](https://wiki.nobaraproject.org/general-usage/troubleshooting/updating-troubleshooting)
- [Nobara Project Wiki: Manual partitioning guide](https://wiki.nobaraproject.org/general-usage/installing/manual-partitioning)
