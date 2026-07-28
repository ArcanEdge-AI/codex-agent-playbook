---
name: subagent-orchestration
description: Use when a coding task may benefit from Codex subagents for planning, engineering, review, testing, or documentation lookup. Enforces task-sized model routing, bounded delegation, and main-agent verification.
---

# Subagent Orchestration Skill

The main agent is the senior developer and orchestrator. Subagents assist but do not own the outcome.

Use this skill when:

- the task is complex, multi-file, risky, or ambiguous
- a Planner could improve the work sequence or validation strategy
- an Engineer can safely handle a bounded implementation slice
- a Reviewer can inspect a diff or design for correctness and risk
- a Tester can analyze failing checks, logs, flakes, or validation gaps
- Docs can verify repository, framework, library, API, or platform behavior

Do not use this skill when:

- the task is trivial
- one coherent design judgment is required
- requirements are materially unclear
- subagents would edit the same files
- the main agent cannot verify the result

## Mandatory Model Routing

Before spawning a subagent, consult `references/model-routing.md` when available.

- Explicitly select a custom agent profile or model for every delegated task when the environment permits it.
- Do not rely on parent-model inheritance for routine subagent work.
- Use the smallest model and lowest reasoning effort likely to complete the bounded task reliably.
- Prefer the installed `gpt-5.6-terra` profiles for supporting work.
- Keep architecture, security-sensitive judgment, destructive operations, migrations, complex concurrency, and other high-impact decisions with the main orchestrator unless a stronger subagent is explicitly justified.
- A subagent must stop and report a capability gap; it must not silently escalate itself or fall back to the main model.
- If a stronger model is selected, record why the smaller configured profile is insufficient and how the result will be independently verified.

## Workflow

1. Clarify the task goal and success criteria.
2. Decide which work, if any, should be delegated.
3. Choose from the Codex roles: Planner, Engineer, Reviewer, Tester, and Docs.
4. Select the smallest suitable custom profile and reasoning effort.
5. Give each subagent a precise assignment:
   - role
   - goal
   - context
   - selected profile or model
   - why it is the smallest suitable choice
   - escalation conditions
   - scope
   - non-goals
   - permissions
   - required evidence
   - output format
6. Wait for delegated results before accepting conclusions.
7. Verify subagent claims against primary evidence.
8. Inspect any changed files yourself.
9. Accept, reject, revise, or rerun with a stronger model only when justified.
10. Report relevant subagent usage and any escalation in the final response.

Never accept a subagent's conclusion solely because it sounds confident.
