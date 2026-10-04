# Game Services VM Plan

Status: Proposed
Last reviewed: 2026-09-30
Scope: Plan for a private game-services guest on PVE, with possible friend access to selected game ports if router forwarding is later approved.

## Direction Selected For Planning

- Create a dedicated gaming VM on an isolated PVE network. Owner reports VM200 was destroyed on 2026-09-30 after the partner moved to Super Productivity.
- An older, comprehensive VM200 backup is reported to exist. Its contents, date, and restoreability are unverified; retain it until the owner confirms whether recovery is needed.
- Use a PVE isolated virtual bridge with routing/NAT and firewall rules as the current preferred network design. The gaming VM should have outbound internet access while being blocked from trusted LAN/document services. The home router would forward only the selected public game port to PVE, which would forward that traffic to the gaming VM.
- Router port forwarding remains pending permission and public-endpoint checks. Until approved and configured, game access stays LAN/WireGuard-only or uses an externally hosted Archipelago room.

## Goal

Provide an always-on place for Archipelago and one selected primary game server at a time (modded Minecraft or Palworld), plus lightweight supporting tools such as a status page, scheduled backups, and server management. Friends should be able to join the selected Minecraft server without installing WireGuard if the router and ISP permit the required inbound connection.

This is a design proposal only. No VM, WAN rule, or public game-service exception has been approved or created. The current VPN-first decision remains in force until explicitly amended.

## Known host constraints

- PVE is a Proxmox VE 9.2.20 host with an Intel Xeon E5-2609 v2 (4 cores) and 32 GiB RAM.
- PVE already runs infrastructure LXCs and VMs, including core services and Home Assistant. A PVE host snapshot exists at `/mnt/core/backups/snapshots/2026-09-29/post/pve/pve_post_2026-09-29_11-05-55.json`, but this plan has not inspected its contents. Usable headroom is unknown until that snapshot and guest allocations are reviewed; one snapshot also cannot establish busy-period peaks.
- Owner-provided live PVE summary after the 2026-09-28/29 update pass: uptime 1 day 21:45; 1/5/15-minute load averages `0.67/0.52/0.47`; 31 GiB total RAM, 18 GiB used, 12 GiB available, and 44 MiB swap used. The `pvesh` status reported about 12.7 GiB available. This is a single sample, not a peak-load series.
- At that sample, VM100 `services` was configured for 4 vCPU and 12 GiB RAM; VM200 (also named `services` in `qm list`) for 2 vCPU and 8 GiB RAM; the three running LXCs each had 1-2 vCPU and 512 MiB RAM. Sum of configured guest vCPUs was 10 on a 4-core host. VM200 is now reported destroyed, but current post-removal host availability has not yet been measured.
- Storage at that sample: PVE root 72 GiB available; `local-lvm` 778 GiB available (6.43% used); `/mnt/core` 819 GiB available (6% used). This indicates ample space at the time of the sample, subject to confirming the intended datastore and backup path.
- Owner-provided PVE network output: `vmbr0` bridges physical `nic0`, has `192.168.0.75/24` with gateway `192.168.0.1`, and currently has VLAN filtering disabled (`vlan_filtering 0`). `bridge vlan show` reports VLAN 1 PVID/untagged on `nic0`, `vmbr0`, existing VM interfaces, and LXC veths. `nic1` is configured manual and unused in the shown host configuration. This is the present flat, untagged LAN layout; it does not establish whether the router or switch can support VLAN isolation. Owner is checking the equipment models.
- `/mnt/core` is a 1 TB SSD. It is shared infrastructure storage and currently has backups, service state, and other data. Current free capacity should be checked before sizing game worlds or backups.
- The dedicated `media` node has an i7-9700K, 15 GB RAM, and an active media workload. Its root filesystem was reported 95% used, and the backing storage for `/media` remains an open check. It is not the preferred first home for a new always-on service.
- Workstation and gaming endpoints are not documented as always-on server hosts.

## Proposed placement

