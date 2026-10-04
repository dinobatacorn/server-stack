# LockBox Maintenance

Status: Draft
Last reviewed: 2026-09-29

## Scope

This is a local, owner-present maintenance procedure for LockBox. The 2026-09-29 captures identify Garuda Linux on `LockBox`; re-check identity, mounts, and snapshots on each maintenance pass because this is a gaming endpoint with owner-managed software.

Confirm the device owner and maintenance window before making changes. Run the steps only after confirming that the active system is LockBox booted into Garuda Linux.

## 1. Read-Only Preflight

Open a terminal on LockBox and capture the current identity and storage layout:

```bash
hostnamectl --static
cat /etc/os-release
uname -r
ip -br address
lsblk -f
findmnt -T /
findmnt -T /boot
df -hT
command -v garuda-update checkupdates snapper btrfs flatpak paru yay
pacman -Qm
if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application,version
else
  echo 'Flatpak is not installed; no action taken.'
fi
```

The `flatpak list` command is read-only. Do not install Flatpak just to inventory applications; if it is absent, record that and continue.

Verify the hostname and Garuda OS before proceeding. Review the `pacman -Qm` list with the owner; these packages are not in the configured sync repositories and may include AUR or manually installed packages. The May inventory listed three physical drives and a LaCie USB disk, but it does not establish the current mount points or what is backed up there.

## 2. Capture The Pre-Update Inventory

Run the repository collector from a checkout that contains `scripts/collect_linux.sh`:

```bash
bash ./scripts/collect_linux.sh --role lockbox --phase pre --output-base "$HOME/lockbox-maintenance"
```

The collector writes an owner-only JSON inventory under `~/lockbox-maintenance/<date>/pre/LockBox/`. It does not back up personal files or create a disk image. Keep the raw JSON private and do not commit it to Git. Current `collect_linux.sh` version `2026-09-29.3` handles `checkupdates` exit status 2 (“no updates available”) as an empty list; status 0 preserves update lines, and other statuses remain failures. If `checkupdates` is unavailable, the collector records that fact; a reported count of zero in that case does not mean the package check found no upgrades.

After confirming a real, writable backup mount with `findmnt -T <mount-path>`, copy the reviewed JSON there to keep it off the machine. Do not assume `/mnt/core` or any USB mount is available; verify the exact target first.

## 3. Verify Recovery Points Before Updating

Check the root filesystem type and whether Snapper has a root configuration:

```bash
findmnt -no SOURCE,FSTYPE,OPTIONS /
sudo snapper list-configs
```

If the root filesystem is Btrfs and `list-configs` shows the root configuration, list existing snapshots and create a named pre-update snapshot:

```bash
sudo snapper -c root list
sudo snapper -c root create --type single --description "LockBox pre-update $(date -Iseconds)"
sudo snapper -c root list
```

Confirm the new snapshot appears in the list. If the root configuration has a different name, substitute the listed name for `root`.

If root is not Btrfs, Snapper is missing, or no appropriate root configuration exists, stop before package updates. First establish a usable recovery method for this installation. A filesystem snapshot on the same drive is not an independent backup; back up irreplaceable personal files to a separate verified disk as well. Do not run Garuda's `remote reset-snapper` command as part of routine maintenance; it deletes Snapper backup subvolumes and snapshots.

## 4. Update Garuda And Applications

Read the Garuda update notes and review the proposed package transaction. Use Garuda's updater interactively:

```bash
garuda-update
```

The updater performs a full system update and asks for confirmation. Review the package changes before accepting. If it proposes removals, reports a keyring or mirror error, or exits before completing the package transaction, stop and resolve that issue before doing more package operations. Do not run `pacman -Sy` or update individual packages on their own; Arch-based systems require full upgrades.

If the reviewed `pacman -Qm` list contains packages the owner wants maintained from the AUR, use Garuda's AUR option instead of a separate partial update:

```bash
garuda-update --aur
```

This runs the Garuda system update and then updates AUR packages through the configured helper. Review build prompts and failures; do not use a no-confirm option. Skip AUR updates if the owner has not confirmed those packages should be maintained.

If Flatpak is installed and the owner wants Flatpak applications updated, review and run its interactive updater separately after the Garuda update:

```bash
flatpak update
```

