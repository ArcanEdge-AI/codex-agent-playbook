<p align="center">
  <img src="./assets/codex-agent-playbook-hero.svg" alt="Codex Agent Playbook hero banner" width="100%" />
</p>

<h1 align="center">Codex Agent Playbook</h1>

<p align="center">
  <strong>Custom instructions, subagents, skills, and reference docs for production-grade AI coding agents.</strong>
</p>

<p align="center">
  Configure Codex to behave less like a loose autocomplete engine and more like a disciplined senior engineer: plan clearly, change surgically, delegate carefully, verify honestly, and ship maintainable code.
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> ·
  <a href="#why-this-exists">Why This Exists</a> ·
  <a href="#whats-inside">What's Inside</a> ·
  <a href="#subagent-model">Subagent Model</a> ·
  <a href="#repository-structure">Structure</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Codex-Playbook-6E7BFF" alt="Codex Playbook" />
  <img src="https://img.shields.io/badge/Subagents-Orchestrated-00C2FF" alt="Subagents Orchestrated" />
  <img src="https://img.shields.io/badge/Instructions-Tool--Agnostic-8A5CFF" alt="Tool Agnostic" />
  <img src="https://img.shields.io/badge/Status-Active-2ECC71" alt="Status Active" />
</p>

---

## Quick Start

Use this repo in two passes: first configure the main agent, then install the support system around it.

### 1. Add the global instructions

Copy this file into **Codex Personalization → Custom instructions**:

```text
custom-instructions/global-coding-agent-instructions.md
```

Those instructions teach the main agent to behave like a senior developer: understand before editing, plan non-trivial work, make surgical changes, validate honestly, and review its own work before final response.

### 2. Install the support system

Open this prompt and run it in Codex:

```text
codex-prompts/setup-global-codex-support-system.md
```

That prompt creates a global support layer for reference docs, reusable skills, and custom subagents while avoiding duplicate global instructions.

### 3. Add repo-specific guidance

Copy this template into individual projects as a starting point:

```text
references/templates/repository-AGENTS.md
```

Then fill in the actual build commands, test commands, architecture rules, generated-file rules, and release expectations for that repository.

---

## Why This Exists

AI coding agents are powerful, but they often fail in predictable ways:

- They start coding before understanding the codebase.
- They over-engineer simple requests.
- They refactor unrelated code.
- They trust editor diagnostics over real builds.
- They claim tests passed when they did not run them.
- They delegate poorly or blindly accept subagent output.
- They turn every task into a context dump instead of a focused engineering loop.

This playbook gives Codex a durable operating model:

```text
Understand → Plan → Implement → Verify → Review → Report
```

The intent is not to make the agent slower for its own sake. The intent is to make it **less wrong**, especially on real repositories with existing conventions and local changes.

---

## What's Inside

| Area | Path | Purpose |
| --- | --- | --- |
| Global instructions | `custom-instructions/` | Tool-agnostic behavior rules for elegant, maintainable code. |
| Setup prompt | `codex-prompts/` | Prompt for creating user-level references, skills, and subagents. |
| Reference docs | `references/` | Routing, subagent delegation, and reusable project-doc templates. |
| Skills | `skills/` | Reusable workflows for orchestration, doc routing, and senior review. |
| Custom agents | `agents/` | Example subagent definitions for exploration, review, research, triage, and isolated implementation. |
| Repo guidance | `AGENTS.md` | Instructions for maintaining this public playbook repository. |

---

## Core Philosophy

The main agent is the senior engineer and orchestrator.

It owns:

- task understanding
- the working plan
- architecture and design judgment
- delegation decisions
- final implementation
- final diff
- validation strategy
- final response

Subagents can help, but they do not own the outcome. Their job is to return bounded findings with evidence. The main agent must verify before accepting.

> Use subagents when they create leverage. Do not use them just because they are available.

---

## Subagent Model

This playbook treats subagents like focused engineering assistants, not autonomous owners.

