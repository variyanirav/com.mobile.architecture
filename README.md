# Mobile Architecture

Mobile Architecture
A 30-day structured learning and hands-on plan to master mobile app architecture using Flutter, focusing on Clean Architecture principles, modularization, platform integration, backend design, testing, and team collaboration.

---

## Measurable outcomes & KPIs

To align this plan with a Solution Architect trajectory, you’ll track a few measurable outcomes:

- Build health: CI is green on main with lint + tests on Day 20 and beyond.
- Test coverage: reach 40–50% by Day 29 (unit + widget + a golden).
- Performance baseline: record cold start, memory footprint and frame build time on Day 11; aim for equal or better at Day 29.
- Architecture governance: import boundary checks automated by Day 26.

Artifacts you will create along the way (referenced in daily tasks):

- C4 context/container diagrams, Clean Architecture diagram
- ADRs using a template (5 comprehensive ADRs)
- PERF_BASELINE.md (with memory leak tracking)
- SECURITY.md (checklist) and threat model notes
- CI workflow with coverage and caching
- Scripts to enforce boundaries
- i18n/l10n configuration with 2+ languages
- Build flavors (dev/staging/prod)
- Design system with theming
- Analytics event taxonomy
- Error handling architecture documentation

## What's covered in this enhanced 30-day plan

**Core architecture (Days 1-8):**
✅ Clean Architecture principles & layering
✅ Modularization & package structure
✅ State management (Provider, Riverpod, BLoC) + advanced patterns
✅ State machines & side effects handling
✅ Dependency injection (get_it/Riverpod)
✅ Navigation architecture (go_router, deep linking)
✅ Data layer: Repository pattern, DTOs, domain models, mappers
✅ Code generation (freezed, json_serializable)
✅ Error handling with Either/Result types

**Platform & performance (Days 9-15):**
✅ Platform channels & native integration
✅ Plugin architecture
✅ Performance profiling & optimization
✅ Memory management & leak detection
✅ Accessibility (a11y) & WCAG compliance
✅ App lifecycle & background tasks
✅ Design systems & theming
✅ Asset management at scale
✅ Internationalization (i18n/l10n) & RTL support
✅ Native SDK integration patterns
✅ Security patterns & secure storage
✅ Build flavors & environment configuration
✅ Feature flags architecture

**Backend & infrastructure (Days 16-22):**
✅ API design (REST/GraphQL) & contracts
✅ Comprehensive error handling architecture
✅ Network resilience (retries, circuit breakers, timeouts)
✅ Offline-first architecture & sync strategies
✅ State persistence & hydration
✅ Local database patterns (SQLite/Hive)
✅ Auth flows (JWT, refresh tokens, social auth)
✅ Cloud architecture decisions
✅ CI/CD pipelines
✅ Observability, crash reporting, analytics
✅ Event taxonomy & funnel tracking
✅ NFRs & SLAs

**Testing & team practices (Days 23-30):**
✅ Comprehensive testing strategies (unit, widget, integration, golden)
✅ Contract testing & API compatibility
✅ Test pyramid best practices
✅ Release management & versioning
✅ A/B testing architecture
✅ Staged rollouts & canary releases
✅ Incident management & runbooks
✅ Team governance & code reviews
✅ Architecture boundary enforcement
✅ 5 comprehensive ADRs
✅ Capstone project integration
✅ Presentation & interview prep

# Week 0 — Setup + strategy (Day 1)

**Goal:** Prep environment & goals so every hour is productive.
**Day 1**

* Task: Install/verify Flutter, Android/iOS toolchains, VS Code/Android Studio, Git; create a new repo `flutter-architect-capstone`.
* Deliverable: Repo scaffold + README with one-line goals for the month.

### Day 1 kickoff checklist (practical)

- Verify toolchains: run `flutter doctor` and fix any issues.
- Initialize repo structure: `/app`, `/packages`, `/docs`.
- Add starter docs: `LEARNING.md`, `RISKS.md`, `ADR_TEMPLATE.md`.
- Enable recommended lints via `analysis_options.yaml`.
- First commit tagged `baseline-initial`.

