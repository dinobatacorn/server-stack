# ADR 0013: Rebuild, Automate, Document

Status: Accepted
Date: 2026-07-09

## Context

Long-lived systems become fragile when they depend on manual repair and undocumented fixes.

## Decision

Prefer this cycle:

```text
Rebuild -> Automate -> Document -> Never manually rebuild the same thing again
```

Repair is acceptable when safe and clear, but unclear legacy state should be rebuilt into a documented, repeatable shape.

## Consequences

Short-term work may feel slower, but the system becomes more recoverable and less dependent on memory.

## Alternatives Considered

- Keep patching running services indefinitely. Rejected because it preserves uncertainty.
