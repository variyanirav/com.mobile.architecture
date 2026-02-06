# **Day 8: Review & Mini-Refactor**

---

## 🎯 Goal

Consolidate Week 1 learnings by reviewing, refactoring, and documenting your architectural decisions. This is your **quality checkpoint** before moving to advanced platform integration in Week 2. By the end of Day 8, you'll:

* **Review all code from Days 2-7** for consistency and quality
* **Identify and fix technical debt** before it compounds
* **Refactor inconsistencies** in naming, structure, and patterns
* **Update architecture diagrams** with actual implementation details
* **Create Week 1 retrospective** documenting lessons learned
* **Standardize patterns** across all packages
* **Prepare a clean foundation** for Week 2's native integration

**Time allocation (60 minutes):**
- 20m: Comprehensive code review and identify technical debt
- 20m: Refactor inconsistencies and standardize patterns
- 20m: Update documentation and create retrospective

**Why Day 8 matters:**
> This is where developers become architects. You're not just writing code anymore—you're evaluating decisions, identifying patterns, and creating maintainable systems. Week 2 adds native complexity; solidify your foundation now.

---

## 🔍 Step 1: Comprehensive Code Review (20 minutes)

### 📘 What to Review?

Day 8 is about **architectural quality**, not just "does it work". You're evaluating:
- **Consistency**: Do all features follow the same patterns?
- **Coupling**: Are dependencies pointing in the right direction?
- **Clarity**: Can a new developer understand the structure?
- **Completeness**: Are there half-implemented patterns?
- **Standards**: Is naming, formatting, and organization consistent?

---

### ✅ Review Checklist

#### **1. Package Structure & Boundaries**

**Check your packages directory:**
```
packages/
├── core/              ← Shared infrastructure
├── feature_auth/      ← Authentication feature
└── feature_cart/      ← Shopping cart feature
```

**Questions to ask:**

- [ ] Does `core` package contain ONLY shared utilities (no feature logic)?
- [ ] Do feature packages depend on `core` (not on each other)?
- [ ] Are all packages using the same Clean Architecture layers?
- [ ] Is there duplicated code that should be in `core`?

**How to check:**
```bash
# Navigate to project root
cd /path/to/com.mobile.architecture

# Check dependencies
cat packages/feature_auth/pubspec.yaml | grep "dependencies:" -A 10
cat packages/feature_cart/pubspec.yaml | grep "dependencies:" -A 10

# Look for cross-feature dependencies (should not exist!)
grep -r "feature_cart" packages/feature_auth/lib/
grep -r "feature_auth" packages/feature_cart/lib/
```

**✅ Good dependency direction:**
```
feature_auth → core ✓
feature_cart → core ✓
core → (nothing) ✓
```

**❌ Bad dependency direction:**
```
feature_auth → feature_cart ✗ (features shouldn't depend on each other)
core → feature_auth ✗ (core can't depend on features)
```

---

#### **2. Clean Architecture Consistency**

**Check each feature package has proper layers:**

**Expected structure for each feature:**
```
packages/feature_auth/lib/
├── domain/                    ← Pure business logic
│   ├── entities/             ← Domain models
│   ├── repositories/         ← Interfaces (abstractions)
│   └── usecases/             ← Business operations
├── data/                      ← External implementations
│   ├── models/               ← DTOs (Data Transfer Objects)
│   ├── repositories_impl/    ← Repository implementations
│   ├── datasources/          ← Remote/Local data sources
│   └── mappers/              ← DTO ↔ Domain conversion
└── presentation/              ← UI layer
    ├── bloc/ (or provider/)  ← State management
    └── pages/                ← UI screens
```

**Questions to ask:**

- [ ] Does domain layer have NO dependencies on data or presentation?
- [ ] Are all repository interfaces in domain/repositories/?
- [ ] Are all repository implementations in data/repositories_impl/?
- [ ] Are DTOs separate from domain entities?
- [ ] Do you have mappers converting DTOs to domain models?

**How to verify:**
```bash
# Check if domain has imports from data/presentation (should be NONE)
grep -r "import.*data/" packages/feature_auth/lib/domain/
grep -r "import.*presentation/" packages/feature_auth/lib/domain/

# Check if repositories are interfaces in domain
grep "abstract class.*Repository" packages/feature_auth/lib/domain/repository/*.dart

# Check if implementations are in data layer
grep "implements.*Repository" packages/feature_auth/lib/data/repositories_impl/*.dart
```

---

#### **3. State Management Consistency**

**You explored 3 patterns on Day 4:**
- Provider (ChangeNotifier)
- Riverpod (StateNotifier)
- BLoC (Event → State)