---

# Week 1 — Core architecture foundations & modularization (Days 2–8)

**Goal:** Master project structure, high-level design patterns, modularization and package layering.

Day 2 — **Clean Architecture basics**

* 15m: Read summary of Clean Architecture (entities, use-cases, interface adapters, frameworks).
* 25m: Sketch (paper/whiteboard) how a Flutter app maps to Clean Arch layers.
* 15m: Create C4 Context diagram (`docs/c4/context.md`).
* 5m: Enable `analysis_options.yaml` with `flutter_lints`.
* Deliverable: 1-page architecture diagram in repo, C4 context diagram, lint configuration.
* Add: Document dependency rule (inner layers never depend on outer layers) in your notes.

Day 3 — **Modularization & packages**

* 15m: Learn how to split app into packages (feature modules, core, shared UI).
* 20m: Create package structure: `packages/feature_auth`, `packages/core`.
* 15m: Implement `core` package with logger API.
* 10m: Set up Melos 7.x with Pub Workspaces configuration.
* Deliverable: Working multi-package repo with logger API, C4 Container diagram.
* Add: Create C4 Container diagram (`docs/c4/container.md`) showing package relationships.

Day 4 — **State management patterns & advanced patterns**

* 10m: Review Provider, Riverpod, BLoC, Cubit, GetX tradeoffs.
* 30m: Implement a tiny counter feature in two ways (Provider + Riverpod).
* 20m: Explore advanced patterns: state machines, event sourcing concepts, side effects handling.
* Deliverable: short notes comparing implementation complexity & testability, plus one state machine example.
* Add: Document error state handling, loading states, and state transitions in your comparison.

Day 5 — **Dependency injection**

* 15m: Understand DI concepts (constructor injection, service locator vs DI container).
* 20m: Implement DI with get_it for auth feature.
* 15m: Compare with Riverpod DI approach (if using Riverpod for state).
* 10m: Create ADR documenting DI choice and rationale.
* Deliverable: DI wiring code, README notes with get_it vs Riverpod comparison.
* Add: Create ADR using `ADR_TEMPLATE.md`, document when to use which approach.

Day 6 — **Feature-first architecture & navigation**

* 25m: Set up declarative navigation architecture (go_router or Navigator 2.0).
* 25m: Implement one end-to-end feature (login flow) inside a feature package with DI and state management.
* 10m: Configure deep linking and route guards for authenticated routes.
* Deliverable: Working login mock flow with unit tests for business logic, navigation architecture doc.
* Add: Navigation graph diagram, deep link configuration (`flutter.dev/<route>`), route parameter handling.

Day 7 — **Data layer architecture & code generation**

* 15m: Set up code generation tools (freezed, json_serializable, build_runner).
* 20m: Define interfaces for repositories with local + remote data sources (AuthRepo, UserRepo).
* 15m: Implement Repository pattern with DTO ↔ Domain model mapping layer.
* 10m: Add Either<Failure, Success> pattern for error handling in data layer.
* Deliverable: Complete `AuthRepository` with remote/local data sources, DTOs, domain models, mappers, and mock implementation.
* Add: Create `build.yaml`, implement freezed models for immutability, generate JSON serialization code.
* Add: Document data flow: Remote → DTO → Mapper → Domain → Presentation.

Day 8 — **Review & mini-refactor**

* 20m: Review all code from Days 2-7, identify technical debt.
* 20m: Refactor inconsistencies (naming, structure, patterns).
* 20m: Update architecture diagram with actual package boundaries and dependencies.
* Deliverable: Clean codebase, updated diagram, detailed commit message describing Week 1 decisions.
* Add: Create `WEEK_1_RETROSPECTIVE.md` documenting what worked, what didn't, and key learnings.

---

