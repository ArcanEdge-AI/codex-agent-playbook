# Codex Subagent Model Routing

The main agent must explicitly route each delegated task to the smallest model and lowest reasoning effort likely to complete it reliably.

This is an execution rule, not a suggestion.

## Why Explicit Routing Is Required

Codex custom-agent fields such as `model` and `model_reasoning_effort` may inherit from the parent session when omitted. That can cause routine subagents to use the same expensive model as the main orchestrator.

The installed agent profiles therefore pin a smaller model by default. Do not remove those fields without an explicit maintainer decision.

## Default Profiles

| Profile | Model | Reasoning | Intended work |
| --- | --- | --- | --- |
| `docs` | `gpt-5.6-terra` | low | Focused documentation lookup and source extraction. |
| `planner` | `gpt-5.6-terra` | medium | Bounded planning whose architecture decisions remain with the main agent. |
| `engineer` | `gpt-5.6-terra` | medium | Small, isolated, well-specified implementation. |
| `tester` | `gpt-5.6-terra` | medium | Targeted reproduction, log analysis, and test-gap identification. |
| `reviewer` | `gpt-5.6-terra` | high | Evidence-backed review with escalation for high-impact judgment. |

These are supporting agents. The main orchestrator retains architecture ownership and final judgment.

## Selection Rules

Before spawning a subagent:

1. Confirm delegation creates real leverage.
2. Bound the goal, scope, permissions, and evidence requirements.
3. Choose the profile whose role most closely matches the task.
4. Use the configured smaller model instead of parent-model inheritance.
5. State why the selected profile is sufficient.
6. Define the conditions that require stopping and escalation.
7. Define how the main agent will independently verify the result.

When two profiles appear suitable, choose the cheaper or more constrained one.

## Keep With the Main Agent

Do not delegate final ownership of:

- architecture and system design
- security-sensitive or access-control decisions
- authentication, authorization, privacy, payments, or billing
- destructive operations
- data migrations or persisted-schema strategy
- concurrency, locking, queues, caching, or background-job design
- public API compatibility
- release or production-impacting configuration
- large or high-impact refactors
- final acceptance of meaningful changes

A smaller subagent may gather evidence for these areas, but the main agent must make and verify the decision.

## Escalation

A subagent must stop and report when:

- requirements are materially ambiguous
- primary evidence conflicts
- the task exceeds its assigned scope
- the conclusion cannot be independently verified
- the work becomes security-sensitive, destructive, or production-impacting
- the task requires architectural or cross-system judgment

The subagent must not silently change models, request a stronger model, or fall back to the parent model.

The main agent may rerun a narrowed task with a stronger model only after documenting:

- why the configured smaller profile was insufficient
- why narrowing or supplying more context did not solve the problem
- what evidence the stronger agent must return
- how the result will be independently checked

## Required Assignment Fields

```text
Role:
Selected profile or model:
Reasoning effort:
Why this is the smallest suitable choice:
Goal:
Context:
Scope:
Non-goals:
Permissions:
Evidence required:
Escalation conditions:
Output format:
```

## Acceptance Check

Before accepting delegated work, confirm:

- the model or profile was explicitly selected
- parent-model inheritance was not used unintentionally
- any stronger-model escalation was justified
- the subagent stayed within scope
- claims are supported by primary evidence
- the main agent independently reviewed material findings and edits
