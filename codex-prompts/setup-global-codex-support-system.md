# Prompt: Set Up Global Codex Support System

Paste this prompt into Codex after you have already added the global coding-agent instructions from `custom-instructions/global-coding-agent-instructions.md` to Codex Personalization > Custom instructions.

```markdown
You are configuring my global Codex support system.

Important context:
I have already added my full global coding-agent instructions in Codex Personalization > Custom instructions. Treat that as true even if you cannot inspect the UI.

Do not duplicate those full instructions into `AGENTS.md`.

Your job is to create the supporting global reference system only:

- global reference documents
- reference document routing docs
- subagent delegation docs
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
8. Keep everything tool-agnostic.
9. Do not mention issue-tracker-specific review mechanics, repo-specific workflows, local machine quirks, or project names.
10. Do not ask me questions unless you are blocked. Make reasonable assumptions and report them.

## Desired Global Structure

Create or update this structure:

```text
$CODEX_HOME/
  AGENTS.md
  references/
    README.md
    subagents.md
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
  agents/
    planner.toml
    engineer.toml
    reviewer.toml
    tester.toml
    docs.toml

$HOME/.agents/skills/
  subagent-orchestration/
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
- Add only a small reference section if it is missing.
- If the existing file already appears to duplicate the full UI custom instructions, report that possible duplication but do not delete anything.

If `$CODEX_HOME/AGENTS.override.md` exists:
- Do not modify it.
- Report that it exists because it may override normal AGENTS guidance.

The pointer section should be:

```markdown
# Global Codex Reference Map

The primary global coding-agent behavior is configured in Codex Personalization > Custom instructions.

Supporting global reference documents live under the Codex home references directory:

- `references/README.md` — map of available global reference docs
- `references/subagents.md` — subagent delegation rules, model selection guidance, assignment template, and acceptance checklist
- `references/reference-doc-routing.md` — how to decide which docs to consult and how to treat them
- `references/templates/` — templates for repository-level architecture, testing, security, design-system, release, API, and data-model docs

Custom Codex subagents live under the Codex home agents directory:

- `agents/planner.toml`
- `agents/engineer.toml`
- `agents/reviewer.toml`
- `agents/tester.toml`
- `agents/docs.toml`

Reference documents are supporting context, not automatic truth.

The main agent must verify implementation-relevant claims against primary evidence such as current code, tests, schemas, configuration, logs, build output, typecheck output, runtime behavior, and authoritative external documentation.

When delegating to subagents, the main agent should pass only relevant reference document names, paths, or sections. Do not dump large documents into subagent prompts unless necessary.

The main agent remains accountable for the final plan, final diff, validation, and final response.
```

If adding this to an existing `AGENTS.md`, use the heading `## Global Reference Documents and Subagent Support` and include the same content below that heading without duplicating a similar section.

## Create Supporting Files

Use the contents from this repository as the canonical source for:

- `references/README.md`
- `references/subagents.md`
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
5. Validate that each `SKILL.md` has frontmatter with `name` and `description`.
6. Report any files backed up.
7. Report any files skipped and why.
8. Report any assumptions.
9. Report whether the small `AGENTS.md` pointer section was created, updated, already present, or skipped.

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