# Week 2 — Cross-platform/native integration & platform concerns (Days 9–15)

**Goal:** Understand how Flutter apps interact with native layers, performance, platform channels and packaging.

Day 9 — **Platform channels & native services**

* 15m: Learn platform channel concepts (MethodChannel, EventChannel, BasicMessageChannel).
* 25m: Implement method channel to call native function (e.g., battery level on Android/iOS).
* 20m: Test platform channel on both Android and iOS, handle platform-specific code.
* Deliverable: Working platform channel example with Android + iOS native implementations.
* Add: Document platform channel architecture, error handling, and thread safety considerations.

Day 10 — **Plugin design & publishing basics**

* 15m: Study plugin architecture (federated plugins, platform interfaces).
* 20m: Scaffold a mini plugin using `flutter create --template=plugin`.
* 15m: Implement platform-specific code for Android and iOS.
* 10m: Create plugin publishing checklist (pub.dev requirements, versioning, documentation).
* Deliverable: Plugin scaffold with working implementation, publish-ready checklist.
* Add: Document plugin API design principles, platform interface patterns, and testing strategy.

Day 11 — **Performance, memory management & accessibility**

* 15m: Learn Flutter rendering pipeline, widget rebuild reasons, and profiling basics.
* 15m: Memory management: leak detection with DevTools, dispose patterns, WeakReference usage.
* 20m: Hands-on: Profile a sample page for performance and memory leaks.
* 10m: Accessibility fundamentals: Semantics widgets, screen reader support, contrast ratios.
* Deliverable: Performance checklist (avoid rebuilds, const, keys, list virtualization), memory leak detection guide.
* Add: Record baseline metrics to `PERF_BASELINE.md` (cold start, frame build time, memory, leaked widgets). Commit numbers.
* Add: Accessibility checklist with semantic widget examples, WCAG compliance notes.

Day 12 — **App lifecycle, background tasks & design systems**

* 20m: Explore app lifecycle handling, background fetch, notifications (Firebase Cloud Messaging basics).
* 20m: Design system fundamentals: theming architecture, design tokens, component library structure.
* 20m: Asset management at scale: image optimization strategies, font loading, resource management.
* Deliverable: Push-notification architecture plan, basic design system with theme structure.
* Add: Custom theme with light/dark mode, typography scale, color palette as code.
* Add: Asset organization strategy, SVG vs raster guidelines, responsive image loading.

Day 13 — **Native SDK integrations & internationalization**

* 20m: Architect integration for native SDKs (analytics, crash reporting).
* 20m: Implement internationalization (i18n) architecture: Flutter intl, ARB files, locale management.
* 20m: Set up multi-language support, RTL (right-to-left) layout handling, date/number formatting.
* Deliverable: Integration plan (where to initialize, abstraction layer), i18n architecture with 2+ languages working.
* Add: Locale switching mechanism, `l10n.yaml` configuration, generated localization classes.
* Add: Document pluralization, gender variants, and locale-specific asset handling.

Day 14 — **Security patterns & build configurations**

* 20m: Learn secure storage, key management, safe handling of secrets, obfuscation basics.
* 25m: Implement build flavors (dev/staging/prod) with environment-specific configurations.
* 15m: Set up feature flags architecture for gradual rollouts and A/B testing.
* Deliverable: Security checklist + `flutter_secure_storage` example, 3 working build flavors.
* Add: Mini threat model (assets, threats, mitigations) in `SECURITY.md`.
* Add: Environment configuration files (`.env.dev`, `.env.prod`), flavor-specific app icons/names.
* Add: Feature flag service with remote config integration pattern (Firebase Remote Config or similar).

Day 15 — **Review & docs**

* 20m: Review Week 2 work (platform channels, performance, i18n, security, configs).
* 25m: Write comprehensive "Integration and Platform" document covering all Week 2 topics.
* 15m: Update architecture diagrams to reflect platform integrations and build configurations.
* Deliverable: `docs/PLATFORM_INTEGRATION.md` with all learnings, updated diagrams.
* Add: Create `WEEK_2_RETROSPECTIVE.md`, document platform-specific gotchas and best practices.

