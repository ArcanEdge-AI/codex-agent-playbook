# Prompt: Coordinate Active Project Work

Use this prompt when multiple Codex threads are working on related features in the same project.

```markdown
Coordinate all active work for the current project.

Use the `multi-session-coordination` skill and consult `references/multi-session-coordination.md`.

Identify the current project, repository, default branch, active branch, and available worktrees from the environment. Do not ask me for information that can be detected reliably.

When creating a new project thread, use `Project - Three-to-Four-Word Description`. Detect the project name and derive the description from the primary objective. Do not include literal square brackets or ask me for a title when the project and task are already clear.

Begin with related Codex threads active during the previous 72 hours. Include older work when repository evidence shows that it remains unmerged, incomplete, blocked, contract-relevant, or otherwise active.

When direct thread discovery is unavailable, inspect branches, worktrees, pull requests, commits, diffs, tests, and optional active-work records. Clearly distinguish directly reviewed threads from repository-inferred work and identify any potentially missing work.

Build a shared change map and identify conflicts across files, architecture, APIs, events, schemas, migrations, shared types, dependencies, authentication, user flows, and tests. Do not limit the review to Git merge conflicts.

Assign clear ownership for shared areas, recommend the safest implementation order, identify work that should continue or pause, and provide copy-ready instructions for each active thread.

Return:

1. Executive summary
2. Discovery coverage
3. Active work summary
4. Shared change map
5. Conflict and overlap matrix
6. Ranked integration risks
7. Recommended implementation order
8. Instructions for each thread
9. Integration verification checklist
10. Open decisions requiring my approval

Do not implement changes unless I explicitly ask. Do not claim complete coverage when relevant thread context is inaccessible. Ask for a specific thread identifier only when missing context materially prevents a safe coordination decision.
```

Optional constraints can be added in plain language, for example:

- Prioritize one feature.
- Include a known thread.
- Exclude an abandoned branch.
- Prevent database changes until approval.
- Coordinate only planning and review work.
