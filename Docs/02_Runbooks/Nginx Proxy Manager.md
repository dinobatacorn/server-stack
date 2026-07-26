# Nginx Proxy Manager

Status: Current
Last reviewed: 2026-07-25
Source docs:
- ADR 0016: Docker Networking Strategy
- to-do list 17.05.26.md
- vm100-output_09072026.txt
- Homelab Documentation Update Handoff, 2026-07-25
Next action: Apply this standard as new user-facing services are deployed or existing Proxy Hosts are touched.

## Purpose

Nginx Proxy Manager is the primary reverse proxy for user-facing homelab services.

It provides HTTP(S) entrypoints, central TLS certificate handling, and proxy routing to containers attached to the shared Docker `proxy` network.

## Deployment Standard

Canonical host:

```text
VM100 services
```

Compose location:

```text
/mnt/core/stacks/core/npm/docker-compose.yml
```

Image:

```text
jc21/nginx-proxy-manager:latest
```

Persistent mounts:

```text
/mnt/core/appdata/core/npm/data        -> /data
/mnt/core/appdata/core/npm/letsencrypt -> /etc/letsencrypt
```

NPM uses:

```text
/data/database.sqlite
```

The database was present after the July 25 update and was approximately 124 KB at verification time.

NPM currently runs with UID/GID 0. Treat this as technical debt and do not change permissions casually.

Use [IP, Port, And Proxy Assignments](../01_Architecture/IP%20Port%20Proxy%20Assignments.md) as the assignment reference when choosing hostnames, ports, and forward targets.

When deploying a new web service:

1. Attach the service container to the shared Docker `proxy` network.
2. Create a local DNS record for the selected `*.dustynest.com` hostname.
3. Create a new Proxy Host in Nginx Proxy Manager.
4. Set the Forward Hostname to the container name on the `proxy` network when possible.
5. Set the Forward Port to the service's internal HTTP port.
6. Use the existing wildcard `*.dustynest.com` certificate.
7. Do not request a separate Let's Encrypt certificate unless the wildcard certificate cannot satisfy the deployment.

Example:

```text
Domain Names: db.dustynest.com
Forward Hostname / IP: baserow
Forward Port: 80
Certificate: *.dustynest.com
```

Prefer container names on the shared Docker network over VM IP addresses when Nginx Proxy Manager and the target service share the `proxy` network.

## TLS Certificate Strategy

Use a single wildcard Let's Encrypt certificate for `*.dustynest.com`, managed by Nginx Proxy Manager.

Individual services should not receive separate certificates unless there is a specific technical requirement.

Services covered by the wildcard pattern include:

- `home.dustynest.com`.
- `db.dustynest.com`.
- `cloud.dustynest.com`.
- `paperless.dustynest.com`.
- `vault.dustynest.com`.
- `media.dustynest.com`.
- `requests.dustynest.com`.
- `grafana.dustynest.com`.
- `status.dustynest.com`.
- `ai.dustynest.com`.
- `automation.dustynest.com`.

Operational benefits:

- New services can reuse the existing certificate.
- Routine service additions do not require repeated ACME certificate requests.
- Certificate renewal remains centralized in Nginx Proxy Manager.
- HTTPS behavior stays consistent across homelab services.

## Subdomain Naming Convention

Reserve hostnames by service function.

| Service | Hostname |
| --- | --- |
| Homepage | `home.dustynest.com` |
| Baserow | `db.dustynest.com` |
| Nextcloud | `cloud.dustynest.com` |
| Paperless-ngx | `paperless.dustynest.com` |
| Vaultwarden | `vault.dustynest.com` |
| Jellyfin | `media.dustynest.com` |
| Seerr | `requests.dustynest.com` |
| Grafana | `grafana.dustynest.com` |
| Uptime Kuma | `status.dustynest.com` |
| AnythingLLM | `ai.dustynest.com` |
| n8n | `automation.dustynest.com` |

Use functional names for future services unless a service has a stronger established homelab convention.

## Validation

After adding or changing a Proxy Host:

- Confirm the hostname resolves through Pi-hole for intended clients.
- Confirm Nginx Proxy Manager can reach the service by container name on the `proxy` network.
- Confirm HTTPS uses the wildcard `*.dustynest.com` certificate.
- Confirm the service remains internal-first unless public exposure has been explicitly approved.

July 25 update validation:

- NPM started successfully.
- Backend and nginx initialized.
- Cloudflare Certbot plugin installed.
- Certificate renewal initialized.
- Backend reported listening on port 3000.
- No obvious application errors were observed.

## Related Decisions

- [ADR 0002: VPN-First Networking](../05_Decisions/ADR/0002-vpn-first-networking.md)
- [ADR 0016: Docker Networking Strategy](../05_Decisions/ADR/0016-docker-networking-strategy.md)