---

# Week 3 — Backend, APIs, infra & system design (Days 16–22)

**Goal:** Architect backend interactions, offline-first, caching, synchronization, and CI/CD architecture.

Day 16 — **API design, error handling & network resilience**

* 15m: REST vs GraphQL tradeoffs, versioning strategies, comprehensive error handling architecture.
* 15m: Implement Either<Failure, Success> or Result type pattern for domain errors.
* 15m: Network resilience: retry policies (exponential backoff), circuit breakers, timeout strategies.
* 15m: Set up connectivity monitoring, request/response interceptors (Dio), error boundaries in UI.
* Deliverable: API contract (OpenAPI-style) with error codes, resilient network layer with retry logic.
* Add: Scaffold a contract test (mock server vs interface) to validate client behavior.
* Add: Error handling architecture doc: network errors, business errors, validation errors, unknown errors.
* Add: Create custom Failure types (NetworkFailure, ServerFailure, CacheFailure) with proper error propagation.

Day 17 — **Offline, sync & state persistence**

* 15m: Learn optimistic updates, conflict resolution, local DB (SQLite / Hive / ObjectBox).
* 20m: Implement local caching layer with `sqflite` or `hive`.
* 15m: State persistence and hydration strategies: save/restore app state across sessions.
* 10m: Implement sync queue for offline operations, background sync architecture.
* Deliverable: Sync strategy doc with conflict resolution logic, working offline-first feature.
* Add: State hydration on app launch, persisted state for critical user data (cart, drafts).
* Add: Sync status indicator UI, retry mechanism for failed sync operations.

Day 18 — **Auth and scalability**

* 15m: Design JWT authentication flow (login, token storage, refresh logic).
* 15m: Architect refresh token mechanism with automatic renewal.
* 15m: Plan social auth integration (Google, Apple, Facebook) with abstraction layer.
* 15m: Consider multi-tenant architecture patterns (tenant isolation, data partitioning).
* Deliverable: Comprehensive auth sequence diagrams for JWT, refresh, and social auth flows.
* Add: Document token security (secure storage, rotation), session management, and logout flows.

Day 19 — **Cloud choices & serverless patterns**

* 20m: Compare Firebase (BaaS) vs AWS Amplify vs custom backend for Flutter apps.
* 15m: Evaluate serverless patterns (Lambda, Cloud Functions) for mobile backends.
* 15m: Analyze cost, scalability, vendor lock-in, and development velocity tradeoffs.
* 10m: Create ADR documenting cloud/backend choice with decision drivers.
* Deliverable: Comprehensive comparison matrix, ADR for backend strategy.
* Add: Document API Gateway patterns, serverless cold starts impact, and offline-first considerations.

Day 20 — **CI/CD for Flutter**

* 15m: Design CI/CD pipeline architecture (build, test, analyze, deploy stages).
* 20m: Create GitHub Actions workflow with test + lint + analyze.
* 15m: Add caching strategy (pub cache, build cache) for faster builds.
* 10m: Set up code coverage collection with lcov and upload to Codecov/Coveralls.
* Deliverable: Complete `.github/workflows/ci.yml` with caching and coverage.
* Add: Fastlane basics for iOS/Android releases, artifact upload, dependency scanning.

Day 21 — **Observability, monitoring & analytics architecture**

* 20m: Set up crash reporting (Sentry/Firebase Crashlytics) and custom telemetry.
* 20m: Design analytics architecture: event taxonomy, funnel tracking, user properties.
* 20m: Implement structured logging with correlation IDs, log levels, and contextual data.
* Deliverable: Observability plan with crash reporting, analytics abstraction layer, logging strategy.
* Add: Define telemetry categories (performance, business, reliability) and implement correlation ID pattern.
* Add: Analytics events schema, user journey tracking, conversion funnel instrumentation.
* Add: Create analytics wrapper to abstract provider (Firebase/Mixpanel/Amplitude) for easy migration.

