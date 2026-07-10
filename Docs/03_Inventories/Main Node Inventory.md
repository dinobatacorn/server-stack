# Main Node Inventory

Status: Current
Last reviewed: 2026-07-10
Source docs:
- pve-output_09072026.txt
- vm100-output_09072026.txt
- User-provided Baserow deployment summary, 2026-07-10
Next action: Normalize legacy VM100 `/mnt/core/stacks` compose projects into `/mnt/core/services`.

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
- Disk: 64 GB root disk, 8% used at inventory time
- Role: core services platform

Running containers:

- `npm`: Nginx Proxy Manager
- `syncthing`: Syncthing
- `isponsorblocktv`: iSponsorBlockTV
- `baserow`: Baserow

## VM100 Storage Snapshot

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
- Baserow data: `/mnt/core/appdata/knowledge/baserow`

## Current Compose Locations

Current state includes both normalized and legacy locations:

- `/mnt/core/services/media/compose/core/docker-compose.yml`
- `/mnt/core/services/knowledge/baserow/docker-compose.yml`
- `/mnt/core/services/syncthing/compose.yml`
- `/mnt/core/stacks/core/npm/docker-compose.yml`
- `/mnt/core/stacks/knowledge/affine/docker-compose.yml`
- `/mnt/core/stacks/utilities/isponsorblocktv/docker-compose.yml`
- `/mnt/core/stacks/utilities/vaultwarden/docker-compose.yml`

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
- Confirm whether Vaultwarden has any active data that needs preservation before redeploying under the normalized service layout.