**Decision point:**

- [ ] Have you chosen ONE primary pattern for your project?
- [ ] Are all features using the same state management?
- [ ] Do you have a clear reason documented (ADR)?

**Real-world example from your project:**

Your `feature_cart` has all three implementations:
```
presentation/
├── provider/
├── riverpod/
└── bloc/
```

**For Day 8:**
1. **Choose one** based on:
   - Team familiarity
   - Testing ease
   - Project complexity
   - Performance needs

2. **Document why** (create ADR on Day 8)

3. **Remove or archive** the other two implementations

4. **Standardize** feature_auth to use the same pattern

**Example decision:**
> "We chose **BLoC** because: (1) Explicit state transitions for debugging, (2) Separation of business logic from UI, (3) Team familiar with streams, (4) Better for complex state machines (auth flows, multi-step forms)"

---

#### **4. Error Handling Consistency**

**Check your core package:**
```dart
// packages/core/lib/error/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure { ... }
class ServerFailure extends Failure { ... }
class CacheFailure extends Failure { ... }
```

**Check your repositories use Either pattern:**
```dart
// domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  // OR
  Future<Result<User>> login(String email, String password);
}
```

**Questions to ask:**

- [ ] Are all repositories returning `Either<Failure, SuccessType>`?
- [ ] Are all Failure types defined in `core/error/`?
- [ ] Is error handling consistent across features?
- [ ] Do you handle all failure types in presentation layer?

**How to check:**
```bash
# Find all repository methods
grep -r "Future<.*>" packages/*/lib/domain/repository/*.dart

# Check if they use Either or Result
grep -r "Either<Failure" packages/*/lib/domain/
grep -r "Result<" packages/*/lib/domain/
```

---

#### **5. Code Generation & Freezed**

**Day 7 introduced code generation:**
- `freezed` for immutable models
- `json_serializable` for JSON conversion
- `build_runner` to generate code

**Check your models:**
```dart
// Domain model with freezed
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    String? avatarUrl,
  }) = _UserProfile;
}

// DTO with freezed + json
@freezed
class UserProfileDTO with _$UserProfileDTO {
  const factory UserProfileDTO({
    @JsonKey(name: 'user_id') required String userId,
    required String email,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _UserProfileDTO;
  
  factory UserProfileDTO.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDTOFromJson(json);
}
```

**Questions to ask:**

- [ ] Are all DTOs using `@freezed` and `@JsonSerializable`?
- [ ] Are all domain models immutable (final fields or freezed)?
- [ ] Have you run `dart run build_runner build` recently?
- [ ] Are generated files (.freezed.dart, .g.dart) in .gitignore?

**How to check:**
```bash
# Check for freezed usage
grep -r "@freezed" packages/*/lib/

# Check if generated files exist
find packages/ -name "*.freezed.dart"
find packages/ -name "*.g.dart"

# Regenerate if needed
melos run build_runner
# or
dart run build_runner build --delete-conflicting-outputs
```

---

#### **6. Naming Consistency**

**Common inconsistencies to fix:**

| ❌ Inconsistent | ✅ Consistent |
|----------------|---------------|
| `AuthRepo`, `auth_repository`, `authRepository` | `AuthRepository` (PascalCase for classes) |
| `user_dto.dart`, `UserDTO.dart` | `user_dto.dart` (snake_case for files) |
| `fetchUser`, `getUser`, `retrieveUser` | Pick one: `getUser` or `fetchUser` consistently |
| `login()`, `signIn()`, `authenticate()` | Pick one: `login()` throughout |

**How to find:**
```bash
# Check file naming
find packages/ -name "*.dart" | grep -v ".freezed.dart" | grep -v ".g.dart"

# Check for mixed naming conventions
grep -rn "class.*Repository" packages/*/lib/domain/
grep -rn "class.*Repo" packages/*/lib/domain/
```

**Standardize in Day 8:**
- Class names: `PascalCase`
- File names: `snake_case.dart`
- Function names: `camelCase`
- Constants: `kPascalCase` or `SCREAMING_SNAKE_CASE`
- Private members: `_leadingUnderscore`

---

## 🔧 Step 2: Refactor Inconsistencies (20 minutes)

### 📘 What to Refactor?

Based on your code review, prioritize these refactorings:

---

### **Refactoring 1: Consolidate Duplicate Code**

**Problem:**
You might have similar code in both `feature_auth` and `feature_cart`.