Day 22 — **Cost, SLAs and non-functional requirements**

* 15m: Define performance NFRs (app startup <2s, API response <500ms, 60fps UI).
* 15m: Document reliability targets (99.9% uptime, error rate <0.1%, crash-free rate >99.5%).
* 15m: Establish scalability requirements (concurrent users, data volume, geographic distribution).
* 15m: Create cost model (API calls, storage, CDN, monitoring) with budgets and alerts.
* Deliverable: Comprehensive `docs/NFR.md` with measurable targets and acceptance criteria.
* Add: SLA definitions for critical user journeys, monitoring strategy, and capacity planning.

---

# Week 4 — Testing, reliability, docs, team architecture (Days 23–29)

**Goal:** Harden app with tests, docs, blueprints for team adoption, and prepare final capstone submission.

Day 23 — **Testing strategies & contract testing**

* 20m: Unit tests, widget tests, integration tests, golden tests overview.
* 20m: Contract testing: validate API contracts don't break client expectations.
* 20m: Hands-on: Add unit tests for a use-case, one widget test, and one golden test.
* Deliverable: Test report (coverage focus points), contract test example.
* Add: Set minimum coverage threshold in CI (40%), golden test baseline.
* Add: API compatibility tests using mock server (MockWebServer/Mockito), backward compatibility validation.
* Add: Test pyramid documentation: balance between unit (70%), widget (20%), integration (10%).

Day 24 — **Release management, versioning & A/B testing**

* 20m: Semantic versioning, staged rollout strategies, release trains.
* 20m: A/B testing architecture: experimentation platform, variant assignment, metrics collection.
* 20m: Feature flags for gradual rollouts, kill switches, and canary releases.
* Deliverable: Release strategy document, A/B testing architecture design.
* Add: Version bump automation, changelog generation, release notes template.
* Add: Experiment configuration schema, variant bucketing logic, statistical significance tracking.
* Add: Integration plan for experimentation platforms (Firebase A/B, Optimizely, LaunchDarkly).

Day 25 — **Cost & deployment operations**

* 15m: Document app update process (staged rollouts, phased releases, rollback procedures).
* 15m: Design hotfix workflow (emergency fixes, expedited review, targeted deployment).
* 15m: Create monitoring dashboard for post-release metrics (crashes, ANRs, API errors).
* 15m: Develop incident response runbook (detection, triage, communication, resolution).
* Deliverable: `docs/DEPLOYMENT_RUNBOOK.md` with step-by-step operations procedures.
* Add: Rollback decision matrix, hotfix approval process, post-mortem template.

Day 26 — **Team architecture — governance & libraries**

* 15m: Design architecture governance model (ADR process, review gates, style guides).
* 20m: Create boundary enforcement script to prevent layer violations (UI → Domain checks).
* 15m: Generate dependency graph visualizing package relationships and imports.
* 10m: Document onboarding checklist and code review standards.
* Deliverable: Governance documentation, boundary script, onboarding + review checklists.
* Add: Create `scripts/check_import_boundaries.dart`, CODEOWNERS file, PR template.

Day 27 — **Architecture review & tradeoffs**

* 60-75m: Create 5 comprehensive ADRs documenting major architectural decisions.
* ADR breakdown (12-15m each):
  - State management (Provider/Riverpod/BLoC): rationale, alternatives, consequences
  - DI approach (get_it/Riverpod): decision drivers, testability impact
  - Data layer (Repository + DTOs): why separate entities/models, mapping strategy
  - Navigation (go_router/Navigator 2.0): deep linking requirements, type safety
  - Backend/API (Firebase/custom/REST/GraphQL): cost, scalability, team expertise
* Deliverable: 5 ADR files in `docs/adr/` following ADR template.
* Add: For each ADR, document context, decision, alternatives considered, consequences, and migration path if needed.

