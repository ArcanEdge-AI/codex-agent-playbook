# Multi-Session Coordination Reference

The main agent is responsible for coordinating independent Codex threads when several threads are working on related areas of the same project.

This workflow is different from ordinary subagent delegation:

- **Subagent orchestration**: one main agent assigns bounded work to subordinate agents and verifies their output.
- **Multi-session coordination**: multiple independent Codex threads are already planning, implementing, testing, reviewing, or documenting related project work.

The main agent remains accountable for architecture, ownership decisions, integration sequencing, validation, and the final user-facing report.

## When to Use This Reference

Use multi-session coordination when:

- multiple Codex threads are active in the same project or repository
- several features are being implemented concurrently
- active branches or worktrees may overlap
- one feature may invalidate another feature's assumptions
- shared APIs, schemas, types, components, dependencies, or user flows are changing
- the user asks to coordinate, reconcile, integrate, or review parallel work

Do not use it when:

- only one implementation thread is active
- the work is unrelated across repositories
- a normal bounded subagent assignment is sufficient
- the user only wants a code review of one completed change
- available evidence is too incomplete to compare the work meaningfully

## Core Principles

1. **Repository state takes precedence over thread recency.**
2. **Recent activity identifies candidates; it does not prove relevance.**
3. **Directly reviewed evidence is stronger than inferred work.**
4. **Avoid write-heavy parallel work in the same files or tightly coupled areas.**
5. **Assign one clear owner for each shared contract or contested area.**
6. **Resolve conflicts using primary evidence, not confident summaries.**
7. **Do not claim a thread was reviewed when only its branch or diff was inspected.**
8. **The final goal is behavioral compatibility, not merely a clean Git merge.**
9. **A worktree is not disposable until its exact owner and task-local lifecycle are verified.**

## Project Thread Naming

When creating a new project thread, use this format:

```text
Project - Three-to-Four-Word Description
```

Examples:

```text
ArcLedger - Validate Billing Evidence
LoreBound - Implement Campaign Imports
United Tradesmen - Coordinate Scheduler Changes
```

Rules:

- detect the project name from the current Codex project or repository
- derive a concise three-to-four-word description from the primary objective
- use clear title-style wording that distinguishes the thread from other active work
- do not include literal square brackets in the title
- do not ask the user to provide a title when the project and objective are already clear
- do not rename existing threads automatically; apply the standard to newly created threads unless the user requests cleanup

## Active Work Discovery

Begin with the current project and repository.

Use this discovery order when the environment supports it:

```text
Current project
    ↓
Current repository
    ↓
Threads active within the previous 72 hours
    ↓
Active branches and worktrees
    ↓
Open pull requests and unmerged commits
    ↓
Older threads referenced by active work
    ↓
Manual thread identifiers only when necessary
```

The previous 72 hours is the standard initial discovery window. Do not ask the user to configure it during normal use.

Include older work when repository evidence shows that it still has one or more of the following:

- an active branch or worktree
- unmerged commits
- an open pull request
- incomplete implementation
- an unresolved architectural decision
- a shared contract used by recent work
- a dependency or blocker affecting current work

Do not include a thread solely because it was recently active.

Exclude work that is clearly:

- unrelated to the current repository or project
- fully merged and no longer relevant to active decisions
- abandoned with no remaining dependency or contract impact
- purely exploratory and never adopted

## Evidence Classification

Classify each work item as one of these:

- **Directly reviewed thread** — the coordinator inspected the thread itself.
- **Repository-inferred work** — the coordinator identified the work through branches, worktrees, commits, diffs, pull requests, tests, or project files.
- **User-supplied thread** — the user explicitly identified the thread or supplied its contents.
- **Potentially missing work** — repository evidence suggests additional related work, but the coordinator cannot access enough context to classify it safely.

Always state which classification applies.

## Shared Change Map

For every relevant work item, record:

- thread title and identifier when available
- evidence classification
- stated feature or objective
- last known activity
- repository
- branch or worktree
- worktree class and task-local permit when applicable
- current status
- files and modules affected
- APIs, events, routes, or shared interfaces affected
- schemas, migrations, or persistence affected
- software or service dependencies added or changed
- accepted upstream work artifacts or decisions required before the item can begin or integrate
- tests added, changed, or invalidated
- handoff and integration verification gates
- assumptions
- unmet upstream dependencies and other blockers
- open decisions
- merge or integration status

The map should distinguish confirmed facts from inference.

When a task proposes or owns an auxiliary worktree, consult `references/worktrees.md`. Keep its worktree permit separate from subagent or graph-node permits. The coordinating root may clean only auxiliary worktrees that its own task created or explicitly adopted; existing user-managed or other-thread worktrees remain preserved unless ownership is transferred through primary evidence.