Start with a dedicated Debian VM on PVE, isolated from the existing `services` VM and media services. VM200 is reported destroyed; obtain a fresh PVE memory/load reading before deciding how much capacity is available for the gaming guest. Use Docker Compose or systemd-managed services inside that guest, with persistent state on a guest data disk. Keep public game traffic off Nginx Proxy Manager; game protocols are not ordinary web proxy traffic.

PVE best fits the present always-on requirement and uses the existing hypervisor. That is a placement preference, not proof that the host has adequate spare capacity. Before creating the VM, collect PVE and guest memory/CPU usage during representative busy periods and check storage headroom. If the measured spare memory cannot support the chosen game plus existing guests, consider increasing PVE RAM or using a separate always-on host. The media node is a secondary candidate only after its storage and workload constraints are resolved. Cloud hosting is an alternative if inbound home networking or local capacity is unsuitable.

## Resource planning envelope

These are initial allocations to validate with the actual modpack, player count, and world; they are not vendor guarantees. Based on the live sample above, begin any Minecraft pilot conservatively (about 4-6 GiB RAM) and monitor host/guest memory before increasing it. The sample suggests a modest pilot may fit at that moment; it does not establish safe capacity during peak workload.

| Workload | Initial planning allocation | Notes |
| --- | ---: | --- |
| Debian guest and lightweight management/monitoring | 2 GiB RAM, 1-2 vCPU | Keep management tools small; avoid adding general-purpose applications here. |
| Archipelago server | 1-2 GiB RAM, 1 vCPU | Its official setup guide documents a default server port of 38281 and also supports website-hosted rooms, which can avoid hosting this component locally. |
| Modded Minecraft, selected main server | 4-6 GiB RAM for a cautious pilot; likely 6-10 GiB for larger packs, 2-4 vCPU | Actual use depends heavily on modpack, players, view distance, and world activity. Start with a measured allocation and avoid promising a player capacity before trial runs. |
| Palworld, selected main server | Plan around 16 GiB RAM initially; reserve 4 vCPU if available | Public server guidance commonly cites a substantial memory requirement, but the official setup page does not give a stable RAM sizing promise. The observed host sample has only about 12.7 GiB available, so this allocation is not supported by the current baseline without reducing other usage, adding RAM, or moving workloads. Validate current release and observed memory before deployment. |

The 32 GiB PVE host cannot be assumed to have enough spare memory for all the above at once: the other guests and host need memory too. The supplied snapshot is encouraging for storage and a small Minecraft pilot, but not enough to justify a 16 GiB Palworld guest alongside the running workload. A sensible operating model is Archipelago plus one primary game server, with the Minecraft and Palworld instances installed but only one enabled at a time. A small idle instance may technically run alongside another workload, but it should not be counted on until measured.

The Xeon E5-2609 v2's four cores are shared by the whole PVE host. Even if guest vCPU counts add up to more than four, that is CPU overcommit, not extra compute. Minecraft's tick performance and Palworld's load need real-world checks on this older CPU. GPU passthrough is not needed for dedicated servers.

## Network design if public access is approved

### Isolation requirement

Do not attach the public game VM to the ordinary trusted LAN without a deliberate isolation policy. A normal Proxmox bridge connects guests as if they were plugged into the LAN; forwarding only the Minecraft port limits inbound WAN access, but does not by itself stop a compromised guest from initiating connections to other LAN devices.

Preferred layout: a dedicated game-server network (DMZ) isolated from the household LAN. A VLAN/subnet on the router and switch is one option, but it is not the only one. PVE could instead host an isolated virtual bridge with routing/NAT and firewall policy, with the home router forwarding only the selected public game port to PVE for forwarding to the VM. This avoids requiring VLAN support from the router/switch, but makes PVE responsible for routing and isolation and needs careful configuration. A rented/managed game host is another option if home-network changes are undesirable.

For either isolated-network design, configure policy to:

- allow inbound WAN traffic only to the selected game's exact port and protocol;
- deny game-VM-initiated access to trusted LAN ranges, including document storage, PVE management, and other service hosts;
- allow only required outbound DNS, time sync, and update/game-service traffic;
- allow administration from a trusted LAN/VPN management device to only the necessary guest management ports;
- apply equivalent restrictions to IPv6, or disable guest IPv6 if it is not intentionally supported.

