# Public Evidence

This area separates three related but different forms of evidence:

- **Field use:** ArcanEdge uses these patterns in real engineering work.
- **Private field evidence:** deeper records from client and unreleased-product work remain private and are not a public evidence dump.
- **Public reproducibility:** benchmark fixtures and run records let others inspect the playbook's observable behavior without access to private code.

Public runs can measure the prompt, root plan, task graph, model routing, bounded delegation, tests, independent review, correction cycles, final validation, and outcome. They may record account usage only when exact before-and-after evidence was captured.

This repository does not publish private repositories, source, credentials, internal implementation details, confidential client information, or unredacted private logs. Missing evidence is recorded as missing, not estimated.

## Reproduce or contribute

Start with [Benchmark 001](./BENCHMARK-001.md). Its first published measured record, [Benchmark 001 Run 001](./BENCHMARK-001-RUN-001.md), documents one execution and links to the public, open and unmerged [implementation PR #1](https://github.com/ArcanEdge-AI/coding-agent-playbook-benchmarks/pull/1). Reset the separate public fixture to its documented baseline, and record a new run with [RUN-TEMPLATE.md](./RUN-TEMPLATE.md). Community runs may be submitted through [Share a Playbook Run](https://github.com/ArcanEdge-AI/coding-agent-playbook-codex/issues/new?template=share_playbook_run.md). Public fixture links and artifacts are welcome; private repositories are not required.

See [METHODOLOGY.md](./METHODOLOGY.md) for the capture rules and limits of these records.
