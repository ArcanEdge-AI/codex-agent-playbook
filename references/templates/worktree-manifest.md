# Worktree Manifest: [Task Name]

Use this template only when a task creates, adopts, or coordinates auxiliary Git worktrees. Keep a small ledger in the working plan when a repository artifact is unnecessary.

## Task Context

- Root owner: [Main session]
- Repository root: [Verified path]
- Common Git directory: [Verified path]
- Primary workspace: [Canonical path]
- Primary workspace class: [Host-managed primary / user-managed existing]
- Auxiliary-worktree budget: [Finite count; default 0]
- User approval for two or more active auxiliaries: [N/A or exact approval]
- Applicable instructions: [Paths or sources]

## Permit Ledger

| Permit | Node or owner | Canonical path | Base ref and SHA | Branch or HEAD | Write scope | Isolation reason | Integration target | Cleanup condition | State |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W1 | [Owner] | [Exact path] | [Ref and SHA] | [Branch or detached SHA] | [Paths/state] | [Why sharing/serialization fails] | [Accepted handoff] | [Required evidence] | proposed |

Allowed states: `proposed`, `active`, `integration-ready`, `cleanup-ready`, `removed`, or `preserved`.

Only the root issues permits or changes the budget. A subagent may report an isolation need but must not create, adopt, repurpose, move, or remove a worktree.

## Handoff and Integration

| Permit | Produced artifact or commit | Acceptance evidence | Integrated into | Combined validation |
| --- | --- | --- | --- | --- |
| W1 | [Artifact] | [Evidence] | [Target] | [Command/result] |

## Cleanup Ledger

| Permit | Clean tracked/untracked/submodules | Ignored artifacts checked | Processes checked | Recoverability verified | Path and registration verified absent | Final disposition or blocker |
| --- | --- | --- | --- | --- | --- | --- |
| W1 | [Yes/evidence] | [Yes/evidence] | [Yes/evidence] | [Yes/evidence] | [Yes/evidence or N/A] | [removed / preserved with exact blocker] |

## Completion Check

- Every task-created auxiliary permit has a final disposition: [Yes / No]
- No descendant created or removed a worktree: [Confirmed / Exception]
- Retries reused their compatible workspace: [Yes / N/A]
- Integrated behavior was validated from the integration workspace: [Yes / No]
- Preserved worktrees name exact owner, path, branch or HEAD, blocker, and next action: [Yes / N/A]
- Cleanup was completed inside the task rather than deferred to scheduled automation: [Yes / No]

Do not store credentials, sensitive access material, private local paths in committed public examples, full transcripts, or long logs.
