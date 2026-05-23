# VPN External Access Validation

Status: Current
Last reviewed: 2026-05-23
Source docs:
- Server Plan 21.05.26.md
- to-do list 17.05.26.md
- User update on 2026-05-23: VPN port has been forwarded externally.
Next action: Test WireGuard from a client that is not on the home LAN.

## Purpose

Prove that WireGuard still works correctly now that its UDP port is forwarded and should be externally reachable. This runbook should be completed before media-node work resumes, because VPN access is the recovery path for remote administration.

## Known State

- WireGuard runs in LXC 102.
- The environment follows a VPN-first access model.
- The WireGuard UDP port has been forwarded at the router.
- The exact forwarded port, router destination IP, and peer endpoint still need to be recorded here.

Fill in during validation:

```text
Forwarded UDP port:
Router forwards to:
WireGuard LXC LAN IP:
WireGuard interface:
Tunnel subnet:
External endpoint or DDNS name:
Test client:
Test date:
Result:
```

## Do Not Change Yet

- Do not expose application services directly to the internet.
- Do not change DNS, reverse proxy, or media services while validating VPN.
- Do not rotate keys unless there is evidence the current keys are wrong or compromised.
- Do not troubleshoot internal services until the tunnel itself is proven up.

## Validation Steps

1. Confirm the router forward points UDP traffic on the chosen public port to the WireGuard LXC LAN IP and WireGuard listen port.
2. On the WireGuard LXC, confirm the service is running and listening on UDP.
3. Confirm the LXC firewall, host firewall, and router firewall allow the forwarded UDP port.
4. Confirm the client peer config uses the current external endpoint and forwarded port.
5. Test from outside the LAN, such as a phone hotspot or mobile-data client. Do not test only from home Wi-Fi.
6. Bring up the client tunnel and confirm the server sees a recent handshake.
7. From the VPN client, test the WireGuard gateway, Pi-hole/DNS if routed through VPN, and one internal service.
8. Confirm split tunnel or full tunnel behavior matches intent.
9. Record the result in this file or a dated validation note.

## Useful Manual Checks

Server-side checks:

```bash
sudo systemctl status wg-quick@wg0
sudo wg show
sudo ss -lunp
ip addr
ip route
```

Client-side checks:

```bash
wg show
ping <wireguard-gateway-ip>
ping <internal-lan-ip>
curl -I http://<internal-service>
```

DNS checks, if Pi-hole or internal DNS should be reachable over VPN:

```bash
nslookup <internal-hostname> <dns-server-ip>
dig @<dns-server-ip> <internal-hostname>
```

## Expected Pass Criteria

VPN validation passes when:

- An external client can complete a WireGuard handshake.
- The handshake timestamp updates on the server.
- The client can reach intended internal subnets or services.
- DNS works over the tunnel if that is part of the intended design.
- The tunnel survives disconnect/reconnect without manual server-side fixes.
- The final working endpoint, port, subnet, and client behavior are documented.

## Common Fixes If It Fails

- If there is no handshake, check the router UDP forward, public endpoint, listen port, LXC IP, and firewall rules.
- If handshake works but nothing routes, check `AllowedIPs`, server forwarding, return routes, and firewall policy.
- If IP access works but names fail, check the VPN client DNS server and Pi-hole/internal DNS reachability.
- If mobile clients work only briefly, set or verify client `PersistentKeepalive = 25`.
- If the endpoint changed, update peer configs or DDNS before retesting.

## Stop Conditions

Stop and document the blocker if:

- The forwarded port is unknown.
- The router target IP does not match the WireGuard LXC.
- The WireGuard LXC IP is not static or reserved.
- The tunnel requires disabling broad firewall protections to work.
- Testing from inside the LAN gives different results than testing from outside.
