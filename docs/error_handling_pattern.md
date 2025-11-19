# Error Handling Pattern - Result Type

## Overview

This project implements a **functional error handling** pattern using a custom `Result<L, R>` type (also known as `Either`), which is a common pattern in Clean Architecture to handle errors explicitly in the type system.

## Why Result Type?

### Traditional Try-Catch Problems:
```dart
// ❌ Problems with try-catch:
try {
  final user = await repository.login(email, password);
  // Success path
} catch (e) {
  // What type of error? Network? Validation? Server?
  // We don't know without inspecting the string or type checking
}
```

### Result Type Benefits:
```dart
// ✅ Explicit error handling:
final result = await repository.login(email, password);
result.fold(
  (failure) {
    // Type-safe error handling
    if (failure is ValidationFailure) {
      // Handle validation
    } else if (failure is NetworkFailure) {
      // Handle network issue
    }
  },
  (user) {
    // Success path
  },
);
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│  core/error/                                        │
│  ├── failures.dart    (Error types)                 │
│  │   ├── Failure (base)                             │
│  │   ├── ValidationFailure                          │
│  │   ├── AuthenticationFailure                      │
│  │   ├── NetworkFailure                             │
│  │   └── ServerFailure                              │
│  └── result.dart      (Result wrapper)              │
│      ├── Result<L, R> (sealed)                      │
│      ├── Left<L, R>   (failure case)                │
│      └── Right<L, R>  (success case)                │
└─────────────────────────────────────────────────────┘
```

## Implementation Details

### 1. Failure Hierarchy

```dart
abstract class Failure {
  final String message;
  final String? code;
}

class ValidationFailure extends Failure {}
class AuthenticationFailure extends Failure {}
class NetworkFailure extends Failure {}
class ServerFailure extends Failure {}
```

### 2. Result Type (Either Pattern)

```dart
sealed class Result<L, R> {
  T fold<T>(
    T Function(L failure) onLeft,
    T Function(R success) onRight,
  );
  
  bool get isSuccess;
  bool get isFailure;
}

class Left<L, R> extends Result<L, R> {}  // Failure
class Right<L, R> extends Result<L, R> {} // Success
```

### 3. Usage in Layers

#### Domain Layer (Use Case)
```dart
class LoginUserUseCase {
  Future<Result<Failure, UserEntity>> call(String email, String password) async {
    // Validation happens here
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }
    
    // Delegate to repository
    return await repository.login(email, password);
  }
}
```

#### Data Layer (Repository)
```dart
class UserRepositoryImpl implements UserRepository {
  @override
  Future<Result<Failure, UserEntity>> login(String email, String password) async {
    try {
      // API call
      final response = await api.login(email, password);
      return Right(UserModel.fromJson(response));
    } on SocketException {
      return const Left(NetworkFailure('No internet connection'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Server error: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }
}
```

#### Presentation Layer (Bloc)
```dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  Future<void> _onSubmitted(LoginSubmitted event, Emitter emit) async {
    emit(const LoginLoading());
    
    final result = await loginUser(email, password);
    
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (user) => emit(LoginSuccess(user)),
    );
  }
}
```

## Benefits

### 1. **Type Safety**
- Compiler forces you to handle both success and failure cases
- No forgotten error handling

### 2. **Explicit Error Types**
- Know exactly what can go wrong
- Different UI responses for different errors

### 3. **Testability**
- Easy to test success and failure paths
- Mock specific failure types

### 4. **Clean Architecture Compliance**
- Domain layer defines error contracts
- Data layer maps exceptions to failures
- Presentation layer displays appropriate UI

## Example Flow

```
User enters invalid email → 
  UseCase validates → 
    Returns Left(ValidationFailure) → 
      Bloc emits LoginFailure → 
        UI shows "Invalid email format"

User enters valid credentials → 
  UseCase validates ✓ → 
    Repository calls API → 
      API fails → 
        Returns Left(ServerFailure) → 
          Bloc emits LoginFailure → 
            UI shows "Server error"

User enters valid credentials → 
  UseCase validates ✓ → 
    Repository calls API → 
      API succeeds → 
        Returns Right(UserEntity) → 
          Bloc emits LoginSuccess → 
            UI navigates to home
```

## Testing Examples

```dart
test('returns ValidationFailure when email is empty', () async {
  final result = await loginUser('', 'password');
  
  expect(result.isFailure, true);
  expect(result.getFailure(), isA<ValidationFailure>());
});

test('returns Right with UserEntity on success', () async {
  final result = await loginUser('test@example.com', 'password123');
  
  expect(result.isSuccess, true);
  expect(result.getSuccess().email, 'test@example.com');
});
```

## Comparison with Other Approaches

| Approach | Type Safety | Explicit Errors | Testability | Clean Arch Fit |
|----------|-------------|-----------------|-------------|----------------|
| Try-Catch | ❌ | ❌ | ⚠️ | ❌ |
| Exceptions | ❌ | ❌ | ⚠️ | ❌ |
| Nullable Returns | ⚠️ | ❌ | ✅ | ⚠️ |
| **Result/Either** | ✅ | ✅ | ✅ | ✅ |

## Alternative Packages

If you prefer not to implement your own Result type:

1. **dartz** - Full functional programming library
   ```yaml
   dependencies:
     dartz: ^0.10.1
   ```

2. **fpdart** - Modern functional programming for Dart
   ```yaml
   dependencies:
     fpdart: ^1.1.0
   ```

3. **oxidized** - Rust-inspired Result type
   ```yaml
   dependencies:
     oxidized: ^6.1.0
   ```

## Best Practices

1. ✅ **Always use Result in domain/data boundaries**
2. ✅ **Create specific Failure subclasses for different error types**
3. ✅ **Add error codes for tracking/analytics**
4. ✅ **Use fold() to handle both cases**
5. ❌ **Don't use getSuccess() without checking isSuccess first**
6. ❌ **Don't create generic "Error" failures**

---

**Status:** Implemented ✅
**Location:** `mobile/lib/core/error/`
**Used in:** Auth feature (login flow)
