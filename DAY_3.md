# **Day 3: Modularization & Packages**

---

## 🎯 Goal

Transform your monolithic Flutter app into a **multi-package architecture** where:

* **Features are isolated** in their own packages
* **Core utilities are shared** across features
* **Dependencies are explicit** and manageable
* **Teams can work independently** on different features
* **Testing is easier** with clear boundaries

**Time allocation (60 minutes):**
- 15m: Learn modularization concepts and package types
- 20m: Create package structure (feature_auth, core)
- 15m: Implement core logger API
- 10m: Set up Melos 7.x with Pub Workspaces

---

## 🧠 Step 1: Understanding Modularization

### 📘 What is Modularization?

Modularization is the practice of splitting your application into **separate, independent packages** rather than keeping everything in one large codebase.

Think of it like building with LEGO blocks:
* Each block (package) has a clear purpose
* Blocks can be combined to build something bigger
* You can replace or update one block without breaking others
* Each block is self-contained and testable

### 🎯 Why Modularize?

**1. Separation of Concerns**
* Each package has a single responsibility
* Changes in one package don't affect others
* Easier to understand and maintain

**2. Team Scalability**
* Multiple teams can work on different packages simultaneously
* No merge conflicts in unrelated code
* Clear ownership boundaries

**3. Build Performance**
* Only rebuild changed packages
* Faster CI/CD pipelines
* Incremental compilation

**4. Code Reusability**
* Share core utilities across features
* Publish packages to pub.dev if needed
* Use packages across multiple apps

**5. Testing Benefits**
* Test packages in isolation
* Mock dependencies easily
* Faster test execution

**6. Enforced Boundaries**
* Compiler prevents illegal imports
* Architecture rules are enforced by structure
* No accidental coupling

### 🏗 Package Types

#### **1. Feature Packages**
Complete vertical slices of functionality:
* `packages/feature_auth` - Login, register, password reset
* `packages/feature_tasks` - Task list, create, edit
* `packages/feature_profile` - User profile, settings

**Structure:**
```
feature_auth/
  ├── lib/
  │   ├── domain/        # Business logic
  │   ├── data/          # Data sources
  │   ├── presentation/  # UI
  │   └── feature_auth.dart  # Public API
  ├── test/
  └── pubspec.yaml
```

#### **2. Core Packages**
Shared utilities and infrastructure:
* `packages/core` - Logger, error handling, base classes
* `packages/network` - HTTP client, API config
* `packages/storage` - Local database, cache

**Structure:**
```
core/
  ├── lib/
  │   ├── error/         # Failures, Result type
  │   ├── logging/       # Logger interface
  │   ├── utils/         # Helper functions
  │   └── core.dart      # Public API
  ├── test/
  └── pubspec.yaml
```

#### **3. Shared UI Packages**
Common widgets and theming:
* `packages/ui_kit` - Buttons, text fields, cards
* `packages/theme` - Colors, typography, spacing

---

## 🧩 Step 2: Understanding Melos

### 📘 What is Melos?

**Melos** is a tool for managing Dart/Flutter monorepos (multiple packages in one repository).

> **Note:** As of Melos 7.x, configuration is done via `pubspec.yaml` (using Pub Workspaces) instead of a separate `melos.yaml` file. See the migration guide in Task 5 for details.

Think of it as:
* **Package Manager** - Manages dependencies between packages
* **Task Runner** - Runs commands across all packages
* **Orchestrator** - Coordinates multi-package workflows

### 🎯 Why Use Melos?

**Without Melos:**
```bash
# To run tests in all packages
cd packages/core && flutter test
cd ../feature_auth && flutter test
cd ../feature_tasks && flutter test
cd ../../mobile && flutter test
```

**With Melos:**
```bash
# Run tests everywhere with one command
melos run test
```

### 🔧 Key Melos Concepts

#### **1. Bootstrap**
Links local packages together:
```bash
melos bootstrap
```

What it does:
* Runs `flutter pub get` in all packages
* Creates symlinks for local dependencies
* Ensures all packages can find each other

#### **2. Scripts**
Define reusable commands in root `pubspec.yaml` (under `melos:` key):
```yaml
# pubspec.yaml (root)
melos:
  scripts:
    analyze:
      run: flutter analyze
      description: Run static analysis
    
    test:
      exec: flutter test
      description: Run all tests
      packageFilters:
        dirExists: test
```

Then run with:
```bash
melos run analyze
melos run test
```

#### **3. Filters**
Run commands on specific packages:
```bash
# Only feature packages
melos run test --scope="feature_*"

# Everything except mobile app
melos run analyze --ignore="mobile"

# Only packages that changed
melos run test --since=main
```

---

## 💻 Step 3: Implementation Tasks

### Task 1: Create Package Structure ✅

**What we're building:**
```
packages/
  ├── core/
  │   ├── lib/
  │   │   └── core.dart
  │   ├── test/
  │   └── pubspec.yaml
  │
  └── feature_auth/
      ├── lib/
      │   └── feature_auth.dart
      ├── test/
      └── pubspec.yaml
```

**Key concepts:**
* Each package has its own `pubspec.yaml`
* Package names follow convention: `<repo>_<package>`
* Main file exports public API

---

### Task 2: Implement Core Logger API

**What we're building:**
A logging abstraction that:
* Has an interface (abstract class)
* Has a console implementation
* Can be replaced with other implementations (Firebase, Sentry)
* Is testable

**Structure:**
```
core/
  └── lib/
      ├── error/          # Existing failures & result
      ├── logging/
      │   ├── logger.dart           # Abstract interface
      │   ├── console_logger.dart   # Implementation
      │   └── logging.dart          # Barrel export
      └── core.dart       # Exports everything
```

