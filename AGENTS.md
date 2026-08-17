# Repository Coding Agent Instructions

This repository is a public playbook for Codex custom instructions, reference documents, skills, and custom subagent definitions.

Repository-specific guidance overrides the global instructions where it is more specific.

## Repository Goals

- Keep the playbook useful for many teams and codebases.
- Keep global guidance tool-agnostic and durable.
- Keep repository-specific, machine-specific, and workflow-specific details out of global instructions.
- Prefer concise, practical guidance over long theory.
- Make the main agent accountable for planning, delegation, validation, and final reporting.
- Keep the Codex subagent model aligned around `planner`, `engineer`, `reviewer`, `tester`, and `docs`.
- Keep every custom subagent pinned to an explicit task-appropriate model and reasoning effort so it does not inherit the main session model unintentionally.
- Keep the canonical Codex model order explicit: `gpt-5.6-sol` rank 3, `gpt-5.6-terra` rank 2, and `gpt-5.6-luna` rank 1. Treat the selected main-session model as the root ceiling rather than assuming Sol.
- Keep role and tier separate: every bundled role has a Terra variant and a Luna variant; equal-tier delegation is allowed, and no child may exceed its parent's model rank or reasoning-effort ceiling.

## Content Rules

- Do not include sensitive access material, private local paths, internal-only URLs, full thread transcripts, or long incident logs.
- Do not hardcode project names, organization-specific workflows, or local machine quirks in global guidance.
- Do not add instructions tied to a specific issue tracker, review tool, package manager, shell, or hosting provider unless the file is explicitly an example or template.
- Use Codex terminology, paths, TOML agent schemas, model identifiers, reasoning-effort fields, and thread concepts in Codex-specific files.
- Do not copy configuration paths, file names, agent formats, model identifiers, or command vocabulary from another coding-agent environment into this repository.
- Prefer terms like "safety", "access control", and "sensitive access material" when public documentation does not need product-specific terminology.
- Keep templates reusable and clearly marked as templates.
- Keep generic behavioral policy aligned with the companion Claude Code playbook. When a difference is intentional, document the concrete harness capability that requires it instead of preserving unexplained drift.

## Validation

This repo is mostly Markdown and TOML. Before finalizing meaningful changes:

- Review Markdown headings and fenced code blocks for correctness.
- Confirm TOML files are syntactically valid when a TOML parser is available.
- Confirm every `agents/*.toml` file explicitly defines `model` and `model_reasoning_effort`.
- Confirm every bundled role has exactly one Terra profile and one Luna profile and that no profile exceeds the canonical tier declared by its filename and model field.
- Confirm smaller-model profiles include clear stop and escalation conditions.
- Confirm each `SKILL.md` has YAML frontmatter with `name` and `description`.
- Confirm links and paths in `README.md` match the repository tree.
- Confirm install docs and scripts reference the current Codex agent files.
- Confirm PowerShell and Bash installers default normal installs and updates to full mode, create a marked global section on first install, maintain the managed-file manifest, retire only unchanged formerly managed files, and preserve customized or unrelated files.
- Confirm installer validation lists include `references/worktrees.md`, `references/templates/worktree-manifest.md`, and `skills/worktree-lifecycle/SKILL.md`.
- Compare generic policy changes with the companion Claude Code playbook and either align them or record the concrete harness-specific reason for divergence.
- Search the final diff for paths, schemas, model names, and commands that belong to another coding-agent environment; remove any accidental contamination before merging.

## License

This repository is MIT licensed. See `LICENSE`. Do not change the license without an explicit maintainer decision.
