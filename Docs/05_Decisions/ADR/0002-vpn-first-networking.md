# ADR 0002: VPN-First Networking

Status: Accepted
Date: 2026-07-09

## Context

The homelab needs secure remote access without making every service public. The router also cannot be made the authoritative DNS source for LAN clients.

## Decision

WireGuard is the preferred remote-access path. Services are internal-first unless there is a specific reason to expose them.

Pi-hole owns local homelab DNS records. Clients that need local records must use Pi-hole directly when router or adapter behavior prevents reliable local resolution.

## Consequences

The default posture is private and simpler to reason about. Public exposure remains deliberate. Windows DNS adapter precedence is documented as an operational exception, with the Windows Wi-Fi adapter using Pi-hole directly.

## Alternatives Considered

- Publicly expose most services through reverse proxy. Rejected as unnecessary risk.
- Depend on router DNS. Rejected because the router must keep ISP DNS.
