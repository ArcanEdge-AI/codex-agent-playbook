# Prompt: Set Up Global Codex Support System

> This is an explicit support-only setup prompt, not a normal installer or updater. For every normal install or update, follow `INSTALL.md` in full mode. Do not select this prompt merely because existing playbook files are present.

Paste this prompt into Codex after you have already added the global coding-agent instructions from `custom-instructions/global-coding-agent-instructions.md` to Codex Personalization > Custom instructions.

```markdown
You are configuring my global Codex support system.

Important context:
I have already added my full global coding-agent instructions in Codex Personalization > Custom instructions. Treat that as true even if you cannot inspect the UI.
Do not duplicate those full instructions into `AGENTS.md`.
This explicit statement is the authorization for support-only behavior. Without it, stop using this prompt and follow `INSTALL.md` in full mode.

Your job is to create the supporting global reference system only:

- global reference documents
- reference document routing docs
- subagent model-routing docs
- subagent delegation docs
- multi-session coordination docs
- reusable skills, if supported
- global custom subagent definitions, if supported
- a small pointer section in `$CODEX_HOME/AGENTS.md` only if helpful

Do not modify any repository files. Work only in user-level/global Codex and agent configuration locations.

## Path Resolution

Resolve paths like this:

- `CODEX_HOME`: use the `CODEX_HOME` environment variable if set; otherwise use the user's Codex home directory, normally `~/.codex`.
- `USER_SKILLS_HOME`: use `$HOME/.agents/skills`.
- `GLOBAL_AGENTS_HOME`: use `$CODEX_HOME/agents`.
- `GLOBAL_REFERENCES_HOME`: use `$CODEX_HOME/references`.

If the platform is Windows, resolve equivalent user-home paths safely instead of hardcoding Unix-only paths.

Do not hardcode machine-specific usernames or absolute paths.

## Preflight Requirements

Before writing anything:

1. Print the resolved paths.
2. Inspect whether these exist:
   - `$CODEX_HOME/AGENTS.md`
   - `$CODEX_HOME/AGENTS.override.md`
   - `$GLOBAL_REFERENCES_HOME`
   - `$USER_SKILLS_HOME`
   - `$GLOBAL_AGENTS_HOME`
3. Do not delete existing content.
4. Do not overwrite existing content without a timestamped backup.
5. If a file already exists, prefer a careful merge/update over replacement.
6. If replacement is necessary, create a timestamped backup next to the file.
7. Do not store sensitive access material, private local paths, or long incident logs.
8. Keep everything tool-agnostic except where a Codex-specific workflow is explicitly documented in a skill or reference.
9. Do not mention issue-tracker-specific review mechanics, repo-specific workflows, local machine quirks, or project names.
10. Do not ask me questions unless you are blocked. Make reasonable assumptions and report them.

## Desired Global Structure

Create or update this structure:

```text
$CODEX_HOME/
  AGENTS.md
  references/
    README.md
    model-routing.md
    subagents.md
    multi-session-coordination.md
    reference-doc-routing.md
    templates/
      repository-AGENTS.md
      architecture.md
      testing.md
      security.md
      design-system.md
      release.md
      api-contracts.md
      data-model.md
      active-work-record.md
      task-graph.md
  agents/
    planner.toml
    planner-luna.toml
    engineer.toml
    engineer-luna.toml
    reviewer.toml
    reviewer-luna.toml
    tester.toml
    tester-luna.toml
    docs.toml
    docs-luna.toml

$HOME/.agents/skills/
  subagent-orchestration/
    SKILL.md
  task-graph-orchestration/
    SKILL.md
  multi-session-coordination/
    SKILL.md
  reference-doc-routing/
    SKILL.md
  senior-code-review/
    SKILL.md
