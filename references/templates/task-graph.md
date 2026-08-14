# Task Graph: [Task Name]

Use this template only for work that benefits from a formal instruction-only task graph. Keep smaller or genuinely linear tasks in the normal working plan.

## Graph Metadata

- Goal: [One concrete outcome]
- Owner: [Main agent or coordinating thread]
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

| ID | Work | Executor | Inputs | Output and acceptance condition | Depends on | Reads | Writes or mutable state | Model / effort | Verification gate | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N0 | [Bounded work] | Main | [Authoritative inputs] | [Artifact plus acceptance rule] | None | [Scope] | None | Main | [Evidence] | Ready |

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

Concurrency limit: [Number and rationale]

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

## Maintenance Rules

- Let the main orchestrator own graph topology, state transitions, and final acceptance.
- Treat a dependency as real only when the downstream node consumes an accepted upstream artifact or decision.
- Keep completed outputs unless their inputs become invalid.
- Update the ready set after every accepted, failed, blocked, or superseded node.
- Do not store credentials, sensitive access material, private local paths, full transcripts, or long logs.
- Preserve or remove the graph artifact according to repository policy after completion.
