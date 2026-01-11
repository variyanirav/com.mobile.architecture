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