**Why?**
* Decouples logging from implementation
* Easy to switch logging providers
* Can mock for testing
* Centralized logging configuration

---

### Task 3: Move Error Handling to Core

**What we're doing:**
Moving `failures.dart` and `result.dart` from `mobile/lib/core/error/` to `packages/core/lib/error/`

**Why?**
* Error handling is shared infrastructure
* All features need Result type and Failures
* Core package is the right home for shared utilities

**Import changes:**
```dart
// Before
import 'package:mobile/core/error/failures.dart';

// After
import 'package:core/error/failures.dart';
```

---

### Task 4: Move Auth Feature to Package

**What we're doing:**
Moving entire `mobile/lib/features/auth/` to `packages/feature_auth/lib/`

**Structure after move:**
```
feature_auth/
  ├── lib/
  │   ├── domain/
  │   ├── data/
  │   ├── presentation/
  │   └── feature_auth.dart
  ├── test/
  └── pubspec.yaml
```

**Dependencies:**
```yaml
dependencies:
  core:
    path: ../core
  flutter_bloc: ^9.1.1
  equatable: ^2.0.5
```

**Why?**
* Auth is a complete feature
* Can be developed independently
* Can be tested in isolation
* Can be reused in other apps

---

### Task 5: Set Up Melos

**What we're doing:**
1. Install Melos globally
2. Create `melos.yaml` configuration
3. Run `melos bootstrap`

**melos.yaml structure:**
```yaml
name: com_mobile_architecture
packages:
  - packages/**
  - mobile

scripts:
  analyze:
    run: flutter analyze
    description: Run static analysis
    
  test:
    run: flutter test
    description: Run all tests
    
  format:
    run: dart format .
    description: Format code
```

**Why?**
* Single command to manage all packages
* Consistent tooling across packages
* Easier CI/CD integration

---

### 🚀 Melos 7.x Migration Guide (Latest Configuration)

> ⚠️ **Important:** Starting from Melos 7.x, the standalone `melos.yaml` file is **deprecated**. Melos now uses **Pub Workspaces** (Dart 3.6+) and configuration is moved to `pubspec.yaml`.

#### 📋 What Changed in Melos 7.x?

**Old Way (Deprecated):**
- Separate `melos.yaml` file for configuration
- Uses `pubspec_overrides.yaml` for local package linking
- Requires Dart SDK 2.12+

**New Way (Melos 7.x+):**
- Configuration in root `pubspec.yaml` under `melos:` key
- Uses **Pub Workspaces** for package linking
- Requires **Dart SDK 3.6.0+**
- No more `pubspec_overrides.yaml` generation

#### 🔧 Step-by-Step Migration for Freshers

**Step 1: Update Root `pubspec.yaml`**

Create or update your root `pubspec.yaml` with workspace configuration:

```yaml
name: com_mobile_architecture
publish_to: none

environment:
  sdk: ">=3.9.2 <4.0.0"

# 👇 Define all packages in the workspace
workspace:
  - packages/core
  - packages/feature_auth
  - mobile

# 👇 Add melos as dev dependency
dev_dependencies:
  melos: ^7.3.0

# 👇 Move all melos.yaml content here
melos:
  name: com_mobile_architecture
  
  scripts:
    # Analyze all packages
    analyze:
      description: Run static analysis on all packages
      run: flutter analyze

    # Format all code
    format:
      description: Format code in all packages
      run: dart format .

    # Check if code is properly formatted
    format:check:
      description: Check if code is properly formatted
      run: dart format --output=none --set-exit-if-changed .

    # Run all tests (only in packages with test directories)
    test:
      description: Run tests in all packages
      exec: flutter test
      packageFilters:
        dirExists: test

    # Clean all packages
    clean:
      description: Clean all packages
      run: flutter clean

    # Get dependencies for all packages
    get:
      description: Get dependencies in all packages
      run: flutter pub get

    # Analyze only feature packages
    analyze:features:
      description: Run analysis on feature packages only
      run: flutter analyze
      packageFilters:
        scope: "feature_*"
```

**Key Points:**
- `workspace:` - List all package paths (no glob support yet, coming in Dart 3.11)
- `melos:` - All previous `melos.yaml` content goes here
- `publish_to: none` - Root workspace should not be published

**Step 2: Add `resolution: workspace` to ALL Package `pubspec.yaml` Files**

This is **required** for every package in the workspace.

**`packages/core/pubspec.yaml`:**
```yaml
name: core
description: Core utilities and shared infrastructure
version: 0.1.0
publish_to: "none"
resolution: workspace  # 👈 Add this line

environment:
  sdk: ^3.9.2  # 👈 Must be 3.6.0 or higher

dependencies:
  equatable: ^2.0.5
  flutter:
    sdk: flutter
```

**`packages/feature_auth/pubspec.yaml`:**
```yaml
name: feature_auth
description: Authentication feature package
version: 0.1.0
publish_to: "none"
resolution: workspace  # 👈 Add this line

environment:
  sdk: ^3.9.2  # 👈 Must be 3.6.0 or higher

dependencies:
  core:
    path: ../core  # 👈 Path dependencies still work
  flutter:
    sdk: flutter
```

**`mobile/pubspec.yaml`:**
```yaml
name: mobile
description: "A new Flutter project."
publish_to: "none"
version: 1.0.0+1
resolution: workspace  # 👈 Add this line

environment:
  sdk: ^3.9.2  # 👈 Must be 3.6.0 or higher

dependencies:
  flutter:
    sdk: flutter
  core:
    path: ../packages/core
  feature_auth:
    path: ../packages/feature_auth
```

