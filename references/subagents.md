# Subagent Delegation Reference

The root main agent is the orchestrator and senior developer. For every repository task, it delegates actual execution to at least one bounded subagent when subagents are available. Subagents execute bounded work but do not own the final outcome.

The main agent owns:

- task understanding
- working plan
- architecture and design judgment
- routing, decomposition, and delegation decisions
- integration and final acceptance
- final diff
- validation strategy
- final user-facing response

Subagents may locally orchestrate only inside their assigned node. The root main agent exclusively owns root-task framing, topology, ready-set transitions, architecture, cross-subtree conflicts, authority actions, integration, acceptance, and reporting. See the assignment template below for the inherited-constraint and return-bundle contract.

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

## Default Subagent Execution

Use at least one bounded subagent execution assignment for every repository task when subagents are available. The main agent frames the work, selects the assignment, and verifies the result; a single subagent may perform the complete bounded task.

Default assignments include:

- planning non-trivial or risky work
- implementing a small isolated change after the main design is clear
- reviewing a proposed diff
- reproducing UI, integration, or workflow bugs
- analyzing test failures, logs, snapshots, traces, or large files
- checking framework, library, or API behavior against authoritative documentation
- auditing many independent files or components
- finding existing patterns, call sites, APIs, components, functions, events, schemas, or configuration

At the root, direct main-agent execution is allowed only when subagents are unavailable, the user explicitly forbids delegation, or the specific action cannot be delegated because required authority must remain with the main agent. Record the exact exception and limit it to that action. For high-impact work, delegate evidence gathering, bounded authorized work, or independent review while the main agent retains the decision, authority-bound action, and final acceptance.

Prefer read-only subagents for planning, review, documentation lookup, reproduction, and diagnosis.

Be careful with write-heavy parallel work. Do not allow multiple agents to edit the same files or tightly coupled areas at the same time. If parallel writes are necessary, require verified isolation and explicit ownership; a request for parallel execution alone does not prove that concurrent edits are safe.

## Dependency-Aware Orchestration

Keep a single bounded task as one node. When work has multiple delegable parts, describe each node before fan-out:

| Field | Purpose |
| --- | --- |
| Node ID | Stable identifier for dependencies, gates, and retries. |
| Goal | One concrete outcome. |
| Inputs / authoritative sources | Artifacts, decisions, code, tests, or documentation the node may rely on. |
| Output and acceptance condition | The artifact or finding the node must return and the criteria it must satisfy. |
| Depends on | Only upstream nodes whose accepted output is required before this node can correctly begin. |
| Write ownership or read scope | Disjoint paths or state a writer may change, or the bounded sources a read-only node may inspect. |
| Verification gate | Proportionate evidence required before the output may be treated as integration-ready. |
| Parent ID / child ID | Stable lineage pair; a retry retains both IDs and its permit. |
| Completion subset | Non-empty work that is strictly smaller than the parent's remaining completion subset. |
| Permit | Root-issued authorization for this spawned node, tracked against the finite total budget. |
| Selected model / effort | Explicit routing for this node; never silently inherited. |
| Workspace | Exact shared/current workspace or root-permitted auxiliary worktree; a worktree permit is separate from the node permit. |

An edge is real only when the downstream node cannot correctly begin without an accepted upstream artifact or decision. Do not serialize independent work merely because it was written as a list, and do not parallelize nodes that share mutable state, overlapping write ownership, or an unresolved contract.

Before execution:

- identify parallel-safe nodes
- identify the remaining chain of blocking work that controls completion
- dispatch only permitted ready assignments while runtime capacity exists; when full, execute current ready work and do not create speculative descendants
- verify that any claimed context, filesystem, worktree, or state isolation actually exists

Verification must evaluate the artifact against stated criteria and primary evidence, not the producer's self-assessment. For meaningful implementation, prefer a separate Reviewer or Tester assignment with only the necessary artifact, criteria, and evidence requirements when the runtime supports it. This does not replace main-agent acceptance, and not every low-risk node needs a separate verification subagent.

If a verification gate fails, revise or rerun the failed node and every downstream node whose inputs became invalid. Do not restart unrelated work by default. Before combining results, confirm all required inputs passed their gates, then validate the integrated behavior and final combined diff.

## Worktrees Are Not Delegation Units

Start with the current workspace and an auxiliary-worktree budget of zero. Do not create a worktree for each agent, role, node, retry, or depth level. Read-only agents and disjoint bounded writers normally share the current workspace; serialize overlapping writes unless a concrete branch or filesystem isolation need makes a separate checkout necessary.

Only the root may raise the finite worktree budget, issue a worktree permit, create or adopt an auxiliary worktree, repurpose it, or remove it. Root may authorize one active auxiliary without additional approval; two or more require user approval for the exact count and reasons. Every child receives an exact workspace assignment. A descendant may report an isolation need but must not create, move, or remove a worktree. Retries reuse their compatible assigned workspace.

Consult `references/worktrees.md` for creation, integration, cleanup, and preservation gates. Before task completion, the root must integrate and safely remove every task-created auxiliary worktree or preserve it with its exact owner, path, branch or HEAD, blocker, and next action. Do not defer task-owned cleanup to scheduled automation.

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
- Apply the canonical Codex order `gpt-5.6-sol` rank 3, `gpt-5.6-terra` rank 2, and `gpt-5.6-luna` rank 1. Record the actual user-selected root model instead of assuming Sol.
- Require every child model rank to be equal to or lower than its parent's rank. Same-tier delegation is allowed; depth does not force a tier drop.
- Treat reasoning effort as a separate parent ceiling.
- With a Sol root, prefer the installed Terra variants for normal bounded work and Luna variants for cheap work with objective acceptance. With a Terra root, use Terra or Luna. With a Luna root, use Luna only.
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

