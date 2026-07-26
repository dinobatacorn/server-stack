# ADR 0017: Public Onboarding And Member Maintenance Portals

Status: Proposed
Date: 2026-07-10

## Context

The homelab follows a VPN-first security model where nearly all services remain inaccessible from the public Internet. This minimizes exposed attack surface while allowing authenticated users to securely access internal resources after connecting through WireGuard.

As the number of users grows, manually onboarding family, friends, collaborators, convention staff, and other members becomes repetitive and error-prone.

Maintaining documentation about available services, announcements, downloads, and operational status in multiple places also creates duplication and increases maintenance effort.

## Decision

Create two separate web portals with distinct purposes:

- Public Onboarding Portal.
- Member Maintenance Portal.

## Public Onboarding Portal

The onboarding portal is the only intentionally public-facing component of the ecosystem.

Responsibilities:

- Explain what the server ecosystem is.
- Advertise available services at a high level.
- Provide a Request Access workflow.
- Host WireGuard installation guides.
- Publish a detailed privacy statement.
- Display high-level infrastructure status: Operational, Maintenance, or Outage.
- Act as the public front door for the homelab.

The onboarding portal does not expose internal services, dashboards, or authenticated user information.

Planned pages:

- Home.
- Request Access.
- Downloads.
- Available Services.
- System Status.
- Privacy Statement.

## Member Maintenance Portal

The maintenance portal is accessible only to authenticated users already connected through the VPN. It may also be protected by Authelia or equivalent identity management.

Responsibilities:

- Member announcements.
- Internal documentation.
- Downloads.
- Available services.
- Device management, future.
- VPN key rotation, future.
- Support documentation.
- Maintenance history.
- Service-specific documentation.

The maintenance portal serves existing users rather than prospective users.

## Single Source Of Truth

Avoid maintaining duplicate information across websites.

Baserow is the canonical metadata source for portal content.

Service metadata examples:

- Name.
- Description.
- Category.
- Visibility: Public or Members.
- Lifecycle.
- Documentation URL.
- VPN Required.
- Icon.
- Tags.

Announcement metadata examples:

- Title.
- Message.
- Severity.
- Audience.
- Active Dates.

Download metadata examples:

- Software.
- Platform.
- Version.
- Official Download URL.
- Installation Instructions.

Category examples:

- Media.
- Productivity.
- Knowledge.
- Administration.
- Utilities.
- Gaming.

Both portals should consume this shared metadata rather than maintaining separate copies.

## Automation

n8n may eventually automate synchronization between Baserow and the portals.

Potential workflows:

- Service added to Baserow updates the public Available Services page and member portal catalog.
- Announcement created publishes to the appropriate portal or portals.
- Status changed updates the system status page.
- Access request submitted notifies the administrator and records the request in Baserow.
- Access approved generates a WireGuard peer, generates a QR code, sends onboarding email, and records peer metadata.

## Design Principles

- Public exposure should remain minimal.
- Internal services remain VPN-first.
- Information should have one authoritative source.
- Automation should eliminate repetitive administrative work.
- Public and member experiences should remain intentionally separate.
- Manual website editing should be minimized.

## Consequences

Benefits:

- Reduced administrative overhead.
- Consistent information across portals.
- Clear separation between prospective and existing users.
- Improved scalability as additional services are deployed.
- Preserves the project's VPN-first security philosophy.

Trade-offs:

- Introduces dependency on Baserow as a metadata source.
- Requires automation workflows such as n8n to remain functional.
- Initial implementation is more complex than manually editing static pages but should reduce long-term maintenance.

## Future Enhancements

- Self-service VPN key rotation.
- Device inventory per member.
- Temporary access grants.
- Access expiration policies.
- Maintenance scheduling.
- Service screenshots.
- Service request workflow.
- Member-specific permissions.
- Integration with Authelia identities.
- Automatic regeneration of static site content from Baserow.

## Related Architectural Decisions

- [ADR 0002: VPN-First Networking](0002-vpn-first-networking.md)
- [ADR 0009: Knowledge Ecosystem Roles](0009-knowledge-ecosystem-roles.md)
- [ADR 0016: Docker Networking Strategy](0016-docker-networking-strategy.md)
