# Task Graph: [Task Name]

Use this template only for work that benefits from a formal instruction-only task graph. Keep smaller or genuinely linear tasks in the normal working plan.

## Graph Metadata

- Goal: [One concrete outcome]
- Owner: [Main orchestrator or coordinating thread]
- Root owner: [Root main session that exclusively owns root topology and ready set]
- Actual root model / canonical rank / reasoning-effort ceiling: [Record; never assume Sol]
- Repository and worktree: [Current verified context]
- Applicable instructions: [Paths or sources]
- Status: [Proposed / Active / Blocked / Complete]
- Last updated: [Timestamp or execution checkpoint]
- Graph-mode reason: [Why the added structure is justified]
- Multi-session preflight: [Not needed / completed with evidence / blocked]

## Success Criteria

- [Observable criterion]
- [Required validation]
- [Required user-visible result]

## Nodes

- Root manifest and total spawned-node budget: [Finite node IDs/count, including depth-1 and depth-2]
- Permit ledger: [Required root-issued permit; parent/child IDs; strict non-empty subset; disjoint ownership; profile/model rank/effort; parent model-rank and effort ceilings; child-at-or-below-parent proof; acceptance]
- Auxiliary-worktree budget: [Finite count; default 0 and separate from node budget; user approval required for 2 or more active auxiliaries]
- Worktree permit ledger: [None, or root-issued permit IDs linked to exact workspace, owner, isolation reason, integration target, and cleanup condition]

| ID | Parent / lineage | Work | Executor | Inputs | Output and acceptance condition | Depends on | Reads | Writes or mutable state | Model / rank / effort | Parent model-rank and effort ceilings / child-at-or-below-parent proof | Verification gate | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N0 | [Root or parent node] | [Bounded work] | [Subagent role by default] | [Authoritative inputs] | [Artifact plus acceptance rule] | None | [Scope] | None | [Explicit model / rank / effort] | [Explicit parent ceilings and proof, or N/A for root] | [Evidence] | Ready |

Use node states consistently: `Proposed`, `Ready`, `Running`, `Complete`, `Failed`, `Blocked`, or `Superseded`.

## Dependency Edges

| From | To | Consumed artifact or decision |
| --- | --- | --- |
| N0 | N1 | [Why N1 cannot correctly begin without accepted N0 output] |

Do not add an edge solely to mirror list order.

## Hidden-Edge Review

- Shared file writes: [None or exact conflicts]
- Shared mutable state: [Ports, services, environments, locks, credentials, rate limits, or cost]
- Schema, interface, migration, or contract ordering: [None or exact dependency]
- External thread, branch, worktree, or pull-request ownership: [None or exact constraint]
- Destructive, irreversible, production, sensitive, costly, or audience-facing actions: [None or approval node]

## Current Ready Set

- [Node IDs whose dependencies and hidden constraints are satisfied]

Ready-node dispatch: [Only nodes in the finite root manifest whose dependencies and hidden constraints are satisfied, that have a required root-issued node permit, fit the remaining total node budget, and fit runtime, safety, and verified ownership or isolation capacity; every node has an exact assigned workspace]

## Local Child Subtrees

| Parent node | Local child ownership and sibling non-overlap | Inherited constraints | Parent model-rank / effort ceilings | Child-at-or-below-parent proof | Compact return bundle |
| --- | --- | --- | --- | --- | --- |
| [N0] | [Paths/state; no overlap] | [Goal, inputs, data access, permissions, scope, non-goals, ownership/isolation, authority, approval boundary] | [Explicit ceilings] | [Selected child model rank and effort compared with both ceilings] | [Lineage, accepted artifact paths, evidence, blockers] |

Use the Codex order `gpt-5.6-sol` rank 3, `gpt-5.6-terra` rank 2, and `gpt-5.6-luna` rank 1. Record the actual user-selected root model; never assume Sol. A child's model rank and reasoning effort must be at or below its parent's separate ceilings. Equal-tier children are valid, and depth does not force a tier drop. Only root issues permits and expands budget. Depth 1 executes directly and stops local splitting when no valid permitted strict-subset split exists; depth 2 is a leaf and cannot spawn. Runtime-full is backpressure, not speculative queuing. Retry reuses ID/permit. Every expansion records a documented root reason limited to a newly discovered dependency, an invalidated gate, or changed user scope; a material-cost expansion additionally requires immediate user approval. A replacement is a new root-routed depth-1 node at any model rank and effort at or below the root task ceilings and requires a new root permit/budget. Descendants that cannot complete within their ceilings stop and report rather than escalating themselves.

