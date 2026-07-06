# VPN External Access Validation

Status: Current
Last reviewed: 2026-07-06
Source docs:
- Server Plan 21.05.26.md
- to-do list 17.05.26.md
- User update on 2026-05-23: VPN port has been forwarded externally.
- User update on 2026-05-23: WireGuard service is inactive and no UDP listener is present.
- User update on 2026-05-23: `wg-quick@wg0` is enabled, `wg0` is up, and UDP `51820` is listening.
Next action: Record the final external endpoint and a dated known-good client test when convenient.

## Purpose

Prove that WireGuard still works correctly now that its UDP port is forwarded and should be externally reachable. This runbook should be completed before media-node work resumes, because VPN access is the recovery path for remote administration.

## Known State

- WireGuard runs in LXC 102.
- The environment follows a VPN-first access model.
- WireGuard is operational and split tunneling has been restored.
- Proxy addresses have been verified working.
- The original failure mode was not conclusively identified; service resumed after portions of the configuration were rebuilt.
- The WireGuard UDP port has been forwarded at the router.
- Router forward target: `192.168.0.110`.
- WireGuard LXC MAC: `bc:24:11:d2:6f:77`.
- Forwarded/listen port: UDP `51820`.
- WireGuard interface: `wg0`.
- WireGuard gateway/tunnel address: `10.0.0.1/24`.
- Known peer tunnel addresses: `10.0.0.2/32` through `10.0.0.10/32`.
- Local service state is now good: `wg-quick@wg0` is enabled and active, `wg show` reports `wg0`, and `ss -lunp` shows UDP `51820`.
- External endpoint or DDNS name still needs to be recorded in this runbook.

Fill in during validation:

```text
Forwarded UDP port: 51820/udp
Router forwards to: 192.168.0.110
WireGuard LXC LAN IP: 192.168.0.110
WireGuard LXC MAC: bc:24:11:d2:6f:77
WireGuard interface: wg0
Tunnel subnet: 10.0.0.1/24 server, peers 10.0.0.2/32 through 10.0.0.10/32
External endpoint or DDNS name:
Test client:
Test date:
Result: WireGuard operational as of 2026-07-06; split tunneling restored and proxy addresses verified. Final endpoint and dated client details remain to be recorded here.
```

## Do Not Change Yet

- Do not expose application services directly to the internet.
- Do not change DNS, reverse proxy, or media services while validating VPN.
- Do not rotate keys unless there is evidence the current keys are wrong or compromised.
- Do not troubleshoot internal services until the tunnel itself is proven up.

## Validation Steps

1. Confirm the router forward points UDP traffic on the chosen public port to the WireGuard LXC LAN IP and WireGuard listen port.
2. On the WireGuard LXC, start and enable `wg-quick@wg0`.
3. Confirm the service is running and listening on UDP `51820`.
4. Confirm the LXC firewall, host firewall, and router firewall allow the forwarded UDP port.
5. Confirm the client peer config uses the current external endpoint and forwarded port.
6. Test from outside the LAN, such as a phone hotspot or mobile-data client. Do not test only from home Wi-Fi.
7. Bring up the client tunnel and confirm the server sees a recent handshake.
8. From the VPN client, test the WireGuard gateway, Pi-hole/DNS if routed through VPN, and one internal service.
9. Confirm split tunnel or full tunnel behavior matches intent.
10. Record the result in this file or a dated validation note.

## Laptop Hotspot Test Procedure

Use this when the laptop has to leave the home LAN to prove external access. Keep this file open locally before switching networks, because the browser, editor, or remote terminal may temporarily disconnect.

Before leaving LAN:

1. Save any open files.
2. Keep this runbook open in the editor.
3. Open the WireGuard client app but do not connect yet.
4. Confirm the selected peer uses the public endpoint or DDNS name plus UDP `51820`, not the LAN IP `192.168.0.110`.
5. Prepare a terminal for client-side tests:

```bash
ping 10.0.0.1
ping 192.168.0.110
ping <another-internal-lan-ip>
```

External test:

1. Disconnect the laptop from home LAN/Wi-Fi.
2. Connect the laptop to the phone hotspot.
3. Wait for basic internet to work on the hotspot.
4. Connect the WireGuard VPN.
5. Confirm the WireGuard client shows traffic sent/received or an active tunnel.
6. Run `ping 10.0.0.1`.
7. Run `ping 192.168.0.110`.
8. Run `ping <another-internal-lan-ip>`.
9. If the pings work, optionally test one internal service in a browser.
10. Record which tests passed or failed.

Return to normal:

1. Disconnect the WireGuard VPN.
2. Reconnect the laptop to home LAN/Wi-Fi.
3. Turn off or ignore the phone hotspot.
4. Refresh the browser/editor if the session did not reconnect automatically.
5. On the WireGuard LXC, run `sudo wg show` and look for a recent handshake on the tested peer.
6. Update this runbook with the test client, test date, and result.

If the Codex/browser window does not come back immediately, reconnect to LAN first, then reload the page. The workspace files are local to the repo and the runbook changes are not dependent on the browser staying connected during the network switch.

## Local Service Startup Result

Observed on 2026-05-23:

```text
wg-quick@wg0.service: inactive (dead)
wg show: no interfaces reported
ss -lunp: no UDP listeners reported
```

Interpretation: the router could forward traffic, but the WireGuard LXC was not accepting it.

Fix applied:

```bash
sudo systemctl enable --now wg-quick@wg0
sudo systemctl status wg-quick@wg0
sudo wg show
sudo ss -lunp
```

Result:

- `wg-quick@wg0` is enabled.
- `wg-quick@wg0` is active.
- `wg0` has server tunnel address `10.0.0.1/24`.
- `wg show` reports listening port `51820`.
- `ss -lunp` shows UDP `51820` listening on `0.0.0.0` and `[::]`.

Next gate: external client handshake from outside the LAN.

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
