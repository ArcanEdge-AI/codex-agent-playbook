# Install Coding Agent Playbook — Codex Edition

This file is written for both humans and AI coding agents.

The intended experience is:

```text
Install this repo into my Codex setup:
https://github.com/ArcanEdge-AI/coding-agent-playbook-codex

Follow INSTALL.md. Use full install unless I explicitly ask for support-only mode.
Preserve my existing files with backups and report exactly what changed.
```

## What Gets Installed

A full install creates or updates this user-level structure:

```text
$CODEX_HOME/
  AGENTS.md
  .coding-agent-playbook-codex-managed-files.tsv
  references/
    README.md
    model-routing.md
    subagents.md
    worktrees.md
    multi-session-coordination.md
    reference-doc-routing.md
    templates/
      active-work-record.md
      task-graph.md
      worktree-manifest.md
      *.md
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
  subagent-orchestration/SKILL.md
  task-graph-orchestration/SKILL.md
  worktree-lifecycle/SKILL.md
  multi-session-coordination/SKILL.md
  reference-doc-routing/SKILL.md
  senior-code-review/SKILL.md
```

Path resolution:

- `CODEX_HOME`: use `$CODEX_HOME` if set, otherwise `~/.codex`.
- `USER_SKILLS_HOME`: use `$HOME/.agents/skills`.
- On Windows, resolve equivalent user-home paths safely.

## Install Modes

### Full install

Use this for normal installs and every normal update. It is the default when no mode flag is provided.

Full install:

- installs the global coding-agent instructions into `$CODEX_HOME/AGENTS.md`
- copies reference docs into `$CODEX_HOME/references/`
- copies custom agent definitions into `$CODEX_HOME/agents/`
- copies skills into `$HOME/.agents/skills/`

The global instruction body is always installed inside one clearly marked Coding Agent Playbook — Codex Edition section. Existing content outside that section is preserved. Re-running a full install replaces the existing marked section instead of appending a duplicate.

After a successful run, the installer writes `$CODEX_HOME/.coding-agent-playbook-codex-managed-files.tsv` with every managed support-file path and source SHA-256. On later runs, files removed from the repository are backed up and retired only when they still match the previously installed hash. Customized formerly managed files are preserved and reported. Files that were never recorded as playbook-managed are never removed. An existing `.codex-agent-playbook-managed-files.tsv` is migrated automatically after a successful update.

The first manifest-aware update has no previous ownership record, so it safely preserves existing unlisted files. Subsequent updates can distinguish unchanged retired files from user customizations.

### Support-only install

Use this only when the user explicitly requests support-only mode and confirms that the full global instructions already live in Codex Personalization > Custom instructions. Do not infer support-only mode merely because an older installation or an existing `AGENTS.md` is present.

Support-only install:

- does not duplicate the full global instructions into `$CODEX_HOME/AGENTS.md`
- adds only a short reference-map pointer if useful
- still copies reference docs, skills, and custom agent definitions
- still updates the managed-file manifest and safely retires unchanged files removed from later playbook releases

## Human Install

Clone the repository and run the installer for your shell.

### macOS / Linux / WSL

```bash
git clone https://github.com/ArcanEdge-AI/coding-agent-playbook-codex.git
cd coding-agent-playbook-codex
bash install/install.sh --full
```

Support-only mode:

```bash
bash install/install.sh --support-only
```

### Windows PowerShell

```powershell
git clone https://github.com/ArcanEdge-AI/coding-agent-playbook-codex.git
cd coding-agent-playbook-codex
pwsh -ExecutionPolicy Bypass -File install/install.ps1 -Full
```

Support-only mode:

```powershell
pwsh -ExecutionPolicy Bypass -File install/install.ps1 -SupportOnly
```

## Agent Install Instructions

When an AI coding agent is asked to install this repo, it should:

1. Clone or fetch the repository from the provided URL.
2. Read this `INSTALL.md` file first.
3. Resolve `CODEX_HOME` and `USER_SKILLS_HOME`.
4. Inspect existing target files before writing.
5. Back up any existing file before changing it.
6. Use full install for both installation and update unless the user explicitly asks for support-only mode. Existing global instructions, markers, or support files are not permission to change modes.
7. Copy reference docs, skills, and custom agent definitions to the expected user-level locations.
8. Validate the installed files.
9. Report exactly what changed, what was skipped, and where backups were written.

Do not modify arbitrary repositories during installation. Only use a temporary clone of this repository and user-level Codex configuration locations.

## Validation Checklist

After installation, verify:

- `$CODEX_HOME/AGENTS.md` exists or was intentionally left as a pointer-only file.
- `$CODEX_HOME/.coding-agent-playbook-codex-managed-files.tsv` exists and lists every current managed support file once.
- `$CODEX_HOME/references/model-routing.md` exists.
- `$CODEX_HOME/references/subagents.md` exists.
- `$CODEX_HOME/references/worktrees.md` exists.
- `$CODEX_HOME/references/multi-session-coordination.md` exists.
- `$CODEX_HOME/references/reference-doc-routing.md` exists.
- `$CODEX_HOME/references/templates/active-work-record.md` exists.
- `$CODEX_HOME/references/templates/task-graph.md` exists.
- `$CODEX_HOME/references/templates/worktree-manifest.md` exists.
- `$CODEX_HOME/agents/planner.toml` exists.
- `$CODEX_HOME/agents/planner-luna.toml` exists.
- `$CODEX_HOME/agents/engineer.toml` exists.
- `$CODEX_HOME/agents/engineer-luna.toml` exists.
- `$CODEX_HOME/agents/reviewer.toml` exists.
- `$CODEX_HOME/agents/reviewer-luna.toml` exists.
- `$CODEX_HOME/agents/tester.toml` exists.
- `$CODEX_HOME/agents/tester-luna.toml` exists.
- `$CODEX_HOME/agents/docs.toml` exists.
- `$CODEX_HOME/agents/docs-luna.toml` exists.
- Every installed `agents/*.toml` file explicitly defines `model` and `model_reasoning_effort`.
- Every bundled role has one Terra profile and one Luna profile, and each profile's model field matches its tier.
- `$HOME/.agents/skills/subagent-orchestration/SKILL.md` exists.
- `$HOME/.agents/skills/task-graph-orchestration/SKILL.md` exists.
- `$HOME/.agents/skills/worktree-lifecycle/SKILL.md` exists.
- `$HOME/.agents/skills/multi-session-coordination/SKILL.md` exists.
- Each `SKILL.md` has `name` and `description` frontmatter.
- TOML agent files are parseable if a TOML parser is available.
- Every current manifest entry matches its repository source SHA-256.
- Every formerly managed path was either absent, backed up and retired unchanged, or preserved with an explicit customization warning.

## Uninstall

This project does not currently ship an automatic uninstall command.

To remove it manually, delete:

```text
$CODEX_HOME/references/
$CODEX_HOME/.coding-agent-playbook-codex-managed-files.tsv
$CODEX_HOME/agents/planner.toml
$CODEX_HOME/agents/planner-luna.toml
$CODEX_HOME/agents/engineer.toml
$CODEX_HOME/agents/engineer-luna.toml
$CODEX_HOME/agents/reviewer.toml
$CODEX_HOME/agents/reviewer-luna.toml
$CODEX_HOME/agents/tester.toml
$CODEX_HOME/agents/tester-luna.toml
$CODEX_HOME/agents/docs.toml
$CODEX_HOME/agents/docs-luna.toml
$HOME/.agents/skills/subagent-orchestration/
$HOME/.agents/skills/task-graph-orchestration/
$HOME/.agents/skills/worktree-lifecycle/
$HOME/.agents/skills/multi-session-coordination/
$HOME/.agents/skills/reference-doc-routing/
$HOME/.agents/skills/senior-code-review/
```

If you used full install and want to remove the global instructions, edit `$CODEX_HOME/AGENTS.md` and remove the section between the Coding Agent Playbook — Codex Edition start/end markers.