```

If the installed Codex version does not support user-level skills or custom agents, do not fail the whole task. Create the reference documents and update the small pointer section if appropriate, then report which optional pieces were skipped and why.

Do not create custom agents named `default`, `worker`, or `explorer`, because those may shadow built-in agents. Use the custom names listed above.

## Handle `$CODEX_HOME/AGENTS.md` Safely

The full global coding-agent instructions have already been added through Codex Personalization > Custom instructions.

Do not duplicate those instructions into `$CODEX_HOME/AGENTS.md`.

Inspect `$CODEX_HOME/AGENTS.md` if it exists.

If `$CODEX_HOME/AGENTS.md` does not exist:
- Create a small pointer file only.
- Do not recreate the full global instruction set.

If `$CODEX_HOME/AGENTS.md` already exists:
- Preserve it.
- Do not replace it.
- Do not remove existing guidance.
- Preserve all user-authored content outside the exact `<!-- coding-agent-playbook-codex:start -->` and `<!-- coding-agent-playbook-codex:end -->` markers. Migrate one valid legacy `codex-agent-playbook` marker pair instead of appending a duplicate section.
- If exactly one well-ordered marked section exists, create a timestamped backup and replace only that inclusive marked block with the current small reference section; do not leave stale marked content unchanged.
- If neither marker exists, add the small reference section.
- If only one marker exists, either marker is duplicated, or the end marker appears before the start marker, stop and report the malformed state without writing the file.
- If the existing file already appears to duplicate the full UI custom instructions, report that possible duplication but do not delete anything.

If `$CODEX_HOME/AGENTS.override.md` exists:
- Do not modify it.
- Report that it exists because it may override normal AGENTS guidance.

The pointer section should be:

```markdown
# Global Codex Reference Map

The primary global coding-agent behavior may be configured in Codex Personalization > Custom instructions or in this AGENTS.md file.

Supporting global reference documents live under the Codex home references directory:

- `references/README.md` — map of available global reference docs
- `references/model-routing.md` — mandatory subagent model-selection, escalation, and acceptance rules
- `references/subagents.md` — subagent delegation rules, assignment template, and acceptance checklist
- `references/worktrees.md` — root-owned task-local worktree budgeting, permits, integration, cleanup, and preservation rules
- `references/multi-session-coordination.md` — discovery, thread naming, ownership, sequencing, conflict detection, and integration guidance for independent project threads
- `references/reference-doc-routing.md` — how to decide which docs to consult and how to treat them
- `references/templates/` — templates for repository-level architecture, testing, access-control, design-system, release, API, data-model, active-work, task-graph, and worktree-manifest docs

Reusable skills live under the user skills directory, including:

- `subagent-orchestration`
- `task-graph-orchestration`
- `worktree-lifecycle`
- `multi-session-coordination`
- `reference-doc-routing`
- `senior-code-review`

Custom Codex subagents live under the Codex home agents directory:

- `agents/planner.toml`
- `agents/engineer.toml`
- `agents/reviewer.toml`
- `agents/tester.toml`
- `agents/docs.toml`
- `agents/planner-luna.toml`, `agents/engineer-luna.toml`, `agents/reviewer-luna.toml`, `agents/tester-luna.toml`, `agents/docs-luna.toml`

Reference documents are supporting context, not automatic truth. For every repository task when subagents are available, the main agent delegates actual execution to at least one bounded subagent; it remains accountable for orchestration, final diff, validation, acceptance, and final response. Direct main-agent execution is limited to unavailable subagents, an explicit user prohibition, or a specific authority-bound action that cannot be delegated; record the exact exception.