## Worktree Lifecycle

Worktrees are not delegation units. Start with the current workspace and an auxiliary-worktree budget of zero. Only root may issue a worktree permit, and descendants must not create, adopt, repurpose, move, or remove worktrees.

| Worktree permit | Node or owner | Canonical path | Base ref and SHA | Branch or HEAD | Isolation reason | Integration target | Cleanup condition | State |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W1 | [Owner] | [Exact path] | [Ref and SHA] | [Branch or detached SHA] | [Why sharing/serialization fails] | [Accepted handoff] | [Required evidence] | [proposed / active / integration-ready / cleanup-ready / removed / preserved] |

Remove the placeholder row when no auxiliary worktree exists. Reuse a compatible task-owned worktree for retries. Before the final response, mark every task-created auxiliary as `removed` with path and registration verification or `preserved` with exact owner, path, branch or HEAD, blocker, and next action. Do not defer task-owned cleanup to scheduled automation.

## Execution Ledger

| Node | Attempt | Result | Evidence or produced artifact | Downstream nodes invalidated |
| --- | --- | --- | --- | --- |
| N0 | 1 | [Complete / Failed / Blocked] | [Path, command result, diff, or finding] | [None or IDs] |

## Completeness Check

- Expected node IDs: [IDs]
- Accepted node IDs: [IDs]
- Missing node IDs: [IDs or None]
- Failed node IDs: [IDs or None]
- Blocked node IDs: [IDs or None]
- Superseded node IDs: [IDs or None]

## Approval Gates

| Gate | Action | Exact scope and consequence | Required authority | Status |
| --- | --- | --- | --- | --- |
| G1 | [Action] | [Target, audience, cost, permanence, and recovery path] | [User or system authority] | Blocked |

If no approval-gated action exists, write `None` and remove the placeholder row.

## Fan-In and Final Verification

- Consolidation nodes: [IDs and expected inputs]
- Preserved evidence identifiers: [Paths, node IDs, counts, severity, confidence]
- Integrated validation: [Commands, runtime checks, or inspection]
- Independent verification: [Reviewer or Tester node, or reason not needed]
- Final diff reviewed: [Yes / No]
- Required nodes and gates complete: [Yes / No]
- Every task-created auxiliary worktree has a verified final disposition: [Yes / No / N/A]

## Maintenance Rules

- Let the main orchestrator own graph topology, state transitions, integration, authority-bound actions, and final acceptance.
- Let local parents orchestrate only their declared child subtree; no child may change root topology or root-ready work.
- At the root, assign actual execution to at least one bounded subagent when available. Root direct main-agent execution is allowed only when subagents are unavailable, the user forbids delegation, or the action must remain with the main agent because of required authority; record the exact exception. A depth-1 local owner executes directly when no valid permitted strict-subset split exists; depth 2 cannot spawn.
- Record the actual root model and its canonical rank; never assume Sol. Require each child to be equal to or narrower than its parent in inherited constraints, with explicitly selected profile, model rank, and effort at or below its parent's separate ceilings; record the proof and never silently inherit or escalate.
- Give each child an exact workspace. Keep the auxiliary-worktree budget separate from the node budget, default it to zero, and let only root create or remove a worktree under `references/worktrees.md`.
- Treat a dependency as real only when the downstream node consumes an accepted upstream artifact or decision.
- Keep completed outputs unless their inputs become invalid.
- Update the ready set after every accepted, failed, blocked, or superseded node.
- Do not store credentials, sensitive access material, private local paths, full transcripts, or long logs.
- Reuse accepted outputs and pass only minimum relevant paths and evidence in parent return bundles.
- Preserve or remove the graph artifact according to repository policy after completion.
