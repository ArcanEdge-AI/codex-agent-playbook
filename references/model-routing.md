# Codex Subagent Model Routing

The parent of each delegated node must explicitly select a profile or model and reasoning effort suited to the assigned task and inherited limits.

This is an execution rule, not a suggestion.

## Why Explicit Routing Is Required

Codex custom-agent fields such as `model` and `model_reasoning_effort` may inherit from the parent session when omitted. That can cause routine subagents to use the parent session's routing rather than an explicit task-appropriate selection.

The installed agent profiles therefore pin explicit default routing. Do not remove those fields without an explicit maintainer decision.

## Canonical Model-Tier Ceiling

Use this ordered routing policy for Codex 5.6 models:

| Rank | Model | Intended use |
| --- | --- | --- |
| 3 | `gpt-5.6-sol` | Root orchestration and exceptional bounded work that needs frontier reasoning. |
| 2 | `gpt-5.6-terra` | Normal bounded planning, implementation, review, testing, and documentation work. |
| 1 | `gpt-5.6-luna` | Mechanical, low-risk, read-only, or otherwise easily verified work. |

The user-selected main-session model establishes the root ceiling. Record the actual root model; never assume it is `gpt-5.6-sol`. Every child's selected model rank must be equal to or lower than its parent's rank. Equal-tier delegation is allowed. Depth controls authority and spawning, not model strength, so do not require a one-tier drop at each depth.

Treat reasoning effort as a separate ceiling. A child must satisfy both `child model rank <= parent model rank` and `child reasoning effort <= parent reasoning-effort ceiling`.

Default routing by known root model:

| Root model | Permitted descendant models | Default approach |
| --- | --- | --- |
| `gpt-5.6-sol` | Sol, Terra, or Luna | Prefer Terra for normal bounded work and Luna for cheap, objective work. Use a Sol child only for an exceptional bounded task with a recorded justification. |
| `gpt-5.6-terra` | Terra or Luna | Use Terra when the task needs it and Luna when acceptance is objective and cheap to verify. Never use Sol. |
| `gpt-5.6-luna` | Luna only | Keep every descendant on Luna. If Luna is insufficient, stop and report rather than upgrading. |

This ordering is a routing and cost-control policy, not a claim that one model is best for every task. If the root model or a requested model is unknown, unavailable, or cannot be selected explicitly, do not infer a rank or silently substitute another model. Use the exact known parent model when it can be selected explicitly, keep the work with the parent, or report the routing constraint.

## Default Profiles

| Profile | Model | Reasoning | Intended work |
| --- | --- | --- | --- |
| `docs` | `gpt-5.6-terra` | low | Focused documentation lookup and source extraction. |
| `docs_luna` | `gpt-5.6-luna` | low | Cheap, tightly scoped documentation lookup with objective source evidence. |
| `planner` | `gpt-5.6-terra` | medium | Bounded planning whose architecture decisions remain with the main agent. |
| `planner_luna` | `gpt-5.6-luna` | medium | Small planning decompositions with explicit inputs and an easy parent review. |
| `engineer` | `gpt-5.6-terra` | medium | Small, isolated, well-specified implementation. |
| `engineer_luna` | `gpt-5.6-luna` | medium | Mechanical, isolated implementation with objective acceptance checks. |
| `tester` | `gpt-5.6-terra` | medium | Targeted reproduction, log analysis, and test-gap identification. |
| `tester_luna` | `gpt-5.6-luna` | medium | Deterministic test execution or simple log and result summarization. |
| `reviewer` | `gpt-5.6-terra` | high | Evidence-backed review with escalation for high-impact judgment. |
| `reviewer_luna` | `gpt-5.6-luna` | high | Narrow checklist review where findings can be checked directly. |

These are supporting agents. The main orchestrator retains architecture ownership and final judgment.

The bundle does not add Sol variants for every role. Sol normally remains the root orchestrator. If an exceptional bounded Sol child is justified, use an explicit host-supported model route; otherwise keep that work with the Sol parent.

## Selection Rules

Before spawning a subagent:

1. At root depth 0, record the actual root model and reasoning-effort ceilings and maintain a finite task manifest and total spawned-node budget that count every depth-1 and depth-2 node. A depth-1 child is a direct worker or local orchestrator that normally uses an installed/callable custom Codex role in its eligible Terra or Luna variant, selected by the root through an `@` tag or equivalent programmatic routing. An exceptional bounded Sol child may instead use an explicit host-supported model route within the root ceilings when the root records the justification. A depth-2 child is a direct-execution leaf that may not spawn and uses an explicitly selected permitted profile or model; do not create depth-3 work. This routing contract does not claim that a UI tag picker has been runtime smoke-tested. Only the root may issue child permits or expand that budget.
2. At the root, treat subagent execution as required for every repository task. Use direct main-agent execution only when subagents are unavailable, the user explicitly forbids delegation, or a specific authority-bound action cannot be delegated; record the exact exception and limit it to that action.
3. Give every child a root-issued permit, parent ID, child ID, a non-empty strict completion subset, declared ownership or read scope, explicitly selected model and effort, parent model rank and effort ceiling, child-at-or-below-parent proof, and acceptance condition. Require disjoint sibling write ownership.
4. Confirm the child is equal to or narrower than its parent in inputs, data access, permissions, scope, non-goals, authority, and approval boundary; that its completion subset is strictly smaller than the parent's remaining subset; and that both its model rank and effort do not exceed its parent's explicit ceilings.
5. Choose the role that matches the task, then choose the smallest eligible model tier likely to pass its acceptance condition without avoidable retries.
6. Explicitly select the profile, model, and effort; do not use parent-model inheritance.
7. State why the selected profile is sufficient.
8. Define the conditions that require stopping and escalation.
9. Define how the parent will independently verify the result and return compact lineage and evidence upward.

When runtime capacity is full, execute current ready work and do not create speculative descendants. Retry with the existing node ID and permit. A replacement requires a new root-issued permit and consumes budget. Every root manifest or budget expansion requires a documented root reason limited to a newly discovered dependency, invalidated gate, or changed user scope; material execution cost additionally requires user approval immediately before issuing the added nodes or permits.

When two variants of a role appear suitable, prefer Luna only when the work is bounded and objectively verifiable; otherwise use Terra when the parent ceiling permits it. Do not force a downgrade merely because a node is deeper in the delegation tree.

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

No descendant may silently change models, request a higher-ranked model, fall back to a stronger parent model, or exceed its parent's explicit model-rank or effort ceiling. If the ceiling is insufficient, the descendant must stop and report upward.

The root may route a new depth-1 replacement at any model rank and effort at or below the root task ceilings. The replacement may be stronger than the failed child because it is a new child of the root, not a descendant-controlled escalation. It consumes a new root-issued permit and budget and requires a documented reason and verification plan. No descendant may request or perform that replacement. The root main agent retains authority for root-level routing, approval-bound changes, and any change that would exceed inherited constraints.

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
Parent model rank / selected child model rank and proof:
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
- the actual root model was recorded rather than assumed
- the selected child model rank and effort are at or below the parent's explicit ceilings
- the root-issued permit, parent/child IDs, and manifest budget are recorded
- the completion subset is non-empty and strictly smaller than the parent's remaining subset
- sibling write ownership is disjoint
- the subagent used its exact assigned workspace and did not create, repurpose, move, or remove a worktree
- the stated acceptance condition passed
- any root-routed new depth-1 replacement stayed within the root task model-rank and effort ceilings, consumed a new permit and budget, and has documented reason and verification evidence
- the subagent stayed within scope
- claims are supported by primary evidence
- the main agent independently reviewed material findings and edits
