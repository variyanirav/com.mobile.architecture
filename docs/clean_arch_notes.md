# Clean Architecture - Flutter Mapping

## Overview

This document explains how Clean Architecture principles are applied in this Flutter project, serving as a quick reference for developers and architects.

---

## Core Principle: The Dependency Rule

> **Dependencies must point inward only. Inner layers never import outer layers.**

```
                 ┌─────────────────────────┐
                 │    Frameworks & UI      │  ← Outermost (Flutter, Widgets)
                 └───────────┬─────────────┘
                             │
                 ┌───────────▼─────────────┐
                 │   Interface Adapters    │  ← Controllers, Presenters, BLoCs
                 └───────────┬─────────────┘
                             │
                 ┌───────────▼─────────────┐
                 │    Application Logic    │  ← Use Cases
                 └───────────┬─────────────┘
                             │
                 ┌───────────▼─────────────┐
                 │    Domain (Entities)    │  ← Innermost (Pure business logic)
                 └─────────────────────────┘

All arrows point INWARD ↑
```

---

## Layer Mapping

### 1. Domain Layer (Core)
**Location:** `lib/features/{feature}/domain/`

**Purpose:** Pure business rules, independent of frameworks

**Contains:**
- **Entities** - Business objects with no framework dependencies
- **Repository Interfaces** - Contracts for data access
- **Use Cases** - Business workflows

**Rules:**
- ✅ No Flutter imports
- ✅ No external library dependencies (except pure Dart)
- ✅ Can import other domain entities
- ❌ Cannot import data or presentation layers

**Example:**
```dart
// domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String email;
  
  UserEntity({required this.id, required this.email});
}

// domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<Result<Failure, UserEntity>> login(String email, String password);
}

// domain/usecases/login_user_use_case.dart
class LoginUserUseCase {
  final UserRepository repository;
  
  Future<Result<Failure, UserEntity>> call(String email, String password) {
    // Validation and business logic here
    return repository.login(email, password);
  }
}
```

---

### 2. Data Layer (Infrastructure)
**Location:** `lib/features/{feature}/data/`

**Purpose:** Implement data access, convert external data to domain entities

**Contains:**
- **Models** - Entities with serialization logic (`fromJson`, `toJson`)
- **Repository Implementations** - Concrete implementations of domain interfaces
- **Data Sources** - API clients, local database access

**Rules:**
- ✅ Can import domain layer (entities, interfaces)
- ✅ Can use external packages (http, dio, sqflite)
- ✅ Can import Flutter for platform-specific code
- ❌ Cannot import presentation layer

**Example:**
```dart
// data/entities/user_model.dart
class UserModel extends UserEntity {
  UserModel({required super.id, required super.email});
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], email: json['email']);
  }
  
  Map<String, dynamic> toJson() => {'id': id, 'email': email};
}

// data/repositories_impl/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  @override
  Future<Result<Failure, UserEntity>> login(String email, String password) async {
    try {
      final response = await http.post('/auth/login', body: {...});
      return Right(UserModel.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

---

### 3. Presentation Layer (UI)
**Location:** `lib/features/{feature}/presentation/`

**Purpose:** Display UI, handle user interaction, manage UI state

**Contains:**
- **Widgets/Pages** - Flutter UI components
- **BLoCs/Cubits** - State management
- **Events/States** - BLoC contracts

**Rules:**
- ✅ Can import domain layer (use cases, entities)
- ✅ Can use Flutter and UI packages
- ✅ Should use dependency injection for use cases
- ❌ Cannot import data layer directly
- ❌ Cannot contain business logic (belongs in use cases)

**Example:**
```dart
// presentation/bloc/login_bloc.dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUserUseCase loginUser;
  
  LoginBloc({required this.loginUser}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }
  
  Future<void> _onSubmitted(LoginSubmitted event, Emitter emit) async {
    emit(LoginLoading());
    
    final result = await loginUser(email, password);
    
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (user) => emit(LoginSuccess(user)),
    );
  }
}
```

---

## Feature Structure

Each feature follows this structure:

```
lib/features/auth/
├── domain/
│   ├── entities/
│   │   └── user_entity.dart          # Pure business object
│   ├── repositories/
│   │   └── user_repository.dart      # Interface (abstract)
│   └── usecases/
│       └── login_user_use_case.dart  # Business logic
├── data/
│   ├── entities/
│   │   └── user_model.dart           # Entity + JSON
│   └── repositories_impl/
│       └── user_repository_impl.dart # Implementation
└── presentation/
    ├── bloc/
    │   ├── login_bloc.dart
    │   ├── login_event.dart
    │   └── login_state.dart
    └── screen/
        └── login_page.dart           # UI
```

---

## Key Concepts

### Entities vs Models

| Aspect | Entity (Domain) | Model (Data) |
|--------|----------------|--------------|
| **Location** | `domain/entities/` | `data/entities/` |
| **Purpose** | Business logic | Data transfer |
| **Dependencies** | None | JSON, APIs |
| **Serialization** | No | Yes (`fromJson`, `toJson`) |
| **Example** | `UserEntity` | `UserModel extends UserEntity` |

**Why separate?**
- API schema can change without breaking business logic
- Domain layer stays pure and testable
- Can merge data from multiple sources into one entity

---

### Repository Pattern

**Interface in Domain:**
```dart
abstract class UserRepository {
  Future<Result<Failure, UserEntity>> login(String email, String password);
}
```

**Implementation in Data:**
```dart
class UserRepositoryImpl implements UserRepository {
  final ApiClient api;
  final LocalStorage cache;
  
