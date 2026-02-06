# Week 1 Mental Model: Architecture Foundations

**Purpose:** This document helps you (and any team member) quickly refresh on Week 1 learnings by connecting theory to actual implementation in our codebase. Use this as a cheat sheet for:
- Remembering key concepts
- Finding where patterns live in code
- Understanding why decisions were made
- Teaching new team members

---

## 🧠 Core Mental Models

### Mental Model 1: The Onion (Clean Architecture)

**Theory:**
```
┌─────────────────────────────────┐
│      Presentation (UI)          │  ← Flutter widgets, BLoC
├─────────────────────────────────┤
│      Application (Use Cases)    │  ← Business workflows
├─────────────────────────────────┤
│      Domain (Entities)          │  ← Pure business models
├─────────────────────────────────┤
│      Data (API/DB)              │  ← External systems
└─────────────────────────────────┘

Rule: Dependencies point INWARD only
```

**Where to see it in our code:**
```
packages/feature_auth/lib/
├── presentation/           ← Outer layer (UI)
│   └── login/
│       ├── bloc/          ← State management
│       └── pages/         ← Widgets
├── domain/                 ← Core layer (business logic)
│   ├── entities/          ← Pure models (User, Profile)
│   ├── repositories/      ← Interfaces only
│   └── usecases/          ← Business operations
└── data/                   ← Outer layer (implementation)
    ├── models/            ← DTOs from API
    ├── repositories_impl/ ← Actual implementations
    └── datasources/       ← API/Database calls
```

**Check if you're doing it right:**
```bash
# Domain should NEVER import from data or presentation
cd packages/feature_auth
grep -r "import.*presentation" lib/domain/  # Should be empty!
grep -r "import.*data" lib/domain/          # Should be empty!

# Data CAN import from domain
grep -r "import.*domain" lib/data/          # Should see imports ✓
```

**Real example from our code:**
```dart
// ❌ WRONG - Domain importing from Data
// lib/domain/usecases/login_usecase.dart
import '../../data/models/user_dto.dart';  // NO!

// ✅ RIGHT - Domain only imports domain
// lib/domain/usecases/login_usecase.dart
import '../entities/user_entity.dart';     // YES!
import '../repositories/auth_repository.dart'; // YES!
```

---

### Mental Model 2: Packages as Boundaries

**Theory:**
Packages = physical boundaries that prevent coupling

```
┌──────────────┐      ┌──────────────┐
│ feature_auth │      │ feature_cart │
│              │      │              │
│  (Login)     │      │  (Shopping)  │
└───────┬──────┘      └──────┬───────┘
        │                     │
        └──────┬──────────────┘
               ▼
        ┌─────────────┐
        │    core     │
        │             │
        │  (Shared)   │
        └─────────────┘
```

**Rule:** Features should NOT depend on each other

**Where to see it in our code:**
```
packages/
├── core/              ← Shared infrastructure
│   ├── error/        ← Failure types, Result
│   ├── logging/      ← Logger interface
│   └── widgets/      ← Common UI components
├── feature_auth/     ← Authentication (standalone)
└── feature_cart/     ← Shopping cart (standalone)
```

**Check your dependencies:**
```bash
# Check what feature_auth depends on
cat packages/feature_auth/pubspec.yaml | grep "dependencies:" -A 5
# Should see: core ✓
# Should NOT see: feature_cart ✗

# Check what feature_cart depends on
cat packages/feature_cart/pubspec.yaml | grep "dependencies:" -A 5
# Should see: core ✓
# Should NOT see: feature_auth ✗
```

**Why this matters:**
If `feature_cart` depends on `feature_auth`:
- ❌ Can't extract cart as separate package
- ❌ Can't test cart without auth
- ❌ Changes in auth break cart
- ❌ Deployment coupling (must release together)

**Solution if features need to share data:**
Put the interface in `core`, let both features implement it.

```dart
// ❌ BAD: feature_cart imports feature_auth
import 'package:feature_auth/domain/entities/user.dart';

// ✅ GOOD: Both import from core
// In core/lib/domain/user_provider.dart
abstract class UserProvider {
  User? getCurrentUser();
}

// feature_auth implements it
// feature_cart uses the interface (doesn't know about auth)
```

---

### Mental Model 3: DTO vs Domain (The Translation Layer)

