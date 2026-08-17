---
name: subagent-orchestration
description: Use for every repository task when Codex subagents are available. Makes the main agent the orchestrator, delegates bounded execution by default, enforces dependency-aware decomposition and task-sized model routing, and requires main-agent verification.
---

# Subagent Orchestration Skill

The root main agent is the senior developer and orchestrator. It owns a finite manifest and total spawned-node budget. Where the host supports callable installed profiles, root may select a depth-1 profile through an `@tag` or equivalent programmatic route; this is a host capability statement, not a claim that a picker or callable route was tested. Depth 1 is a direct worker or a permitted local orchestrator. Depth 2 uses an explicitly selected permitted profile/model, executes a strict non-empty subset directly, and never spawns.

Use this skill for every repository task when subagents are available. Select a single bounded execution assignment for simple or linear work. For broader work, dispatch only nodes that satisfy the manifest, permit, budget, and capacity rules below. At the root, direct main-agent execution is allowed only when subagents are unavailable, the user explicitly forbids delegation, or a specific action cannot be delegated because required authority must remain with the main agent. Record the exact exception and limit it to that action.

When multiple independent project threads need conflict detection, ownership, sequencing, or integration guidance, use the `multi-session-coordination` skill instead. Do not spawn additional implementation agents to solve an existing parallel-work conflict.

## Dependency-Aware Delegation

Keep simple tasks simple. For work with multiple delegable parts, define each candidate work node with:

- a node identifier
- one bounded goal
- inputs and authoritative sources
- an output and acceptance condition
- only the upstream nodes that block it from starting
- write ownership or read scope
- a verification gate proportionate to risk

A dependency exists only when a node cannot correctly begin without an accepted upstream artifact or decision. Identify which nodes are safe to run in parallel and which remaining chain of blocking work controls completion.

Dispatch only ready nodes in the finite root manifest that have a root-issued permit, fit within the remaining total node budget, and fit runtime capacity, safety constraints, and verified ownership or isolation. Runtime-full is backpressure: continue ready permitted work or report the constraint; do not queue speculative descendants. Siblings require disjoint ownership.

Use the current workspace by default with an auxiliary-worktree budget of zero. A subagent, node, retry, or depth level does not imply a new checkout. Only the root may issue a separate worktree permit or create, adopt, repurpose, move, or remove a worktree. Root may authorize one active auxiliary without additional approval; two or more require user approval for the exact count and reasons. Descendants receive an exact workspace and report additional isolation needs upward. Consult `references/worktrees.md` whenever an auxiliary worktree is proposed or already task-owned.

While delegated work is running, continue available independent, non-conflicting planning, inspection, integration, or validation work in the main thread. Do not wait solely for a subagent when useful work remains. Do not invent parallel work, exceed runtime limits, or trade evidence and verification for lower latency.

When a formal task graph exists, each delegated assignment must identify its graph node, consume only declared inputs, remain within its declared read scope and write ownership, and return the declared output shape. A subagent may report a hidden dependency or invalid graph assumption, but it must not silently restructure the graph or advance blocked nodes; the main agent owns topology changes and ready-set recalculation.

## Recursive Delegation

Subagents may locally orchestrate only inside their assigned node. A local child must be equal to or narrower than its parent in goal, inputs, data access, permissions, scope, non-goals, write ownership or isolation, authority, and approval boundary. Each child model rank and effort must be at or below its parent's explicit ceilings. Explicitly select each child profile, model, and effort; never silently inherit or escalate. A descendant that cannot complete within its ceilings stops and reports the gap; it must not escalate to a higher-ranked model.

The root alone issues child-specific permits and expands budget. Depth-1 delegation needs a permit and budget; depth-2 is leaf-only. Retry reuses its node ID and permit. A replacement is a new root-routed depth-1 node at any model rank and effort at or below the root task ceilings and consumes a new root permit and budget. It may be stronger than the failed child because it is a new child of root, not a descendant-controlled escalation. Every expansion must record a root reason limited to a newly discovered dependency, an invalidated gate, or changed user scope; a material expansion also requires immediate user approval. Keep payloads to minimum paths and accepted artifacts; reuse accepted outputs and avoid full history, transcripts, and long logs.

