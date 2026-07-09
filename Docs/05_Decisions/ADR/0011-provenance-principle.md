# ADR 0011: Provenance Principle

Status: Accepted
Date: 2026-07-09

## Context

Projects become harder to maintain when they document outcomes without preserving origin, rationale, assumptions, or dependencies.

## Decision

Documentation should include provenance where useful:

- Origin.
- Rationale.
- Assumptions.
- Dependencies.
- Evidence or source inventories.

## Consequences

Future troubleshooting and rebuilds require less reverse engineering. ADRs become the natural home for provenance around architectural choices.

## Alternatives Considered

- Document only the current state. Rejected because it loses the reasoning that makes the state understandable.