**Example duplicate:**
```dart
// feature_auth/lib/data/datasources/auth_remote_datasource.dart
class AuthRemoteDataSource {
  final Dio _dio;
  
  Future<Map<String, dynamic>> makeRequest(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } catch (e) {
      throw ServerException();
    }
  }
}

// feature_cart/lib/data/datasources/cart_remote_datasource.dart
class CartRemoteDataSource {
  final Dio _dio;
  
  // Same code! 🚨
  Future<Map<String, dynamic>> makeRequest(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } catch (e) {
      throw ServerException();
    }
  }
}
```

**✅ Refactored (move to core):**

Create `packages/core/lib/network/http_client.dart`:
```dart
/// Centralized HTTP client wrapper
class HttpClient {
  final Dio _dio;
  
  const HttpClient(this._dio);
  
  Future<T> get<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.get(endpoint);
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return NetworkFailure('Connection timeout');
    }
    if (e.response?.statusCode == 401) {
      return AuthFailure('Unauthorized');
    }
    return ServerFailure('Server error: ${e.message}');
  }
}
```

Now both features use the shared client:
```dart
// feature_auth/lib/data/datasources/auth_remote_datasource.dart
class AuthRemoteDataSource {
  final HttpClient _client; // ← From core
  
  Future<UserDTO> login(String email, String password) async {
    return _client.get(
      '/auth/login',
      fromJson: UserDTO.fromJson,
    );
  }
}
```

---

### **Refactoring 2: Standardize State Management**

**Based on Day 4 exploration, choose ONE pattern.**

**Example: Standardizing on BLoC**

**Before (mixed patterns):**
```
feature_auth/
  └── presentation/
      └── login/
          └── bloc/           ← Uses BLoC
          
feature_cart/
  └── presentation/
      ├── provider/           ← Has all 3! 🚨
      ├── riverpod/
      └── bloc/
```

**After refactoring:**
```
feature_auth/
  └── presentation/
      └── login/
          └── bloc/           ← BLoC only ✓
          
feature_cart/
  └── presentation/
      └── cart/
          └── bloc/           ← BLoC only ✓
```

**Steps:**
1. Choose pattern (BLoC in this example)
2. Keep only `presentation/bloc/` in feature_cart
3. Delete `presentation/provider/` and `presentation/riverpod/`
4. Update exports in `feature_cart.dart`
5. Document choice in ADR (see Step 3)

---

### **Refactoring 3: Extract Common Widgets to Core**

**Problem:**
Similar UI widgets duplicated across features.

**Example:**
```dart
// feature_auth/lib/presentation/widgets/loading_button.dart
class LoadingButton extends StatelessWidget {
  // Implementation
}

// feature_cart/lib/presentation/widgets/loading_button.dart
class LoadingButton extends StatelessWidget {
  // Same implementation! 🚨
}
```

**✅ Refactored:**

Create `packages/core/lib/widgets/loading_button.dart`:
```dart
/// Reusable loading button used across features
class LoadingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  
  const LoadingButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
```

Export from core:
```dart
// packages/core/lib/core.dart
export 'widgets/loading_button.dart';
```

Both features now import from core:
```dart
import 'package:core/core.dart';

// Use LoadingButton
```

---

### **Refactoring 4: Standardize Repository Patterns**

**Check all repositories follow the same structure:**

**✅ Standard pattern:**
```dart
// Domain: Interface
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
  Future<Either<Failure, User>> updateUser(User user);
}

// Data: Implementation
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;
  final UserMapper _mapper;
  
  const UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._mapper,
  );
  
  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      // Try local first
      final localDto = await _localDataSource.getUser(id);
      if (localDto != null) {
        return Right(_mapper.fromDto(localDto));
      }
      
      // Fetch from remote
      final remoteDto = await _remoteDataSource.getUser(id);
      
      // Cache locally
      await _localDataSource.saveUser(remoteDto);
      
      // Return domain model
      return Right(_mapper.fromDto(remoteDto));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

**Ensure all your repositories:**
- [ ] Have interface in `domain/repositories/`
- [ ] Have implementation in `data/repositories_impl/`
- [ ] Use dependency injection (constructor)
- [ ] Return `Either<Failure, T>` or `Result<T>`
- [ ] Have both remote and local data sources (if applicable)
- [ ] Use mappers to convert DTOs to domain models

---

### **Refactoring 5: Clean Up Imports**

**Remove unused imports:**
```bash
# Find unused imports (requires dart analyzer)
dart analyze
```

**Organize imports:**
```dart
// ✅ Good order:
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports (alphabetically)
import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';

// 4. Relative imports
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';
```

**Auto-format:**
```bash
# Format all Dart files
dart format .

