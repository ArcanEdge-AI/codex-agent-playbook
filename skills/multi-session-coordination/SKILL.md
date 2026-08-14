---
name: multi-session-coordination
description: Use when multiple independent Codex threads are working on related areas of the same project and need conflict detection, ownership, sequencing, and integration guidance.
---

# Multi-Session Coordination Skill

The main agent is the integration coordinator. Independent Codex threads may contribute work, but the main agent owns architecture, compatibility decisions, sequencing, validation, and the final report.

Use this skill when:

- multiple Codex threads are active in the same project or repository
- several features are being implemented concurrently
- branches or worktrees may overlap
- shared APIs, schemas, types, components, dependencies, or user flows are changing
- one thread's work could invalidate another thread's assumptions
- the user asks to coordinate, reconcile, integrate, or review parallel work

Do not use this skill when:

- only one implementation thread is active
- the task is ordinary bounded subagent delegation
- the work is unrelated across repositories
- the user only wants a review of one completed change
- available evidence is too incomplete to compare the work meaningfully

Consult `references/multi-session-coordination.md` for the detailed coordination rules.

## Project Thread Naming

When creating a new project thread, title it:

```text
Project - Three-to-Four-Word Description
```

Detect the project name from the current project or repository and derive the description from the thread's primary objective. Use clear title-style wording, omit literal square brackets, and do not ask the user for a title when the project and task are already clear.

Apply this standard to newly created threads. Do not rename existing threads automatically unless the user requests cleanup.

## Workflow

### 1. Resolve the operating context

Identify the current:

- project
- repository
- default branch
- active branch
- worktrees when available
- applicable repository instructions and authoritative project docs

Do not ask the user for values that can be detected reliably from the environment or repository.

### 2. Discover active work

Start with threads active during the previous 72 hours when the environment supports thread discovery.

Then inspect:

- active branches
- worktrees
- open pull requests
- unmerged commits
- active-work records under `.codex/coordination/active-work/` when present

Include older work when repository evidence shows that it remains unmerged, incomplete, blocked, contract-relevant, or otherwise active.

Repository state takes precedence over thread recency.

Ask for specific thread identifiers only when automatic discovery is unavailable or materially incomplete and the missing context affects a safe integration decision.

### 3. Classify discovery coverage

Label every work item as:

- directly reviewed thread
- repository-inferred work
- user-supplied thread
- potentially missing work

Do not claim direct review when only repository evidence was inspected.

### 4. Build the shared change map

For each relevant work item, capture:

- thread title and identifier when available
- objective
- status
- last activity
- branch or worktree
- files and modules affected
- APIs, events, routes, and shared interfaces affected
- schemas, migrations, and persistence affected
- software or service dependencies added or changed
- accepted upstream work artifacts or decisions required before the item can begin or integrate
- tests affected
- handoff and integration verification gates
- assumptions
- unmet upstream dependencies and other blockers
- open decisions
- integration status

Separate confirmed facts from inference.

### 5. Detect conflicts

Check for:

- overlapping file ownership
- incompatible architectural decisions
- conflicting API or event contracts
- conflicting shared types
- incompatible schemas or migrations
- dependency-version conflicts
- authentication or authorization inconsistencies
- user-flow and lifecycle conflicts
- duplicate utilities, components, or services
- tests based on incompatible assumptions
- combined behavior that fails even when isolated changes pass

Do not stop at Git merge-conflict detection.

### 6. Establish ownership and sequence

Define:

- one owner for each shared file, contract, schema, or tightly coupled area
- which work may continue independently
- which work must pause
- which dependency must complete first
- which shared contract must be fixed before implementation continues
- which thread must adapt to an established interface
- required integration checkpoints
- the remaining chain of blocking work that controls integration completion

Prefer the smallest safe coordination change. Do not allow independent redesigns of the same shared subsystem.

### 7. Resolve disagreements with primary evidence

Use this order:

1. repository instructions and authoritative project docs
2. current code, tests, schemas, configuration, and runtime behavior
3. explicit user decisions
4. established shared contracts
5. smallest safe compatible change

Ask the user only when a remaining decision materially affects architecture, behavior, data, safety, release timing, or user-visible output.

### 8. Produce copy-ready thread instructions

For each active thread, state:

- what may continue
- what must pause
- owned paths or systems
- prohibited paths or systems
- required contracts
- upstream dependencies
- compatibility changes
- validation to run
- evidence to return
- integration-ready completion condition

Do not use vague instructions such as “coordinate with the other thread.”

### 9. Define integration verification

Require validation appropriate to the combined blast radius, including when relevant:

- targeted tests for each feature
- contract tests
- schema or migration checks
- typechecking
- build validation
- integration tests
- end-to-end user-flow checks
- final combined diff review

The main agent must inspect the combined result before declaring the work compatible.

## Output Format

Return:

- Executive summary
- Discovery coverage
- Active work summary
- Shared change map
- Conflict and overlap matrix
- Ranked risks: Critical, High, Medium, Low
- Recommended implementation order
- Copy-ready instructions for each thread
- Integration verification checklist
- Open decisions requiring user approval

## Stop Conditions

Stop and report the limitation when:

- the current project or repository cannot be identified safely
- relevant work is inaccessible and repository evidence cannot compensate
- destructive, production-impacting, or sensitive changes require approval
- two plausible resolutions materially affect architecture or behavior and primary evidence does not resolve them

Do not implement code unless the user explicitly requests implementation. The default role of this skill is coordination, conflict detection, sequencing, and integration planning.
