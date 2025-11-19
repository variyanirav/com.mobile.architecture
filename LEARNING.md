# LEARNING LOG

Use this file daily (10 minutes):
- What I learned (3 bullets)
- One issue/blocker
- Next step (1 bullet)

Template (copy per day):

## Day 1 — 2025-10-10
- Learned:
  - Repository structure for Flutter monorepo with Melos.
  - Setting up linting with flutter_lints package.
  - Running Flutter analyze across multiple packages.
- Issue:
  - None.
- Next:
  - Day 2 — Clean Architecture basics.

## Day 2 — 2025-11-19
- Learned:
  - Clean Architecture layers (Presentation → Application → Domain → Data) and dependency rule (dependencies point inward only).
  - Separation between Entities (pure business) and Models (with serialization) - Entity in domain, Model in data layer.
  - Result/Either pattern for functional error handling - avoids try-catch in presentation layer and makes errors explicit in type system.
- Issue:
  - Initial naming conflict between Failure class (error types) and Failure wrapper (Result type) - resolved by renaming to Left/Right pattern.
- Next:
  - Day 3 — Modularization & packages (feature modules, core package, shared UI).
