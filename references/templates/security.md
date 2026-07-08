# Safety and Access-Control Reference

## Identity Model

Describe authentication and identity assumptions.

## Authorization Model

Describe permission checks, roles, ownership, tenancy, and access boundaries.

## Sensitive Data

Document what data is sensitive and how it must be handled.

## Logging Rules

Do not log sensitive access material or sensitive user data.

## Dependency Rules

Document safety expectations for new dependencies.

## Common Risks

List known risks:

- privilege escalation
- insecure direct object references
- injection
- sensitive data leakage
- unsafe redirects
- CSRF/CORS mistakes
- unsafe deserialization
- improper caching
- overly broad permissions
