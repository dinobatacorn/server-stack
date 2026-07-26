# IP, Port, And Proxy Assignments

Status: Current
Last reviewed: 2026-07-25
Source docs:
- Main Node Inventory.md
- Media Node Inventory.md
- Service Map.md
- Nginx Proxy Manager.md
- ADR 0016: Docker Networking Strategy
- User-provided Baserow deployment summary, 2026-07-10
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
Next action: Fill in Baserow's documented internal forward port and missing media-node IP as assignments are confirmed.

## Purpose

This reference records documented IP, port, DNS, and reverse-proxy assignments for the homelab.

Use this page when adding a service, creating a Pi-hole record, or creating a Proxy Host in Nginx Proxy Manager.

This page distinguishes deployed values from planned naming standards. It does not prove that a planned service is deployed.

## Assignment Rules

- Infrastructure IPs should remain stable and documented before dependent services are added.
- User-facing web services should receive functional `*.dustynest.com` hostnames.
- New user-facing Docker services should join the shared `proxy` network when possible.
- Nginx Proxy Manager should forward to container names on the `proxy` network when possible.
- Services should use the shared wildcard `*.dustynest.com` certificate unless a specific technical requirement calls for a separate certificate.
- Host ports should be exposed only when needed for LAN access, non-HTTP protocols, or services that are not yet reachable through the reverse proxy path.

## Infrastructure IP Assignments

| System | Role | IP | Notes |
| --- | --- | --- | --- |
| `pve` | Proxmox host and `/mnt/core` NFS source | `192.168.0.75` | Hosts Pi-hole, WireGuard, VM100, and Home Assistant OS. |
| `pihole` LXC 101 | DNS filtering and local records | `192.168.0.120` | Authoritative for documented local `*.dustynest.com` records. |
| `wireguard` LXC 102 | VPN entrypoint | `192.168.0.110` | Router forwards WireGuard traffic here. |
| VM100 `services` | Core Services Docker host | `192.168.0.125` | Runs Nginx Proxy Manager, Syncthing, and iSponsorBlockTV in the documented inventory. |
| `media` | Dedicated media node | Not documented | Hostname is documented; IP is not documented in canonical inventory. |

## Infrastructure Port Assignments

| System | Port | Protocol | Purpose | Exposure or routing |
| --- | ---: | --- | --- | --- |
| WireGuard | `51820` | UDP | VPN tunnel | Router forwards to `192.168.0.110`. |
| Pi-hole | Not documented | DNS | Local DNS for `*.dustynest.com` | Used by VPN and selected LAN clients. |
| Nginx Proxy Manager | Not documented | HTTP(S) | Reverse proxy entrypoint | Managed through VM100; canonical ports are not documented in this repo. |

## Current Service Port Reference

| Service | Host or node | Documented port(s) | Current proxy hostname | Preferred proxy target |
| --- | --- | --- | --- | --- |
| Nginx Proxy Manager | VM100 `services` | Not documented | Not documented | Reverse proxy control plane. |
| Syncthing | VM100 `services` | Not documented | Not documented | Not currently assigned in canonical proxy docs. |
| iSponsorBlockTV | VM100 `services` | Not documented | Not documented | Not currently assigned in canonical proxy docs. |
| Baserow | VM100 `services` | Not documented | `db.dustynest.com` | Baserow container on the shared `proxy` network. |
| qBittorrent | `media` | `8080`, `6881` | Not documented | TBD after media-node proxy path is documented. |
| Prowlarr | `media` | `9696` | Not documented | TBD after media-node proxy path is documented. |
| Sonarr | `media` | `8989` | Not documented | TBD after media-node proxy path is documented. |
| Radarr | `media` | `7878` | Not documented | TBD after media-node proxy path is documented. |
| Jellyfin | `media` | `8096` | `media.dustynest.com` standard | TBD after media-node proxy path is documented. |
| Seerr | `media` | `5055` | `requests.dustynest.com` standard | Intended request service; returned successfully after 2026-07-25 mount repair. |
| Kodi | `media` | Native app | Not applicable | Not a Docker reverse-proxy target. |
| RustDesk | `media` | Not documented | Not applicable | Native remote administration service; enabled and active. |

## Planned Proxy Hostname Standards

| Service | Hostname | Default proxy certificate | Forward target status |
| --- | --- | --- | --- |
| Homepage | `home.dustynest.com` | `*.dustynest.com` | Planned. |
| Baserow | `db.dustynest.com` | `*.dustynest.com` | Operational; internal forward port not documented. |
| Nextcloud | `cloud.dustynest.com` | `*.dustynest.com` | Planned. |
| Paperless-ngx | `paperless.dustynest.com` | `*.dustynest.com` | Planned. |
| Vaultwarden | `vault.dustynest.com` | `*.dustynest.com` | Planned. |
| Jellyfin | `media.dustynest.com` | `*.dustynest.com` | Service port documented; proxy target TBD. |
| Seerr | `requests.dustynest.com` | `*.dustynest.com` | Service port documented; proxy target TBD. |
| Grafana | `grafana.dustynest.com` | `*.dustynest.com` | Planned. |
| Uptime Kuma | `status.dustynest.com` | `*.dustynest.com` | Planned. |
| AnythingLLM | `ai.dustynest.com` | `*.dustynest.com` | Planned. |
| n8n | `automation.dustynest.com` | `*.dustynest.com` | Planned. |

## New Service Assignment Checklist

1. Choose the functional `*.dustynest.com` hostname.
2. Record the service's internal container port.
3. Decide whether a host port is required.
4. Attach the service to the shared `proxy` Docker network if it is user-facing.
5. Add or update the Pi-hole local DNS record.
6. Create the Nginx Proxy Manager Proxy Host.
7. Use the wildcard `*.dustynest.com` certificate.
8. Update this reference with the final IP, port, hostname, and forward target.

## Open Assignments

- Document the media-node LAN IP.
- Document Baserow's internal Proxy Host forward port.
- Document Nginx Proxy Manager's management and listener ports.
- Decide whether media-node web apps are proxied by host IP, shared network reachability, or a second local proxy on the media node.
- Record actual Proxy Host forward targets as services are created or migrated.
