# Benchmark 001 Run 001: Scoped Expiring Waivers

This is the first published measured run for [Benchmark 001](./BENCHMARK-001.md). It records one execution against the frozen public fixture and does not make a comparison or universal-performance claim.

## Identity and baseline

- Benchmark identifier: Benchmark 001 — Scoped Expiring Waivers.
- Run date: 2026-08-17.
- Playbook version / commit: [`5bea3c1ebacfa376e959206be5d1228904d6bd7e`](https://github.com/ArcanEdge-AI/coding-agent-playbook-codex/commit/5bea3c1ebacfa376e959206be5d1228904d6bd7e).
- Codex version (where available): Codex CLI `0.125.0`; Codex Desktop application build: Not captured.
- Starting repository commit: [`2a7244f0106cf7f4e106a832b737028144d28389`](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks/commit/2a7244f0106cf7f4e106a832b737028144d28389), tag `benchmark-001-baseline-v1`.
- Repository visibility and disclosure permission: The [Playbook](https://github.com/ArcanEdge-AI/coding-agent-playbook-codex), [benchmark fixture](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks), implementation commit, and [implementation PR #1](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks/pull/1) are public. PR #1 is open and unmerged.
- Exact user task: Extend the fixture's TypeScript release-readiness CLI with scoped, expiring waivers (`checkId`, `reason`, and `expiresAt`), requiring deterministic `--as-of` handling whenever waivers exist, and meet the published Benchmark 001 acceptance criteria.

## Routing and execution

- Root model: `gpt-5.6-sol`.
- Root reasoning effort: `xhigh`.
- Subagent roles: N1 Planner; N2 Engineer; N3 Independent Reviewer.
- Subagent models: N1 `gpt-5.6-terra`; N2 `gpt-5.6-terra`; N3 `gpt-5.6-terra`.
- Subagent reasoning efforts: N1 `medium`; N2 `medium`; N3 `high`.
- Task graph: Root orchestration directed a planner, then an engineer, then an independent reviewer before final acceptance.
- Dependencies: The implementation followed planning; independent review followed the implementation correction cycle; final validation followed the implementation and independent review.
- Agent count: 3 agents spawned.
- Worktree usage: 0 auxiliary worktrees.
- Exact start time (with timezone): `2026-08-17T11:27:04.6737774-05:00`.
- Exact end time (with timezone): `2026-08-17T11:50:30.1160957-05:00`.
- Elapsed time: `00:23:25.4423183`.
- Human interventions: None during execution.

## Change and validation

- Commits produced: One implementation commit, [`d87a25a8fb9e8b334696547bf33bbdfd5bbdfc3b`](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks/commit/d87a25a8fb9e8b334696547bf33bbdfd5bbdfc3b), on `benchmark/001-scoped-expiring-waivers`.
- Files changed: 9.
- Additions / deletions: 230 additions / 23 deletions.
- Tests run: Baseline: `npm ci`, `npm run typecheck`, and `npm test`. Final: `npm ci`, `npm run check`, typecheck, build, tests, explicit `npm run build`, `git diff --check`, and the CLI validations listed below.
- Test results: Baseline tests passed, 4/4. Final tests passed, 9/9.
- Typecheck results: Baseline `npm run typecheck` passed. Final typecheck passed.
- Build results: Final build passed, including explicit `npm run build`.
- Lint results: Not applicable; the fixture has no lint script.
- Independent reviewer findings: 0 actionable findings.
- Correction cycles and dispositions: One orchestrator-to-engineer correction cycle occurred before independent review. It corrected TypeScript inference; exact fractional-second expiry comparison; exposure of internal timestamp helpers from the public barrel; explicit CLI invalid-input coverage; and no-waiver JSON compatibility coverage. Review-triggered correction cycles: 0.
- Final validation: `npm ci`, `npm run check`, typecheck, build, tests, explicit `npm run build`, and `git diff --check` passed. CLI validation confirmed: active-waiver human output (`WAIVED` / ready / exit 0); expired-waiver JSON (`expired` / blocked / exit 2); exact expiry boundary (active / exit 0); identical boundary runs (exact output match); waiver without `--as-of` (exit 65); legacy ready/blocked behavior (exits 0 and 2); unknown, duplicate, malformed, and inapplicable waivers (exit 65); duplicate, missing, and unknown CLI options plus extra positionals (exit 64); and preserved no-waiver human and JSON behavior.
- Final outcome: The implementation met the recorded validation criteria in the public [implementation PR #1](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks/pull/1), which remains open and unmerged.

## Usage, environment, and limits

- Account usage observation: Not applicable for benchmark attribution. Account-level usage was not attributable to this benchmark because other Codex workloads were active concurrently. No benchmark-specific usage, cost, token, or efficiency claim is made.
- Before evidence for account usage: Not applicable; no benchmark-specific usage observation is reported.
- After evidence for account usage: Not applicable; no benchmark-specific usage observation is reported.
- Environmental limitations: No lint script exists. On Windows, the npm wrapper normalized the intentionally blocked child exit to 1, while direct Node execution returned the documented exit 2. Codex Desktop application build was not captured.
- Failures: No unresolved execution failures were recorded.
- Unresolved findings: None recorded.
- Public artifacts or reproducibility link: [Playbook source commit](https://github.com/ArcanEdge-AI/coding-agent-playbook-codex/commit/5bea3c1ebacfa376e959206be5d1228904d6bd7e); [frozen baseline](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks/commit/2a7244f0106cf7f4e106a832b737028144d28389); [measured implementation commit](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks/commit/d87a25a8fb9e8b334696547bf33bbdfd5bbdfc3b); [public implementation PR #1](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks/pull/1).

## Missing-evidence check

- Which required fields are `Not captured`, and why? The Codex Desktop application build was not captured.
- Which required fields are `Not applicable`, and why? Lint results are not applicable because the fixture has no lint script. Benchmark-specific account usage and before-and-after evidence are not applicable because concurrent workloads prevented attribution and no quantitative observation is reported.
- Does every reported account-usage observation have before-and-after evidence? No account-usage observation is reported; no usage, cost, token, or efficiency claim is made.
- Are review findings, corrections, and final validation linked or described with enough public evidence to inspect? Yes. The public implementation commit and open, unmerged [PR #1](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks/pull/1) provide the inspectable implementation trail; the correction cycle, independent-review result, and validation outcomes are recorded above.

## What This Run Does Not Prove

A single run does not prove universal cost savings, universal token savings, universal speed improvements, causation, superiority over standard Codex, superiority over another coding agent, or identical results on other repositories. A controlled comparison requires a separately designed control with equivalent task, baseline, environment, capture method, and acceptance criteria.
