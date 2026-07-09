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

## Content Rules

- Do not include sensitive access material, private local paths, internal-only URLs, or long incident logs.
- Do not hardcode project names, organization-specific workflows, or local machine quirks in global guidance.
- Do not add instructions tied to a specific issue tracker, review tool, package manager, shell, or hosting provider unless the file is explicitly an example or template.
- Prefer terms like "safety", "access control", and "sensitive access material" when public documentation does not need product-specific terminology.
- Keep templates reusable and clearly marked as templates.

## Validation

This repo is mostly Markdown and TOML. Before finalizing meaningful changes:

- Review Markdown headings and fenced code blocks for correctness.
- Confirm TOML files are syntactically valid when a TOML parser is available.
- Confirm each `SKILL.md` has YAML frontmatter with `name` and `description`.
- Confirm links and paths in `README.md` match the repository tree.
- Confirm install docs and scripts reference the current Codex agent files.

## License

This repository is MIT licensed. See `LICENSE`.
