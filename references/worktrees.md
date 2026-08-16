# Worktree Lifecycle Reference

The root main agent owns every Git worktree decision made inside its task. Worktrees are isolation tools, not the unit of delegation. Creating a subagent, retrying a node, or increasing fan-out does not create a worktree requirement.

This reference governs task-local worktree use. It does not depend on a scheduled cleanup task and does not authorize a broad sweep of old or unrelated worktrees.

## Workspace Classes

Classify every relevant checkout before acting:

| Class | Meaning | Task-local disposition |
| --- | --- | --- |
| Host-managed primary | The current task workspace was created or managed by the host. | Record it. Do not try to delete the active checkout from inside itself. Use the supported host task/workspace lifecycle when available. |
| User-managed existing | A checkout or worktree predates the task or has ownership outside the task. | Inspect read-only unless the user or repository evidence grants ownership. Never remove it as task cleanup. |
| Task-created auxiliary | The root created it under a task-local permit for a declared isolation need. | Integrate, verify, and remove before the final response when every cleanup gate passes; otherwise preserve with an exact blocker. |

## Default Policy

- Start with the current workspace and an auxiliary-worktree budget of `0`.
- The root may authorize at most one active auxiliary worktree without additional user approval. Two or more require approval for the exact count and reasons.
- Do not allocate one worktree per agent, node, role, retry, or depth level.
- Read-only work uses the current workspace.
- Disjoint bounded writers normally share the current workspace when the runtime and repository permit it.
- Serialize overlapping or tightly coupled writes. Do not create worktrees merely to hide conflicts that still must be reconciled.
- Raise the finite worktree budget only for a specific planned writer that needs real branch or filesystem isolation.
- Only the root may issue a worktree permit, create or adopt an auxiliary worktree, change its purpose, or remove it.
- Depth-1 and depth-2 agents work only in the exact workspace assigned by the root. They report additional isolation needs upward.
- Retries reuse the same compatible worktree. A replacement agent does not receive a new worktree automatically.

The worktree budget is separate from the spawned-node budget. A task may have many bounded agents and zero auxiliary worktrees.

## When an Auxiliary Worktree Is Justified

An auxiliary worktree may be justified when:

- the user explicitly requests a separate branch or worktree
- the host or repository workflow requires branch-isolated delivery
- an independent writer must preserve a conflicting in-progress tree while working from a verified base
- build, test, generation, or mutable-state behavior cannot be isolated safely inside the current workspace
- a long-running write stream needs a stable branch and checkout while integration proceeds elsewhere

It is not justified only because:

- another subagent is available
- tasks can run in parallel
- a node is read-only
- a previous attempt failed
- the current worktree is old
- a clean checkout looks removable

## Root Worktree Permit

Before creating or adopting a task-local auxiliary worktree, record:

| Field | Required value |
| --- | --- |
| Permit ID | Stable root-issued identifier. |
| Node or owner | The node responsible for work in the checkout. |
| Repository identity | Repository root and common Git directory. |
| Canonical path | Exact absolute worktree path. |
| Base | Base ref and exact base SHA. |
| Branch or detached HEAD | Exact intended Git state. |
| Write scope | Paths or mutable state owned in this workspace. |
| Isolation reason | Why shared execution or serialization is insufficient. |
| Integration target | Branch, commit, patch, pull request, or other accepted handoff. |
| Cleanup condition | Evidence that will make removal safe. |
| State | `proposed`, `active`, `integration-ready`, `cleanup-ready`, `removed`, or `preserved`. |

Use `references/templates/worktree-manifest.md` when the ledger needs to persist across phases or sessions. A concise entry in the working plan is enough for a small task.

## Creation Procedure

1. Inspect `git worktree list --porcelain` from the verified repository.
2. Resolve the common Git directory, current branch or detached HEAD, exact HEAD, and dirty state.
3. Check active thread, branch, and worktree ownership when related work may exist.
4. Prefer a compatible existing task-owned worktree or serial execution.
5. Confirm that the proposed path is explicit, narrow, and outside any existing checkout.
6. Confirm that the branch is not already checked out elsewhere and the exact base SHA is correct.
7. Record the root permit and decrement the finite auxiliary-worktree budget. Obtain user approval first if this would allow two or more active auxiliaries.
8. Create the worktree through supported Git or host behavior without force.
9. Verify the new canonical path, registration, branch or HEAD, and clean starting state before assigning work.

Do not create a worktree speculatively. Do not let a descendant choose an unrecorded path or branch.

## Execution and Integration

- Give every writer the exact assigned workspace and write scope.
- Keep sibling ownership disjoint even when worktrees are separate.
- Record the checkout HEAD and dirty state at meaningful handoffs.
- Validate the produced artifact before integration.
- Integrate through the declared target and verify the combined result in the integration workspace.
- Keep the auxiliary worktree until its accepted work is recoverable and the cleanup gate passes.
- Reuse the same workspace for a retry of the same node unless primary evidence proves it is invalid.

## In-Task Cleanup Procedure

Before the final response, enumerate every task-created auxiliary permit. For each worktree:

1. Reconfirm the canonical path, common Git directory, branch or detached HEAD, exact HEAD, and root permit.
2. Confirm the node is complete and its output is accepted and integrated, or that abandonment is explicitly within the task's authority.
3. Check tracked and untracked changes, submodules, and valuable ignored artifacts. A clean short status alone is not sufficient.
4. Check for running processes, services, terminals, or tests that still depend on the checkout when the environment can expose them.
5. Confirm the commit or branch is recoverable through the integration target, remote backup, tag, or explicit preservation decision.
6. Confirm the target is not the active checkout and is not owned by another task or user.
7. Remove only the exact registered auxiliary worktree using non-force supported behavior.
8. Prune only stale registration metadata for the verified repository when needed; never use prune as a substitute for ownership checks.
9. Verify both that the path is absent and that `git worktree list --porcelain` no longer registers it.
10. Mark the permit `removed` with evidence.

Never use force removal, reset, clean, stash, broad recursive deletion, age, inactivity, or a clean status as the sole cleanup decision. If any check is unavailable or ambiguous, set the permit to `preserved` and report the exact missing evidence or ownership blocker.

## Final Task Contract

The root must report one disposition for every task-created auxiliary worktree:

- `removed` — cleanup gates passed and path plus registration removal were verified
- `preserved` — the exact path, owner, branch or HEAD, blocker, and next action are named
- `reused` — the task used an existing checkout and did not own its removal
- `host-managed` — the current task workspace remains under the host's supported lifecycle

Do not say the task is clean merely because a scheduled cleaner may inspect it later. Task-created auxiliaries are closed inside the task or explicitly preserved.
