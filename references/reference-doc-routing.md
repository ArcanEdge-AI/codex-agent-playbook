# Reference Document Routing

Reference documents help the main agent and subagents find relevant context without bloating every prompt.

Reference documents are supporting context, not automatic truth.

## When to Consult Reference Docs

Consult reference docs when a task touches:

- architecture
- domain rules
- API contracts
- data models
- schemas or migrations
- testing strategy
- design-system conventions
- safety requirements
- release or deployment expectations
- known pitfalls
- recurring mistakes
- subagent role definitions or review checklists

## Authority Levels

Classify documents before relying on them.

### Authoritative

A document is authoritative when repository or user instructions explicitly say it is the source of truth.

Examples:

- current API contract
- current schema migration rules
- current design-system rules
- current access-control model
- current release checklist

### Advisory

A document is advisory when it gives guidance but current code, tests, or user instructions may override it.

Examples:

- architecture overview
- style guidance
- testing recommendations
- implementation notes

### Historical

A document is historical when it may describe past decisions or deprecated behavior.

Examples:

- incident notes
- old migration plans
- archived design proposals
- superseded implementation docs

Do not silently rely on historical docs for current implementation.

## Conflict Resolution

If a reference document conflicts with current code, tests, configuration, runtime behavior, or repository instructions:

1. Report the conflict.
2. Prefer primary evidence for implementation decisions.
3. Update or flag stale docs when appropriate.
4. Do not choose silently.

Primary evidence includes:

- current code
- tests
- schemas
- configuration
- logs
- build output
- typecheck output
- runtime behavior
- authoritative external documentation

## Passing Docs to Subagents

When delegating:

- include only relevant document names, paths, or sections
- tell the subagent whether each document is authoritative, advisory, or historical
- require implementation-relevant claims to be checked against current code when implementation decisions depend on the document
- avoid dumping entire documents into prompts unless necessary
- ask for evidence, not vibes