  @override
  Future<Result<Failure, UserEntity>> login(...) async {
    // Call API, handle errors, cache data
  }
}
```

**Benefits:**
- Domain doesn't know about HTTP, JSON, databases
- Easy to swap implementations (mock for testing)
- Can add caching, retry logic without changing domain

---

### Use Cases (Application Layer)

Each use case represents **one business workflow**.

**Rules:**
- One use case = one `call()` method
- Contains input validation
- Orchestrates repositories
- Returns `Result<Failure, Entity>`

**Example:**
```dart
class LoginUserUseCase {
  final UserRepository repository;
  
  Future<Result<Failure, UserEntity>> call(String email, String password) async {
    // Validation
    if (email.isEmpty) return Left(ValidationFailure('Email required'));
    if (!email.contains('@')) return Left(ValidationFailure('Invalid email'));
    
    // Delegate to repository
    return await repository.login(email, password);
  }
}
```

---

## Error Handling: Result Type

We use `Result<Failure, Success>` instead of try-catch:

**Why?**
- ✅ Type-safe: Compiler forces error handling
- ✅ Explicit: Know exactly what can fail
- ✅ Composable: Can chain operations
- ✅ Testable: Easy to test both paths

**Pattern:**
```dart
// Return type is explicit about failure and success
Future<Result<Failure, UserEntity>> login(...) async {
  // Return Left for errors
  return Left(NetworkFailure('No connection'));
  
  // Return Right for success
  return Right(userEntity);
}

// Consumer handles both cases
result.fold(
  (failure) => handleError(failure),
  (user) => handleSuccess(user),
);
```

See `docs/error_handling_pattern.md` for details.

---

## Dependency Injection

Use **constructor injection** to provide dependencies:

```dart
// ❌ Bad: Direct instantiation
class LoginBloc {
  final repository = UserRepositoryImpl(); // Hardcoded!
}

// ✅ Good: Constructor injection
class LoginBloc {
  final LoginUserUseCase loginUser;
  
  LoginBloc({required this.loginUser}); // Injected
}

// Wire dependencies in main or page
BlocProvider(
  create: (_) => LoginBloc(
    loginUser: LoginUserUseCase(UserRepositoryImpl()),
  ),
)
```

**Benefits:**
- Easy to test (inject mocks)
- Easy to swap implementations
- Clear dependencies

---

## Testing Strategy

### Unit Tests - Domain Layer
```dart
test('LoginUserUseCase returns failure for empty email', () async {
  final useCase = LoginUserUseCase(mockRepository);
  
  final result = await useCase('', 'password');
  
  expect(result.isFailure, true);
  expect(result.getFailure(), isA<ValidationFailure>());
});
```

### Widget Tests - Presentation Layer
```dart
testWidgets('LoginPage shows error on failed login', (tester) async {
  await tester.pumpWidget(LoginPage());
  
  await tester.enterText(find.byType(TextField).first, 'test@example.com');
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
  
  expect(find.text('Login failed'), findsOneWidget);
});
```

### Integration Tests - Full Flow
```dart
test('Full login flow', () async {
  final bloc = LoginBloc(loginUser: realUseCase);
  
  bloc.add(LoginSubmitted());
  
  await expectLater(
    bloc.stream,
    emitsInOrder([LoginLoading(), LoginSuccess(user)]),
  );
});
```

---

## Best Practices

### ✅ DO

1. **Keep domain pure** - No Flutter, no external packages
2. **Use interfaces** - Define contracts in domain, implement in data
3. **One responsibility** - One use case per business workflow
4. **Inject dependencies** - Constructor injection everywhere
5. **Return Result types** - Make errors explicit
6. **Test each layer** - Unit tests for domain, widget tests for UI

### ❌ DON'T

1. **Don't put business logic in BLoC** - Belongs in use cases
2. **Don't import data in presentation** - Use dependency injection
3. **Don't import Flutter in domain** - Keep it pure
4. **Don't use try-catch everywhere** - Use Result type
5. **Don't skip validation** - Always validate in use cases
6. **Don't couple to implementation** - Depend on abstractions

---

## Common Violations & Fixes

| Violation | Why Bad | Fix |
|-----------|---------|-----|
| BLoC calls repository directly | Bypasses business logic | BLoC → UseCase → Repository |
| Entity has `fromJson` | Domain depends on JSON format | Create Model in data layer |
| UI imports data layer | Breaks dependency rule | Inject through constructor |
| Business logic in BLoC | Not testable independently | Move to use case |
| Hardcoded repository | Can't test with mocks | Use dependency injection |

---

## Quick Reference

### Import Rules

```dart
// ✅ Domain can import:
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/core/error/failures.dart';

// ✅ Data can import:
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/user_repository.dart';
import 'package:http/http.dart';

// ✅ Presentation can import:
import 'package:flutter/material.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/usecases/login_user.dart';

// ❌ Never:
// - Domain importing data or presentation
// - Presentation importing data
// - Domain importing Flutter
```

---

## Resources

- **Uncle Bob's Clean Architecture:** [blog.cleancoder.com](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- **Reso Coder Flutter Clean Architecture:** YouTube series
- **Project Examples:** See `lib/features/auth/` for complete implementation

---

**Last Updated:** Day 2 - November 19, 2025  
**Status:** Implemented and tested ✅  
**Next Steps:** Add more features following the same pattern
