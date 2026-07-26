# Docker Compose Operations

Status: Draft operational standard
Last reviewed: 2026-07-25
Source docs:
- Homelab Documentation Update Handoff, 2026-07-25
- Syncthing Recovery and Architecture Update, 2026-07-25
- MediaCenter maintenance/update summary, 2026-07-25
- ADR 0004: Containers Are Disposable
- ADR 0018: Docker Container Paths Must Match Container Mounts
- ADR 0019: Shared Storage Requires Workload Ownership And Mount Verification
Next action: Turn these checks into guarded n8n maintenance automation after manual procedures are proven.

## Purpose

This runbook defines the safety checks for Docker Compose workloads whose definitions and persistent state live on shared `/mnt/core` storage.

Two lessons drive this standard:

- A Compose file visible from a host does not mean that host owns the workload.
- A directory existing at `/mnt/core` does not prove the NFS filesystem is mounted.

## Preflight Checks

Before `docker compose up`, `down`, `pull`, `restart`, destructive cleanup, or restore work:

```bash
hostname
findmnt -T /mnt/core
```

For a specific critical path:

```bash
findmnt -T /mnt/core/path/to/data
```

Expected `/mnt/core` backing filesystem on VM100 and MediaCenter:

```text
192.168.0.75:/mnt/core -> /mnt/core
Filesystem: NFSv4
```

Do not treat these as sufficient:

- `/mnt/core` exists.
- `ls /mnt/core` returns files.
- A Compose file is visible on the host.
- `docker.socket` is active.

`docker.socket` activation can occur before `docker.service` starts workloads. Use service and container state, not socket presence alone, when reasoning about workload startup.

## Workload Ownership

Verify the canonical host before operating on shared Compose definitions.

| Workload | Canonical host | Compose location |
| --- | --- | --- |
| Syncthing | VM100 `services` | `/mnt/core/services/syncthing/compose.yml` |
| Baserow | VM100 `services` | `/mnt/core/services/knowledge/baserow/docker-compose.yml` |
| Nginx Proxy Manager | VM100 `services` | `/mnt/core/stacks/core/npm/docker-compose.yml` |
| iSponsorBlockTV | VM100 `services` | `/mnt/core/stacks/utilities/isponsorblocktv/docker-compose.yml` |
| Media stack | MediaCenter `media` | `/mnt/core/services/media` |
| Affine | VM200 | `/mnt/core/stacks/knowledge/affine/docker-compose.yml` |
| Vaultwarden | Dormant, not currently deployed | `/mnt/core/stacks/utilities/vaultwarden/docker-compose.yml` |

Do not start the media stack on VM100 merely because the Compose definition is visible through `/mnt/core`.

Do not deploy Affine on VM100. The visible Affine Compose file requires environment-specific configuration for VM200. Missing variables on VM100 are not evidence that the working VM200 deployment is broken.

Do not start Vaultwarden as part of cleanup. Its dormant Compose definition uses a relative `./data:/data` mount and should be reviewed before future deployment.

## Mount Documentation

Document persistent mounts as:

```text
host source -> container destination
```

Never assume a host pathname exists at the same pathname inside a container.

## Standard Update Workflow

For low-risk stateless services:

```text
identify canonical host
verify critical mounts
inventory current state/version
pull images
record old/new image information
recreate/update containers
wait for startup
validate health
inspect restart counts and relevant errors
record successful state
```

For stateful or database-backed services, insert service-specific backup and validation before pulling or recreating containers.

Example guarded workflow:

```text
identify canonical host
-> verify critical mounts
-> inventory current state/version
-> perform service-specific backup
-> validate backup
-> pull images
-> record old/new image information
-> recreate/update containers
-> wait for startup
-> validate container/application health
-> inspect restart counts and relevant errors
-> record successful state
-> update inventory/docs
-> notify on failure or intervention requirement
```

Do not prune previous Docker images immediately after successful updates. Preserve a rollback window and perform cleanup separately.

On failed validation, stop further maintenance, preserve recovery material, collect diagnostics, and alert the administrator. Do not attempt increasingly invasive automatic repairs.

## Future Automation Direction

The future n8n maintenance system should collect:

```text
hostname
/mnt/core mount source and filesystem
Compose projects and owning host
running container names/images
image versions
container health
restart counts
persistent bind mounts
recent ERR/WRN logs
disk utilization
available image updates
backup status/age
```

It should eventually perform routine Docker/Compose updates, but updates must be gated and recoverable rather than unconditional.

Database-backed services such as Baserow/PostgreSQL must require a fresh validated dump before automatic update.

Automatic update policies should be per-service. Treating every container identically is not acceptable.
