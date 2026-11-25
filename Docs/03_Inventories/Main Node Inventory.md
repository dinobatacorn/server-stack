# Main Node Inventory

Status: Current
Last reviewed: 2026-11-25
Source docs:
- pve-output_09072026.txt
- vm100-output_09072026.txt
- Fleet Update Report, 2026-09-28
- Fleet Update Follow-up, 2026-09-29
- RustDesk Server Maintenance, 2026-09-29
- PVE, Pi-hole, WireGuard, VM100, and MediaCenter fleet inventory JSON from September 28/29 were part of the 2026-11-25 move to `scripts/output/YYYY-MM-DD/{pre,post}/`; final per-file reconciliation remains pending.
- User-provided Baserow deployment summary, 2026-07-10
- Syncthing Recovery and Architecture Update, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
- User-provided Proxmox BIOS/baseboard dmidecode excerpt, 2026-07-26
- Baserow PostgreSQL 16 to 17 migration handoff, 2026-11-24/25
- Proxmox Backup and Fleet Inventory Cleanup handoff, 2026-11-25
- Fleet post-collection JSON captures, `scripts/output/2026-11-25/post/`; summarized in [2026-11-25 Fleet Update Report](../06_Operations/Update%20Reports/2026-11-25.md).
Next action: Establish independent PostgreSQL 17 backups and test restore; complete old Compose service cleanup and Baserow restart checks; retain PostgreSQL 16 data until recovery requirements are addressed.

## Role

The main node is the Proxmox-backed infrastructure and personal-cloud platform. It is separate from the dedicated media node.

Application-domain split:

- VM100: infrastructure, knowledge, utilities, security, automation, monitoring, personal cloud, and backup orchestration.
- Media node: acquisition, processing, discovery, serving, playback, reading, and preservation.

## Proxmox Host

Host: `pve`

- OS: Debian GNU/Linux 13 Trixie
- Platform: Proxmox VE; version 9.2.20 was recorded in the September 2026 fleet report. The 2026-11-25 JSON capture did not include the installed Proxmox VE package version.
- Latest collected kernel: `7.0.14-30-pve` (2026-11-25 post capture; the earlier same-day capture recorded `7.0.14-25-pve`)
- IP: `192.168.0.75`
- CPU: Intel Xeon E5-2609 v2, 4 cores
- Memory: 32 GiB
- `/mnt/core`: 1 TB Samsung SSD mounted at `/dev/sdb1`
- The 2026-11-25 15:34 CST post capture reported zero pending apt updates. An earlier 12:29 CST capture reported 28; no transaction log was included.
- The later capture reported two scanned disks with SMART status passed. It did not record the Proxmox VE package version or guest/application validation.
- PVE services and all four guests recovered after reboot; see the 2026-09-28 Fleet Update Report for validation details and guest backup archives.
- 2026-09-29 PVE inventory JSON is fleet output, separate from recovery archives. The restricted PVE host-configuration archive was relocated to `/mnt/core/backups/pve/2026-09-29/`; a fresh snapshot-mode VM100 vzdump remains under `/mnt/core/backups/snapshots/dump/`. Both recovery archives passed `zstd -t` before/after relocation as reported.
- No RustDesk package or service is installed on PVE; direct SSH and the Proxmox web service are available.

Firmware and baseboard:

- BIOS vendor: Intel Corp.
- BIOS version: `SE5C600.86B.02.04.0003.102320141138`
- BIOS release date: 2014-10-23
- Baseboard: Intel Corporation S2600CP, version `G50768-511`

Running LXCs:

- 101 `pihole`, `192.168.0.120`, on boot
- 102 `wireguard`, `192.168.0.110`, on boot, `/mnt/core` mounted into the container
- 103 `rustdeskserver`, `192.168.0.189` by DHCP, on boot; unprivileged Debian 13; RustDesk `hbbs`, `hbbr`, and API/UI installed. RustDesk application state is on `/mnt/core/appdata/security`. User-provided screenshot shows a DNS A record for this address; the router-side DHCP reservation for MAC `BC:24:11:7F:0E:7E` remains unverified.
- CT104 `postgresql`, `192.168.0.139`, unprivileged Debian 13, PostgreSQL 17.12, production Baserow database `baserow` per the 2026-11-24/25 migration handoff; data is bind-mounted from PVE `/mnt/core/appdata/postgresql` to `/var/lib/postgresql/17/main`. Production restore and application operation were verified during cutover; backups and restore procedure remain pending. **ID conflict:** the older [Server Plan](../Server%20Plan%2021.05.26.md) assigns VM104 to Home Assistant OS. Verify current PVE guest IDs before treating this CT number as live state. See [Baserow migration record](../06_Operations/Incidents/2026-11-24-baserow-postgresql-migration.md).

Running VMs:

- VM100 `services`, Core Services Docker host, `192.168.0.125`, on boot
- VM200 `infra-proxy` was destroyed, per owner report on 2026-09-30, after the partner moved to Super Productivity. The owner reports an older, comprehensive backup exists; its contents, date, and restoreability have not been independently checked. Historical VM200 records below are retained as history.

## RustDesk Server LXC 103 Storage

