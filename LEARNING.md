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

## Day 3 — 2025-11-26
- Learned:
  - Package modularization transforms monolithic app into multi-package architecture with clear boundaries - packages can be built/tested independently.
  - Created two packages: `core` (shared infrastructure - error handling, logging) and `feature_auth` (complete auth feature with domain/data/presentation layers).
  - Melos 7.x uses Pub Workspaces (Dart 3.6+) with configuration in root `pubspec.yaml` instead of separate `melos.yaml` - all packages require `resolution: workspace` field.
  - Solution architecture for decoupling: use domain interfaces for shared data (SessionProvider), micro packages for optional features, composition over inheritance for extended entities.
- Issue:
  - Discovered `melos.yaml` is deprecated in Melos 7.x - migrated to `pubspec.yaml` with `workspace:` and `melos:` keys, added `resolution: workspace` to all packages.
- Next:
  - Day 4 — State management patterns comparison (Provider vs Riverpod vs BLoC).

## Day 4 — 2026-01-10
- Learned:
  - Implemented real shopping cart feature with all three state management patterns (Provider, Riverpod, BLoC) sharing domain/data layers - practical comparison reveals Provider's simplicity vs Riverpod's safety vs BLoC's predictability.
  - Provider uses ChangeNotifier with notifyListeners() for mutations; Riverpod uses immutable StateNotifier with copyWith pattern; BLoC uses event handlers with Emitter for state transitions.
  - Shared architecture: domain (entities, repository interface) + data (repository impl with SharedPreferences) + three presentation implementations (provider/, riverpod/, bloc/) - demonstrates clean separation.
  - Key differences in practice: Provider = `Consumer<CartProvider>` + `context.read()`, Riverpod = `ref.watch(cartProvider)` + derived providers for granular rebuilds, BLoC = `BlocBuilder` + `context.read<CartBloc>().add(event)`.
- Issue:
  - flutter_bloc version conflict (8.1.5 vs 9.1.1) between feature_cart and feature_auth - resolved by aligning to ^9.1.1 across all packages.
- Next:
  - Test all three implementations in simulator, compare performance/developer experience, choose one pattern for project and document ADR.

## Day 5 — 2026-01-15
- Learned:
  - Dependency Injection (DI) solves tight coupling by passing dependencies from outside instead of creating them inside classes - makes code testable and maintainable.
  - Three types of DI: Constructor injection (preferred, explicit dependencies), Property injection (for optional dependencies), Method injection (for operation-specific dependencies).
  - Two DI patterns: Service Locator (get_it - global registry, easy but hidden dependencies) vs DI Container (Riverpod - scoped, compile-time safe, but steeper learning curve).
  - Implemented get_it for feature_auth: single global ServiceLocator, registered repositories/datasources/mappers/blocs as singletons/factories, injected into widgets via GetIt.instance.get<T>().
- Issue:
  - Initially confused between "DI pattern" (how to inject) and "DI container" (what manages dependencies) - clarified that get_it is service locator pattern, Riverpod is DI container.
- Next:
  - Day 6 — Feature-first architecture and declarative navigation with go_router.

## Day 6 — 2026-01-20
- Learned:
  - Feature-first (vertical slice) architecture organizes code by features (auth/, cart/) not layers (models/, repositories/) - each feature is self-contained with domain/data/presentation layers.
  - Declarative navigation (Navigator 2.0/go_router) treats routes as application state - URL determines screen, deep links work automatically, browser back button works on web.
  - Implemented complete login flow: go_router with named routes, route guards for authentication checks, deep linking with custom scheme (myapp://login), redirect logic for protected routes.
  - Navigation pattern: RouteObserver logs navigation events, AutoRoute/GoRoute generates type-safe routes, redirect callback checks auth state and redirects to login if needed.
- Issue:
  - Route guards initially didn't work because redirect callback wasn't checking auth state correctly - fixed by making it async and checking token validity, not just null check.
- Next:
  - Day 7 — Data layer architecture with DTOs, mappers, and code generation (freezed, json_serializable).

## Day 7 — 2026-01-25
- Learned:
  - Data layer architecture separates DTOs (API format with json_serializable) from domain models (business format) using mappers - isolates API changes from app logic.
  - Repository pattern coordinates: try local cache first (fast), fallback to remote API (slow), cache the result, convert DTO to domain via mapper, return Either<Failure, Success>.
  - Code generation with freezed eliminates boilerplate: immutability, copyWith, equality, toString auto-generated from @freezed annotation - reduces ~50 lines to ~10 lines per model.
  - Implemented complete data flow: UserProfileDTO (data/models/) with @freezed + @JsonSerializable → UserProfileMapper (data/mappers/) → UserProfile (domain/entities/) with @freezed only.
- Issue:
  - Initial confusion about where to put @JsonSerializable - clarified that DTOs need it (in data layer), domain entities don't (never serialized directly).
- Next:
  - Day 8 — Review & mini-refactor: audit Week 1 code for consistency, standardize patterns, update architecture diagram, create retrospective.

## Day 8 — 2026-02-02
- Learned:
  - Code review as architectural practice: audited all packages for consistency (naming, patterns, dependency directions), identified technical debt before it compounds.
  - Refactoring priorities: extracted duplicate code to core (HttpClient), standardized state management choice (chose BLoC over Provider/Riverpod for explicit state transitions), cleaned up imports.
  - Documentation is architecture: created WEEK_1_RETROSPECTIVE.md documenting what worked/didn't work, ADR 001 explaining state management choice with tradeoffs, updated architecture diagram with actual implementation.
  - Week 1 foundation complete: packages (core, feature_auth, feature_cart) with Clean Architecture layers, repository pattern with DTOs/mappers, BLoC state management, Either error handling, freezed code generation.
- Issue:
  - Realized keeping all 3 state management implementations in feature_cart creates confusion about "which pattern to use" - decided to archive Provider/Riverpod, standardize on BLoC across all features.
- Next:
  - Week 2 Day 9 — Platform channels & native services: calling Android/iOS native code from Flutter via MethodChannel/EventChannel.
