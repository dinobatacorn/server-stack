# Fleet Update Runbook

Status: Draft
Last reviewed: 2026-09-29

## Purpose

Run staged updates across all devices that can be reached and authenticated. This runbook is intentionally conservative so it can become the foundation for later automation.

## Storage Contract

Raw snapshots stay on infrastructure storage:

```text
/mnt/core/backups/snapshots/<date>/<phase>/<host>/
```

Redacted summaries and scripts live in this repository. Do not commit raw snapshots unless they have been reviewed for secrets and sensitive local details.

Raw inventory snapshots and recovery archives stay owner-only (`600` files, `700` directories) because they can expose network details, service configuration, or credentials. The Linux collector uses `umask 077` (script version `2026-09-29.3`) to enforce those permissions at creation.

## Stages

1. Goal 0: verify Codex workspace, SSH key, SSH aliases, and reachability inventory.
2. Baseline: collect `pre` snapshots from every reachable device.
3. Infrastructure: update Proxmox, Pi-hole, WireGuard, and VM100 in that order. On VM100, include a separate Docker image update pass after the OS packages.
4. Media: update MediaCenter host and media Docker images after `/mnt/core` and `/media` are verified. The OS preflight does not refresh Docker images.
5. Endpoints: update Windows, Linux, LockBox, and Steam Deck devices with OS plus core apps.
6. Post-check: collect `post` snapshots and compare versions, health, logs, disk usage, and key workflows.
7. Document: update the dated report and record automation candidates.

## Private-Network Access Gate

Every service except WireGuard itself is intended to be reachable only from the home LAN or WireGuard-connected clients. Do not add router WAN port forwards or public reverse-proxy routes for internal services. A future public portal is the sole planned exception and is not deployed. Before treating this as enforced, inspect the router's WAN forwarding rules and applicable firewall policy; a Cloudflare DNS record alone neither grants nor blocks network access.

## Linux Snapshot Command

```bash
./scripts/collect_update_baseline.sh --role vm100 --phase pre
```

Use `--role pve`, `--role pihole`, `--role wireguard`, `--role media`, `--role linux-endpoint`, or `--role steamdeck` as appropriate.

LockBox is a Garuda Linux endpoint maintained locally by its owner; current 2026-09-29 pre/post snapshots exist, but SSH is not available. Follow [LockBox Maintenance](../02_Runbooks/LockBox%20Maintenance.md) to confirm its active boot, storage, Snapper setup, and update path before each change.

The dual-boot workstation's Nobara installation is maintained locally while it is the active boot. Follow [Nobara Maintenance](../02_Runbooks/Nobara%20Maintenance.md) while booted into Nobara; its standalone pre/post records do not require this repository to be available on that OS.

If `/mnt/core` is not verified, the wrapper refuses to write there. For non-homelab endpoints, use a local output base:

```bash
./scripts/collect_linux.sh --role linux-endpoint --phase pre --output-base ./output
```

The Linux collector is inventory-only. It does not update the OS, Docker images, Flatpak apps, or firmware. It validates JSON before writing and prints the saved filename; a created directory alone is not proof that a snapshot was written.

## Windows Snapshot Command

Run the collector from an elevated PowerShell session so Windows hardware, storage, and OS details are available. HWiNFO is optional; use `-SkipHWiNFO` when its command-line reporting mode is unavailable. The collector can parse an existing XML report by supplying `-HWiNFOReport <path>` together with `-SkipHWiNFO`.

```powershell
.\scripts\collect_windows.ps1 -Role windows-endpoint -Phase pre -SkipHWiNFO
```

Use `-OutputBase` to place output in a dated local folder. Review before committing or syncing.

This collector creates an inventory snapshot; it is not a disk image or a full recovery backup. Before applying Windows or driver updates, confirm a usable recovery path. A Windows System Restore point covers system settings and files, not personal files or a complete disk image. If the machine needs full-disk recovery, make and verify an image backup to independent storage first. Do not count a successful JSON collector run as proof of recoverability.