# Or use Melos
melos run format
```

---

## 📝 Step 3: Update Documentation (20 minutes)

### **Task 1: Update Architecture Diagram**

**Original diagram (from Day 2):** Theoretical structure  
**Day 8 diagram:** Actual implementation

**Create or update:** `docs/architecture_diagram.md`

**Include:**

1. **Actual package structure:**
```
┌─────────────────────────────────────────────────────────────┐
│                        Mobile App                            │
│                     (mobile/lib/)                            │
│                                                              │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │   Login UI   │────────▶│  Auth BLoC   │                 │
│  │              │         │              │                 │
│  └──────────────┘         └──────────────┘                 │
│                                  │                          │
└──────────────────────────────────┼──────────────────────────┘
                                   │
                                   ↓ uses
┌──────────────────────────────────────────────────────────────┐
│                    Feature Auth Package                      │
│                 (packages/feature_auth/)                     │
│                                                              │
│  Domain Layer:                                              │
│    • UserEntity                                             │
│    • AuthRepository (interface)                             │
│    • LoginUseCase                                           │
│                                                              │
│  Data Layer:                                                │
│    • UserDTO (with @freezed)                                │
│    • AuthRepositoryImpl                                     │
│    • AuthRemoteDataSource                                   │
│    • UserMapper (DTO ↔ Entity)                              │
│                                                              │
│  Presentation Layer:                                        │
│    • AuthBloc / AuthEvent / AuthState                       │
│    • LoginPage                                              │
└──────────────────────────────────────────────────────────────┘
                                   │
                                   ↓ depends on
┌──────────────────────────────────────────────────────────────┐
│                      Core Package                            │
│                  (packages/core/)                            │
│                                                              │
│  • Result<T> / Either<L, R>                                 │
│  • Failure types (NetworkFailure, ServerFailure, etc.)      │
│  • Logger interface                                         │
│  • HttpClient (Dio wrapper)                                 │
│  • Common widgets (LoadingButton, etc.)                     │
└──────────────────────────────────────────────────────────────┘
```

2. **Dependency graph:**
```
mobile/
  ├─► feature_auth
  ├─► feature_cart
  └─► core
  
feature_auth/
  └─► core

feature_cart/
  └─► core

core/
  └─► (external packages only: dio, freezed, etc.)
```

3. **Data flow:**
```
User Action (LoginPage)
    ↓
AuthBloc.add(LoginRequested)
    ↓
LoginUseCase.execute(email, password)
    ↓
AuthRepository.login(email, password)
    ↓
AuthRemoteDataSource.login(email, password)
    ↓
HttpClient.post('/auth/login')
    ↓
API Response (UserDTO)
    ↓
UserMapper.fromDto(dto) → UserEntity
    ↓
Either<Failure, UserEntity> returned
    ↓
AuthBloc.emit(Authenticated(user))
    ↓
UI shows home screen
```

---

### **Task 2: Create Week 1 Retrospective**

**Create:** `WEEK_1_RETROSPECTIVE.md`

**Template:**

```markdown
# Week 1 Retrospective (Days 1-8)

**Date:** [Your date]  
**Focus:** Core Architecture Foundations

---

## 🎯 What We Set Out to Do

Build a solid architectural foundation with:
- Clean Architecture layering
- Modular package structure
- State management patterns
- Dependency injection
- Feature-first architecture
- Data layer with code generation

---

## ✅ What Worked Well

### 1. Package Modularization (Day 3)

**What we did:**
- Created `core` package for shared infrastructure
- Created `feature_auth` package with complete Clean Architecture layers
- Created `feature_cart` package to test pattern reusability
- Set up Melos for monorepo management

**Why it worked:**
- Clear boundaries between features
- Easy to build/test packages independently
- Forced us to think about dependencies
- Real-world validation of patterns

**Evidence:**
```bash
melos run analyze  # All packages pass ✓
melos run test     # All tests pass ✓
```

### 2. Data Layer Architecture (Day 7)

**What we did:**
- Implemented DTO ↔ Domain model separation
- Used freezed for immutable models
- Used json_serializable for JSON parsing
- Created mapper layer for clean conversion
- Implemented Either<Failure, Success> pattern

**Why it worked:**
- API changes isolated in DTOs
- Type-safe error handling
- Reduced boilerplate with code generation
- Easy to test each layer independently