Day 28 — **Capstone build**

* 20m: Integrate all architectural pieces (verify all layers connect properly).
* 20m: End-to-end testing of critical user flows (auth, main feature, offline).
* 15m: Verify CI/CD pipeline runs successfully with all checks passing.
* 15m: Polish UX, fix any critical bugs, ensure consistent error handling.
* Deliverable: Working prototype with integrated modular app, API client, local cache, DI, CI passing.
* Add: Create demo script with 3-4 key user flows, capture screenshots/recordings for presentation.

Day 29 — **Polish & prepare presentation**

* 25m: Write comprehensive `ARCHITECTURE.md` (system overview, key decisions, tradeoffs).
* 20m: Create presentation slides/demo script highlighting architectural achievements.
* 15m: Prepare architecture case study (problem, solution, results, metrics).
* Deliverable: `ARCHITECTURE.md`, `PRESENTATION.md`, demo script with talking points.
* Add: Include before/after metrics (test coverage, build time, package count), architecture diagrams, and 3 key interview talking points.

---

# Day 30 — Final review + interview prep

**Goal:** Summarize, prepare to present, and list next steps to continue growth.

Day 30

* Task: Run through your architecture doc, demo the prototype (record a 5–8 min screencast if possible).
* Deliverable: Final checklist: repo link, architecture doc, demo link, 3 talking points for interviews.

## Roadmap beyond 30 days

### Phase 2 — Next 60–90 hours (months 2–3)

**Advanced architecture patterns:**
- Reactive programming deep-dive: advanced Stream patterns, RxDart in architecture layers.
- Animation architecture: Rive/Lottie integration, custom implicit/explicit animations, performance optimization.
- Cross-platform strategy: Web/Desktop adaptations, platform-specific architecture decisions.
- White-labeling & multi-tenancy: architecture for rebranding, theme switching, tenant isolation.

**Scale & operations:**
- Scale backend interactions: rate limits, pagination, retries, idempotency; formalize contract tests and run them in CI.
- Performance program: capture perf samples each release; compare against `PERF_BASELINE.md`; add alerts if regressions exceed thresholds.
- App size optimization: code splitting, deferred/lazy loading, tree shaking analysis.
- Migration strategies: legacy code modernization, incremental architecture adoption.

**Team & governance:**
- Strengthen governance: template repos, CODEOWNERS, pre-commit hooks (format, analyze, boundary checks), PR checklist for architecture.
- Monorepo vs multi-repo strategies: evaluate for your team size and velocity.
- Architecture fitness functions: automated architecture compliance checks.
- Publish and maintain one plugin on pub.dev; document versioning and changelog policy.

**Testing maturity:**
- Deepen testing: more golden tests, integration tests with mock server, flaky test quarantine strategy.
- Chaos testing: simulate network failures, slow responses, partial data scenarios.
- Fuzz testing: input validation and edge case discovery.

### Phase 3 — Real‑world exposure (4–12 weeks)

**Production operations:**
- Operate at scale: add crash/ANR budget, reliability targets (error budgets), and monthly postmortems.
- Cost management: track CI minutes, device farm usage, and 3rd‑party SDK costs; introduce budgets and alerts.
- Incident response: on-call rotations, postmortem culture, blameless retrospectives.
- SRE practices: SLIs, SLOs, error budgets for mobile apps.

**Advanced technical depth:**
- Advanced performance: shader precompilation, frame budget audits under stress (lists, animations), and JIT/AOT differences.
- Platform depth: complex native integrations (e.g., background isolates, foreground services on Android, extensions on iOS).
- Event-driven architecture: event bus patterns, CQRS in mobile context.
- GraphQL client architecture: caching strategies, normalized cache, optimistic updates.

**Leadership & mentorship:**
- Team patterns: run lightweight architecture reviews, introduce ADR governance, and mentor contributors.
- Conway's Law application: align team structure with architecture.
- Technical strategy: create multi-quarter architecture roadmaps.
- Knowledge sharing: tech talks, internal documentation, architecture guild.