For Windows endpoint maintenance:

1. Confirm the active hostname and Windows boot. On a dual-boot machine, run this only for the OS currently booted; the collector cannot inventory the other installation.
2. Create a pre-update inventory with `collect_windows.ps1`. If the output contains access warnings or reports the OS as `unknown`, rerun from elevated PowerShell and treat the capture as incomplete until the warnings are resolved. HWiNFO warnings are optional hardware/sensor-report issues and do not by themselves make the OS inventory incomplete.
3. Review Windows Update in Settings and install the offered OS/security updates. Review optional driver updates separately; do not install optional drivers without a reason.
4. Run `winget upgrade` to review application updates. Apply the reviewed set with `winget upgrade --all --accept-source-agreements --accept-package-agreements`; do not use `--include-unknown` as a blanket update.
5. Reboot when Windows requests it. Confirm the machine boots into the intended Windows installation and that the other boot entry remains available.
6. Capture a post-update inventory with `collect_windows.ps1 -Role windows-endpoint -Phase post -SkipHWiNFO`; compare OS build, pending app updates, volumes, warnings, and key workflows with the pre capture. If no updates were available and no state changes were made, record the maintenance result as `no updates available`; the pre capture remains the post-state evidence for that pass.

## Update Gates

Before any server-side update:

```bash
hostname
findmnt -T /mnt/core
```

For stateful services, create and validate a fresh backup before pulling images or recreating containers.

Before PVE host maintenance, archive `/etc/pve` and relevant host network, mount, SSH, APT, boot, module, and systemd configuration. Back up guests whose state will change with snapshot-mode `vzdump`; verify its completion log and run `zstd -t`. After the PVE update, collect the standard PVE post snapshot.

## Docker Image Update Pass

OS package updates do not update application versions packaged inside Docker images. During every server maintenance pass, enumerate running containers and active Compose projects on each canonical Docker host. Include VM100 `services` and MediaCenter `media`; check any other Docker host only after confirming its workload owner and maintenance window.

For each active Compose project:

1. Verify the canonical host and required storage mounts.
2. Record current container names, configured image tags, running image IDs/digests, versions, health, and restart counts.
3. Review upstream release notes for major application upgrades, database migrations, plugin compatibility, and any required post-upgrade tasks. Defer an update if required recovery steps cannot be completed in the maintenance window.
4. Back up persistent data. Create and validate application-level database dumps for databases before image pulls/recreation.
   For a consistent MediaCenter recovery archive, stop its active Compose project, archive `/mnt/core/services/media`, validate the archive, then restart the project and recheck all containers and local web ports.
5. Pull images, then run `docker compose up -d` so containers use the pulled images. `docker compose pull` by itself does not update running containers.
6. Verify the running image IDs/versions changed where an update was available; wait for startup and health checks.
7. Check recent logs, restart counts, local service ports, and at least one user-facing route for proxy-backed services. Complete application-specific post-upgrade steps such as library scans when required by the upstream release.
8. Check disk usage after pulling and recreating containers. On MediaCenter, stop further image updates if root use exceeds 95% or available space falls below 8 GB; schedule image cleanup separately after the rollback window.
9. Save post-update snapshots and document versions, backup locations, and any skipped hosts/projects.

The MediaCenter sudo preflight checks the existing media containers but does not pull or recreate images. Run this image-update pass separately after the preflight gates succeed. Preserve old images during the rollback window; do not prune them during the update pass.

Do not update or restart a partner-owned workload until its owner and the maintenance window are confirmed. Record inaccessible Docker hosts as incomplete rather than treating them as updated.

## MediaCenter Sudo Preflight

MediaCenter has a dedicated sudo-backed gate before OS package updates:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Invoke-MediaSudoPreflight.ps1
```

To let the script proceed with safe package/log cleanup and OS package updates only after the gates pass:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Invoke-MediaSudoPreflight.ps1 -UpdateOsIfSafe -SafeCleanup
```