Do not run `pacman -Sy` by itself or use a partial package update. If Garuda's updater completes its database refresh but fails during package installation, resolve the failure and finish the full update before other package operations.

Resolved during the 2026-09-29 pass: the owner confirmed `proton-ge-custom-bin` was no longer needed for Steam and `wine-ge-custom` had never worked. The proposed recursive removal listed both runtimes and 22 related packages. `pacman -Qi perl-json` showed its sole installed dependent was `lib32-vkd3d`, which appeared in the same removal list. The owner accepted the reviewed removal and proceeded with the full Garuda update. Do not treat this as blanket approval to remove custom packages on a future run; verify ownership and the exact transaction again.

Before considering removal, inspect Steam games' **Properties → Compatibility** settings for an explicitly forced Proton GE tool. Steam provides Valve's Proton versions and lets the user select a compatibility tool per game; test a replacement on the affected game before removing its custom tool. Also check whether Lutris, Heroic, or another non-Steam launcher uses `wine-ge-custom`. A Steam default/Valve Proton selection is an alternative for Steam games, but it does not automatically replace a Wine runner configured in another launcher.

The separate Flatpak transaction installed `flatpak 1:1.18.3-1` plus `composefs`, `libmalcontent`, and `ostree`. The `flatpak list` inventory command is read-only and did not install Flatpak. The Garuda full-update blocker was the exact-version dependency pins on `lib32-audit` and `lib32-libpcap`; the available evidence does not link Flatpak to that failure. Flatpak remains installed; do not remove it without the owner's decision. A hook also reported `/etc/pacman.d/mirrorlist.pacnew`; merging it was not verified.

## 5. Reboot And Verify

After the full package transaction completes, reboot when the owner is ready. Do not interrupt a kernel or graphics-driver transaction. After reboot, verify:

```bash
hostnamectl --static
cat /etc/os-release
uname -r
ip -br address
findmnt -T /
df -hT
systemctl --failed --no-pager
```

Confirm the graphical desktop, Wi-Fi/Ethernet, audio, NVIDIA graphics, Steam, and the owner's usual controller/game workflows. Run `nvidia-smi` only if it is installed. Review `journalctl -p 3 -b --no-pager -n 100` for new critical boot errors if a problem is observed.

List Snapper snapshots again and verify that the update transaction's pre/post snapshots are present if Garuda's hooks created them:

```bash
sudo snapper -c root list
```

## 6. Capture The Post-Update Inventory

After validation, capture the post inventory:

```bash
bash ./scripts/collect_linux.sh --role lockbox --phase post --output-base "$HOME/lockbox-maintenance"
```

Review the post snapshot's OS, kernel, filesystem free space, package check result, failed-service count, and warnings. Copy the reviewed raw file to a verified backup destination and record the snapshot location, update result, reboot result, and anything deferred in the dated fleet update report. If updates were unavailable and no machine state changed, record the result as `no updates available` instead of creating a redundant post file.

Observed 2026-09-29 post state: the post JSON reports Garuda Linux kernel `7.2.7-zen1-1-zen`, zero pending repository updates, and root Btrfs at 77% used with about 447 GiB available. Pre state was kernel `7.1.4-zen1-1-zen`, 611 pending repository updates, and 76% used. Manual Snapper pre-update snapshot `260` was confirmed before the update; a post-update Snapper listing and package transaction log were not captured, so exact package changes and a Snapper post snapshot are unverified. The post JSON was captured with collector version `2026-09-29.3` at `scripts/output/2026-09-29/LockBox/LockBox_post_2026-09-29_18-04-45.json` in the local repository copy. The raw capture remains ignored/private.

## References

- [Garuda Linux: garuda-update](https://gitlab.com/garuda-linux/website/wiki/-/blob/master/garuda-update.md)
- [ArchWiki: System maintenance](https://wiki.archlinux.org/title/System_maintenance)
- [ArchWiki: pacman](https://wiki.archlinux.org/title/Pacman)
- [ValveSoftware/Proton: Steam-provided and local Proton compatibility tools](https://github.com/ValveSoftware/Proton)
- [GloriousEggroll/proton-ge-custom: selecting a compatibility tool per game](https://github.com/GloriousEggroll/proton-ge-custom)