**Theory:**
- **DTO** = Data Transfer Object (API's format)
- **Domain Model** = App's format (what business logic needs)
- **Mapper** = Translator between them

**Why separate them?**
```
API says:          App needs:
"user_id"    →    "id"
"full_name"  →    "name"
1/0          →    true/false
"2024-01-15" →    DateTime object
```

**Where to see it in our code:**

**DTO (in data layer):**
```dart
// packages/feature_auth/lib/data/models/user_profile_dto.dart
@freezed
class UserProfileDTO with _$UserProfileDTO {
  const factory UserProfileDTO({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _UserProfileDTO;
  
  factory UserProfileDTO.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDTOFromJson(json);
}
```

**Domain Model (in domain layer):**
```dart
// packages/feature_auth/lib/domain/entities/user_profile.dart
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    String? avatarUrl,
    required DateTime createdAt,
  }) = _UserProfile;
}
```

**Mapper (in data layer):**
```dart
// packages/feature_auth/lib/data/mappers/user_profile_mapper.dart
class UserProfileMapper {
  UserProfile fromDto(UserProfileDTO dto) {
    return UserProfile(
      id: dto.userId,              // user_id → id
      name: dto.fullName,          // full_name → name
      avatarUrl: dto.avatarUrl,
      createdAt: DateTime.parse(dto.createdAt), // String → DateTime
    );
  }
}
```

**Check your implementation:**
```bash
# DTOs should be in data/models/
find packages/feature_auth/lib/data/models/ -name "*_dto.dart"

# Domain entities should be in domain/entities/
find packages/feature_auth/lib/domain/entities/ -name "*.dart"

# Mappers should be in data/mappers/
find packages/feature_auth/lib/data/mappers/ -name "*_mapper.dart"
```

**Real benefit example:**
```
API changes "user_id" to "userId"
→ Only update UserProfileDTO and mapper
→ UserProfile stays the same
→ Entire app continues working!
```

---

### Mental Model 4: Repository Pattern (The Coordinator)

**Theory:**
Repository = coordinator that hides complexity

```
Presentation asks: "Get me user data"
                    ↓
Repository decides:
  1. Try local cache first (fast)
  2. If not found, fetch from API (slow)
  3. Cache the result
  4. Convert DTO → Domain
  5. Return Either<Failure, User>
```

**Where to see it in our code:**

**Interface (in domain):**
```dart
// packages/feature_auth/lib/domain/repository/user_profile_repository.dart
abstract class UserProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
  Future<Either<Failure, Unit>> updateUserProfile(UserProfile profile);
}
```

**Implementation (in data):**
```dart
// packages/feature_auth/lib/data/repositories_impl/user_profile_repository_impl.dart
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _remoteDataSource;
  final UserProfileLocalDataSource _localDataSource;
  final UserProfileMapper _mapper;
  
  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      // Step 1: Check local cache
      final localDto = await _localDataSource.getUserProfile(userId);
      if (localDto != null) {
        return Right(_mapper.fromDto(localDto));
      }
      
      // Step 2: Fetch from API
      final remoteDto = await _remoteDataSource.getUserProfile(userId);
      
      // Step 3: Cache it
      await _localDataSource.saveUserProfile(remoteDto);
      
      // Step 4: Convert and return
      return Right(_mapper.fromDto(remoteDto));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

**Check your repositories:**
```bash
# Interfaces in domain
ls packages/feature_auth/lib/domain/repository/

# Implementations in data
ls packages/feature_auth/lib/data/repositories_impl/

# Both should exist!
```

**Key pattern:**
- Domain has the interface (what operations)
- Data has the implementation (how to do them)
- Presentation depends on domain interface (not data)

**Why this matters:**
```dart
// Presentation doesn't know about API details
class ProfileBloc {
  final UserProfileRepository _repository; // Interface from domain
  
  Future<void> loadProfile() async {
    final result = await _repository.getUserProfile('123');
    // Don't care if it came from cache or API!
  }
}
```

---

### Mental Model 5: Either/Result (Type-Safe Errors)

**Theory:**
Instead of try-catch everywhere, use types to represent success or failure.

```
Either<Left, Right>
      ↓      ↓
   Failure  Success
```

**Where to see it in our code:**

**Result type (in core):**
```dart
// packages/core/lib/error/result.dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}

// OR using dartz package:
import 'package:dartz/dartz.dart';
Either<Failure, User> // Left = Failure, Right = Success
```

**Failure types (in core):**
```dart
// packages/core/lib/error/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}
```

**Usage in repository:**
```dart
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final dto = await _remoteDataSource.login(email, password);
    final user = _mapper.fromDto(dto);
    return Right(user); // Success!
  } on NetworkException {
    return Left(NetworkFailure('No internet connection'));
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}
```

**Usage in presentation:**
```dart
final result = await _repository.login(email, password);
result.fold(
  (failure) {
    // Left = Error
    showErrorSnackbar(failure.message);
  },
  (user) {
    // Right = Success
    navigateToHome(user);
  },
);
```

**Check your error handling:**
```bash
# All repositories should return Either or Result
grep -r "Future<Either" packages/*/lib/domain/repository/

# All failures should be in core
ls packages/core/lib/error/
```

**Why this is better than try-catch:**
```dart
// ❌ With try-catch (hidden errors)
try {
  final user = await login();
  // What if this throws?
  // Caller doesn't know it can fail!
} catch (e) {
  // Generic error handling
}

// ✅ With Either (explicit errors)
Future<Either<Failure, User>> login() // Type says: "I can fail!"
final result = await login();
// Compiler forces you to handle both cases
```

---

## 📦 Package Tour: Where Everything Lives

### Core Package (`packages/core/`)

**Purpose:** Shared infrastructure used by all features

**What's inside:**
```
lib/
├── core.dart              ← Main export file
├── error/
│   ├── failures.dart      ← All Failure types
│   └── result.dart        ← Result/Either types
├── logging/
│   └── logging.dart       ← Logger interface
└── widgets/
    └── (common widgets)   ← Shared UI components
```

**When to add to core:**
- Code used by 2+ features
- Infrastructure (error handling, logging)
- Common UI components (buttons, cards)
- Shared interfaces (UserProvider, etc.)

**When NOT to add to core:**
- Feature-specific logic
- Business rules for one feature
- One-off utilities

**Check what's exported:**
```bash
cat packages/core/lib/core.dart
```

**Current exports:**
```dart
export 'error/failures.dart';
export 'error/result.dart';
export 'logging/logging.dart';
```

---

### Feature Auth Package (`packages/feature_auth/`)

**Purpose:** Complete authentication feature (login, register, profile)

**Structure:**
```
lib/
├── feature_auth.dart      ← Main export file
├── domain/
│   ├── entities/
│   │   ├── user_entity.dart           ← Pure business model
│   │   └── user_profile.dart          ← With @freezed
│   ├── repository/
│   │   ├── auth_repository.dart       ← Interface
│   │   └── user_profile_repository.dart
│   └── usecases/
│       └── login_usecase.dart         ← Business operation
├── data/
│   ├── models/
│   │   ├── user_dto.dart              ← API format
│   │   └── user_profile_dto.dart      ← With @freezed + JSON
│   ├── repositories_impl/
│   │   └── user_profile_repository_impl.dart  ← Implementation
│   ├── datasources/
│   │   ├── user_profile_remote_datasource.dart  ← API calls
│   │   └── user_profile_local_datasource.dart   ← Cache
│   └── mappers/
│       └── user_profile_mapper.dart   ← DTO → Domain
└── presentation/
    ├── login/
    │   ├── bloc/
    │   │   ├── auth_bloc.dart         ← State management
    │   │   ├── auth_event.dart
    │   │   └── auth_state.dart
    │   └── pages/
    │       └── login_page.dart        ← UI
    └── profile/
        └── (similar structure)
```

**Key files to understand:**

1. **Domain Entity:**
```dart
// lib/domain/entities/user_profile.dart
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    String? avatarUrl,
  }) = _UserProfile;
}
```

2. **Repository Interface:**
```dart
// lib/domain/repository/user_profile_repository.dart
abstract class UserProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String id);
}
```

3. **DTO:**
```dart
// lib/data/models/user_profile_dto.dart
@freezed
class UserProfileDTO with _$UserProfileDTO {
  factory UserProfileDTO({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'full_name') required String fullName,
  }) = _UserProfileDTO;
  
  factory UserProfileDTO.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDTOFromJson(json);
}
```

4. **Mapper:**
```dart
// lib/data/mappers/user_profile_mapper.dart
class UserProfileMapper {
  UserProfile fromDto(UserProfileDTO dto) => UserProfile(
    id: dto.userId,
    name: dto.fullName,
  );
}
```

5. **Repository Implementation:**
```dart
// lib/data/repositories_impl/user_profile_repository_impl.dart
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _remote;
  final UserProfileLocalDataSource _local;
  final UserProfileMapper _mapper;
  
  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String id) async {
    // Implementation with cache, error handling, etc.
  }
}
```

---

### Feature Cart Package (`packages/feature_cart/`)

**Purpose:** Shopping cart feature to validate pattern reusability

**Structure:**
```
lib/
├── feature_cart.dart
├── domain/
│   ├── entities/
│   │   ├── product.dart
│   │   └── cart_item.dart
│   └── repositories/
│       └── cart_repository.dart
├── data/
│   └── repositories/
│       └── cart_repository_impl.dart
└── presentation/
    ├── provider/          ← Provider implementation
    ├── riverpod/          ← Riverpod implementation
    └── bloc/              ← BLoC implementation (chosen)
```

**Why 3 state management implementations?**
Day 4 exploration to compare patterns. Will standardize to BLoC on Day 8.

---

## 🔍 Common Questions (FAQ)

### Q1: Why can't domain import from data?

**Answer:**
Domain = pure business logic. Should work without knowing about APIs, databases, or UI.

**Example:**
```dart
// Domain: "User has a name and email"
class User {
  final String name;
  final String email;
}

// If domain imports from data:
import '../../data/models/user_dto.dart'; // Now coupled to API format!

// What if API changes? Domain breaks!
// What if you swap REST for GraphQL? Domain breaks!
```

**Solution:**
Domain defines interfaces. Data implements them.

---

### Q2: Do I always need a mapper?

**Answer:**
If DTO and Domain are identical, technically no. But in practice, always use mappers because:

1. **APIs change:** Today they're same, tomorrow API adds fields
2. **Clarity:** Makes data flow explicit
3. **Testing:** Easy to test conversion logic
4. **Flexibility:** Can have multiple DTOs for same domain model

**Rule of thumb:**
If you're writing `fromJson` in domain entity, you're doing it wrong. Domain should never know about JSON.

---

### Q3: When should code go in `core` vs feature package?

**Decision tree:**
```
Is it used by 2+ features?
  ├─ Yes → core
  └─ No ─┐
         │
         Is it feature-specific business logic?
           ├─ Yes → feature package
           └─ No → probably core (infrastructure)
```

**Examples:**
- `Failure` types → core (all features need error handling)
- `Logger` → core (all features log)
- `LoadingButton` → core if used by multiple features
- `LoginUseCase` → feature_auth (auth-specific)
- `CartItem` → feature_cart (cart-specific)

---

### Q4: What's the difference between Entity and Model?

**Our convention:**
- **Entity** = Domain object (pure business logic)
- **Model** or **DTO** = Data object (knows about JSON, API, DB)

**Example:**
```dart
// Entity (domain)
class User {
  final String id;
  final String name;
  // No JSON, no API knowledge
}

// Model/DTO (data)
class UserDTO {
  final String userId;
  final String fullName;
  
  factory UserDTO.fromJson(Map<String, dynamic> json) { ... }
  // Knows about JSON serialization
}
```

---

### Q5: Why use freezed?

**Answers:**
1. **Immutability:** Can't accidentally mutate state
2. **copyWith:** Easy to create modified copies
3. **Equality:** Automatic `==` and `hashCode`
4. **toString:** Automatic readable output
5. **Less boilerplate:** ~50 lines → ~10 lines

**Without freezed:**
```dart
class User {
  final String id;
  final String name;
  
  const User({required this.id, required this.name});
  
  User copyWith({String? id, String? name}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.name == name;
  }
  
  @override
  int get hashCode => id.hashCode ^ name.hashCode;
  
  @override
  String toString() => 'User(id: $id, name: $name)';
}
```

**With freezed:**
```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
  }) = _User;
}

// All the above generated automatically!
```

---

### Q6: How do I know if my architecture is right?

**Checklist:**

✅ **Layer separation:**
```bash
# Domain doesn't import data/presentation
grep -r "import.*data" packages/feature_auth/lib/domain/
grep -r "import.*presentation" packages/feature_auth/lib/domain/
# Both should be empty
```

✅ **Feature independence:**
```bash
# Features don't import each other
grep -r "feature_cart" packages/feature_auth/
grep -r "feature_auth" packages/feature_cart/
# Both should be empty
```

✅ **Repository pattern:**
```bash
# Interface in domain
ls packages/*/lib/domain/repository/
# Implementation in data
ls packages/*/lib/data/repositories_impl/
# Both should exist
```

✅ **Error handling:**
```bash
# Repositories return Either or Result
grep "Future<Either" packages/*/lib/domain/repository/*.dart
```

✅ **Code generation:**
```bash
# Freezed models exist
find packages/ -name "*.freezed.dart"
# JSON serialization exists
find packages/ -name "*.g.dart"
```

---

## 🎓 Learning Techniques

### Technique 1: Draw It

After implementing a feature, draw the flow:
```
LoginPage → AuthBloc → LoginUseCase → AuthRepository
              ↓                              ↓
         auth_event.dart           auth_repository.dart (interface)
                                            ↓
                                   AuthRepositoryImpl
                                            ↓
                                   AuthRemoteDataSource
                                            ↓
                                        API call
```

### Technique 2: Explain to Rubber Duck

Pick any component and explain it out loud:
- "AuthRepository is an interface in the domain layer"
- "It defines what operations are available (login, logout)"
- "AuthRepositoryImpl in the data layer implements it"
- "This lets me swap implementations without changing domain"

### Technique 3: Code Golf (Simplify)

Can you simplify this?
```dart
// Before
Future<Either<Failure, User>> getUser(String id) async {
  try {
    final dto = await _remoteDataSource.getUser(id);
    final entity = _mapper.fromDto(dto);
    return Right(entity);
  } on NetworkException {
    return Left(NetworkFailure('No network'));
  }
}

// After (same behavior, cleaner)
Future<Either<Failure, User>> getUser(String id) async {
  try {
    final dto = await _remoteDataSource.getUser(id);
    return Right(_mapper.fromDto(dto));
  } on NetworkException {
    return Left(NetworkFailure('No network'));
  }
}
```

### Technique 4: Test Your Understanding

Without looking at code, can you:
1. Draw the Clean Architecture layers?
2. Explain DTO vs Entity difference?
3. Describe the Repository pattern?
4. List what goes in `core` package?
5. Explain why features don't depend on each other?

If yes, you understand! If no, re-read that section.

---

## 🔗 Cross-References

### Where concepts connect:

**Clean Architecture (Day 2)** + **Packages (Day 3)** =
> Each package has Clean Architecture layers

**Repository Pattern (Day 7)** + **Dependency Injection (Day 5)** =
> Repositories injected into UseCases/BLoCs

**State Management (Day 4)** + **Feature Architecture (Day 6)** =
> Each feature has BLoC for state management

**DTOs (Day 7)** + **Code Generation (Day 7)** =
> DTOs use freezed + json_serializable

**Error Handling (Day 7)** + **Repositories (Day 7)** =
> Repositories return Either<Failure, Success>

---

## 🎯 Week 1 Success Criteria

You've mastered Week 1 if you can:

- [ ] Draw Clean Architecture layers from memory
- [ ] Explain why domain doesn't import from data
- [ ] Create a new feature following the same patterns
- [ ] Explain DTO vs Domain model with real example
- [ ] Implement Repository pattern with tests
- [ ] Set up freezed and json_serializable
- [ ] Use Either/Result for error handling
- [ ] Explain when code goes in core vs feature
- [ ] Show someone your architecture diagram
- [ ] Defend your state management choice

---

## 🚀 What's Next: Week 2

Week 2 is about **platform integration:**
- Day 9: Platform channels (calling native code)
- Day 10: Plugin architecture
- Day 11: Performance & memory profiling
- Day 12: Lifecycle & design systems
- Day 13: i18n/l10n & SDK integration
- Day 14: Security & build flavors
- Day 15: Review & docs

**Why Week 1 foundation matters:**
> Platform code is messy. Without clean architecture, you'll have spaghetti code mixing UI, business logic, and native calls. Week 1's separation of concerns will save you!

---

**Remember:** This document is alive. As you implement more features, update it with real examples from your codebase. Future you (and your team) will thank you! 🎉
