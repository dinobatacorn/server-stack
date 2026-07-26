# Main Node Inventory

Status: Current
Last reviewed: 2026-07-25
Source docs:
- pve-output_09072026.txt
- vm100-output_09072026.txt
- User-provided Baserow deployment summary, 2026-07-10
- Syncthing Recovery and Architecture Update, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
Next action: Remove obsolete Syncthing `SirBranteSaves`, review UID/GID technical debt, and normalize legacy VM100 `/mnt/core/stacks` compose projects into `/mnt/core/services`.

## Role

The main node is the Proxmox-backed infrastructure and personal-cloud platform. It is separate from the dedicated media node.

Application-domain split:

- VM100: infrastructure, knowledge, utilities, security, automation, monitoring, personal cloud, and backup orchestration.
- Media node: acquisition, processing, discovery, serving, playback, reading, and preservation.

## Proxmox Host

Host: `pve`

- OS: Debian GNU/Linux 13 Trixie
- Platform: Proxmox VE 9.2.4
- Kernel: `7.0.0-3-pve`
- IP: `192.168.0.75`
- CPU: Intel Xeon E5-2609 v2, 4 cores
- Memory: 32 GiB
- `/mnt/core`: 1 TB Samsung SSD mounted at `/dev/sdb1`

Running LXCs:

- 101 `pihole`, `192.168.0.120`, on boot
- 102 `wireguard`, `192.168.0.110`, on boot, `/mnt/core` mounted into the container

Running VMs:

- VM100 `services`, Core Services Docker host, `192.168.0.125`, on boot
- VM200 `services`, present and running; purpose needs clarification

## VM100 Core Services Docker Host

Host: `services`

- OS: Debian GNU/Linux 13 Trixie
- Kernel: `6.12.88+deb13-amd64`
- Disk after July 25 maintenance: 63 GB total, 15 GB used, 46 GB available, 24% used
- Role: core services platform

Running containers after July 25 maintenance:

- `syncthing`: `lscr.io/linuxserver/syncthing:latest`
- `baserow`: `baserow/baserow:latest`, healthy
- `baserow-postgres`: `postgres:16`, healthy
- `npm`: `jc21/nginx-proxy-manager:latest`
- `isponsorblocktv`: `ghcr.io/dmunozv04/isponsorblocktv:latest`

All had status running and restart count 0 at final verification.

## VM100 Storage Snapshot

On VM100 `services`, `/mnt/core` is an NFSv4 mount from:

```text
192.168.0.75:/mnt/core
```

Final observed `/mnt/core` utilization after July 25 maintenance:

```text
916 GB total
11 GB used
859 GB available
2% used
```

Verify before maintenance:

```bash
findmnt -T /mnt/core
```

Top-level `/mnt/core` usage at inventory time:

```text
11M     /mnt/core/appdata
7.7G    /mnt/core/backups
16K     /mnt/core/config
3.1M    /mnt/core/data
3.3M    /mnt/core/docs
102M    /mnt/core/exports
264M    /mnt/core/services
56K     /mnt/core/stacks
```

Active mount patterns:

- Syncthing config: `/mnt/core/data/sync/config -> /config`
- Syncthing shared data: `/mnt/core/data/sync -> /sync`
- Nginx Proxy Manager data: `/mnt/core/appdata/core/npm/data -> /data`
- Nginx Proxy Manager certificates: `/mnt/core/appdata/core/npm/letsencrypt -> /etc/letsencrypt`
- iSponsorBlockTV data: `/mnt/core/appdata/utilities/isponsorblocktv -> /app/data`
- Baserow media: `/mnt/core/appdata/knowledge/baserow/media -> /baserow/data`
- Baserow PostgreSQL: `/mnt/core/appdata/knowledge/baserow/postgres -> /var/lib/postgresql/data`

Syncthing current state:

