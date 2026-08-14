---
name: task-graph-orchestration
description: Use for complex coding tasks with substantial fan-out, multiple genuine dependencies, broad file or repository scope, multi-layer consolidation, separate implementation and verification paths, or an approval-gated irreversible action. Compiles an instruction-only task graph, executes only ready nodes, preserves completeness through fan-in, and retries only invalidated work. Skip for small or genuinely linear tasks.
---

# Task Graph Orchestration

Use instructions and Markdown to make complex work topology explicit. Do not introduce a graph database, scheduler, runner, schema package, or orchestration framework. The host executes ordinary inline work and subagent assignments; the main agent compiles the graph, controls transitions, accepts evidence, and owns the final result.

## Decide Whether to Use a Formal Graph

Consider a formal graph when one or more of these conditions apply:

- the task has roughly six or more meaningful work nodes
- work spans ten or more files, documents, repositories, or sources
- multiple independent investigations can run concurrently
- several subagents will be used
- many similar items must be audited or transformed without omissions
- results require layered consolidation
- implementation branches share contracts, schemas, interfaces, or mutable state
- a schema or interface change creates downstream consumers
- the result is difficult for the user to verify manually
- the task ends with deployment, deletion, publication, outbound communication, or another approval-gated action

Skip formal graph mode when the task is small, genuinely linear, dominated by one coherent design judgment, limited to tightly coupled writes, impossible for the main agent to verify, or cheaper to execute than to maintain as a graph. Keep ordinary tasks on the normal engineering loop.

## Establish the Preflight

1. Inspect the request, repository state, applicable instructions, validation surfaces, and existing ownership before compiling nodes.
2. Run the `multi-session-coordination` skill first when related Codex threads, branches, worktrees, pull requests, or active-work records may affect ownership or contracts. Treat that work as external nodes or hidden constraints; do not assume the current graph controls it.
3. Define the overall goal and observable success criteria.
4. Identify actions that require explicit approval because they are audience-facing, destructive, irreversible, sensitive, production-impacting, materially costly, or outside existing authority.
5. Read `references/templates/task-graph.md` before creating a formal graph artifact.

Keep a medium task graph in the working plan or response. For long-running, multi-phase, or multi-session implementation, create `.codex/task-graphs/<task-slug>.md` when repository policy permits a local coordination artifact. Otherwise keep the graph in the available planning mechanism. Do not create or commit a repository artifact for an informational question or when the task does not authorize changes.

## Compile the Graph

Define each node with:

- a stable node identifier
- one bounded goal
- an executor: main agent, subagent role, command, or approval gate
- authoritative inputs
- a declared output shape and acceptance condition
- only the upstream nodes whose accepted outputs it consumes
- read scope
- write or mutable-state ownership
- the smallest suitable model and reasoning effort when delegated
- a verification gate proportionate to risk
- a current status

Audit every proposed edge with this question:

> Can the downstream node correctly begin without consuming an accepted output or decision from the upstream node?

If yes, do not add a data-dependency edge merely to preserve narrative order. Check separately for hidden ordering constraints:

- overlapping file or mutable-state writes
- schemas, migrations, interfaces, or public contracts
- shared ports, services, environments, locks, credentials, or rate limits
- cost or resource ceilings
- active ownership in another thread or worktree
- destructive, irreversible, production, or audience-facing actions

Add explicit fan-in nodes where multiple outputs must be combined. Add independent verification nodes for high-risk claims or changes. Add approval nodes immediately before actions that require user authorization. Identify the completion-controlling path and the initial ready set.

## Dispatch Ready Nodes

Dispatch a node only when all declared dependencies have accepted outputs and all hidden constraints are satisfied.

- Run independent nodes concurrently only when the host supports it, scopes do not conflict, and the coordination cost is justified.
- State a concurrency limit instead of assuming unlimited fan-out.
- If parallel execution is unavailable, process ready nodes sequentially while preserving dependencies and state.
- Keep architecture, security-sensitive judgment, destructive operations, migrations, concurrency design, public API compatibility, and final acceptance with the main agent unless stronger delegated review is explicitly justified.

When delegating, use the existing subagent assignment contract and add:

```text
Graph node:
Declared inputs:
Output and acceptance condition:
Depends on:
Read scope:
Write or mutable-state ownership:
Verification gate:
```

A subagent must not silently restructure the graph, expand its scope, consume undeclared inputs, or claim a blocked dependency is complete. It must return the declared output or report the exact capability gap, hidden dependency, conflict, or missing input to the main agent.

## Update State and Consolidate Results

After each node returns:

1. Check its output against the declared acceptance condition and primary evidence.
2. Record its status, evidence, produced artifacts, and any changed assumptions.
3. Keep dependent nodes blocked when the output is missing, failed, or rejected.
4. Recalculate the ready set.
5. Record expected, received, missing, failed, and blocked node identifiers before fan-in.

For large fan-out, consolidate in layers. Preserve node IDs, paths, evidence references, counts, severity, and confidence. Do not collapse specific findings into vague summaries. Confirm every expected node appears exactly once in the consolidation or is explicitly listed as missing, failed, blocked, or superseded.

## Verify and Retry Selectively

Use an independent Reviewer or Tester node when risk, blast radius, or unverifiable synthesis warrants it. Give the verifier the source artifacts, acceptance criteria, and primary-evidence requirements—not merely the producer's summary.

If a gate fails:

- preserve accepted outputs from unrelated nodes
- revise or rerun the failed node
- rerun downstream nodes only when their consumed inputs became invalid
- recompile the affected graph portion when the failure reveals a missing edge or invalid decomposition
- stop blind retries and report the exact blocker when the same failure persists

Before completion, verify the combined behavior and final diff, confirm the completeness counts, and ensure no required node or approval gate remains blocked.

## Enforce Approval Gates

Complete safe inspection, reversible preparation, and validation before the gate when useful. Immediately before the gated action, present the exact target, scope, consequences, material cost, audience, and rollback or recovery path when one exists. Stop until the required authority is explicit. Approval for the plan or an earlier node does not authorize a broader or different irreversible action.

## Respect Instruction-Only Limits

This skill provides soft executable semantics, not a deterministic scheduler. The host may not support concurrency, graph state may drift, dependency classification may be wrong, and no automatic caching or transactional state exists. Recheck repository state, ownership, node inputs, and approval status at each consequential transition. Do not describe the result as a graph runtime or mechanically enforced workflow.
