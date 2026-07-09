# ADR 0012: Codex And ChatGPT Working Model

Status: Accepted
Date: 2026-07-09

## Context

Different AI tools have been useful for different parts of the workflow.

## Decision

Use Codex as the implementation partner for repository work, file updates, local inspection, and concrete changes.

Use ChatGPT for architecture, review, planning, and documentation thinking.

## Consequences

The workflow has clearer tool boundaries. Architecture can be discussed broadly before Codex turns it into repository changes.

## Alternatives Considered

- Use one tool for every mode of work. Rejected because the split has been effective in practice.
