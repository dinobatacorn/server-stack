# MediaCenter Maintenance — 2026-10-04

Status: Current operational record
Last reviewed: 2026-10-04
Host: `media` / user `mediacenter`
OS: Debian 13 (Trixie)
Source: User-provided Media Center Update, 2026-10-04
Next actions: Rotate the exposed WireGuard private key with the peer configuration coordinated; investigate the extra `192.168.0.0/24` WireGuard AllowedIPs entry separately.

## Kodi / DualShock 4 Controller

Goal: use a DualShock 4 over Bluetooth for Kodi navigation.

Verified:

- The controller connects over Bluetooth as `Gray+OrangeDS4`.
- Linux exposes the expected interfaces:
  - Gamepad: `/dev/input/js0` and `event20`.
  - Motion sensors: `event21`.
  - Touchpad/mouse: `event22` and `mouse0`.
- `/dev/input/js0` is accessible read/write by `mediacenter` through an ACL.
- Debian package `kodi-peripheral-joystick` version `21.1.22+ds-1` is installed.
- Kodi 21.2 is installed (Debian package `2:21.2+dfsg-4`).
- Kodi logs show `peripheral.joystick` discovery and successful loading of its Linux joystick interface.
- After Kodi was reopened, DS4 navigation worked normally over Bluetooth.

No additional DS4-specific Kodi add-on, Steam Input, DS4Windows, InputPlumber, or USB connection was required.

Current status: **Working.**

## WireGuard / Internal DNS Repair

After the controller work, `media` could not resolve internal reverse-proxy names including `seerr.dustynest.com` and `proxy.dustynest.com`, although other VPN-connected clients could resolve and access them.

### Diagnosis

The initial resolver configuration was:

```text
nameserver 192.168.0.1
search lan
```

The Pi-hole/internal DNS server at `192.168.0.120` was missing.

`sudo wg show` showed a recent handshake, but that did not mean host IPv4 networking was configured. The active `wg0` interface had no IPv4 address; `ip addr show wg0` showed only a link-local IPv6 address. Routing showed VPN traffic bypassing WireGuard:

```text
10.0.0.1 via 192.168.0.1 dev wlp4s0
```

NetworkManager was managing the active connection:

```text
Wg0    TYPE wireguard    DEVICE wg0
```

The `wg-quick@wg0.service` unit was inactive. An older `/etc/wireguard/wg0.conf` contained intended settings, including `10.0.0.10/32`, MTU 1420, DNS `192.168.0.120`, and AllowedIPs `10.0.0.0/24`, but it did not control the active interface.

The active NetworkManager profile instead had `ipv4.method: disabled`, no IPv4 addresses or DNS, and `wireguard.peer-routes: no`. The peer could handshake while the host remained without the intended IPv4 address, VPN route, or DNS.

### Repair and verified state

The existing NetworkManager `Wg0` profile was retained as the authoritative manager for `wg0`; `wg-quick` was not enabled. The profile was configured with a manual address of `10.0.0.10/32`, DNS `192.168.0.120`, and `ipv4.never-default yes`. An IPv4 route for `10.0.0.0/24` was added, and the connection was brought down and up again.

Verified afterward:

- `wg0` had `10.0.0.10/32`.
- Route to `10.0.0.1` used `wg0` with source `10.0.0.10`.
- Resolver configuration listed `192.168.0.120` before `192.168.0.1`, with search domain `lan`.
- Internal `*.dustynest.com` proxy addresses worked again.
- Wi-Fi/LAN remained the normal default Internet route; WireGuard remained a split tunnel for `10.0.0.0/24`.

Expected NetworkManager intent for `media`:

| Setting | Expected value |
| --- | --- |
| Interface | `wg0` |
| NetworkManager connection | `Wg0` |
| Host VPN IP | `10.0.0.10/32` |
| VPN subnet route | `10.0.0.0/24` |
| Internal DNS | `192.168.0.120` |
| Default route | Wi-Fi / LAN |
| VPN mode | Split tunnel |

Do not enable `wg-quick@wg0` without intentionally migrating management away from NetworkManager first.

### Follow-up: unexplained AllowedIPs entry

The live peer reported both `10.0.0.0/24` and `192.168.0.0/24` as AllowedIPs, while the explicit NetworkManager IPv4 route added during this repair was only `10.0.0.0/24`. The host is physically attached to `192.168.0.0/24`; no explicit NetworkManager route for that LAN subnet was added to WireGuard during this repair.

Everything was functional after the repair. Investigate the origin and purpose of the additional `192.168.0.0/24` AllowedIPs entry separately before changing the working configuration.

### Security follow-up: rotate exposed key

The `media` host's WireGuard private key was accidentally exposed during troubleshooting and must be treated as compromised. Rotate it and coordinate the replacement with the peer configuration so remote connectivity is retained. **The exposed private key is intentionally not recorded here or in Git.**
