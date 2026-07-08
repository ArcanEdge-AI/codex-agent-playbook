---
name: subagent-orchestration
description: Use when a coding task may benefit from subagents for codebase exploration, review, docs research, test triage, or isolated implementation. Helps the main agent delegate bounded work and verify outputs before accepting them.
---

# Subagent Orchestration Skill

The main agent is the senior developer and orchestrator. Subagents assist but do not own the outcome.

Use this skill when:

- the task is complex, multi-file, or ambiguous
- independent read-heavy exploration would help
- review from multiple perspectives would improve quality
- logs, tests, or large files need parallel analysis
- a small isolated implementation can be delegated safely

Do not use this skill when:

- the task is trivial
- one coherent design judgment is required
- requirements are materially unclear
- subagents would edit the same files
- the main agent cannot verify the result

Workflow:

1. Clarify the task goal and success criteria.
2. Decide which work, if any, should be delegated.
3. Prefer read-only subagents for exploration, diagnosis, research, and review.
4. Give each subagent a precise assignment:
   - role
   - goal
   - context
   - scope
   - non-goals
   - permissions
   - required evidence
   - output format
5. Wait for delegated results before accepting conclusions.
6. Verify subagent claims against primary evidence.
7. Inspect any changed files yourself.
8. Accept, reject, or revise subagent recommendations.
9. Report relevant subagent usage in the final response.

Never accept a subagent's conclusion solely because it sounds confident.