**Example:**
```dart
// Domain (what app needs)
class User {
  final String id;
  final String name;
}

// DTO (what API sends)
@freezed
class UserDTO with _$UserDTO {
  @JsonKey(name: 'user_id') final String userId;
  @JsonKey(name: 'full_name') final String fullName;
}

// Mapper (clean conversion)
class UserMapper {
  User fromDto(UserDTO dto) => User(
    id: dto.userId,
    name: dto.fullName,
  );
}
```

### 3. State Management Exploration (Day 4)

**What we did:**
- Implemented same feature (cart) with 3 patterns:
  - Provider (simple, mutable state)
  - Riverpod (immutable, compile-time safety)
  - BLoC (explicit events, testable)

**Why it worked:**
- Hands-on comparison (not just theory)
- Understood tradeoffs viscerally
- Can now make informed choice
- Learned when to use each pattern

**Key insight:**
> BLoC is best for our project because we need:
> - Explicit state transitions (auth flows are complex)
> - Testability (business logic separate from UI)
> - Team familiarity (coming from Redux background)

---

## ⚠️ What Didn't Go As Planned

### 1. Melos Configuration (Day 3)

**Problem:**
- Started with `melos.yaml` (deprecated in Melos 7.x)
- Got confusing errors about workspace configuration

**What we learned:**
- Melos 7.x uses Pub Workspaces (Dart 3.6+)
- Configuration goes in root `pubspec.yaml`
- All packages need `resolution: workspace` field

**Solution:**
- Migrated to new format
- Updated all package pubspecs
- Created migration notes for team

**Time cost:** ~30 minutes debugging

### 2. Multiple State Management Patterns

**Problem:**
- Kept all 3 implementations in `feature_cart`
- Created confusion about "which pattern are we using?"
- Increased maintenance burden

**What we learned:**
- Exploration is valuable, but need to decide
- Can't maintain 3 patterns in production
- Need ADR to document choice

