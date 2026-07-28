# Active Work Record

Use this optional template for repository-local coordination records under:

```text
.codex/coordination/active-work/
```

Create one record per active feature, migration, shared contract, or other meaningful workstream.

These records are coordination aids, not automatic truth. Verify them against current branches, worktrees, commits, pull requests, code, tests, and thread evidence.

## Thread Naming Standard

When creating a new project thread, use:

```text
Project - Three-to-Four-Word Description
```

Examples:

```text
ArcLedger - Validate Billing Evidence
LoreBound - Implement Campaign Imports
United Tradesmen - Coordinate Scheduler Changes
```

Use the detected project name. Derive a concise three-to-four-word description from the thread's primary objective. Do not ask the user to supply a title when the project and objective are already clear.

The square brackets sometimes used to explain the format are placeholders and are not part of the actual thread title.

## Record

```yaml
feature: "Short feature or workstream name"
thread_title: "Project - Three-to-Four-Word Description"
status: "planned | in-progress | blocked | integration-ready | merged | abandoned"
thread: "Optional thread identifier"
owner: "Optional responsible agent, person, or team"
branch: "feature/example"
base_branch: "main"
last_updated: "YYYY-MM-DDTHH:MM:SSZ"

objective: >-
  One concise description of the intended outcome.

owned_paths:
  - "src/example/**"

shared_paths:
  - "src/shared/contracts.ts"

shared_contracts:
  - "Customer"
  - "POST /api/example"

schemas_or_migrations:
  - "db/migrations/0001_example.sql"

dependencies:
  - "customer-schema"

blocked_by: []

must_not_modify:
  - "src/auth/**"

open_decisions: []

validation_required:
  - "targeted tests"
  - "typecheck"
  - "integration test"

notes: >-
  Include only coordination-relevant assumptions, risks, or handoff details.
```

## Maintenance Rules

- Keep the record current while the work remains active.
- Use repository-relative paths.
- Keep `thread_title` aligned with the naming standard for newly created threads.
- Do not store credentials, tokens, private local paths, or sensitive access material.
- Do not paste long logs, full transcripts, or unrelated implementation notes.
- Mark abandoned work explicitly instead of silently leaving stale records active.
- Remove or archive the record after the work is merged and no longer affects active coordination.