The root records the actual user-selected main model, canonical rank, separate reasoning-effort ceiling, finite manifest, total spawned-node budget, and child-specific permits; never assume the root is Sol. Use `gpt-5.6-sol` rank 3 > `gpt-5.6-terra` rank 2 > `gpt-5.6-luna` rank 1. Every dispatched child must already be a finite-manifest member, fit the remaining total node budget, hold its required root permit, and fit runtime, safety, and ownership capacity. Its model rank and effort must be at or below the separate ceilings of its parent; equal-tier children are valid, and depth does not force a tier drop. Expand the manifest or budget only for a newly discovered dependency, invalidated gate, or changed user scope; a material expansion also needs immediate user approval. Profiles are callable only when the host supports custom-agent invocation, including an `@tag` interface if offered, and are depth 1. A root-permitted depth-1 local orchestrator may create declared depth-2 leaves. Depth 2 executes directly and cannot spawn. Descendants cannot upgrade and must stop and report if their ceilings are insufficient. When capacity is full, do not queue speculative descendants.

The auxiliary-worktree budget starts at zero and is separate from the node budget. Worktrees are not created per agent. Only root may issue a worktree permit or create, adopt, repurpose, move, or remove an auxiliary worktree. Root may authorize one active auxiliary without additional approval; two or more require user approval for the exact count and reasons. Descendants use their exact assigned workspace and report isolation needs upward. Before the final response, root removes each task-created auxiliary under verified safety gates or preserves it with an exact owner, path, branch or HEAD, blocker, and next action. Do not defer task-owned cleanup to scheduled automation. A host-managed active workspace follows the supported host lifecycle.
```

The main agent must verify implementation-relevant claims against primary evidence such as current code, tests, schemas, configuration, logs, build output, typecheck output, runtime behavior, and authoritative external documentation.

When delegating to subagents or coordinating independent threads, pass only relevant reference document names, paths, or sections. Do not dump large documents into prompts unless necessary.

The main agent remains accountable for the final plan, final diff, validation, and final response.

If adding this to an existing `AGENTS.md`, use the heading `## Global Reference Documents and Subagent Support` and include the same content below that heading without duplicating a similar section.

## Create Supporting Files

Use the contents from this repository as the canonical source for:

- `references/README.md`
- `references/model-routing.md`
- `references/subagents.md`
- `references/worktrees.md`
- `references/multi-session-coordination.md`
- `references/reference-doc-routing.md`
- `references/templates/*.md`
- `skills/*/SKILL.md`
- `agents/*.toml`

Preserve the same intent, names, descriptions, and developer instructions. If the installed Codex version uses a different custom-agent schema, adapt only as necessary.

## Validation

After creating or updating files:

1. Print the resulting file tree for `$CODEX_HOME`, `$GLOBAL_REFERENCES_HOME`, `$USER_SKILLS_HOME`, and `$GLOBAL_AGENTS_HOME`.
2. Confirm no repository files were modified.
3. Confirm whether `$CODEX_HOME/AGENTS.override.md` exists and may override `$CODEX_HOME/AGENTS.md`.
4. Validate TOML custom agent files if a TOML parser is available.
5. Confirm every installed custom-agent TOML explicitly defines `model` and `model_reasoning_effort`.
6. Confirm every bundled role has one Terra profile and one Luna profile, and that the model field matches the profile tier.
7. Validate that each `SKILL.md` has frontmatter with `name` and `description`.
8. Confirm `references/model-routing.md`, `references/multi-session-coordination.md`, `references/worktrees.md`, `references/templates/active-work-record.md`, `references/templates/task-graph.md`, `references/templates/worktree-manifest.md`, `skills/task-graph-orchestration/SKILL.md`, `skills/worktree-lifecycle/SKILL.md`, and `skills/multi-session-coordination/SKILL.md` were installed when supported.
9. Report any files backed up.
10. Report any files skipped and why.
11. Report any assumptions.
12. Report whether the small `AGENTS.md` pointer section was created, updated, already present, or skipped.

Final response format:

```text
Summary:
- Created/updated global Codex reference structure.
- Created/updated global skills if supported.
- Created/updated global custom agent definitions if supported.
- Left existing Codex Personalization custom instructions untouched.

Files:
- [list created/updated files]

Verification:
- [checks performed and results]

Notes:
- [backups, skipped files, AGENTS.override.md presence, assumptions, risks]
```
```