The script refuses to update if hostname, `/mnt/core`, `/media`, root free space, SSH, Docker, expected containers, or local media web ports fail. It does not prune Docker images, volumes, or app data.

After each device or group, verify network, disk usage, restart counts, service health, recent errors, and the user-facing workflow that motivated the work.

## Package-Manager Output And Exit Codes

Do not treat every nonzero package-check exit code as an update failure. Preserve stdout/stderr and interpret documented statuses per package manager:

| Check | Status | Meaning | Collector behavior |
| --- | ---: | --- | --- |
| DNF `check-update` | `0` | Check succeeded | Keep output. |
| DNF `check-update` | `100` | Updates are available | Keep pending-update output. |
| Pacman `checkupdates` | `0` | Check succeeded | Preserve listed updates. |
| Pacman `checkupdates` | `2` | No updates available | Record an empty list. |
| Either command | Other | Error | Preserve diagnostics and fail the inventory rather than writing a misleading zero. |

`collect_linux.sh` version `2026-09-29.3` handles these DNF and Pacman statuses. On 2026-09-29, Bash syntax validation and six controlled exit-code/output-preservation checks passed. These were focused branch checks, not full Linux-host integration tests. The LockBox post inventory confirms the revised collector wrote a valid JSON file with zero pending repository updates.

## Automation Readiness Requirements

Treat automation as a later implementation. An inventory command reaching a host does not make that host safe for unattended updates. Before scheduling or applying changes, record for each device:

- Stable host identity, OS/version, active boot/dual-boot constraint, owner, maintenance window, and supported update mechanism.
- Verified reachability and privilege model; do not infer SSH, sudo, or QEMU guest-agent access from a responding IP or an active service.
- Recovery method and freshness: PVE guest backup plus separate bind-mount/appdata backups, filesystem snapshots where configured, and independent personal-file backups for endpoints. Verify destination mounts and archive integrity.
- Preflight thresholds and service checks: correct host, required mounts, free space, failed units, container/image versions, and relevant application workflows.
- Package-manager command, accepted exit codes, logs, reboot-required signal, and explicit result states such as `updated`, `no_updates`, `blocked`, `needs_reboot`, `verification_failed`, or `not_reachable`.
- Post-update evidence: running kernel/version, pending updates, service health, container restart/health, reachable ports, and the user-facing workflow. Require manual confirmation for graphical, game, and controller workflows.

Automation gates:

1. Update one host or application domain at a time; preserve PVE and VPN access while maintaining infrastructure.
2. Stop for unknown identity, missing/stale recovery points, missing mounts, failed health checks, low disk space, package conflicts, unreviewed removals, AUR prompts, or partner-owned workloads.
3. Never auto-accept package removals, WinGet `--include-unknown`, firmware/driver changes, major application/database migrations, Docker image pruning, or reboots of physical dual-boot devices.
4. Keep OS packages, Flatpak, Windows applications, and Docker images as separate update channels with separate before/after evidence.
5. Keep endpoint raw inventories owner-only and ignored by Git. Redact secrets before writing summaries. Notify only on a meaningful change, failure, or human decision.
6. Test each adapter against no-update, update-available, command-error, partial-failure, and output-write-failure cases before it can perform changes. Begin with preflight/dry-run; require explicit approval until rollback and unattended access are proven.

Known manual-only constraints: LockBox is not SSH-enabled in the reachability inventory; Nobara and AtlasOS share a dual-boot workstation; AtlasOS post-update inventory is pending and the owner prefers leaving Sunshine as configured; VM200's QEMU guest agent is not configured and Affine use must be checked; the owner reports RustDesk clients pointed to the self-hosted server and multiple successful sessions, but the network path of the latest phone test is unspecified. Exclude these from unattended execution until the host-specific access and recovery prerequisites are resolved.
