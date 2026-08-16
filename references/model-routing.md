# Codex Subagent Model Routing

The parent of each delegated node must explicitly select a profile or model and reasoning effort suited to the assigned task and inherited limits.

This is an execution rule, not a suggestion.

## Why Explicit Routing Is Required

Codex custom-agent fields such as `model` and `model_reasoning_effort` may inherit from the parent session when omitted. That can cause routine subagents to use the parent session's routing rather than an explicit task-appropriate selection.

The installed agent profiles therefore pin explicit default routing. Do not remove those fields without an explicit maintainer decision.

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

1. At root depth 0, maintain a finite task manifest and total spawned-node budget that count every depth-1 and depth-2 node. A depth-1 child is a direct worker or local orchestrator using an installed/callable custom Codex profile (`planner`, `engineer`, `reviewer`, `tester`, or `docs`) selected by the root through an `@` tag or equivalent programmatic routing. A depth-2 child is a direct-execution leaf that may not spawn and uses an explicitly selected permitted profile or model; do not create depth-3 work. This routing contract does not claim that a UI tag picker has been runtime smoke-tested. Only the root may issue child permits or expand that budget.
2. At the root, treat subagent execution as required for every repository task. Use direct main-agent execution only when subagents are unavailable, the user explicitly forbids delegation, or a specific authority-bound action cannot be delegated; record the exact exception and limit it to that action.
3. Give every child a root-issued permit, parent ID, child ID, a non-empty strict completion subset, declared ownership or read scope, explicitly selected model and effort at or below its parent's explicit ceiling, and acceptance condition. Require disjoint sibling write ownership.
4. Confirm the child is equal to or narrower than its parent in inputs, data access, permissions, scope, non-goals, authority, and approval boundary; that its completion subset is strictly smaller than the parent's remaining subset; and that its model and effort do not exceed the parent's explicit ceiling.
5. Choose the profile whose role most closely matches the task.
6. Explicitly select the profile, model, and effort; do not use parent-model inheritance.
7. State why the selected profile is sufficient.
8. Define the conditions that require stopping and escalation.
9. Define how the parent will independently verify the result and return compact lineage and evidence upward.

When runtime capacity is full, execute current ready work and do not create speculative descendants. Retry with the existing node ID and permit. A replacement requires a new root-issued permit and consumes budget. Every root manifest or budget expansion requires a documented root reason limited to a newly discovered dependency, invalidated gate, or changed user scope; material execution cost additionally requires user approval immediately before issuing the added nodes or permits.

When two profiles appear suitable, choose the one whose explicit routing best fits the task while remaining within inherited limits.

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

A subagent may gather evidence for these areas, but the main agent must make and verify the decision.

## Escalation

A subagent must stop and report when:

- requirements are materially ambiguous
- primary evidence conflicts
- the task exceeds its assigned scope
- the conclusion cannot be independently verified
- the work becomes security-sensitive, destructive, or production-impacting
- the task requires architectural or cross-system judgment

No descendant may silently change models, request a stronger model, fall back to the parent model, or exceed its parent's explicit model or effort ceiling. If the ceiling is insufficient, the descendant must stop and report upward.

The only permitted routing change is a root-routed new depth-1 same-tier replacement within the root task ceiling. It consumes a new root-issued permit and budget and requires a documented reason and verification plan. No descendant may request or perform that replacement; it is never descendant escalation. The root main agent retains authority for root-level routing, approval-bound changes, and any escalation that would exceed inherited constraints.

## Required Assignment Fields

```text
Role:
Selected profile or model:
Reasoning effort:
Why this selection is suitable:
Goal:
Context:
Lineage and inherited constraints:
Parent ID / child ID:
Completion subset:
Parent explicit model / effort ceiling:
Scope:
Non-goals:
Permissions:
Root-issued permit ID and manifest budget status:
Declared ownership or read scope and sibling non-overlap:
Exact assigned workspace and worktree permit ID when applicable:
Acceptance condition:
Evidence required:
Escalation conditions:
Output format:
Parent return bundle:
```

## Acceptance Check

Before accepting delegated work, confirm:

- the model or profile was explicitly selected
- parent-model inheritance was not used unintentionally
- the selected model and effort are at or below the parent's explicit ceiling
- the root-issued permit, parent/child IDs, and manifest budget are recorded
- the completion subset is non-empty and strictly smaller than the parent's remaining subset
- sibling write ownership is disjoint
- the subagent used its exact assigned workspace and did not create, repurpose, move, or remove a worktree
- the stated acceptance condition passed
- any root-routed new depth-1 same-tier replacement stayed within the root task ceiling, consumed a new permit and budget, and has documented reason and verification evidence
- the subagent stayed within scope
- claims are supported by primary evidence
- the main agent independently reviewed material findings and edits