Proxmox supports guest VLAN tags when the Linux bridge is VLAN-aware, but end-to-end isolation also depends on the router/switch and their inter-VLAN firewall rules. A VLAN tag alone is not a security boundary if the upstream network routes between VLANs without restrictions. For the isolated-bridge alternative, define the guest subnet, gateway, outbound NAT, inbound DNAT/port forwarding, and both IPv4 and IPv6 firewall behavior before deployment.

### Public reachability

1. Confirm router/ISP permission, public address behavior, and whether network isolation should use a router/switch VLAN, an isolated routed PVE bridge, or an external host. The current PVE bridge is not VLAN-aware; any PVE network changes must preserve PVE management reachability.
2. Give the VM a stable address in the game VLAN/subnet using DHCP reservation or documented static assignment.
3. Configure a narrow router forward to the VM's game address and exact game port/protocol. Do not publish Proxmox, SSH, Docker management, dashboards, databases, or the guest's general administration ports.
4. Use a DNS name only after confirming a real public endpoint. Public DNS does not create reachability. If the household connection uses CGNAT or the public address changes, direct inbound hosting may require ISP/router support or a tunnel/relay design.
5. Record the exact game, edition, server port, protocol, source/destination, isolation rules, and approval in ADR 0002 before adding any router rule. Revisit the VPN-first policy explicitly; this proposed game-only exception must not implicitly open other services.
6. Use server allowlists/passwords where supported, keep software updated, and do not treat port forwarding as authentication.

For Java Minecraft, the official server help describes compatible Java as a requirement and identifies port 25565 as the common Java server port. The exact modded-server requirements and port configuration still need to be chosen. Archipelago's default local server port is 38281; only forward it when self-hosting the room and when friends need direct access. Palworld's configured game port must be checked against the current server release and chosen configuration.

For occasional Archipelago multiworlds, consider generating the game and creating its room on the official Archipelago website. This avoids exposing any home service; website-hosted rooms save progress and shut down after two hours of inactivity, and can be started again from the room page. If self-hosting instead, forward only the Archipelago server port through the router and isolated PVE network, and keep administration interfaces private.

## Storage and recovery

- Put active worlds and configs on a dedicated virtual disk or clearly owned guest directory, not inside VM100's appdata tree.
- Keep world backups separate from the live world and include at least one copy on the existing backup target after confirming available capacity.
- Use scheduled, versioned backups and test a restore before inviting friends. Snapshotting a running game is not a substitute for application-consistent world backups.
- Keep generated world files, modpack files, and backups out of the PVE root filesystem.

## Rollout sequence

1. Capture a fresh PVE summary after VM200's reported destruction; compare it with the prior baseline and observe memory/CPU under representative busy loads before final resource allocation.
2. Choose the first workload: Archipelago and either a specific Minecraft modpack or Palworld. Record expected player count and uptime needs.
3. Confirm router/ISP permission, public address behavior, and whether inbound forwarding is possible. Until confirmed, operate LAN/WireGuard-only.
4. Create the guest with the smallest suitable initial allocation and a reserved LAN address; configure firewall boundaries and backups.
5. Run a private soak test, capture CPU/RAM/disk use, test save/restore, and tune resources.
6. If a public exception is approved, document the exact port mapping and update ADR 0002 before enabling that single mapping.

## Open decisions

- Which Minecraft edition and modpack, or Palworld release/configuration, is the first primary workload?
- Expected concurrent player count and whether the game world must stay online continuously.
- Can the router owner approve a narrowly scoped inbound port-forward, and does the ISP provide a reachable public IPv4/IPv6 endpoint?
- What PVE memory/CPU headroom is available after measuring current guests?
- Is a RAM upgrade or separate always-on machine acceptable if PVE headroom is insufficient?

## References

- [Minecraft Java server download and setup](https://www.minecraft.net/en-us/download/server)
- [Archipelago setup and hosting guide](https://archipelago.gg/tutorial/Archipelago/setup_en)
- [Archipelago container deployment guide](https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/deploy%20using%20containers.md)
- [Palworld dedicated server guide](https://docs.palworldgame.com/getting-started/deploy-dedicated-server/)