---

# Capstone suggestion (what to build in month)

A small but complete app to showcase architecture: **Team Tasks Manager**

* Features: Auth, projects, tasks, offline capability, push notifications, analytics.
* Backend: mocked via local JSON initially; design API contracts to swap in real backend.
* Deliverables: architecture doc, ADRs, CI workflow, instrumentation, unit & integration tests.

---

# Daily habit template (1-1.5 hours)

* 15m: Read focused articles, official docs, or architecture patterns.
* 45-60m: Hands-on coding or creating architecture docs/diagrams.
* 15m: Commit with descriptive messages + document in `LEARNING.md` (what you learned, one issue encountered, next step).
* Bonus: If time permits, review architectural decisions from previous days for consistency.

**Note:** Some days (especially 7, 11, 13, 14, 16) have dense content. Budget 1.5 hours for those or split learning across morning/evening sessions.

### Weekly cadence add-on

- End-of-week demo: Record a 1–2 min screen capture of what works now.
- Write a 5-bullet recap: wins, risks, decisions, metrics delta, next focus.

---

# Tools / Resources (architecture-focused)

**Essential reading:**
* Official Flutter docs & cookbook — daily reference.
* Dart language tour — for advanced types, async patterns, null safety.
* Flutter architecture samples — official GitHub repo with production patterns.
* Clean Architecture (Robert C. Martin) — core principles summary.
* Domain-Driven Design Distilled — for domain modeling.

**Architecture patterns:**
* Refactoring Guru — design patterns with Flutter examples.
* Software Architecture: The Hard Parts — tradeoff analysis.
* System Design Primer (GitHub) — scalability patterns.

**Flutter-specific:**
* Very Good Ventures blog — production Flutter architecture.
* Flutter Community on Medium — real-world patterns.
* Reso Coder tutorials — Clean Architecture in Flutter.

**DevOps & tooling:**
* GitHub Actions docs + Fastlane quickstart.
* Flutter DevTools profiling & tracing.
* Melos for monorepo management.

**Community:**
* Flutter Discord — architecture discussions.
* Reddit r/FlutterDev — code reviews and patterns.
* Twitter Flutter community — latest architectural trends.

(Bookmark these resources for daily reference throughout your journey.)

---

# How I recommend you use this plan

* Follow days in order; if you already know some topics, skip ahead but still *write the docs* — architects are judged by clarity of docs and decisions more than flashy code.
* **Budget 1-1.5 hours per day**: Days 7, 11, 13, 14, 16 are content-heavy; consider splitting them across morning/evening sessions.
* **Focus on architecture decisions over perfect code**: Your goal is demonstrating architectural thinking, not production-ready features.
* After 30 days, you'll have a portfolio-ready repo with architecture docs, ADRs, CI, and a working prototype — enough to demonstrate solution-architecture thinking.
* Keep iterating: monthly goals after this should include scaling the backend, multi-platform embedding, performance tuning, and mentoring a small team.

## Quick reference: Critical architecture patterns by day

| Day | Critical Topics | Must-Have Deliverables |
|-----|----------------|------------------------|
| 4 | State management + state machines | Comparison doc with state transitions |
| 6 | Feature architecture + navigation | Working flow with deep links |
| 7 | Data layer + code generation | Repository with DTO/Domain mapping |
| 11 | Performance + memory + a11y | Baseline metrics + leak detection |
| 13 | i18n/l10n + native SDKs | Multi-language support working |
| 14 | Security + build flavors | 3 flavors with env configs |
| 16 | Error handling + network resilience | Resilient API client with retries |
| 17 | Offline sync + state persistence | Working offline-first feature |
| 21 | Observability + analytics | Event taxonomy + crash reporting |
| 23 | Testing + contract tests | Coverage >40% with contract test |
| 27 | 5 comprehensive ADRs | Documented architectural decisions |

---