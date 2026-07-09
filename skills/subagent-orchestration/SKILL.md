---
name: subagent-orchestration
description: Use when a coding task may benefit from Codex subagents for planning, engineering, review, testing, or documentation lookup. Helps the main agent delegate bounded work and verify outputs before accepting them.
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

Workflow:

1. Clarify the task goal and success criteria.
2. Decide which work, if any, should be delegated.
3. Choose from the Codex roles: Planner, Engineer, Reviewer, Tester, and Docs.
4. Right-size the model when model selection is available:
   - use cheaper or faster models for bounded, low-risk, easily verifiable work
   - use stronger reasoning for planning, implementation strategy, meaningful review, ambiguous debugging, security-sensitive work, and high-impact changes
5. Give each subagent a precise assignment:
   - role
   - goal
   - context
   - model / reasoning guidance
   - scope
   - non-goals
   - permissions
   - required evidence
   - output format
6. Wait for delegated results before accepting conclusions.
7. Verify subagent claims against primary evidence.
8. Inspect any changed files yourself.
9. Accept, reject, or revise subagent recommendations.
10. Report relevant subagent usage in the final response.

Never accept a subagent's conclusion solely because it sounds confident.
