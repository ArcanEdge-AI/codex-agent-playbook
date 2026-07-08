# Codex Agent Playbook

A public playbook for configuring Codex as a disciplined senior-engineer coding agent: tool-agnostic custom instructions, reference documents, reusable skills, and custom subagent definitions.

The goal is simple: help the main Codex agent produce elegant, maintainable code while using subagents responsibly instead of turning work into context soup or committee coding.

## What is included

```text
custom-instructions/
  global-coding-agent-instructions.md

codex-prompts/
  setup-global-codex-support-system.md

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

skills/
  subagent-orchestration/SKILL.md
  reference-doc-routing/SKILL.md
  senior-code-review/SKILL.md

agents/
  read-only-explorer.toml
  senior-reviewer.toml
  docs-researcher.toml
  test-triager.toml
  isolated-worker.toml
```

## Recommended use

1. Start with `custom-instructions/global-coding-agent-instructions.md` and paste it into Codex Personalization > Custom instructions.
2. Use `codex-prompts/setup-global-codex-support-system.md` to ask Codex to install the reference docs, skills, and custom agents into your user-level Codex configuration.
3. Copy `references/templates/repository-AGENTS.md` into individual repositories as a starting point for repo-specific `AGENTS.md` guidance.
4. Keep the global instructions tool-agnostic. Put repo-specific commands, release procedures, shell quirks, and project rules in repository docs or skills instead.

## Core philosophy

The main agent should act as the senior developer and orchestrator. It owns the plan, architecture, final diff, validation, and final response.

Subagents are useful, but only when they create real leverage: exploration, review, research, test triage, reproduction, and small isolated implementation tasks. The main agent should give subagents precise assignments and verify their work before accepting it.

## Public repo note

This repository is public so people can star it, fork it, and adapt the playbook. Before promoting broad reuse, choose and add an explicit license.

## Status

This is a living playbook. Treat it as a strong baseline, not a universal law. The best setup is global guidance plus local repository instructions that reflect the actual codebase.
