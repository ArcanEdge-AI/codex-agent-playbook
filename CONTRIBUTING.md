# Contributing

Thanks for helping improve Coding Agent Playbook — Codex Edition.

This repository is intentionally public and reusable. Contributions should make the playbook clearer, more durable, and less tool-specific.

## What Belongs Here

Good contributions include:

- clearer global coding-agent instructions
- better subagent delegation guidance
- reusable reference document templates
- improved skill definitions
- corrected custom-agent examples
- examples that stay generic and easy to adapt

## What Does Not Belong Here

Avoid adding:

- organization-specific workflows
- private project names
- local machine quirks
- internal URLs
- sensitive access material
- full thread transcripts
- long incident logs
- instructions tied to one tool unless the file is explicitly an example

## Style

- Prefer concise, direct language.
- Keep guidance tool-agnostic unless the file is explicitly tool-specific.
- Prefer behavior and decision rules over rigid command sequences.
- Use examples that are generic and safe for public reuse.
- Keep the main-agent orchestration, actual-root-model ceiling, bounded hierarchy, permit, capability-ceiling, and task-local worktree lifecycle model intact.
- Compare generic policy changes with the companion Claude Code playbook. Align shared behavior or document the concrete harness capability that requires a difference.

## Pull Request Checklist

Before opening a PR:

- Review Markdown formatting and fenced code blocks.
- Confirm links and paths match the repository tree.
- Confirm `SKILL.md` files include `name` and `description` frontmatter.
- Confirm `agents/*.toml` files are syntactically valid and define explicit `model` and `model_reasoning_effort` values if changed.
- Confirm every bundled role retains one Terra profile and one Luna profile, child routes stay within the actual root model and effort ceilings, and smaller profiles retain clear stop conditions.
- Confirm Unix shell scripts remain LF-only.
- Confirm generic policy changes were compared with the companion Claude Code playbook and any intentional divergence names its harness-specific reason.
- Confirm no sensitive or private material was added.

## License

By contributing to this repository, you agree that your contribution will be licensed under the MIT License. See `LICENSE`. Do not change the license without an explicit maintainer decision.
