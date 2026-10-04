# IP, Port, And Proxy Assignments

Status: Current
Last reviewed: 2026-09-29
Source docs:
- Main Node Inventory.md
- Media Node Inventory.md
- Service Map.md
- Nginx Proxy Manager.md
- ADR 0016: Docker Networking Strategy
- User-provided Baserow deployment summary, 2026-07-10
- MediaCenter maintenance/update summary, 2026-07-25
- Homelab Documentation Update Handoff, 2026-07-25
- RustDesk Server installation and 2026-09-28/29 listener, DNS, and access checks
Next action: Verify RustDesk LXC 103's router DHCP reservation and VPN route; note the network path for the successful phone session if useful, and verify the media-node address assignment/reservation.

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
| RustDesk Server LXC 103 | ID/rendezvous and relay service | `192.168.0.189` | DHCP address observed; MAC `BC:24:11:7F:0E:7E`; router reservation is not verified. No WAN forwards were added. |
| `media` | Dedicated media node | `192.168.0.143` observed | Address appeared in the 2026-09-28 maintenance output; whether it is reserved or static is not verified. |

## Infrastructure Port Assignments

| System | Port | Protocol | Purpose | Exposure or routing |
| --- | ---: | --- | --- | --- |
| WireGuard | `51820` | UDP | VPN tunnel | Router forwards to `192.168.0.110`. |
| Pi-hole | Not documented | DNS | Local DNS for `*.dustynest.com` | Used by VPN and selected LAN clients. |
| Nginx Proxy Manager | Not documented | HTTP(S) | Reverse proxy entrypoint | Managed through VM100; canonical ports are not documented in this repo. |
| RustDesk Server LXC 103 | TCP `21114-21119`; UDP `21116` | RustDesk protocols and API/UI | LAN/WireGuard-only by policy; no WAN forwarding added. Observed listeners; verify again after changes. |

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
| RustDesk Server | LXC 103 | TCP `21114-21119`; UDP `21116` | `rustdesk.dustynest.com` A record shown in user screenshot | RustDesk protocol endpoint; not an NPM Proxy Host. API/UI observed at `http://192.168.0.189:21114`. Owner reports client settings were pointed here during maintenance; a connection check remains open. |

RustDesk DNS/routing notes:

- User-provided Cloudflare screenshot shows an A record named `rustdesk.dustynest.com` pointing to `192.168.0.189` with DNS-only status. A private address in DNS does not open a route through the router.
- User confirmed successful API/UI login at `http://192.168.0.189:21114` from the LAN.
- No router WAN port-forward was added. Service access remains LAN/WireGuard-only; VPN routing to the LXC and the router DHCP reservation remain unverified.
- The API/UI listener is for administration, not a public web Proxy Host. Keep it within trusted networks.

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

- Verify whether MediaCenter's observed `192.168.0.143` address is reserved or static.
- Document Baserow's internal Proxy Host forward port.
- Document Nginx Proxy Manager's management and listener ports.
- Decide whether media-node web apps are proxied by host IP, shared network reachability, or a second local proxy on the media node.
- Record actual Proxy Host forward targets as services are created or migrated.