- The Debian OS and installed packages use the 2 GiB `local-lvm` root disk.
- Persistent server state: `/mnt/core/appdata/security/rustdesk-server` on PVE -> `/var/lib/rustdesk-server` in CT 103. This contains the server identity key and SQLite database.
- Persistent API state: `/mnt/core/appdata/security/rustdesk-api` on PVE -> `/var/lib/rustdesk-api` in CT 103.
- `/mnt/core` on PVE is the ext4 filesystem `/dev/sdb1`; the LXC bind mounts were verified against that mount.
- The RustDesk private identity key is mode `600` in the guest. Backups containing appdata also contain this private key and must be protected.
- Proxmox vzdump archives the CT root disk but does not include the bind-mounted appdata. A separate appdata archive passed `zstd -t` and was relocated to `/mnt/core/backups/rustdesk/2026-09-28/`. Future appdata backups must continue separately from CT vzdump backups.
- A pre-migration CT backup is stored at `/mnt/core/backups/snapshots/dump/vzdump-lxc-103-2026_09_28-19_20_53.tar.zst` and passed `zstd -t`.
- Services `rustdesk-hbbs`, `rustdesk-hbbr`, and `rustdesk-api` were active; observed listeners were TCP `21114-21119` and UDP `21116`. The user confirmed successful API/UI login at `http://192.168.0.189:21114`.
- No WAN port forwards were added. The DNS-only Cloudflare A record to the RFC1918 address was shown by the user; DNS does not establish routing. The router reservation and VPN reachability remain open checks.
- The server uses the `lejianwen/rustdesk-server` fork installed by Proxmox Community Scripts, including API/UI; do not conflate its component versions with the upstream RustDesk server release number.

## VM100 Core Services Docker Host

Host: `services`

- OS: Debian GNU/Linux 13 Trixie
- Kernel: `6.12.118+deb13-amd64` in the 2026-11-25 post capture
- Latest collector storage snapshot (2026-11-25): root 40% used, about 24.1 GiB used and 36.1 GiB available; `/mnt/core` was reported mounted via NFSv4.
- Role: core services platform

Containers reported running in the 2026-11-25 post capture:

- `syncthing`: `lscr.io/linuxserver/syncthing:latest`
- `baserow`: `baserow/baserow:latest`; collector reported healthy. Production PostgreSQL 17.12 remains in CT104 per migration handoff.
- `actual-budget`: `actualbudget/actual-server:latest`; collector reported healthy. Compose file: `/mnt/core/services/core/actual-budget/compose.yml`.
- `npm`: `jc21/nginx-proxy-manager:latest`
- `syncthing`: `lscr.io/linuxserver/syncthing:latest`
- `isponsorblocktv`: `ghcr.io/dmunozv04/isponsorblocktv:latest`

At capture, all five listed containers were running; Baserow and Actual Budget had Docker health status `healthy`. The legacy PostgreSQL 16 container did not appear in this snapshot; this is not by itself proof that its Compose definition or data has been removed. Package update count was zero. No HTTP, database, or user-level service checks were part of this collector record. Historical 2026-09-28 details remain below as historical evidence.

Historical 2026-09-28 verification: all five containers then captured were running; Baserow and its then-local PostgreSQL 16 were healthy and all five restart counts were 0. Following the later cutover, PostgreSQL 17.12 on CT104 is the production database. Nginx Proxy Manager was verified at `2.16.0`; its UI returned HTTP 200, the `db.dustynest.com` route returned HTTP 302, and its active certificate expires 2026-12-01. The pre-refresh NPM data/certificate archive passed validation and was relocated to `/mnt/core/backups/npm/2026-09-28/`. The Baserow PostgreSQL dump at `/mnt/core/backups/baserow/2026-09-28/baserow-pre-image-refresh.dump` passed `pg_restore --list`.

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
- Legacy PostgreSQL 16 data: `/mnt/core/appdata/knowledge/baserow/postgres` (retained historical copy; not synchronized with production)
- PostgreSQL 17 data: PVE `/mnt/core/appdata/postgresql -> /var/lib/postgresql/17/main` in CT104

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

## PostgreSQL 17 Database Guest

- CT104 hostname `postgresql`, address `192.168.0.139`, Debian 13 unprivileged LXC.
- PostgreSQL 17.12 listens on port `5432`; production database/role are `baserow`.
- PVE stores database files on `/mnt/core/appdata/postgresql`; inside CT104 they appear at `/var/lib/postgresql/17/main`. Ownership mapping was verified as UID/GID `988:988` inside CT104 to `100988:100988` on PVE; LXC protection was restored after mount configuration.
- Adminer 5.2.1 is available at `http://192.168.0.139/adminer`.
- The host-based rule currently covers `192.168.0.0/24` with SCRAM; narrowing to VM100 remains a follow-up. Do not put passwords in documentation.
- PostgreSQL 17 scheduled backups and restore testing are not established.

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
- `/mnt/core/stacks/knowledge/affine/docker-compose.yml` is a historical deployment definition associated with VM200. VM200 is reported destroyed; the partner now uses Super Productivity. No active AFFiNE deployment is confirmed.
- Historical AFFiNE inspection from VM100 without the right environment produced missing variable warnings for `DB_DATA_LOCATION`, `DB_USERNAME`, `DB_PASSWORD`, `UPLOAD_LOCATION`, and `CONFIG_LOCATION`, ending with `invalid spec: :/root/.affine/storage: empty section between colons`. This was not evidence that the VM200 deployment was broken.
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
- RustDesk clients only; the self-hosted server is in PVE LXC 103, not VM100.

Monitoring:

- Uptime Kuma
- Grafana
- Prometheus
- Node Exporter
- cAdvisor, if useful

Backup:

- Restic

## Open Questions

- Confirm the contents, date, and restoreability of the older VM200 backup if any data needs recovery; do not treat it as restore-validated.
- Decide whether the historical AFFiNE export and stack definition should remain archived only now that the partner uses Super Productivity and Obsidian is the knowledge direction.
- Review dormant Vaultwarden before redeploying under the normalized service layout.
- Decide whether Baserow should eventually use a PostgreSQL image/build with pgvector support.
- Plan migrations away from UID/GID 0 for Syncthing and Nginx Proxy Manager after NFS permissions are understood.