**Step 3: Remove Old `melos.yaml` File**

```bash
rm melos.yaml
```

The file is no longer needed as everything is now in `pubspec.yaml`.

**Step 4: Install Melos and Bootstrap Workspace**

```bash
# Install dependencies (including melos)
dart pub get

# Bootstrap the workspace
melos bootstrap
```

**Expected Output:**
```
melos bootstrap
  └> /path/to/your/project
Running "flutter pub get" in workspace...
  > SUCCESS

Generating IntelliJ IDE files...
  > SUCCESS

 -> 3 packages bootstrapped
```

**Step 5: Verify Melos Commands Work**

```bash
# List all packages
melos list

# Run analyze on all packages
melos run analyze

# Run tests (only on packages with tests)
melos run test

# Format all code
melos run format
```

#### 🆚 Before & After Comparison

**Before (Old melos.yaml):**
```yaml
# melos.yaml (DEPRECATED)
name: com_mobile_architecture
packages:
  - packages/**
  - mobile

scripts:
  analyze:
    run: flutter analyze
```

**After (New pubspec.yaml):**
```yaml
# pubspec.yaml (ROOT)
name: com_mobile_architecture
publish_to: none

environment:
  sdk: ^3.9.2

workspace:  # 👈 Explicit package list
  - packages/core
  - packages/feature_auth
  - mobile

dev_dependencies:
  melos: ^7.3.0  # 👈 Melos as dependency

melos:  # 👈 Configuration moved here
  name: com_mobile_architecture
  scripts:
    analyze:
      run: flutter analyze
```

#### 🎯 Key Benefits of Melos 7.x

1. **Native Dart Support** - Uses pub workspaces built into Dart SDK
2. **No More Overrides** - No `pubspec_overrides.yaml` generation
3. **Better IDE Support** - IDEs understand workspace structure natively
4. **Single Configuration** - Everything in `pubspec.yaml`
5. **Future-Proof** - Aligns with Dart's direction for monorepo support

#### ⚠️ Common Issues & Solutions

**Issue 1: "workspace and resolution requires at least language version 3.5"**

**Solution:** Update SDK constraint in ALL packages:
```yaml
environment:
  sdk: ^3.9.2  # Must be 3.6.0 or higher
```

**Issue 2: "Melos not found"**

**Solution:** Run `dart pub get` in root directory first to install melos.

**Issue 3: "Package not in workspace"**

**Solution:** Verify the package is listed in `workspace:` array in root `pubspec.yaml`.

**Issue 4: Tests fail with "not within workspace"**

**Solution:** Ensure `resolution: workspace` is added to that package's `pubspec.yaml`.

#### 📚 Migration Checklist for Freshers

- [ ] Root `pubspec.yaml` created with `workspace:` list
- [ ] Root `pubspec.yaml` has `melos: ^7.3.0` in `dev_dependencies`
- [ ] Root `pubspec.yaml` has `melos:` configuration section
- [ ] All packages have `resolution: workspace` in their `pubspec.yaml`
- [ ] All packages have `sdk: ^3.9.2` or higher
- [ ] Old `melos.yaml` file deleted
- [ ] `dart pub get` runs successfully in root
- [ ] `melos bootstrap` runs successfully
- [ ] `melos list` shows all packages
- [ ] `melos run analyze` works
- [ ] All tests still pass

#### 🔗 Official Documentation

