# Install Codex Agent Playbook

This file is written for both humans and AI coding agents.

The intended experience is:

```text
Install this repo into my Codex setup:
https://github.com/ArcanEdge-AI/codex-agent-playbook

Follow INSTALL.md. Use full install unless I explicitly ask for support-only mode.
Preserve my existing files with backups and report exactly what changed.
```

## What Gets Installed

A full install creates or updates this user-level structure:

```text
$CODEX_HOME/
  AGENTS.md
  references/
    README.md
    subagents.md
    reference-doc-routing.md
    templates/*.md
  agents/
    read-only-explorer.toml
    senior-reviewer.toml
    docs-researcher.toml
    test-triager.toml
    isolated-worker.toml

$HOME/.agents/skills/
  subagent-orchestration/SKILL.md
  reference-doc-routing/SKILL.md
  senior-code-review/SKILL.md
```

Path resolution:

- `CODEX_HOME`: use `$CODEX_HOME` if set, otherwise `~/.codex`.
- `USER_SKILLS_HOME`: use `$HOME/.agents/skills`.
- On Windows, resolve equivalent user-home paths safely.

## Install Modes

### Full install

Use this for most users.

Full install:

- installs the global coding-agent instructions into `$CODEX_HOME/AGENTS.md`
- copies reference docs into `$CODEX_HOME/references/`
- copies custom agent definitions into `$CODEX_HOME/agents/`
- copies skills into `$HOME/.agents/skills/`

If `$CODEX_HOME/AGENTS.md` already exists, preserve it and append a clearly marked Codex Agent Playbook section unless the section is already present.

### Support-only install

Use this when the user already pasted the global instructions into Codex Personalization > Custom instructions.

Support-only install:

- does not duplicate the full global instructions into `$CODEX_HOME/AGENTS.md`
- adds only a short reference-map pointer if useful
- still copies reference docs, skills, and custom agent definitions

## Human Install

Clone the repository and run the installer for your shell.

### macOS / Linux / WSL

```bash
git clone https://github.com/ArcanEdge-AI/codex-agent-playbook.git
cd codex-agent-playbook
bash install/install.sh --full
```

Support-only mode:

```bash
bash install/install.sh --support-only
```

### Windows PowerShell

```powershell
git clone https://github.com/ArcanEdge-AI/codex-agent-playbook.git
cd codex-agent-playbook
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
6. Use full install unless the user explicitly asks for support-only mode or the user clearly states the global instructions already live in Codex Personalization.
7. Copy reference docs, skills, and custom agent definitions to the expected user-level locations.
8. Validate the installed files.
9. Report exactly what changed, what was skipped, and where backups were written.

Do not modify arbitrary repositories during installation. Only use a temporary clone of this repository and user-level Codex configuration locations.

## Validation Checklist

After installation, verify:

- `$CODEX_HOME/AGENTS.md` exists or was intentionally left as a pointer-only file.
- `$CODEX_HOME/references/subagents.md` exists.
- `$CODEX_HOME/references/reference-doc-routing.md` exists.
- `$CODEX_HOME/agents/read-only-explorer.toml` exists.
- `$HOME/.agents/skills/subagent-orchestration/SKILL.md` exists.
- Each `SKILL.md` has `name` and `description` frontmatter.
- TOML agent files are parseable if a TOML parser is available.

## Uninstall

This project does not currently ship an automatic uninstall command.

To remove it manually, delete:

```text
$CODEX_HOME/references/
$CODEX_HOME/agents/read-only-explorer.toml
$CODEX_HOME/agents/senior-reviewer.toml
$CODEX_HOME/agents/docs-researcher.toml
$CODEX_HOME/agents/test-triager.toml
$CODEX_HOME/agents/isolated-worker.toml
$HOME/.agents/skills/subagent-orchestration/
$HOME/.agents/skills/reference-doc-routing/
$HOME/.agents/skills/senior-code-review/
```

If you used full install and want to remove the global instructions, edit `$CODEX_HOME/AGENTS.md` and remove the section between the Codex Agent Playbook start/end markers.
