# ADR 0003: Platform Services Node Vs Media Node

Status: Accepted
Date: 2026-07-09

## Context

The older architecture tended toward one large Docker VM. The system evolved into specialized nodes with clearer responsibilities.

## Decision

Treat the homelab as separate application domains:

- Proxmox host: hypervisor, storage, networking, and infrastructure orchestration.
- VM100: platform services, knowledge, automation, utilities, security, monitoring, and personal cloud.
- Media node: media acquisition, processing, serving, discovery, reading ecosystem, and couch experience.

VM100 is not being phased out. It is the platform services node.

The media node is an appliance. It should remain reachable for SSH, Docker, Jellyfin playback, and RustDesk remote administration, and it should not automatically suspend or hibernate during normal operation.

## Consequences

The media node can be rebuilt independently without impacting core knowledge or infrastructure services. VM100 remains application-light toward media, but central for platform services.

System sleep policy and graphical display policy are separate layers: systemd sleep-target masks keep the computer awake, while X11 screensaver/DPMS settings keep the display visible during living-room playback.

## Alternatives Considered

- One giant Docker host. Rejected because it increases coupling and makes rebuild boundaries unclear.
- Move all platform services to the media node. Rejected because the media node should remain a specialized appliance.
