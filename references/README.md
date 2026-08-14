# Global Codex Reference Documents

This directory contains global reference documents that the main Codex agent may consult when planning, delegating, implementing, reviewing, validating, or coordinating work.

These documents are intentionally generic and tool-agnostic. They should not contain repo-specific workflows, sensitive access material, local machine quirks, project names, or one-off incident notes.

## How to Use These References

The main agent should:

1. Start with the current user request and applicable repository instructions.
2. Inspect current code, tests, configuration, and docs.
3. Consult only the global reference documents that are relevant.
4. Treat reference docs as supporting context, not automatic truth.
5. Pass only relevant context to subagents or independent project threads.
6. Resolve conflicts using primary evidence.

Primary evidence includes:

- current code
- tests
- schemas
- configuration
- logs
- build output
- typecheck output
- runtime behavior
- authoritative external documentation

## Available References

- `model-routing.md` — mandatory model-selection and escalation rules for subagents.
- `subagents.md` — dependency-aware rules for when and how to delegate to subagents, verify handoffs, and combine results.
- `multi-session-coordination.md` — discovery, ownership, sequencing, thread naming, conflict detection, and integration guidance for independent Codex project threads.
- `reference-doc-routing.md` — how to choose and classify reference documents.
- `templates/repository-AGENTS.md` — starter template for repo-specific instructions.
- `templates/architecture.md` — architecture reference template.
- `templates/testing.md` — testing strategy template.
- `templates/security.md` — safety and access-control model template.
- `templates/design-system.md` — design-system and UI convention template.
- `templates/release.md` — release and deployment template.
- `templates/api-contracts.md` — API contract template.
- `templates/data-model.md` — data model and persistence template.
- `templates/active-work-record.md` — optional repository-local record for active thread ownership, contracts, upstream work dependencies, blockers, and validation gates.

## Placement Rules

Use global references for durable, cross-repository guidance.

Use repository-level docs for:

- repo architecture
- repo build/test commands
- repo release flow
- repo-specific design rules
- framework-specific conventions
- domain-specific business logic
- project-specific subagent roles
- project-specific active-work records

Use skills for repeatable workflows.

Use local notes for machine-specific or shell-specific quirks.