## Mandatory Model Routing

Before spawning a subagent, consult `references/model-routing.md` when available.

- Explicitly select a custom agent profile or model for every delegated task when the environment permits it.
- Do not rely on parent-model inheritance for routine subagent work.
- Use the smallest model and lowest reasoning effort likely to complete the bounded task reliably.
- Use the canonical model order `gpt-5.6-sol` rank 3, `gpt-5.6-terra` rank 2, and `gpt-5.6-luna` rank 1. Record the actual user-selected root model; never assume Sol.
- Require every child model rank to be equal to or lower than its parent's rank. Same-tier delegation is valid, and depth does not force a tier drop. Enforce reasoning effort as a separate ceiling.
- With a Sol root, prefer Terra variants for normal bounded work and Luna variants for cheap work with objective acceptance evidence. With a Terra root, use Terra or Luna. With a Luna root, use Luna only.
- Keep architecture, security-sensitive judgment, destructive operations, migrations, complex concurrency, and other high-impact decisions with the main orchestrator. Delegate only bounded evidence gathering for those areas, at or below the delegating parent's explicit model and effort ceiling.
- A subagent must stop and report a capability gap; it must not silently escalate itself or fall back to the main model.
- Only root may create a replacement at a model rank and effort within the root task ceilings, using the already-required new root permit and budget; no descendant may create or request a stronger-model escalation.

## Workflow

1. Clarify the task goal and success criteria.
2. For multi-node work, map bounded nodes, real blocking dependencies, parallel-safe nodes, the completion-controlling path, and required handoff gates.
3. At the root, assign actual execution to at least one bounded subagent when available; record any root direct-execution exception and its exact reason. A depth-1 worker executes directly when no valid, permitted strict-subset split exists. Depth 2 is a leaf and cannot spawn.
4. Choose from the Codex roles: Planner, Engineer, Reviewer, Tester, and Docs.
5. Select the smallest suitable custom profile and reasoning effort.
6. Give each subagent a precise assignment:
   - role
   - goal
   - context
   - lineage and inherited constraints
   - selected profile or model
   - why it is the smallest suitable choice
   - escalation conditions
   - scope
   - non-goals
   - permissions
   - exact assigned workspace and worktree permit ID when applicable
   - local child ownership and sibling non-overlap
   - required evidence
   - output format
   - compact parent return bundle
   - for multi-node work, the node identifier, inputs, output and acceptance condition, blocking dependencies, ownership or read scope, and verification gate
7. Launch only ready manifest nodes that have a root permit, remaining node budget, and runtime, safety, and ownership capacity; serialize real write or mutable-state conflicts unless isolation is verified.
8. Verify subagent claims against primary evidence. For meaningful implementation, use a separate verification task with only the necessary artifact, criteria, and evidence requirements when the runtime supports it; the main agent still decides acceptance.
9. If a gate fails, revise or rerun the failed node and any downstream nodes whose inputs became invalid. Do not restart unrelated nodes by default.
10. Before combining results, confirm every required input passed its designated gate, then inspect the combined diff and run validation for the integrated behavior.
11. Accept, reject, or revise within the existing ceilings. Only root may create a depth-1 replacement at any model rank and effort at or below the root task ceilings, with a new permit and budget; descendants stop and report rather than escalating themselves.
12. Before the final response, remove each task-created auxiliary worktree under the verified cleanup gates or preserve it with its exact owner, path, branch or HEAD, blocker, and next action. Do not defer task-owned cleanup to scheduled automation.
13. Report relevant subagent usage, concurrency decisions, workspace dispositions, and any escalation in the final response.

Never accept a subagent's conclusion solely because it sounds confident.
