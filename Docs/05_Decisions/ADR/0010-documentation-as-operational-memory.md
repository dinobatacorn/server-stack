# ADR 0010: Documentation As Operational Memory

Status: Accepted
Date: 2026-07-09

## Context

The homelab has accumulated decisions, procedures, and recovery assumptions across many conversations. Notes that only record commands do not preserve enough context for future rebuilds.

## Decision

Documentation is infrastructure and operational memory.

Docs should answer:

- Why was this chosen?
- What exists?
- How does it work?
- What depends on it?
- How is it recovered?

GitHub is the canonical version-controlled documentation repository.

## Consequences

Documentation updates are part of architecture work, not cleanup. Runbooks, inventories, ADRs, and status pages should stay distinct.

## Alternatives Considered

- Treat docs as informal notes. Rejected because Future Raven needs recoverable reasoning, not just command history.
