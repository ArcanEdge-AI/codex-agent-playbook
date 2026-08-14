---
name: subagent-orchestration
description: Use when a coding task may benefit from Codex subagents for planning, engineering, review, testing, or documentation lookup. Enforces dependency-aware decomposition, task-sized model routing, bounded delegation, and main-agent verification.
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
- multiple independent Codex threads are already implementing related work

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

Run independent nodes concurrently only when the runtime can isolate them, their writes and mutable state do not conflict, and the coordination cost is justified. State a concurrency limit and rationale instead of assuming unlimited fan-out. Serialize overlapping writers unless verified isolation is available.

While delegated work is running, continue available independent, non-conflicting planning, inspection, integration, or validation work in the main thread. Do not wait solely for a subagent when useful work remains. Do not invent parallel work, exceed runtime limits, or trade evidence and verification for lower latency.

When a formal task graph exists, each delegated assignment must identify its graph node, consume only declared inputs, remain within its declared read scope and write ownership, and return the declared output shape. A subagent may report a hidden dependency or invalid graph assumption, but it must not silently restructure the graph or advance blocked nodes; the main agent owns topology changes and ready-set recalculation.

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
2. For multi-node work, map bounded nodes, real blocking dependencies, parallel-safe nodes, the completion-controlling path, and required handoff gates.
3. Decide which work, if any, should be delegated and whether parallel execution creates real leverage.
4. Choose from the Codex roles: Planner, Engineer, Reviewer, Tester, and Docs.
5. Select the smallest suitable custom profile and reasoning effort.
6. Give each subagent a precise assignment:
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
   - for multi-node work, the node identifier, inputs, output and acceptance condition, blocking dependencies, ownership or read scope, and verification gate
7. Launch only parallel-safe nodes concurrently and keep write-heavy work sequential unless isolation is verified.
8. Verify subagent claims against primary evidence. For meaningful implementation, use a separate verification task with only the necessary artifact, criteria, and evidence requirements when the runtime supports it; the main agent still decides acceptance.
9. If a gate fails, revise or rerun the failed node and any downstream nodes whose inputs became invalid. Do not restart unrelated nodes by default.
10. Before combining results, confirm every required input passed its designated gate, then inspect the combined diff and run validation for the integrated behavior.
11. Accept, reject, revise, or rerun with a stronger model only when justified.
12. Report relevant subagent usage, concurrency decisions, and any escalation in the final response.

Never accept a subagent's conclusion solely because it sounds confident.
