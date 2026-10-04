# RustDesk Server Maintenance

Status: Current operational record; client configuration changes reported, connection checks open  
Last reviewed: 2026-09-30

## Deployed Service

- Proxmox LXC 103, container name `rustdeskserver`, Debian 13, unprivileged, auto-start enabled.
- Current observed address: `192.168.0.189`, MAC `BC:24:11:7F:0E:7E`. It was assigned by DHCP; the router reservation is not verified.
- Installed using the Proxmox Community Scripts RustDesk Server installer. The observed implementation is the `lejianwen/rustdesk-server` fork, which includes an API/UI; do not describe it as the upstream `rustdesk/rustdesk-server` build.
- Installer reference supplied by the owner: [RustDesk Server community script](https://community-scripts.org/scripts/rustdeskserver). The deployed script revision was not recorded.
- Observed services: `rustdesk-hbbs`, `rustdesk-hbbr`, and `rustdesk-api` active.
- Observed listeners: TCP `21114-21119`, UDP `21116`. The API/UI answered at `http://192.168.0.189:21114`; the user set its password and confirmed a successful login.
- The server public key observed during installation is `DC3buJSs+UqXo3WKgBT2gtVMia7z6NwvKGz81tHssgU=`. The private identity key is secret; never copy it into Git, tickets, or chat.
- A Cloudflare DNS-only A record pointing to `192.168.0.189` was shown in a user-provided screenshot. It is a DNS record, not a WAN route or firewall rule. No WAN port forwards were added. Service access policy remains LAN/WireGuard-only.

## Storage And Recovery

The container OS and packages are on its 2 GiB `local-lvm` root disk. Persistent state is bind-mounted from the PVE `/mnt/core` filesystem:

```text
/mnt/core/appdata/security/rustdesk-server -> /var/lib/rustdesk-server
/mnt/core/appdata/security/rustdesk-api    -> /var/lib/rustdesk-api
```

Before maintenance, verify `/mnt/core` is the expected mounted filesystem on PVE; do not trust the directory alone. A PVE `vzdump` of CT 103 does not include the bind-mounted appdata. Back up both the container and these appdata directories. Appdata archives contain the private identity key and must remain owner-only. Existing validated archives are listed in the [2026-09-28 fleet report](../06_Operations/Update%20Reports/2026-09-28.md); they are on the same PVE SSD and are not offsite copies.

## Update Procedure

The exact upstream update cadence and currently available version for the installed fork have not been independently verified. Until the update process and rollback have been tested:

1. Confirm the maintenance window and keep PVE access available.
2. Record `pct status 103`, `pct config 103`, current service status, listener checks, and current version output from the installed components.
3. Create and validate a fresh CT backup and a separate appdata archive. Preserve the appdata permissions and private key.
4. Use the Community Scripts-provided update function for this installation, or use its documented package update path. Do not replace this fork with an upstream image or installer as an incidental update.
5. Record exact before/after versions and the update output. Stop if the updater proposes an unreviewed migration or cannot establish a rollback path.
6. Verify all three services are active, TCP/UDP listeners are present, the UI responds from the LAN, and a pilot RustDesk client can connect.
7. Save a post-update CT snapshot/inventory and update the dated fleet report. Do not declare client migration complete based only on the API UI login.

Do not automate the updater until the approved update command, backup restore procedure, version checks, and client-session check are repeatable.

## Client Rollout

The owner reports that RustDesk clients were pointed to the self-hosted server while device updates were being performed and that multiple client sessions succeeded. The latest reported test connected the owner's phone to this desktop after joining the network; the specific LAN or WireGuard path was not stated. MediaCenter's inspected configuration showing `rs-ny.rustdesk.com:21116` predates that migration report and is historical. Nobara's pre/post application inventory lists RustDesk Flatpak `1.4.9`.

The owner reports successful client sessions, including phone-to-desktop. For future client changes, confirm the self-hosted ID/rendezvous server, relay server if the client exposes that field, and server public key, then test a remote-control session. Keep API administration at `:21114` inside the trusted network; it is not a user-facing Nginx Proxy Manager service.

## Current Follow-Up

- Verify DHCP reservation `192.168.0.189` for MAC `BC:24:11:7F:0E:7E`.
- Confirm VPN routing reaches the LXC from a remote WireGuard client.
- Verify the LXC DHCP reservation and VPN route.
- If a device inventory is needed, record configured server/relay values without collecting passwords or private keys.
- Verify WAN forwarding and firewall rules against the LAN/WireGuard-only policy; router ingress was not inspected in the last maintenance pass.