- [Melos 7.x Documentation](https://melos.invertase.dev/)
- [Dart Pub Workspaces](https://dart.dev/tools/pub/workspaces)
- [Migration Guide](https://melos.invertase.dev/getting-started#migrating-from-yaml)

---

### Task 6: Verify Everything Works

**Checklist:**
- [ ] `melos run analyze` passes
- [ ] `melos run test` passes
- [ ] App runs successfully
- [ ] Login flow works
- [ ] No import errors

---

### Task 7: Update Documentation

**What we're creating:**
* `packages/README.md` - Package architecture overview
* Update C4 Container diagram with package boundaries
* Document package dependencies

---

## 🎓 Key Concepts to Remember

### 1. Package Independence
Each package should be able to build and test independently:
```bash
cd packages/core
flutter test  # Should work without other packages
```

### 2. Public API Pattern
Each package exports only what others need:
```dart
// core.dart
export 'error/failures.dart';
export 'error/result.dart';
export 'logging/logger.dart';
// Don't export implementation details
```

### 3. Dependency Direction
```
mobile (app)
  ↓
feature_auth
  ↓
core
```

* App depends on features
* Features depend on core
* Core depends on nothing (except flutter/dart)

### 4. Circular Dependencies
**Never do this:**
```
core → feature_auth  ❌
feature_auth → core  ❌
```

If two packages need each other, extract shared code to a third package.

### 5. Path Dependencies
```yaml
dependencies:
  core:
    path: ../core  # Relative path during development
```

For published packages, use pub.dev versions.

---

## 📊 Before vs After

### Before (Monolithic)
```
mobile/
  └── lib/
      ├── core/
      │   └── error/
      └── features/
          └── auth/
```

**Problems:**
* Everything in one package
* No enforced boundaries
* Hard to test in isolation
* Slow rebuilds

### After (Modular)
```
packages/
  ├── core/
  │   └── lib/error/
  └── feature_auth/
      └── lib/
mobile/
  └── lib/
```

**Benefits:**
* Clear boundaries
* Independent testing
* Faster builds
* Team scalability

---

## 🔍 Mental Models

### Mental Model 1: LEGO Blocks
* **Core** = Foundation blocks (same in every build)
* **Features** = Specialized blocks (specific purposes)
* **Mobile** = Final assembly (puts blocks together)

### Mental Model 2: Microservices
* Each package = microservice
* Well-defined interfaces
* Independent deployment (in theory)
* Explicit dependencies

### Mental Model 3: Libraries
* You're creating your own library ecosystem
* Each package is like a pub.dev package
* Version and maintain like libraries

---

## ✅ Definition of Done (Day 3)

By end of Day 3, you should have:

- [x] Created `packages/core` with pubspec.yaml
- [x] Created `packages/feature_auth` with pubspec.yaml
- [x] Implemented logger interface in core
- [x] Moved error handling to core package
- [x] Moved auth feature to feature_auth package
- [x] Installed and configured Melos
- [x] All tests passing
- [x] App runs successfully
- [x] Documentation updated

---

## 📚 Further Reading

* [Melos Documentation](https://melos.invertase.dev/)
* [Flutter Package Development](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)
* [Monorepo Best Practices](https://monorepo.tools/)

---

## 💡 Pro Tips

**Tip 1: Start Small**
Don't try to split everything at once. Start with core and one feature.

**Tip 2: Test Continuously**
After each move, run tests to ensure nothing broke.

**Tip 3: Update Imports Carefully**
Use IDE's "Find and Replace" to update import statements.

**Tip 4: Think About Public APIs**
What should other packages see? Export only that.

**Tip 5: Document Dependencies**
Keep a diagram of package dependencies updated.

---

## 🎯 Success Criteria

You've completed Day 3 successfully if you can answer YES to:

1. Can I run `melos bootstrap` without errors?
2. Can I run `melos run test` and all tests pass?
3. Can I run the mobile app and login works?
4. Are error handling and auth in separate packages?
5. Can I build `feature_auth` independently?
6. Do I understand why we modularized?
7. Can I add a new feature package following the pattern?

---

## 🚀 What's Next (Day 4)?

* Compare state management patterns (Provider, Riverpod, BLoC)
* Implement same feature with different approaches
* Understand tradeoffs and when to use each

---

# 📘 **DAY 3 — Questions & Answers**

---

## 🧩 **Q1: How to handle shared data (tokens, user profile) without tight coupling?**

### **Problem:**
Auth feature creates bearer tokens and user profiles. Multiple features (feed, payment, profile) need this data. How do we share without making features depend on each other?

### **Answer:**

Create a **domain package** with **interfaces** (contracts) that define how to access shared data.

**Wrong approach (Tightly coupled):**
```dart
// ❌ BAD: feature_feed imports feature_auth directly
import 'package:feature_auth/feature_auth.dart';

class FeedRepository {
  final AuthBloc authBloc; // Direct dependency!
}
```

**Right approach (Loosely coupled):**

**Step 1:** Create domain package with interface
```dart
// packages/domain/lib/repositories/session_provider.dart
abstract class SessionProvider {
  User? getCurrentUser();
  AuthToken? getCurrentToken();
  bool isAuthenticated();
  Stream<bool> get authStateChanges;
}
```

**Step 2:** Auth feature implements interface
```dart
// packages/feature_auth/lib/data/session_manager.dart
class SessionManager implements SessionProvider {
  User? _currentUser;
  AuthToken? _currentToken;
  
  @override
  User? getCurrentUser() => _currentUser;
  
  @override
  AuthToken? getCurrentToken() => _currentToken;
}
```

**Step 3:** Other features depend on interface, not implementation
```dart
// packages/feature_feed/lib/data/repositories/feed_repository.dart
import 'package:domain/domain.dart'; // Only domain!

class FeedRepository {
  final SessionProvider sessionProvider; // Interface!
  
  Future<Result<Failure, List<Post>>> fetchFeed() async {
    final token = sessionProvider.getCurrentToken();
    // Use token...
  }
}
```

**Dependency graph:**
```
feature_feed → domain ← feature_auth
```

Both features depend on `domain` (stable contracts), not each other!

**Benefits:**

✅ Features don't know about each other  
✅ Can test with mock SessionProvider  
✅ Can swap auth implementation  
✅ No tight coupling  

---

## 🧩 **Q2: What if features need extended entity data (User + Payment Methods)?**

### **Problem:**
Payment feature needs User data plus payment-specific data. Should PaymentUser extend User?

### **Answer:**

Use **Composition over Inheritance**.

**Wrong approach:**
```dart
// ❌ BAD: Inheritance across packages
class PaymentUser extends User {
  final List<PaymentMethod> paymentMethods;
}
```

**Right approach:**
```dart
// ✅ GOOD: Composition
// packages/domain/lib/entities/user.dart
class User {
  final String id;
  final String email;
  final String name;
}

// packages/feature_payment/lib/domain/entities/payment_profile.dart
class PaymentProfile {
  final User user; // Compose, don't inherit!
  final List<PaymentMethod> paymentMethods;
  
  const PaymentProfile({
    required this.user,
    required this.paymentMethods,
  });
}
```

**Benefits:**
✅ User entity stays stable in domain  
✅ Each feature extends as needed  
✅ No coupling  

---

## 🧩 **Q3: Different apps need different login UI (email, OTP, social). How to handle?**

### **Problem:**
- App A: Email + Password only
- App B: OTP + Social Login
- App C: All methods

Copying login page creates inflexibility. How do we support variations?

### **Answer:**

**Solution 1: Separate Domain from UI**

```
packages/
├── feature_auth_domain/      # Business logic (no UI!)
│   └── usecases/
│       ├── login_with_email_use_case.dart
│       ├── login_with_otp_use_case.dart
│       └── login_with_social_use_case.dart
│
├── feature_auth_ui_basic/    # Email + Password UI
│   └── pages/email_login_page.dart
│
└── feature_auth_ui_advanced/ # All methods UI
    └── pages/
        ├── email_login_page.dart
        ├── otp_login_page.dart
        └── social_login_page.dart
```

**App A imports:**
```yaml
dependencies:
  feature_auth_domain:
    path: ../packages/feature_auth_domain
  feature_auth_ui_basic:  # Only basic UI
    path: ../packages/feature_auth_ui_basic
```

**App B imports:**
```yaml
dependencies:
  feature_auth_domain:
    path: ../packages/feature_auth_domain
  feature_auth_ui_advanced:  # All methods UI
    path: ../packages/feature_auth_ui_advanced
```

**App C builds custom UI:**
```yaml
dependencies:
  feature_auth_domain:
    path: ../packages/feature_auth_domain
  # No UI package - builds custom using domain layer
```

---

**Solution 2: Conditional Exports (Single Package)**

```dart
// packages/feature_auth/lib/feature_auth.dart
// Always export domain
export 'domain/usecases/logout_use_case.dart';

// Conditional - apps import only what they need
export 'domain/usecases/login_with_email_use_case.dart';
export 'presentation/email_login/email_login_page.dart';

export 'domain/usecases/login_with_otp_use_case.dart' show LoginWithOTPUseCase;
export 'presentation/otp_login/otp_login_page.dart' show OTPLoginPage;
```

**App imports only what it needs:**
```dart
// App A
import 'package:feature_auth/feature_auth.dart'
  show
    LoginWithEmailUseCase,
    EmailLoginPage;

// App B
import 'package:feature_auth/feature_auth.dart'
  show
    LoginWithEmailUseCase,
    LoginWithOTPUseCase,
    EmailLoginPage,
    OTPLoginPage;
```

**Benefits:**

✅ Reuse business logic  
✅ Customize UI per app  
✅ No code bloat  

---

## 🧩 **Q4: Importing unused auth methods (OTP, social) affects code coverage. How to avoid?**

### **Problem:**
If `feature_auth` has 10 login methods but app uses 1, you import 9 unused methods. This:
- Increases bundle size
- Reduces code coverage (untested code)
- Creates unnecessary dependencies

### **Answer:**

**Use Micro Packages (Granular Dependencies)**

```
packages/
├── auth_core/              # Essential only
│   ├── session_manager.dart
│   └── logout_use_case.dart
│
├── auth_email/             # Email login only
│   ├── login_with_email_use_case.dart
│   └── email_login_page.dart
│
├── auth_otp/               # OTP login only
│   ├── login_with_otp_use_case.dart
│   └── otp_login_page.dart
│
├── auth_social/            # Social login only
│   └── login_with_social_use_case.dart
│
└── auth_biometric/         # Biometric login
    └── login_with_biometric_use_case.dart
```

**App imports only what it needs:**
```yaml
# App that only needs email login
dependencies:
  auth_core:
    path: ../packages/auth_core
  auth_email:
    path: ../packages/auth_email
  # auth_otp - NOT imported!
  # auth_social - NOT imported!
  # auth_biometric - NOT imported!
```

**Benefits:**
✅ Only import what you use  
✅ Smaller bundle size  
✅ Better code coverage  
✅ Tree-shaking works optimally  

---

## 🧩 **Q5: Decision Framework - When to use which pattern?**

| Your Situation | Pattern to Use | Why |
|----------------|----------------|-----|
| **Token/session sharing** | Domain package with interfaces | Loose coupling, testable |
| **User data in multiple features** | Composition over inheritance | Each feature extends as needed |
| **Different login UI per app** | Separate domain from UI | Reuse logic, customize UI |
| **Multiple optional auth methods** | Micro packages | Avoid code bloat |
| **Feature needs another feature's data** | Domain interfaces | No direct dependency |
| **Simple app (1-2 features)** | Monolithic with clean arch | Don't over-engineer |
| **Complex app (5+ features)** | Full modular architecture | Scalability matters |

---

## 🧩 **Q6: How to test features without depending on other features?**

### **Answer:**

Use **mock implementations** of domain interfaces.

```dart
// test/mocks/mock_session_provider.dart
class MockSessionProvider implements SessionProvider {
  User? _user;
  AuthToken? _token;
  
  @override
  User? getCurrentUser() => _user;
  
  @override
  AuthToken? getCurrentToken() => _token;
  
  void setMockSession(User user, AuthToken token) {
    _user = user;
    _token = token;
  }
}

// test/feed_repository_test.dart
void main() {
  test('fetchFeed returns data when authenticated', () async {
    // Arrange - no dependency on feature_auth!
    final mockSession = MockSessionProvider();
    mockSession.setMockSession(
      User(id: '1', email: 'test@example.com'),
      AuthToken(accessToken: 'mock_token'),
    );
    
    final repository = FeedRepository(
      sessionProvider: mockSession, // Mock!
    );
    
    // Act
    final result = await repository.fetchFeed();
    
    // Assert
    expect(result.isSuccess, true);
  });
}
```

**Benefits:**

✅ No dependency on real auth implementation  
✅ Fast tests (no real network, no real auth)  
✅ Easy to test edge cases  

---

## 🧩 **Q7: Should every project use a modular package structure?**

### **Answer:**

No. Packaging depends on **team size and future scope** of the project.

| Project Size       | # Devs | Recommended Architecture                         |
| ------------------ | ------ | ------------------------------------------------ |
| Small              | 1–2    | Single app + features folder (no packages)       |
| Medium             | 3–5    | One package per **major domain** (auth, tickets) |
| Large / Enterprise | 5+     | Multi-package monorepo with melos                |

> **Key Principle:** Use packaging only when problem size demands scalability — avoid over-engineering.

**When NOT to modularize:**
- Solo developer, simple app
- Proof of concept / MVP
- Short-term project (< 3 months)
- No plan to scale team

**When TO modularize:**
- Multiple developers working simultaneously
- Long-term project with evolving features
- Need to reuse features across multiple apps
- Large codebase (10+ features)

---

## 🧩 **Q8: Why do packages improve scalability?**

### **Answer:**

Because each feature becomes an **independent unit** with:

✅ **Independent development** - Teams work on different packages without conflicts  
✅ **Independent testing** - Test packages in isolation with their own test suites  
✅ **Independent business logic** - Domain rules stay encapsulated  
✅ **Clear developer boundaries** - Ownership and responsibility are explicit  
✅ **Lower merge conflicts** - Changes in one package don't affect others  
✅ **Faster CI builds** - Only rebuild changed packages  
✅ **Reusable modules** - Share packages across multiple apps  

**Real-world example:**
```
Without packages:
- 5 devs working in mobile/lib/features/
- Constant merge conflicts
- 10-minute full rebuild on every change
- Unclear who owns what

With packages:
- Dev A: packages/feature_auth
- Dev B: packages/feature_payment
- Dev C: packages/feature_profile
- Dev D: packages/feature_feed
- Dev E: packages/core
- No conflicts, 2-minute incremental builds
```

---

## 🧩 **Q9: What should go inside feature packages?**

### **Answer:**

A **feature package** must contain a complete vertical slice following Clean Architecture:

```
packages/feature_auth/
  ├── lib/
  │   ├── domain/              # Business logic layer
  │   │   ├── entities/        # Core business objects
  │   │   ├── repositories/    # Repository interfaces
  │   │   └── usecases/        # Business use cases
  │   │
  │   ├── data/                # Data layer
  │   │   ├── models/          # Data transfer objects
  │   │   ├── repositories/    # Repository implementations
  │   │   └── datasources/     # API clients, local storage
  │   │
  │   ├── presentation/        # UI layer
  │   │   ├── bloc/            # State management
  │   │   ├── pages/           # Screen widgets
  │   │   └── widgets/         # Feature-specific widgets
  │   │
  │   └── feature_auth.dart    # Public API (exports)
  │
  ├── test/                    # Unit & widget tests
  └── pubspec.yaml             # Dependencies
```

**Optional additions:**
- `utils/` - Feature-specific helper functions
- `constants/` - Feature-specific constants
- `routing/` - Feature navigation logic

**What NOT to include:**
- Generic utilities (goes in `core`)
- Shared UI widgets (goes in `shared_ui`)
- Dependencies on other features (use domain interfaces)

---

## 🧩 **Q10: Where should common models go?**

### **Answer:**

It depends on **who uses the model**:

| Usage Scenario                                                     | Location                         | Example                           |
| ------------------------------------------------------------------ | -------------------------------- | --------------------------------- |
| Used by multiple features (global entities)                        | **`packages/domain`**            | User, AppConfig, Profile          |
| Used by one feature only                                           | **That feature's domain/models** | LoginRequest, OTPToken            |
| Data transfer object (API response)                                | **That feature's data/models**   | UserDTO, LoginResponseModel       |
| Shared across apps (if multi-app workspace)                        | **`packages/shared_domain`**     | Address, Currency, PaymentMethod  |
| UI-specific model (view state)                                     | **That feature's presentation**  | LoginFormState, ProfileViewModel  |

**Decision Rule:**
> If a model has **domain-specific meaning** and is used by only one feature → keep it inside that feature's domain.
> If it's **truly global** (User, Session, AppConfig) → move to shared domain package.

**Example:**
```dart
// ✅ GOOD: User is global, used by auth, profile, payment
packages/domain/lib/entities/user.dart

// ✅ GOOD: LoginRequest is auth-specific
packages/feature_auth/lib/domain/entities/login_request.dart

// ❌ BAD: Don't put LoginRequest in shared domain
// It's only used by auth!
```

---

## 🧩 **Q11: What about shared UI widgets used by multiple features?**

### **Answer:**

Use a **`shared_ui`** (or `core_ui`) package **only if** the widget meets these criteria:

✅ Has **reusable logic** (loading states, validation, animations)  
✅ **Design is consistent** across the entire app  
✅ You want a **single tested implementation**  

**Examples of shared UI widgets:**
- `AppPrimaryButton` (with loading state, theme, analytics)
- `AppTextField` (with validation styling, icons)
- `LoadingOverlay` (consistent loading indicator)
- `ErrorDialog` (standardized error display)
- `EmptyStateWidget` (consistent empty state design)

**When NOT to add to shared UI:**
- Widget looks different on different screens
- Very simple composition (Text + Padding + Icon)
- Has domain-specific meaning (`LoginButton`, `TicketTile`)
- Only used in one feature

**Structure:**
```
packages/shared_ui/
  ├── lib/
  │   ├── buttons/
  │   │   ├── app_primary_button.dart
  │   │   └── app_text_button.dart
  │   ├── inputs/
  │   │   └── app_text_field.dart
  │   ├── dialogs/
  │   │   ├── error_dialog.dart
  │   │   └── confirmation_dialog.dart
  │   └── shared_ui.dart
  └── test/
```

> **Principle:** Only move components to shared when **reuse + consistency** makes sense.

---

## 🧩 **Q12: If we have multiple login methods (email, OTP), do we need multiple repositories?**

### **Answer:**

No. One **AuthRepository** can serve multiple authentication methods.

**You split behavior at the Use Case level:**

```dart
// packages/feature_auth/lib/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Result<Failure, AuthToken>> loginWithEmail(String email, String password);
  Future<Result<Failure, void>> sendOTP(String phoneNumber);
  Future<Result<Failure, AuthToken>> verifyOTP(String phoneNumber, String code);
  Future<Result<Failure, AuthToken>> loginWithGoogle();
  Future<Result<Failure, void>> logout();
}

// Single implementation in data layer
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  @override
  Future<Result<Failure, AuthToken>> loginWithEmail(
    String email, 
    String password,
  ) async {
    // Implementation
  }
  
  @override
  Future<Result<Failure, void>> sendOTP(String phoneNumber) async {
    // Implementation
  }
  
  // ... other methods
}
```

**Different Use Cases consume the repository:**
```dart
// Login with email use case
class LoginWithEmailUseCase {
  final AuthRepository repository;
  
  Future<Result<Failure, AuthToken>> call(
    String email, 
    String password,
  ) {
    return repository.loginWithEmail(email, password);
  }
}

// OTP authentication use case
class VerifyOTPUseCase {
  final AuthRepository repository;
  
  Future<Result<Failure, AuthToken>> call(
    String phoneNumber, 
    String code,
  ) {
    return repository.verifyOTP(phoneNumber, code);
  }
}
```

**Different BLoCs for different workflows:**
```dart
LoginBloc       → uses LoginWithEmailUseCase
OTPAuthBloc     → uses SendOTPUseCase + VerifyOTPUseCase
SocialAuthBloc  → uses LoginWithGoogleUseCase
```

**Benefits:**

✅ Single source of truth for auth logic  
✅ Easier to maintain and test  
✅ Shared session management  
✅ Consistent error handling  

---

## 🧩 **Q13: Will unused code inside packages increase final app size?**

### **Answer:**

**No.** Flutter uses **tree shaking** → only imported & reachable code ends up in the final build.

**How tree shaking works:**
1. Compiler starts from `main()` function
2. Traces all reachable code paths
3. Includes only what's actually imported and used
4. Removes all unreachable code

**Example:**
```dart
// packages/feature_auth/lib/feature_auth.dart
export 'presentation/email_login_page.dart';
export 'presentation/otp_login_page.dart';      // ← You don't import this
export 'presentation/social_login_page.dart';   // ← You don't import this

// mobile/lib/main.dart
import 'package:feature_auth/feature_auth.dart' show EmailLoginPage;
```

**Result:**
- ✅ `EmailLoginPage` → **included** in build
- ❌ `OTPLoginPage` → **NOT included** (unreachable)
- ❌ `SocialLoginPage` → **NOT included** (unreachable)

**Build size depends on:**
- What you **import**
- What's **reachable** from imported code
- Not on what exists in the package folder

> **Takeaway:** Don't worry about unused code bloating your app. Flutter's compiler is smart enough to exclude it.

---

## 🧩 **Q14: Will unused packaged code reduce test coverage?**

### **Answer:**

**No.** Coverage is calculated **per app**, not per workspace.

**How coverage works:**
- Coverage measures: "What percentage of code **in your app** is tested?"
- It only counts files that are **imported and compiled** into your app
- Unused code in packages is **not part of your app's coverage report**

**Example:**
```yaml
# Your app only imports email login
dependencies:
  feature_auth:
    path: ../packages/feature_auth

# main.dart
import 'package:feature_auth/feature_auth.dart' show EmailLoginPage;
```

**Coverage report will only include:**
- ✅ `EmailLoginPage` and its dependencies
- ❌ NOT `OTPLoginPage` (not imported)
- ❌ NOT `SocialLoginPage` (not imported)

**If you want package-level coverage:**
```bash
cd packages/feature_auth
flutter test --coverage
```

This tests **the entire package** independently.

**Best practice:**
- Test each package independently in its own directory
- Test the app as a whole with integration tests
- Don't worry about unused package code affecting app coverage

---

## 🧩 **Q15: What ensures one package doesn't depend directly on UI of another package?**

### **Answer:**

Enforce this through **Clean Architecture layers + package structure**:

### **1. Architectural Rules:**

```
Domain Layer → No dependencies on other features ✅
Data Layer   → Can depend on domain interfaces only ✅
UI Layer     → Can depend on domain + data within same feature ✅
```

**Example of violation:**
```dart
// ❌ BAD: feature_payment imports feature_auth UI
// packages/feature_payment/lib/presentation/payment_page.dart
import 'package:feature_auth/presentation/login_page.dart'; // ❌ WRONG!

class PaymentPage extends StatelessWidget {
  void handleLogout() {
    Navigator.push(context, LoginPage()); // ❌ Direct UI dependency!
  }
}
```

**Correct approach:**
```dart
// ✅ GOOD: Navigate via routes, use domain events
// packages/feature_payment/lib/presentation/payment_page.dart
import 'package:core/navigation/app_router.dart';

class PaymentPage extends StatelessWidget {
  void handleLogout() {
    context.read<AuthBloc>().add(LogoutRequested()); // Domain event
    AppRouter.navigateToLogin(); // Route-based navigation
  }
}
```

### **2. Melos Package Dependency Validation:**

Configure `pubspec.yaml` to prevent illegal dependencies:

```yaml
# packages/feature_payment/pubspec.yaml
dependencies:
  core:
    path: ../core
  domain:
    path: ../domain
  # ❌ feature_auth is NOT listed - compiler will prevent import!
```

If you try to import `feature_auth`:
```dart
import 'package:feature_auth/feature_auth.dart'; // ❌ Compile error!
```

### **3. Use Linting Rules:**

Add custom lint rules in `analysis_options.yaml`:

```yaml
# analysis_options.yaml
linter:
  rules:
    - prefer_relative_imports
    
analyzer:
  errors:
    # Treat cross-feature imports as errors
    invalid_annotation_target: error
```

### **4. Code Review Checklist:**

- [ ] Does PR add dependency to another feature package?
- [ ] Does UI import from another feature's presentation layer?
- [ ] Are domain interfaces used instead of concrete implementations?

### **5. Automated CI Checks:**

```bash
# scripts/check_import_boundaries.dart
#!/usr/bin/env dart

// Check for illegal cross-feature imports
// Run in CI pipeline
```

**Summary:**
- **Architecture** defines the rules
- **Package structure** enforces them at compile time
- **Linting** catches violations early
- **CI/CD** prevents merging violations

---

## 🧩 **Q16: How does Melos help practically?**

### **Answer:**

Melos provides **monorepo automation** that saves hours of manual work:

### **1. Auto-Link Local Packages**

**Without Melos:**
```bash
cd mobile && flutter pub get
cd ../packages/core && flutter pub get
cd ../feature_auth && flutter pub get
# Manually manage path dependencies
```

**With Melos:**
```bash
melos bootstrap
# ✅ All packages linked automatically
# ✅ Symlinks created for local dependencies
# ✅ Single command for entire workspace
```

### **2. Run Commands on Changed Packages Only**

**Without Melos:**
```bash
# Have to manually identify what changed
cd packages/core && flutter test
cd ../feature_auth && flutter test
# Skip feature_payment (didn't change)
```

**With Melos:**
```bash
melos run test --since=main
# ✅ Only runs tests in packages changed since main branch
# ✅ Saves CI time and cost
```

### **3. Lint All Packages Together**

**Without Melos:**
```bash
cd mobile && flutter analyze
cd ../packages/core && flutter analyze
cd ../packages/feature_auth && flutter analyze
# Check each one manually
```

**With Melos:**
```bash
melos run analyze
# ✅ Runs in all packages
# ✅ Aggregated error report
```

### **4. Selective Package Execution**

```bash
# Run tests only in feature packages
melos run test --scope="feature_*"

# Format code everywhere except mobile
melos run format --ignore="mobile"

# Analyze only core packages
melos run analyze --scope="*core*"
```

### **5. Version Management**

```bash
# Bump versions of changed packages
melos version

# Generate changelog
melos run changelog
```

### **6. Parallel Execution**

```bash
# Run tests in all packages concurrently
melos run test --no-select
# ✅ Faster than sequential execution
```

### **7. Custom Scripts**

Define in root `pubspec.yaml`:

```yaml
melos:
  scripts:
    # Run code generation everywhere
    generate:
      exec: dart run build_runner build --delete-conflicting-outputs
      packageFilters:
        dependsOn: "build_runner"
    
    # Clean all packages
    clean:
      exec: flutter clean
      
    # Update dependencies
    outdated:
      exec: flutter pub outdated
```

Then run:
```bash
melos run generate
melos run clean
melos run outdated
```

### **Real-World Time Savings:**

| Task                  | Without Melos | With Melos | Time Saved |
| --------------------- | ------------- | ---------- | ---------- |
| Bootstrap workspace   | 10 min        | 1 min      | 90%        |
| Run all tests         | 5 min         | 30 sec     | 90%        |
| Analyze all packages  | 3 min         | 20 sec     | 89%        |
| Format all code       | 2 min         | 15 sec     | 87%        |
| Version bumps         | 15 min        | 1 min      | 93%        |

**Annual impact for 5-person team:**
- Daily time saved: ~30 minutes/developer
- Weekly: 2.5 hours/developer = 12.5 hours/team
- **Yearly: 650 hours saved** ≈ **$65,000 in developer time** (at $100/hr)

> **Melos is essential for any Flutter monorepo with 3+ packages.**

---

## 🎯 **Summary: Golden Rules**

### ✅ DO:
1. **Depend on abstractions** (interfaces in domain), not implementations
2. **Use domain package** for shared contracts
3. **Separate domain from UI** for flexibility
4. **Create micro packages** for optional features
5. **Compose entities**, don't inherit across packages
6. **Test with mocks**, not real dependencies

### ❌ DON'T:
1. Import feature packages directly (feature_a → feature_b)
2. Mix business logic with UI
3. Create god packages with everything
4. Force all apps to import all features
5. Inherit entities across feature boundaries

### 🎯 The Golden Rule:
> **Features depend on contracts (domain), not other features (implementations).**

---

## 🧠 **Quick Memory Rule**

```
If it's shared behavior        → shared package (core, domain)
If it's feature-specific       → feature package
If it's global domain model    → domain package
If it's trivial UI             → keep local in feature
If it's reusable styled UI     → shared_ui package
If multiple features need it   → create interface in domain
If only one feature needs it   → keep in that feature
```

**Dependency Direction (Always):**
```
mobile (app)
    ↓
features (auth, payment, profile)
    ↓
domain (contracts, interfaces)
    ↓
core (utilities, logging)
```

**The "Don't" List:**
- ❌ Feature A → Feature B (direct dependency)
- ❌ Core → Feature (reverse dependency)
- ❌ Domain → Data layer (wrong direction)
- ❌ Mixing UI with business logic
- ❌ Inheritance across package boundaries

**The "Do" List:**
- ✅ Use interfaces in domain for shared contracts
- ✅ Compose entities instead of inheriting
- ✅ Export only public APIs from packages
- ✅ Test packages independently
- ✅ Keep packages focused and cohesive

---

### 📚 Further Reading:
See `docs/solution_architecture_coupling.md` for detailed examples and patterns.

