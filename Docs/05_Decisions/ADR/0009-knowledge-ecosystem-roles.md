# ADR 0009: Knowledge Ecosystem Roles

Status: Accepted
Date: 2026-07-09

## Context

AFFiNE, Obsidian, Nextcloud, Paperless, Baserow, AnythingLLM, and n8n overlap unless each has a clear responsibility.

## Decision

Assign one primary role to each knowledge-platform service:

- Obsidian: personal thinking, notes, and long-form writing.
- GitHub documentation: canonical infrastructure docs, ADRs, runbooks, and recovery docs.
- Paperless-ngx: document archive, OCR, and retrieval.
- Baserow: structured relational information such as theatre, convention scheduling, inventories, collections, and operational databases.
- AnythingLLM: AI interface to selected knowledge sources.
- Nextcloud: user files, mobile access, sharing, WebDAV, collaboration, photo uploads, and user-facing file browsing.
- n8n: automation glue.

## Consequences

The knowledge stack becomes a set of cooperating tools instead of competing places to put the same thing.

## Alternatives Considered

- Use one monolithic knowledge app. Rejected because the use cases are meaningfully different.
- Treat Baserow as a miscellaneous utility. Rejected because structured data is becoming foundational.
