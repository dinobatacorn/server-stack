# ADR 0019: Shared Storage Requires Workload Ownership And Mount Verification

Status: Accepted
Date: 2026-07-25

## Context

VM100 and MediaCenter both mount the shared `/mnt/core` NFS filesystem. This makes Compose definitions visible from multiple hosts, even when only one host owns a given workload.

During July 2026 maintenance, two related failure modes were confirmed:

- A Syncthing Compose file was visible from MediaCenter, and some recovery/recreation work was accidentally performed there even though Syncthing's canonical Docker host is VM100 `services`.
- MediaCenter ran Docker while the real `/mnt/core` NFS filesystem was absent. Because `/mnt/core` still existed as a local mountpoint directory, local data was written beneath the mountpoint and later hidden by the real NFS mount.

Both cases show that path visibility is not the same as workload ownership or storage correctness.

## Decision

Before host-specific Docker/Compose operations against shared `/mnt/core`, verify the host:

```bash
hostname
```

Before container startup, recreation, restore, or destructive operations involving critical `/mnt/core` data, verify the actual mounted filesystem:

```bash
findmnt -T /mnt/core
```

For a specific critical path:

```bash
findmnt -T /mnt/core/path/to/data
```

The expected backing filesystem for `/mnt/core` on VM100 and MediaCenter is:

```text
192.168.0.75:/mnt/core
Filesystem: NFSv4
```

Do not treat directory existence, successful `ls`, or Compose file visibility as proof that the correct filesystem is mounted or that the current host owns the workload.

## Consequences

Runbooks must document workload ownership separately from Compose file locations.

Maintenance automation must distinguish:

```text
Compose file visible on host
```

from:

```text
Workload intentionally owned/deployed by host
```

Docker socket activation must not be confused with Docker workloads starting. Use `docker.service`, container state, and application health when reasoning about startup order.

Before destructive repair:

1. Stop writers where necessary.
2. Identify the actual filesystem.
3. Back up important data.
4. Validate the backup.
5. Only then modify/delete/recreate.
6. Verify restored data.
7. Start the service.
8. Verify application health and restart counts.

## Alternatives Considered

- Treat shared Compose file visibility as permission to operate. Rejected because it can start workloads on the wrong Docker host.
- Trust mountpoint directories by path alone. Rejected because local directories can exist underneath absent mounts.
- Automate updates without host and mount gates. Rejected because it risks writing state to the wrong filesystem or host.