| Subagent | Default mode | Best for |
| --- | --- | --- |
| `read_only_explorer` | Read-only | Mapping code paths, call sites, ownership boundaries, and insertion points. |
| `senior_reviewer` | Read-only | Reviewing diffs for correctness, regressions, scope creep, maintainability, safety, performance, and accessibility. |
| `docs_researcher` | Read-only | Checking framework, library, API, or platform behavior against authoritative docs. |
| `test_triager` | Read-mostly | Analyzing failing tests, logs, flakes, snapshots, and likely root causes. |
| `isolated_worker` | Bounded write | Implementing small isolated changes after scope and design are clear. |

The delegation rule is simple:

```text
Precise assignment → Evidence-backed output → Main-agent verification → Accept or reject
```

A good subagent prompt includes role, goal, context, scope, non-goals, permissions, required evidence, output format, and stop conditions.

---

## Reference Docs Without Context Soup

Large documents are useful only when routed correctly.

The main agent should:

1. Identify which docs matter for the task.
2. Read only relevant sections when possible.
3. Classify docs as authoritative, advisory, or historical.
4. Pass only relevant context to subagents.
5. Resolve conflicts using primary evidence.

Primary evidence includes current code, tests, schemas, configuration, logs, build output, typecheck output, runtime behavior, and authoritative external documentation.

See:

```text
references/reference-doc-routing.md
references/subagents.md
```

---

## Repository Structure

```text
.
├── AGENTS.md
├── CONTRIBUTING.md
├── README.md
├── assets/
│   └── codex-agent-playbook-hero.svg
├── agents/
│   ├── docs-researcher.toml
│   ├── isolated-worker.toml
│   ├── read-only-explorer.toml
│   ├── senior-reviewer.toml
│   └── test-triager.toml
├── codex-prompts/
│   └── setup-global-codex-support-system.md
├── custom-instructions/
│   └── global-coding-agent-instructions.md
├── references/
│   ├── README.md
│   ├── reference-doc-routing.md
│   ├── subagents.md
│   └── templates/
│       ├── api-contracts.md
│       ├── architecture.md
│       ├── data-model.md
│       ├── design-system.md
│       ├── release.md
│       ├── repository-AGENTS.md
│       ├── security.md
│       └── testing.md
└── skills/
    ├── reference-doc-routing/
    │   └── SKILL.md
    ├── senior-code-review/
    │   └── SKILL.md
    └── subagent-orchestration/
        └── SKILL.md
```

---

## Example: Better Delegation

Bad delegation:

```text
Look into this and fix it.
```

Better delegation:

```text
Role:
You are a read-only explorer.

Goal:
Find where checkout tax is calculated and identify the smallest safe insertion point for a customer exemption flag.

Scope:
Inspect checkout, cart, customer, and tax calculation code paths only.

Non-goals:
Do not edit files. Do not refactor. Do not propose a new tax engine.

Evidence required:
Return file paths, function names, call chain, relevant tests, and existing exemption concepts.
```

The main agent still decides the design, applies or rejects recommendations, and verifies the final diff.

---

## Recommended Workflow

```text
1. Paste the global custom instructions into Codex.
2. Run the setup prompt to install references, skills, and subagent definitions.
3. Add repo-specific AGENTS.md guidance to each project.
4. For non-trivial work, let the main agent plan first.
5. Delegate only bounded work with clear evidence requirements.
6. Verify the final diff before accepting completion.
```

---

## Public Repo Notes

This repository is public so others can star it, fork it, adapt it, and propose improvements.

Please keep contributions generic, reusable, and safe for public use. Do not add private project details, internal URLs, sensitive access material, local machine quirks, or one-off incident logs.

See `CONTRIBUTING.md` for contribution guidance.

---

## License

No license has been selected yet.

If you want others to freely use and fork this playbook, choose an explicit license. MIT is a common default for permissive open-source documentation and examples, but the repository owner should make that decision intentionally.

---

## Status

This is a living playbook. Treat it as a strong baseline, not a universal law.

The best setup is:

```text
Global behavior + local repository truth + evidence-backed validation
```
