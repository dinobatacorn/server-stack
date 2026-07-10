# ADR 0016: Docker Networking Strategy

Status: Accepted
Date: 2026-07-10

## Context

Docker Compose projects were initially deployed independently, allowing Docker to create a default network for each stack, such as `npm_default` or `syncthing_default`.

This worked, but it made networking inconsistent. Inter-service communication depended on host ports, host IP addresses, or manually connecting containers to multiple project-specific networks.

As the homelab architecture matures, more services need to communicate internally, especially through the reverse proxy. The previous pattern does not scale cleanly as platform services such as Baserow, Paperless-ngx, Nextcloud, Vaultwarden, Homepage, AnythingLLM, n8n, Grafana, and Uptime Kuma are added.

The goal is to simplify service discovery, reduce unnecessary host port exposure, and establish a consistent networking pattern for future deployments.

## Decision

Adopt a shared Docker bridge network named `proxy`.

The `proxy` network is the common communication layer for services that must be reachable by Nginx Proxy Manager or other user-facing infrastructure.

Services connected to `proxy` should communicate through Docker internal DNS whenever possible. Reverse proxy rules should preferentially target container names on the `proxy` network rather than VM IP addresses.

Example reverse proxy target:

```text
Forward Host: baserow
Port: 80
```

Prefer that over:

```text
Forward Host: 192.168.x.x
Port: 8085
```

when both services share the `proxy` network.

## TLS Certificate Strategy

Status: Accepted

The homelab uses a single wildcard Let's Encrypt certificate for `*.dustynest.com` managed by Nginx Proxy Manager.

Individual services do not receive separate certificates unless there is a specific technical requirement.

Examples using the shared wildcard certificate:

- `db.dustynest.com`.
- `media.dustynest.com`.
- `books.dustynest.com`.
- `requests.dustynest.com`.
- `paperless.dustynest.com`.

Rationale:

- Simplifies onboarding new services.
- Avoids repeated ACME requests for routine service additions.
- Reduces certificate management overhead.
- Provides a consistent HTTPS configuration across the homelab.
- Keeps certificate renewal centralized within Nginx Proxy Manager.

Operational standard for new web services:

1. Join the service to the shared `proxy` Docker network.
2. Create a new Proxy Host in Nginx Proxy Manager.
3. Use the existing wildcard `*.dustynest.com` certificate.
4. Do not request a new Let's Encrypt certificate unless the wildcard certificate cannot satisfy the deployment.

## Subdomain Naming Convention

Subdomains should be reserved by function rather than assigned ad hoc.

| Service | Suggested Hostname |
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

This creates a predictable namespace where URLs describe service purpose and future deployments follow the same pattern.

## Network Responsibilities

### proxy

Purpose:

- Reverse proxy communication.
- Internal service discovery.
- User-facing web applications.
- Shared network for services accessed through Nginx Proxy Manager.

Expected members include:

- Nginx Proxy Manager.
- Homepage.
- Vaultwarden.
- Baserow.
- Paperless-ngx.
- Nextcloud.
- AnythingLLM.
- n8n.
- Grafana.
- Uptime Kuma.
- Other HTTP(S) applications.

## Default Compose Networks

Docker Compose may continue creating project-specific default networks unless explicitly disabled.

These networks remain acceptable for private communication between tightly coupled services within a stack, such as an application and its PostgreSQL container.

The shared `proxy` network supplements these internal networks rather than replacing them.

Example:

```text
baserow_default
|-- baserow
`-- postgres

proxy
|-- baserow
|-- nginx-proxy-manager
`-- homepage
```

This preserves internal isolation while allowing reverse proxy access.

## Consequences

Advantages:

- Consistent service discovery using container names.
- Reduced dependence on host IP addresses.
- Simplified reverse proxy configuration.
- Easier migration between hosts.
- Cleaner Compose files.
- Scalable architecture for future services.

Trade-offs:

- Services intended for reverse proxy access must explicitly join the `proxy` network.
- Docker networking becomes an intentional part of deployment rather than relying only on Compose defaults.

## Migration Notes

Existing Compose projects that currently rely solely on Docker-created default networks should be migrated opportunistically.

New deployments should join the `proxy` network from the outset when they are intended for reverse proxy access or user-facing infrastructure.

Existing, functioning services do not need to be modified immediately. They can be updated during routine maintenance or when their Compose files are otherwise being changed.

## Alternatives Considered

- Per-project networks only. Rejected because they require exposing additional host ports or manually attaching containers to multiple networks when services need to communicate.
- Single shared network for all containers. Rejected because it unnecessarily broadens communication between unrelated services and reduces logical separation.
- Multiple functional shared networks, such as `knowledge`, `media`, or `monitoring`. Deferred because the added segmentation is not currently justified by the size of the homelab, but may be revisited if service count or security requirements increase.

## Related Architectural Decisions

- [ADR 0001: Storage Taxonomy And `/mnt/core` Source Of Truth](0001-storage-taxonomy.md)
- [ADR 0003: Platform Services Node Vs Media Node](0003-platform-vs-media-node.md)
- [ADR 0004: Containers Are Disposable](0004-containers-are-disposable.md)
- [ADR 0005: Kodi Frontend And Jellyfin Backend](0005-kodi-frontend-jellyfin-backend.md)