**Solution for Day 8:**
- Choose BLoC as primary pattern
- Archive other implementations (don't delete, keep for reference)
- Document decision in ADR
- Standardize all features on BLoC

**Time cost:** ~20 minutes refactoring

### 3. Import Boundaries (Day 3)

**Problem:**
- Initially had circular dependencies
- Domain layer importing from data layer
- Features importing from each other

**What we learned:**
- Dependency rule violations are easy to create
- Manual checking is error-prone
- Need automated enforcement

**Solution:**
- Created `scripts/check_import_boundaries.dart`
- Will integrate into CI (Day 20)
- Added to pre-commit hook

**Example violation:**
```dart
// ❌ domain importing from data
// packages/feature_auth/lib/domain/usecases/login.dart
import '../../data/models/user_dto.dart'; // WRONG!
```

**Fixed:**
```dart
// ✅ domain only imports from domain
import '../entities/user_entity.dart'; // CORRECT
```

---

## 📊 Metrics & Achievements

### Code Quality
- **Packages created:** 3 (core, feature_auth, feature_cart)
- **Clean Architecture layers:** Fully implemented in all features
- **Test coverage:** Not measured yet (will baseline on Day 11)
- **Lint issues:** 0 (all packages pass `dart analyze`)

### Architectural Patterns Implemented
- ✅ Repository pattern (with interfaces)
- ✅ DTO ↔ Domain model separation
- ✅ Mapper pattern
- ✅ Either/Result for error handling
- ✅ Dependency injection (constructor-based)
- ✅ State management (BLoC chosen)
- ✅ Code generation (freezed + json_serializable)
- ✅ Feature-first architecture

### Documentation Created
- ✅ Architecture diagrams (Clean Architecture, package structure)
- ✅ C4 Context diagram
- ✅ C4 Container diagram
- ✅ Day 1-7 learning notes
- ✅ LEARNING.md with daily entries
- ⏳ ADR for state management (to be created Day 8)

---

## 🎓 Key Learnings

### 1. Architecture is About Tradeoffs

**Insight:**
Every pattern has costs and benefits. There's no "best" pattern—only "best for this context."

**Example:**
- Provider: Simple, but global state can be messy
- Riverpod: Safe, but learning curve steep
- BLoC: Testable, but verbose for simple UI

**Takeaway:**
Document WHY you chose a pattern (ADR), not just WHAT pattern.

### 2. Package Boundaries Force Clear Thinking

**Insight:**
Can't have circular dependencies across packages. Forces you to think about:
- What's shared (core)?
- What's feature-specific?
- What direction should dependencies flow?

**Example:**
```
❓ Should feature_cart depend on feature_auth?
❌ No! Features should be independent.
✅ If they need to share data, put interface in core.
```

### 3. Code Generation Reduces Boilerplate (But Has Setup Cost)

**Insight:**
- Initial setup: 30-40 minutes
- Ongoing benefit: ~50% less boilerplate
- Fewer bugs: Compiler catches JSON errors

**Numbers:**
- **Without freezed:** ~50 lines per model (copyWith, ==, hashCode, toString)
- **With freezed:** ~10 lines per model

**Tradeoff:**
- Setup time ↑
- Maintenance time ↓
- Code clarity ↑

### 4. Early Refactoring Prevents Technical Debt

**Insight:**
Day 8 review found patterns forming:
- Duplicate code in datasources → extracted HttpClient
- Inconsistent naming → standardized
- Multiple state patterns → chose one

**Lesson:**
> Technical debt compounds. Fix it at Week 1, not Month 3.

---

## 🚀 Action Items for Week 2

Based on Week 1 learnings:

### Architecture
- [ ] Create ADR for state management choice (BLoC)
- [ ] Create ADR for error handling approach (Either pattern)
- [ ] Standardize all features on BLoC pattern
- [ ] Extract HttpClient to core package
- [ ] Document import boundary rules

### Code Quality
- [ ] Add import boundary checks to CI
- [ ] Set up pre-commit hooks (format, analyze)
- [ ] Baseline test coverage (Day 11)
- [ ] Add golden test examples

### Process
- [ ] Create PR template with architecture checklist
- [ ] Document code review standards
- [ ] Set up CODEOWNERS file
- [ ] Schedule weekly architecture reviews

---

## 💡 Mental Models That Clicked

### 1. "Interfaces in Domain, Implementations in Data"

**Before:**
"Why not just put everything in data layer?"

**After:**
"Domain layer is pure business logic. If I swap API providers (REST → GraphQL), domain layer doesn't change!"

### 2. "DTOs Protect Against API Changes"

**Before:**
"Why not just use API response directly as domain model?"

**After:**
"API changed `user_id` to `userId`? I only update the DTO. My entire app still uses `User.id`."

### 3. "Features Should Be Pluggable"

**Before:**
"feature_cart can import feature_auth, right?"

**After:**
"If they depend on each other, I can't extract either as a standalone package. Better to use core interfaces."

---

## 📈 What to Improve in Week 2

### 1. Test Coverage
**Current:** Minimal unit tests  
**Goal:** Baseline coverage metrics on Day 11

### 2. Documentation
**Current:** Architecture diagrams exist  
**Goal:** Add sequence diagrams for complex flows (auth, data sync)

### 3. Automation
**Current:** Manual checks for code quality  
**Goal:** CI pipeline with all checks automated (Day 20)

---

## 🎯 Week 2 Preview

**Focus:** Platform Integration & Performance

What we'll tackle:
- Platform channels (calling native code)
- Performance profiling & optimization
- Memory leak detection
- i18n/l10n architecture
- Security patterns
- Build flavors (dev/staging/prod)

**Why Week 1 matters for Week 2:**
> Platform code adds complexity. A solid foundation (Clean Architecture, modular packages, clear boundaries) prevents "spaghetti native integration."

---

## 📚 Resources That Helped

1. **Clean Architecture (Book)** - Uncle Bob's principles
2. **Flutter Documentation** - Official patterns
3. **Very Good Ventures Blog** - Production Flutter architecture
4. **Reso Coder Tutorials** - Clean Architecture in Flutter
5. **Melos Documentation** - Monorepo management

---

## 🙏 Acknowledgments

This retrospective captures 7 days of hands-on learning. Key insights came from:
- Making mistakes (circular dependencies!)
- Refactoring when patterns emerged
- Writing code, not just reading theory
- Daily LEARNING.md entries (reflection is powerful)

---

**Next:** Day 9 - Platform Channels & Native Services
```

---

### **Task 3: Create ADR for State Management**

**Create:** `docs/adr/001-state-management-choice.md`

**Use the ADR template:**

```markdown
# ADR 001: State Management Choice

**Date:** 2026-02-02  
**Status:** Accepted  
**Deciders:** [Your name]  
**Technical Story:** [Link to Day 4 exploration]

---

## Context and Problem Statement

We need to choose a state management solution for our Flutter application. The choice will impact:
- Development velocity
- Code maintainability
- Testability
- Team onboarding
- Performance

We explored three popular options on Day 4:
1. Provider (ChangeNotifier)
2. Riverpod (StateNotifier)
3. BLoC (Event → State)

All three are viable. We need to make an informed decision based on our project requirements.

---

## Decision Drivers

* **Team familiarity:** Team has Redux/Redux-Saga background (event-driven patterns)
* **Testability:** Need to test business logic separately from UI
* **Complex state transitions:** Auth flows, multi-step forms, async workflows
* **Debugging:** Need visibility into state changes (when, why, what changed)
* **Separation of concerns:** Business logic should not be in widgets
* **Long-term maintainability:** Project will scale to 10+ features
* **Type safety:** Want compiler to catch state errors
* **Documentation:** Good ecosystem support for learning

---

## Considered Options

### Option 1: Provider + ChangeNotifier

**Pros:**
- Simple to learn and teach
- Minimal boilerplate
- Official Flutter team support
- Good for small-medium apps
- Easy to get started

**Cons:**
- Mutable state (calls `notifyListeners()`)
- Less structured (no enforced patterns)
- Hard to test complex logic (mixed with UI concerns)
- No built-in time-travel debugging
- Global state can become messy at scale

**Code example:**
```dart
class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  
  void addItem(Product product) {
    _items.add(CartItem(product));
    notifyListeners(); // Mutation!
  }
}
```

**Verdict:** ❌ Too simple for our complex state requirements

---

### Option 2: Riverpod + StateNotifier

**Pros:**
- Compile-time safety (no `context.read()` errors)
- Immutable state by design
- Auto-dispose (no memory leaks)
- Derived state (computed properties)
- Good testing story
- Modern architecture

**Cons:**
- Steeper learning curve
- More conceptual overhead (providers, refs, families)
- Newer (less battle-tested than BLoC)
- Team needs training
- Different mental model from Redux

**Code example:**
```dart
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState.initial());
  
  void addItem(Product product) {
    state = state.copyWith(
      items: [...state.items, CartItem(product)],
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
```

**Verdict:** ⚠️ Good, but team needs training, less familiar than event-driven patterns

---

### Option 3: BLoC + flutter_bloc

**Pros:**
- Explicit state transitions (event → state)
- Clear separation: UI → Event → BLoC → State → UI
- Testable (business logic separate from widgets)
- Time-travel debugging
- Similar to Redux (team familiar)
- Large ecosystem & community
- Built-in error handling patterns
- Good for complex workflows

**Cons:**
- More boilerplate (event classes, state classes)
- Learning curve for new developers
- Can be overkill for simple UI state
- Verbose for trivial features

**Code example:**
```dart
// Events
abstract class CartEvent {}
class AddItemEvent extends CartEvent {
  final Product product;
  AddItemEvent(this.product);
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddItemEvent>((event, emit) {
      emit(CartLoading());
      // Business logic here
      final newState = currentState.copyWith(
        items: [...currentState.items, CartItem(event.product)],
      );
      emit(CartLoaded(newState));
    });
  }
}

// UI
BlocBuilder<CartBloc, CartState>(
  builder: (context, state) {
    if (state is CartLoading) return CircularProgressIndicator();
    if (state is CartLoaded) return CartList(state.items);
    return Container();
  },
)
```

**Verdict:** ✅ Best fit for our requirements

---

## Decision Outcome

**Chosen option:** BLoC (flutter_bloc package)

**Reasoning:**

1. **Team familiarity:** Aligns with Redux mental model (event-driven)
2. **Complex workflows:** Auth flows, multi-step forms benefit from explicit state machines
3. **Testability:** Business logic 100% testable without UI
4. **Debugging:** Built-in BLoC observer for logging all events/states
5. **Scalability:** Proven pattern for large Flutter apps
6. **Documentation:** Extensive tutorials, examples, and community support

**Implementation strategy:**

- Use BLoC for **complex features** (auth, checkout, forms)
- Use simple StatefulWidget for **trivial UI state** (dropdown open/closed)
- Create shared `core/presentation/bloc_observer.dart` for logging
- Use `freezed` for state classes (immutability)
- Create `BaseBloc` for common patterns (loading, error states)

**Example project structure:**
```
feature_auth/
  └── presentation/
      └── login/
          ├── bloc/
          │   ├── auth_bloc.dart
          │   ├── auth_event.dart      ← Explicit events
          │   └── auth_state.dart      ← Explicit states
          └── pages/
              └── login_page.dart       ← BlocBuilder/BlocListener
```

---

## Consequences

### Positive

- Clear separation of business logic and UI
- Easy to write unit tests (events in, states out)
- Predictable state changes (audit log of events)
- Time-travel debugging capability
- Enforced patterns (team consistency)

### Negative

- More files per feature (event, state, bloc)
- Boilerplate for simple features
- Learning curve for developers new to BLoC
- Need to educate team on event-driven patterns

### Mitigation

- Create templates/snippets for common BLoC patterns
- Write team documentation with examples
- Pair programming for first few BLoCs
- Create `BaseBloc` to reduce boilerplate
- Use code generation (freezed) for state classes

---

## Links

- [BLoC Library Documentation](https://bloclibrary.dev/)
- [Flutter BLoC Package](https://pub.dev/packages/flutter_bloc)
- [Day 4 Exploration](../DAY_4.md)
- [State Management Comparison](../docs/state-management-comparison.md)

---

## Alternatives Considered and Why Not Chosen

| Solution | Reason Not Chosen |
|----------|------------------|
| Provider | Too simple for complex state transitions, mutable state |
| Riverpod | Different mental model from team's Redux background |
| GetX | Too magical (service locator antipattern), hard to test |
| MobX | Reactive programming too different from team experience |
| Redux | Too much boilerplate, Flutter community prefers BLoC |
| Vanilla setState | No separation of concerns, not scalable |

---

**Review Date:** Day 15 (end of Week 2)  
**Review Criteria:** If BLoC creates significant development friction, re-evaluate
```

---

## 🎯 Summary: Day 8 Deliverables Checklist

By the end of Day 8, you should have:

### Code Quality
- [ ] Reviewed all packages for consistency
- [ ] Fixed naming inconsistencies
- [ ] Removed duplicate code (extracted to core)
- [ ] Standardized on one state management pattern
- [ ] Verified dependency directions (feature → core only)
- [ ] Confirmed Clean Architecture layers in all features
- [ ] Ran `dart analyze` with zero issues
- [ ] Ran `dart format .` on all files

### Documentation
- [ ] Updated `docs/architecture_diagram.md` with actual structure
- [ ] Created `WEEK_1_RETROSPECTIVE.md` with learnings
- [ ] Created `docs/adr/001-state-management-choice.md`
- [ ] Updated `LEARNING.md` with Day 8 entry
- [ ] Documented refactoring decisions

### Git
- [ ] Committed refactored code with descriptive message
- [ ] Tagged commit: `git tag week-1-complete`
- [ ] Pushed to repository

### Mental Model
- [ ] Can explain architecture to a teammate
- [ ] Know why you made each major decision
- [ ] Can draw architecture diagram from memory
- [ ] Understand tradeoffs of chosen patterns

---

## 🚀 What's Next: Week 2 Preview

Day 9 starts **platform integration** (native code). Week 2 is heavier:
- Platform channels (Android/iOS native calls)
- Performance profiling
- Memory leak detection
- i18n/l10n
- Security patterns
- Build flavors

**Why Day 8 preparation matters:**
> Platform code is complex. A messy architecture makes it exponentially harder. Clean up now, save hours later.

---

## 💬 Day 8 Interview Talking Points

If asked about your architecture:

1. **"I review code weekly for consistency"**
   - "On Day 8, I audited all Week 1 code, identified duplicate patterns, and refactored to maintain quality before complexity increased."

2. **"I make informed architectural decisions"**
   - "I explored Provider, Riverpod, and BLoC hands-on. Chose BLoC because our team knows Redux, and explicit event-driven patterns help with complex auth flows."

3. **"I document decisions with ADRs"**
   - "Every major choice gets an Architecture Decision Record explaining context, options considered, and why we chose what we did."

4. **"I enforce boundaries through packages"**
   - "Features depend only on core, never on each other. This prevents coupling and makes features extractable as standalone packages."

5. **"I refactor proactively"**
   - "I treat technical debt like financial debt—it compounds. Day 8 is dedicated to refactoring before patterns ossify."

---

## 📚 Resources for Day 8

**Code review checklists:**
- [Flutter Best Practices](https://docs.flutter.dev/testing/best-practices)
- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Clean Code (Book)](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)

**Refactoring:**
- [Refactoring Guru](https://refactoring.guru/) - Catalog of refactorings
- [Martin Fowler's Refactoring](https://martinfowler.com/books/refactoring.html)

**ADR Templates:**
- [GitHub ADR Template](https://github.com/joelparkerhenderson/architecture-decision-record)
- [Thoughtworks ADRs](https://www.thoughtworks.com/insights/blog/architecture-decision-records)

**Week 1 Retrospective Formats:**
- [Agile Retrospectives](https://retrospectivewiki.org/index.php?title=Retrospective_Plans)
- [What Went Well Format](https://www.atlassian.com/team-playbook/plays/retrospective)

---

**Congratulations! Week 1 is complete. You now have a solid architectural foundation. Week 2 builds on this to integrate with platform-specific features. Let's keep going! 🚀**
