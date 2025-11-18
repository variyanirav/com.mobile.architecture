# RISKS REGISTER

Track evolving architecture risks. Revisit weekly.

| Category | Risk | Impact | Mitigation | Status |
|----------|------|--------|------------|--------|
| Architecture | Over-coupling between UI & data layer | High | Boundary enforcement script & reviews | Open |
| Performance | Cold start regression | Medium | Baseline metrics + CI perf sampling | Open |
| Security | Secrets in repo | High | Use env vars / secret manager | Open |
| Testing | Low coverage for critical flows | Medium | Coverage gates + targeted tests | Open |
| Process | ADRs not updated | Low | ADR checklist in PR template | Open |

Add new rows as issues emerge.