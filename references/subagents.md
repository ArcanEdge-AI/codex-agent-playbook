# Subagent Delegation Reference

The main agent is the orchestrator and senior developer. Subagents may assist, but they do not own the final outcome.

The main agent owns:

- task understanding
- working plan
- architecture and design judgment
- delegation decisions
- final implementation
- final diff
- validation strategy
- final user-facing response

## When to Use Subagents

Use subagents when delegation is likely to improve quality, speed, coverage, or context hygiene.

Good uses include:

- codebase exploration
- tracing call paths
- finding existing patterns
- finding all call sites of an API, component, function, event, schema, or configuration
- reviewing a proposed diff
- looking for bugs, regressions, safety risks, race conditions, test gaps, or maintainability issues
- reproducing UI, integration, or workflow bugs
- analyzing test failures, logs, snapshots, traces, or large files
- checking framework, library, or API behavior against authoritative documentation
- auditing many independent files or components
- implementing a small isolated change after the main design is clear

## When Not to Use Subagents

Avoid subagents when:

- the task is trivial
- the work requires one coherent design judgment
- requirements are still materially ambiguous
- coordination cost exceeds likely benefit
- multiple agents would need to edit the same files or tightly coupled areas
- the task involves sensitive access material, destructive operations, production-impacting changes, or sensitive data
- the main agent cannot realistically verify the result

Prefer read-only subagents for exploration, review, research, reproduction, and diagnosis.

Be careful with write-heavy parallel work. Do not allow multiple agents to edit the same files or tightly coupled areas at the same time unless the user explicitly asks and the conflict risk is acceptable.

## Subagent Assignment Template

Use this structure when delegating:

```text
Role:
You are the [role] subagent for this task.

Goal:
[One concrete outcome.]

Context:
[Relevant user request, repository constraints, current findings, and branch/diff context.]

Reference documents:
Consult [document/path/section] for context on [topic].
Treat it as [authoritative/advisory/historical].
Verify implementation-relevant claims against current code before relying on them.
Do not summarize unrelated sections.

Scope:
Inspect only [files/areas/systems]. Do not work outside this scope unless necessary; report if scope expansion is needed.

Non-goals:
Do not [unwanted work, refactors, formatting churn, unrelated fixes, broad rewrites].

Permissions:
[Read-only / may edit only X / may run Y checks / do not run expensive or destructive commands.]

Evidence required:
Return specific file paths, symbols, command output summaries, reproduction steps, docs references, or runtime observations that support your conclusions.

Output format:
- Findings:
- Evidence:
- Recommended action:
- Risks/uncertainty:
- Validation run:
```

## Acceptance Checklist

Before accepting subagent work, the main agent must verify:

- the subagent stayed within scope
- the result addresses the assigned goal
- claims are backed by code, tests, logs, docs, runtime behavior, or other primary evidence
- any edits are minimal and task-related
- no unrelated files were changed
- the implementation matches existing architecture and style
- validation was run, or a clear reason was given
- the main agent has inspected the final diff itself

If subagent findings conflict, resolve the disagreement by inspecting primary evidence.

Never accept a subagent's conclusion solely because it sounds confident.

## Useful Subagent Roles

Suggested roles:

- Read-Only Explorer: maps code paths, call sites, invariants, ownership boundaries, and likely insertion points.
- Senior Reviewer: reviews diffs for correctness, regressions, safety risks, test gaps, maintainability, and scope creep.
- Docs Researcher: verifies framework, library, API, or platform behavior against authoritative docs.
- Test Triager: analyzes failing tests, logs, flakes, snapshots, and likely root causes.
- Isolated Worker: implements small, bounded changes only after scope and design are clear.
