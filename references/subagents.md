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

## Codex Subagent Roles

Use these five Codex subagent roles:

| Subagent | Default mode | Best for |
| --- | --- | --- |
| `planner` | Read-only | Decomposing non-trivial tasks, identifying risks, sequencing work, and defining validation. |
| `engineer` | Bounded write | Implementing small, well-scoped changes after the plan and constraints are clear. |
| `reviewer` | Read-only | Reviewing diffs, designs, and implementations for correctness, risk, maintainability, and scope discipline. |
| `tester` | Read-mostly | Reproducing failures, analyzing test output, finding validation gaps, and recommending targeted checks. |
| `docs` | Read-only | Finding, interpreting, and summarizing relevant repo docs, reference docs, and authoritative external documentation. |

The role names are intentionally simple. The main agent remains the senior engineer and orchestrator.

## When to Use Subagents

Use subagents when delegation is likely to improve quality, speed, coverage, or context hygiene.

Good uses include:

- planning non-trivial or risky work
- implementing a small isolated change after the main design is clear
- reviewing a proposed diff
- reproducing UI, integration, or workflow bugs
- analyzing test failures, logs, snapshots, traces, or large files
- checking framework, library, or API behavior against authoritative documentation
- auditing many independent files or components
- finding existing patterns, call sites, APIs, components, functions, events, schemas, or configuration

## When Not to Use Subagents

Avoid subagents when:

- the task is trivial
- the work requires one coherent design judgment
- requirements are still materially ambiguous
- coordination cost exceeds likely benefit
- multiple agents would need to edit the same files or tightly coupled areas
- the task involves sensitive access material, destructive operations, production-impacting changes, or sensitive data
- the main agent cannot realistically verify the result

Prefer read-only subagents for planning, review, documentation lookup, reproduction, and diagnosis.

Be careful with write-heavy parallel work. Do not allow multiple agents to edit the same files or tightly coupled areas at the same time unless the user explicitly asks and the conflict risk is acceptable.

## Independent Project Threads

Independent Codex project threads are not ordinary subagents. They may have separate plans, branches, worktrees, assumptions, and implementation ownership.

When multiple independent threads are already working on related project areas:

- consult `references/multi-session-coordination.md`
- use the `multi-session-coordination` skill
- identify shared ownership, dependencies, contracts, and integration risks before adding more parallel implementation work
- do not treat one thread's summary as authoritative without checking primary evidence
- do not spawn additional implementation agents merely to solve an existing coordination conflict

New project threads created as part of that workflow should use:

```text
Project - Three-to-Four-Word Description
```

Detect the project name and derive the concise description from the task instead of asking the user when both are already clear.

## Mandatory Model Routing

Consult `references/model-routing.md` before spawning a subagent when it is available.

- Explicitly select the custom profile or model for each delegated task when the environment permits it.
- Use the smallest model and lowest reasoning effort likely to complete the bounded assignment reliably.
- Do not rely on parent-model inheritance for routine supporting work.
- Prefer the installed `gpt-5.6-terra` profiles for bounded planning, implementation, review, testing, and documentation work.
- Define stop and escalation conditions before delegation.
- A subagent must stop and report when the task becomes ambiguous, exceeds scope, conflicts with primary evidence, or requires high-impact judgment.
- The subagent must not silently change models or fall back to the main orchestrator's model.

Keep final ownership with the main agent for:

- architecture and system design
- security-sensitive or access-control decisions
- authentication, authorization, privacy, payments, or billing
- destructive operations
- data migrations or persisted-schema strategy
- concurrency, locking, queues, caching, or background-job design
- public API compatibility
- release or production-impacting configuration
- large or high-impact refactors
- final acceptance of meaningful changes

A supporting subagent may gather evidence for these areas, but the main agent must make and verify the decision. A stronger-model rerun requires a documented reason and an independent verification plan.

## Subagent Assignment Template

Use this structure when delegating:

```text
Role:
You are the [planner/engineer/reviewer/tester/docs] subagent for this task.

Selected profile or model:
[Explicit profile or model.]

Reasoning effort:
[Low/medium/high or the environment's equivalent.]

Why this is the smallest suitable choice:
[Explain why the bounded assignment fits this profile.]

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

Escalation conditions:
Stop and report if [ambiguity, scope expansion, conflicting evidence, high-impact judgment, or inability to verify].

Output format:
- Findings:
- Evidence:
- Recommended action:
- Risks/uncertainty:
- Validation run:
- Escalation needed: yes or no, with the reason
```

## Acceptance Checklist

Before accepting subagent work, the main agent must verify:

- the profile or model was explicitly selected when supported
- parent-model inheritance was not used unintentionally
- any stronger-model escalation was justified
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