## Conflict Categories

Check for more than overlapping file edits.

### File and ownership conflicts

- multiple threads editing the same file
- multiple threads owning the same module or service
- broad refactors touching another thread's implementation area

### Architecture conflicts

- competing abstractions for the same responsibility
- incompatible state-management approaches
- independent redesigns of a shared subsystem
- changes that bypass established architectural boundaries

### Contract conflicts

- incompatible API request or response shapes
- conflicting shared types or interface definitions
- event names or payloads that disagree
- one thread consuming an outdated contract

### Data conflicts

- incompatible database migrations
- conflicting schema assumptions
- duplicate persistence models
- destructive changes that another feature does not expect

### Dependency conflicts

- incompatible package versions
- duplicate libraries for the same responsibility
- changes to build, runtime, or environment requirements

### Behavioral conflicts

- one feature changes a user flow another feature relies on
- authentication or authorization behavior disagrees
- error handling, validation, or lifecycle assumptions conflict
- separate implementations work alone but fail when combined

### Validation conflicts

- tests encode incompatible assumptions
- one thread invalidates another thread's fixtures or snapshots
- validation omits the combined workflow
- separate test suites pass while the integrated system fails

## Ownership and Sequencing

When work overlaps, the coordinator must establish:

- one owner for each shared file, contract, schema, or tightly coupled area
- which threads may proceed independently
- which thread must complete first
- which thread must pause or rebase
- which shared interface must be agreed upon before implementation continues
- which implementation must adapt to an established contract
- required integration checkpoints
- required validation before the next dependent change begins
- the remaining chain of blocking work that controls integration completion

Do not tell agents only to “coordinate.” State the exact ownership, dependency, contract, or sequencing decision.

## Conflict Resolution

Resolve conflicts in this order:

1. Current repository instructions and authoritative project documentation
2. Current code, tests, schemas, configuration, and runtime behavior
3. Explicit user decisions
4. Established shared contracts already used by the project
5. The smallest safe change that preserves compatibility

When two approaches are both plausible and the choice materially affects architecture, behavior, data, safety, release timing, or user-visible output, ask the user for the decision.

Do not ask the user when:

- the repository already establishes the answer
- one option is clearly incompatible with current code or tests
- the issue is a minor implementation detail
- a safe default is documented

## Instructions for Active Threads

For each active thread, provide copy-ready instructions covering:

- what may continue
- what must pause
- files or systems it owns
- files or systems it must not modify
- contracts it must follow
- dependencies it must wait for
- changes needed for compatibility
- validation it must run
- evidence it must return
- the condition for declaring the work integration-ready

## Required Coordinator Output

Return:

1. **Executive summary** — overall compatibility and immediate concern level.
2. **Discovery coverage** — what was directly reviewed, inferred, user-supplied, or potentially missing.
3. **Active work summary** — objective, status, branch or worktree, and affected systems for each item.
4. **Shared change map** — ownership, dependencies, contracts, and validation impact.
5. **Conflict and overlap matrix** — file, architecture, contract, data, dependency, behavior, and test overlap.
6. **Ranked risks** — Critical, High, Medium, or Low, with evidence and resolution.
7. **Implementation order** — safest completion and integration sequence.
8. **Instructions for each thread** — precise copy-ready guidance.
9. **Integration verification checklist** — targeted and combined validation.
10. **Open decisions** — only decisions that genuinely require human approval.

## Optional Repository Coordination Records

A repository may maintain optional active-work records under:

```text
.codex/coordination/active-work/
```

Use `references/templates/active-work-record.md` as the starting point.

In that record, `dependencies` names required upstream work artifacts or decisions, `blocked_by` lists dependencies that are not yet satisfied, `owned_paths` records write ownership, and `validation_required` defines the gates that must pass before integration-ready status. Do not introduce synonymous fields unless a concrete consumer requires them.

These records are advisory coordination aids. Verify them against current Git state, code, tests, pull requests, and thread evidence before relying on them.

Task-created auxiliary worktrees must be integrated and removed inside the owning task when all cleanup gates pass, or preserved with an exact owner, path, branch or HEAD, blocker, and next action. Do not assign this task-local responsibility to a scheduled cleaner. A broader stale-worktree sweep is a separate workflow and never supplies missing ownership evidence.

Do not require every repository to adopt this directory.

## Capability Limits

Thread discovery may not be available in every Codex environment.

When direct sibling-thread access is unavailable:

1. inspect branches, worktrees, commits, diffs, pull requests, and active-work records
2. report which work was inferred rather than directly reviewed
3. identify any missing context that could change an integration decision
4. request only the specific thread identifiers or summaries needed to close that gap

Never imply complete coordination coverage when relevant work may be inaccessible.
