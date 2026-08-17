# Benchmark 001: Scoped Expiring Waivers

**Status:** Specification only. The fixture baseline is frozen at [`benchmark-001-baseline-v1`](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks/tree/benchmark-001-baseline-v1), commit [`2a7244f0106cf7f4e106a832b737028144d28389`](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks/commits/2a7244f0106cf7f4e106a832b737028144d28389). No measured run has occurred.

## Fixture

Use [ArcanEdge-AI/coding-agent-playbook-benchmarks](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks) at the frozen tag and exact commit above. Do not substitute a moving branch tip.

## Task

Extend the fixture's small TypeScript release-readiness CLI with **scoped, expiring waivers**. A waiver has `checkId`, `reason`, and `expiresAt`; `checkId` is its scope. The CLI must require `--as-of` whenever waivers exist, so results do not depend on wall-clock time.

The implementation must:

1. Inspect the existing parser, types, evaluator, CLI, tests, and documentation before changing behavior.
2. Define the `checkId`, `reason`, and `expiresAt` waiver shape and parsing path that fit the fixture's existing design.
3. Apply an active waiver (at or before its expiry) only to its matching failed required check. Expired waivers are ignored for readiness but reported. Unknown, duplicate, malformed, and inapplicable waivers are invalid.
4. Surface useful CLI output for applied and ignored waivers without exposing unrelated configuration.
5. Add focused tests for active, expired, unknown, duplicate, malformed, and inapplicable waivers, plus required deterministic `--as-of` behavior.
6. Update the user-facing documentation with the waiver format and deterministic invocation.
7. Route bounded work through a documented task graph, obtain independent review, correct actionable findings, and run the fixture's final validation commands.

## Acceptance criteria

The completed change preserves existing behavior when no waiver is supplied; has deterministic tests; meets the fixture's documented `npm ci`, `npm run typecheck`, `npm test`, and public CLI smoke-check requirements; documents the new behavior; and includes a public review/correction/validation trail. The benchmark values orchestration quality and inspectable evidence over code volume.

## Reproduction record

Run from the published baseline in a fresh session and record all fields in [RUN-TEMPLATE.md](./RUN-TEMPLATE.md). Do not represent the baseline-authoring session as an independent measured run.