A supporting subagent may gather evidence for these areas, but the main agent must make and verify the decision. The root may route a new depth-1 replacement at any model rank and effort at or below the root task ceilings, with a new root-issued permit and budget plus documented reason and verification. A replacement may be stronger than the failed child because it is a new child of root; descendants still cannot escalate themselves.

## Two-Generation Delegation and Leaves

The root is depth 0. A depth-1 child is either a direct worker or a local orchestrator that normally uses an installed/callable custom Codex role (`planner`, `engineer`, `reviewer`, `tester`, or `docs`) in an eligible Terra or Luna variant selected by the root through an `@` tag or equivalent programmatic routing. An exceptional bounded Sol child may instead use an explicit host-supported model route within the root ceilings when the root records the justification. A depth-2 child is a leaf that executes its assigned completion subset directly, must not spawn, and uses an explicitly selected permitted profile or model. This routing contract does not claim that a UI tag picker has been runtime smoke-tested. Depth 3 and deeper are prohibited. Before delegation, the root owns a finite task manifest and total spawned-node budget counting every depth-1 and depth-2 node. Only the root may issue child permits or expand that budget. Every root manifest or budget expansion requires a documented root reason limited to a newly discovered dependency, invalidated gate, or changed user scope; if it adds material execution cost, obtain user approval immediately before issuing the added nodes or permits.

Every child requires a root-issued permit and must declare its parent ID, child ID, non-empty strict completion subset, ownership or read scope, explicitly selected model and effort, parent model rank and effort ceiling, child-at-or-below-parent proof, and acceptance condition. Its completion subset must be strictly smaller than the parent's remaining completion subset, and sibling write ownership must be disjoint. The assignment must otherwise remain equal to or narrower than its parent in inputs, data access, permissions, scope, non-goals, authority, and approval boundary. No descendant may upgrade or request model rank or effort above its parent's ceilings; if insufficient, it must stop and report upward.

A depth-1 direct worker executes its own subset. A depth-1 local orchestrator may dispatch only root-permitted depth-2 leaves within its assigned subset; it cannot issue permits, expand budget, alter root dependencies, dispatch root-ready work, or resolve cross-subtree conflicts. The parent validates each accepted child, consolidates accepted outputs, and returns a compact lineage-and-evidence bundle upward. Retry a failed node with its original node ID and permit. A replacement node needs a new root-issued permit and consumes budget. Root may select any replacement model rank and effort at or below the root task ceilings; the replacement requires documented reason and verification and is not descendant escalation. Every root manifest or budget expansion needs the documented root reason above; material execution cost additionally requires user approval immediately before the added nodes or permits.

Keep local delegation economical: send only the minimum relevant paths and accepted artifacts; reuse accepted results; avoid duplicate discovery; choose the smallest suitable model and effort; and omit full history, transcripts, and long logs.

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

Lineage and inherited constraints:
[Root/node lineage; parent ID and child ID; parent remaining completion subset; this child's non-empty strict completion subset; inherited limits on inputs, data access, permissions, scope, non-goals, authority, approval boundary, and the parent's explicit model-rank and effort ceilings.]

Permit and ownership:
[Root-issued permit ID; manifest budget status; declared write ownership or read scope; confirmation that sibling write ownership is disjoint; actual root model; parent and child model ranks; proof that selected model rank and effort are at or below the parent's explicit ceilings.]

Workspace:
[Exact shared/current workspace or root-permitted auxiliary worktree; worktree permit ID when applicable; descendants may not create, repurpose, move, or remove worktrees.]

Acceptance condition:
[Specific output and evidence required for the parent to accept this child's completion subset.]

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

Local-child limits:
[Only for a depth-1 local orchestrator: dispatch only root-permitted depth-2 leaves; do not issue permits or expand budget. Depth-2 leaves execute directly and may not spawn.]

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
- Parent return bundle: [compact lineage, accepted artifact paths, evidence, unresolved conflicts or blockers]
```

For multi-node work, also include:

```text
Node ID:
Parent ID / child ID:
Inputs / authoritative sources:
Completion subset:
Output and acceptance condition:
Depends on:
Write ownership or read scope:
Verification gate:
Root-issued permit ID:
```

## Acceptance Checklist

Before accepting subagent work, the main agent must verify:

- the profile or model was explicitly selected when supported
- parent-model inheritance was not used unintentionally
- the actual root model was recorded rather than assumed
- the selected model rank and reasoning effort are at or below the recorded parent ceilings
- each local child stayed within inherited constraints, had a bounded output, and did not overlap a sibling
- the returned lineage and evidence bundle is compact and sufficient for the parent to accept or reject the result
- any root-routed new depth-1 replacement stayed within the root task model-rank and effort ceilings, consumed a new permit and budget, and has documented reason and verification evidence
- the subagent stayed within scope
- the result addresses the assigned goal
- claims are backed by code, tests, logs, docs, runtime behavior, or other primary evidence
- any edits are minimal and task-related
- no unrelated files were changed
- the implementation matches existing architecture and style
- validation was run, or a clear reason was given
- any claimed parallel safety or isolation was verified
- every task-created auxiliary worktree has integration evidence and a final `removed` or exact-blocker `preserved` disposition
- required node gates passed before fan-in and combined validation covered the integrated behavior
- the main agent has inspected the final diff itself

If subagent findings conflict, resolve the disagreement by inspecting primary evidence.

Never accept a subagent's conclusion solely because it sounds confident.