- Canonical host: VM100 `services`.
- Compose: `/mnt/core/services/syncthing/compose.yml`.
- Active version: Syncthing v2.1.2.
- Image: `lscr.io/linuxserver/syncthing:latest`.
- Current folders: `/sync/github`, `/sync/obsidian`, and `/sync/school`.
- Host-backed folders: `/mnt/core/data/sync/github`, `/mnt/core/data/sync/obsidian`, and `/mnt/core/data/sync/school`.
- Configuration backup from path repair: `/mnt/core/data/sync/config/config.xml.pre-path-fix-2026-07-25`.
- Validated temporary rescue: `/var/backups/syncthing-rescue/overlay-direct`.
- Obsolete folder: `SirBranteSaves`, to be removed from Syncthing configuration.
- Technical debt: Syncthing currently runs with `PUID=0` and `PGID=0`; migrate to an unprivileged UID/GID after recovery stability is confirmed.

## Current Compose Locations

Current state includes both normalized and legacy locations:

- `/mnt/core/services/media`
- `/mnt/core/services/knowledge/baserow/docker-compose.yml`
- `/mnt/core/services/syncthing/compose.yml`
- `/mnt/core/stacks/core/npm/docker-compose.yml`
- `/mnt/core/stacks/knowledge/affine/docker-compose.yml`
- `/mnt/core/stacks/utilities/isponsorblocktv/docker-compose.yml`
- `/mnt/core/stacks/utilities/vaultwarden/docker-compose.yml`

Ownership notes:

- `/mnt/core/services/media` belongs to MediaCenter `media`, not VM100.
- `/mnt/core/stacks/knowledge/affine/docker-compose.yml` is intentionally deployed on VM200 for temporary/current use by Raven's partner; do not deploy Affine on VM100.
- Affine inspected from VM100 without the right environment produced missing variable warnings for `DB_DATA_LOCATION`, `DB_USERNAME`, `DB_PASSWORD`, `UPLOAD_LOCATION`, and `CONFIG_LOCATION`, ending with `invalid spec: :/root/.affine/storage: empty section between colons`. This indicates missing VM100 invocation configuration, not that the VM200 deployment is broken.
- `/mnt/core/stacks/utilities/vaultwarden/docker-compose.yml` is dormant; no Vaultwarden container currently exists on VM100.
- Vaultwarden currently uses `./data:/data` and should be reviewed before deployment because current architecture prefers explicit `/mnt/core/appdata/...` persistence.
- Vaultwarden also contains obsolete top-level `version: "3"`; remove it when that deployment is next maintained.

Normalization target:

- Service deployment definitions belong under `/mnt/core/services`.
- Persistent application state belongs under `/mnt/core/appdata`.
- Shared user or operational data belongs under `/mnt/core/data`.
- Host-level configuration belongs under `/mnt/core/config`.
- Backups and dumps belong under `/mnt/core/backups`.
- New service definitions should not be created under `/mnt/core/stacks`.

## Planned VM100 Services

Core:

- Homepage
- Nginx Proxy Manager

Security:

- Vaultwarden
- Authelia
- CrowdSec, if later justified

Knowledge:

- Obsidian LiveSync, if self-hosted
- Paperless-ngx
- Nextcloud
- AnythingLLM

Automation:

- n8n

Utilities:

- Syncthing
- iSponsorBlockTV
- RustDesk, if self-hosted

Monitoring:

- Uptime Kuma
- Grafana
- Prometheus
- Node Exporter
- cAdvisor, if useful

Backup:

- Restic

## Open Questions

- VM200 is running and named `services`; document its intended purpose or rename/decommission it.
- Decide whether the legacy AFFiNE export and stack should remain archived only now that Obsidian is the knowledge direction.
- Review dormant Vaultwarden before redeploying under the normalized service layout.
- Decide whether Baserow should eventually use a PostgreSQL image/build with pgvector support.
- Plan migrations away from UID/GID 0 for Syncthing and Nginx Proxy Manager after NFS permissions are understood.
