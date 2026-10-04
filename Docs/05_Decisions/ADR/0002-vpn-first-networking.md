# ADR 0002: VPN-First Networking

Status: Accepted
Date: 2026-07-09
Policy clarification: 2026-09-29

## Context

The homelab needs secure remote access without making every service public. The router also cannot be made the authoritative DNS source for LAN clients.

## Decision

WireGuard is the remote-access path. Every service except WireGuard itself must be reachable only from the home LAN or from WireGuard-connected clients. Do not configure public WAN ingress for application services. A future public portal is the sole planned exception; it is not deployed and must remain isolated from internal services.

Pi-hole owns local homelab DNS records. Clients that need local records must use Pi-hole directly when router or adapter behavior prevents reliable local resolution. Public DNS records are not an access-control mechanism. LAN and VPN clients use Pi-hole's local records; do not add a public Cloudflare record merely to make an internal service work. Reverse proxying through Nginx Proxy Manager does not change the private-network access requirement.

Planning note, 2026-09-29: A separate PVE game-services VM for Archipelago, Minecraft, or Palworld is being conceptualized, including the possibility of friend access without VPN. No VM has been created, no game-service WAN forward has been approved, and this note does not change the accepted LAN/WireGuard-only decision. If public game access is later chosen, amend this ADR with the exact services, ports, isolation, and review before adding router rules.

## Consequences

LAN access does not require a VPN connection when a client is already on the home network and uses Pi-hole for local DNS. Remote access requires WireGuard. Windows DNS adapter precedence is documented as an operational issue, with the Windows Wi-Fi adapter using Pi-hole directly. Any public portal requires an explicit architecture and isolation review before deployment.

## Alternatives Considered

- Publicly expose most services through reverse proxy. Rejected as unnecessary risk.
- Depend on router DNS. Rejected because the router must keep ISP DNS.
