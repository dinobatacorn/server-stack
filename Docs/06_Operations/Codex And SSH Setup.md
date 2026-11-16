# Codex And SSH Setup

Status: Draft operational setup
Last reviewed: 2026-09-29

## Purpose

This document keeps Codex setup separate from maintenance execution. Goal 0 is complete only when the local workspace, Git repository, SSH aliases, and reachable-device inventory are ready enough to support a staged fleet update.

## Workspace Standard

Use this checkout for current Codex work:

```text
E:\GitHub\server-stack
```

The ChatGPT project mirror remains reference material. Do not edit synced `sources/` files in the project mirror.

Use Codex Worktree mode for normal repo edits. Use Local mode only when intentionally editing the synced checkout directly.

## SSH Standard

Dedicated key:

```text
C:\Users\raven\.ssh\id_ed25519_codex_pve_runtime
```

Real aliases live in:

```text
C:\Users\raven\.ssh\config
```

The redacted/template version lives at:

```text
Docs/06_Operations/Templates/homelab-ssh-config.template
```

Do not commit private keys, passwords, tokens, one-time codes, or full sensitive command output.

## Codex Remote Host Policy

Full Codex remote-host capability is for stable admin/development hosts only. On 2026-10-23, dedicated-key SSH access was verified for PVE (`pve`), Pi-hole (`pihole`), WireGuard (`wireguard`), RustDesk (`rustdesk`), MediaCenter (`media`), and VM100 (`services`). VM100's documented `raven` account was absent, so the owner approved setup on its existing root account, which permits SSH. LockBox remains excluded from SSH setup at the owner's direction.

Other devices may use plain SSH for inventory and update checks without installing or authenticating Codex on them. The current client key fingerprint is `SHA256:EBT4cZ0g2tdeSKHQBejYQeNbOEf9BUDEzhYaWi/AImY` (`codex-pve-runtime-2026-09`).

The 2026-09-28/29 fleet pass used PVE as the management path for Pi-hole, WireGuard, and RustDesk LXC 103; VM100 maintenance used its QEMU guest agent. VM200's SSH key access and host-key trust remain unverified, and its QEMU guest agent is not configured. See [Reachability Inventory](Reachability%20Inventory.md) before assuming any target can be managed remotely.

Do not expose SSH or Codex App Server directly to the public internet. Keep access VPN-first.

## Reachability Test

Run from Windows after aliases are adjusted:

```powershell
.\scripts\Test-HomelabSsh.ps1
```

For hosts that return `credentials needed`, install the public key on the host or correct the username. For hosts that return `offline or DNS missing`, confirm hostname resolution or replace `HostName` with the current IP.

## Public Key Installation

Append the public key to the target user's `~/.ssh/authorized_keys` on each reachable Linux host. Preserve existing keys and file permissions.

For appliances or endpoints where SSH is temporary or awkward, record the blocker in the reachability inventory rather than forcing it.

## OpenAI Docs Notes

OpenAI Docs says Codex detects explicit host aliases from `~/.ssh/config`, verifies normal SSH first, and uses SSH to start Codex App Server on remote hosts. The remote host must have `codex` installed, authenticated, and available on the login shell `PATH` before it becomes a full Codex remote host.
