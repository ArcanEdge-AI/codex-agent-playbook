---
name: worktree-lifecycle
description: Manage Git worktrees created or used during a Codex task. Use when an agent proposes an isolated checkout, parallel writers may need filesystem isolation, a task already owns auxiliary worktrees, or the root must integrate, preserve, or remove task-created worktrees before completion.
---

# Worktree Lifecycle

Keep worktree use finite, root-owned, and task-local. A subagent is not a reason to create a worktree. The normal default is the current shared workspace with an auxiliary-worktree budget of zero.

Consult `references/worktrees.md` for the complete decision rules and `references/templates/worktree-manifest.md` when a durable ledger is justified.

## Workflow

1. Inspect the current checkout, common Git directory, branch or detached HEAD, registered worktrees, dirty state, and known thread ownership.
2. Classify the current checkout as host-managed primary, user-managed existing, or task-created auxiliary.
3. Keep the auxiliary-worktree budget at zero unless a planned writer needs real branch or filesystem isolation that cannot be handled safely in the current workspace or by serialization.
4. Let only the root raise the finite budget and issue a worktree permit. The root may authorize one active auxiliary without additional approval; two or more require approval for the exact count and reasons. Record the reason and manifest entry before creation.
5. Reuse a compatible registered worktree before creating another. Never create one merely because a new subagent or retry exists.
6. Assign each node its exact workspace and write scope. Descendants must not create, repurpose, move, or remove worktrees; they report a need upward.
7. Integrate and validate accepted work through the declared integration target.
8. Before the final response, inspect every task-created auxiliary worktree and set its disposition to `removed` or `preserved` with an exact blocker. Do not defer task-owned cleanup to a scheduled job.

## Creation Gate

Create an auxiliary worktree only when all are true:

- the repository and common Git directory are verified
- the base ref and exact base SHA are recorded
- the path and branch are explicit and do not collide with an existing registration
- the planned write or mutable-state isolation is concrete
- reuse or serial execution is insufficient
- the finite root budget has capacity and a root permit exists
- ownership, integration target, and cleanup condition are recorded

Parallel writes to overlapping files normally serialize. Separate worktrees hide filesystem collisions but do not resolve design or merge conflicts.

## Completion Gate

Remove a task-created auxiliary worktree only after verifying all of these:

- it matches the exact root permit, path, repository identity, owner, and expected HEAD
- its work is accepted and integrated, or explicitly abandoned within the task's authority
- tracked files, untracked files, submodules, and valuable ignored artifacts are clean or accounted for
- no running process depends on the checkout
- the branch or commit is recoverable through the declared integration or remote-backup path
- it is not the active checkout from which removal is attempted

Use the supported host lifecycle for a host-managed primary workspace. For a task-created auxiliary worktree, prefer non-force `git worktree remove <exact-path>` followed by targeted registration verification. Never use force removal, reset, clean, stash, broad recursive deletion, age alone, or a clean status alone as proof of safety.

If any gate fails, preserve the worktree and return its canonical path, owner, branch or detached HEAD, exact blocker, and next action. Preservation is a safe task-local outcome; silent abandonment is not.

## Required Result

Return a compact ledger containing:

- starting registered worktrees relevant to the task
- auxiliary budget and permits issued
- worktrees created or reused
- integration evidence
- final disposition for every task-created auxiliary worktree
- any preserved path and blocker

Do not claim cleanup complete until Git registration and path state are verified.
