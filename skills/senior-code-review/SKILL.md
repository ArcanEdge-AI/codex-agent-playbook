---
name: senior-code-review
description: Use before finalizing a meaningful code change. Reviews the final diff for correctness, scope control, maintainability, validation gaps, safety risk, performance risk, accessibility risk, and subagent claims that still need verification.
---

# Senior Code Review Skill

Use this skill before finalizing meaningful code changes.

Review the final diff for:

- unrelated changes
- accidental formatting churn
- generated, vendored, compiled, or package-owned files
- missing or weak validation
- unused imports, variables, types, functions, or files caused by the change
- naming clarity
- consistency with existing patterns
- over-abstraction
- speculative configurability
- behavior changes beyond the request
- API compatibility
- migration risk
- safety risk
- performance risk
- accessibility regressions
- subagent claims that were not independently verified

Ask:

```text
Would I approve this in code review?
```

If not, fix the issue or report the remaining risk clearly.

Final report format:

```text
Summary:
- Changed X to do Y.

Verification:
- Ran: [command or check]
- Result: [passed/failed/not run, with reason]

Notes:
- [Assumptions, unrelated issues, subagent usage, follow-ups, or risk notes if any]
```
