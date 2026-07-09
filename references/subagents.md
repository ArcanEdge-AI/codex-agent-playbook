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

## Model Selection for Subagents

When model selection is available, the main agent should right-size the model and reasoning effort for each delegated task.

Use cheaper or faster models for bounded, low-risk, easily verifiable work, such as:

- simple codebase lookup
- file inventory
- call-site enumeration
- straightforward documentation lookup
- formatting checks
- mechanical audits
- simple test-log summarization

Use stronger reasoning models for work involving:

- planning complex or multi-file work
- implementation strategy
- meaningful code review
- ambiguous debugging
- security-sensitive or access-control-sensitive review
- data migrations
- concurrency, caching, or background jobs
- public API behavior
- high-impact refactors
- final review of meaningful changes

The orchestrator remains accountable regardless of which model a subagent uses.

Never delegate critical judgment to a weaker model unless the main agent can independently verify the result from primary evidence.

## Subagent Assignment Template

Use this structure when delegating:

```text
Role:
You are the [planner/engineer/reviewer/tester/docs] subagent for this task.

Goal:
[One concrete outcome.]

Context:
[Relevant user request, repository constraints, current findings, and branch/diff context.]

Model / reasoning guidance:
Use [cheaper/faster/standard/stronger] model because [why]. Escalate if the task becomes ambiguous, high-risk, or impossible to verify.

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
