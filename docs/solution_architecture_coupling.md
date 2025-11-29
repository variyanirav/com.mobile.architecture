# Solution Architecture: Handling Feature Dependencies & Coupling

## 🎯 The Real-World Challenge

You've identified critical architectural problems:
1. **Shared Data Problem**: Auth tokens, user profiles needed everywhere
2. **Feature Communication**: Features need to share data/state
3. **UI Flexibility**: Different apps need different login UI/flows
4. **Feature Variations**: Not all apps need all auth methods
5. **Code Bloat**: Importing unused code affects bundle size and coverage

Let's solve each with architectural patterns.

---

## 1. Shared Data Problem: Auth Token & User Profile

### ❌ Wrong Approach (Tightly Coupled)
```dart
// ❌ BAD: feature_feed depends directly on feature_auth
// packages/feature_feed/lib/data/repositories/feed_repository.dart
import 'package:feature_auth/feature_auth.dart';

class FeedRepository {
  final AuthBloc authBloc; // Direct dependency on auth feature!
  
  Future<List<Post>> fetchFeed() async {
    final token = authBloc.state.token; // Tightly coupled!
    // ...
  }
}
```

**Problem:** `feature_feed` now depends on `feature_auth`. If you remove auth package, feed breaks.

---

### ✅ Solution 1: Shared Domain Package (Recommended)

Create a `domain` package that defines **interfaces** and **shared entities**.

```
packages/
├── domain/                    # Shared contracts (no implementations!)
│   ├── lib/
│   │   ├── entities/
│   │   │   ├── user.dart      # Shared user entity
│   │   │   └── auth_token.dart
│   │   └── repositories/
│   │       ├── auth_provider.dart    # Interface only!
│   │       └── session_provider.dart # Interface only!
│   
├── core/                      # Infrastructure (error handling, logging)
│   
├── feature_auth/              # Auth implementation
│   └── implements domain/repositories/auth_provider.dart
│   
└── feature_feed/              # Feed implementation
    └── depends on domain/repositories/session_provider.dart
```

**Implementation:**

```dart
// packages/domain/lib/entities/user.dart
class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });
}

// packages/domain/lib/entities/auth_token.dart
class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  
  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// packages/domain/lib/repositories/session_provider.dart
/// Interface for accessing current session data
/// Any feature can depend on this WITHOUT depending on feature_auth
abstract class SessionProvider {
  /// Get current authenticated user (null if not logged in)
  User? getCurrentUser();
  
  /// Get current auth token (null if not logged in)
  AuthToken? getCurrentToken();
  
  /// Check if user is authenticated
  bool isAuthenticated();
  
  /// Stream of authentication state changes
  Stream<bool> get authStateChanges;
}

// packages/domain/lib/repositories/auth_provider.dart
/// Interface for authentication operations
abstract class AuthProvider {
  Future<Result<Failure, User>> login(String email, String password);
  Future<Result<Failure, User>> loginWithOTP(String phone, String otp);
  Future<Result<Failure, void>> logout();
}
```

**Now features depend on domain, not each other:**

```dart
// packages/feature_auth/lib/data/session_manager.dart
import 'package:domain/domain.dart';

/// Auth feature implements the interface
class SessionManager implements SessionProvider {
  User? _currentUser;
  AuthToken? _currentToken;
  final _authStateController = StreamController<bool>.broadcast();
  
  @override
  User? getCurrentUser() => _currentUser;
  
  @override
  AuthToken? getCurrentToken() => _currentToken;
  
  @override
  bool isAuthenticated() => _currentUser != null && 
                           _currentToken != null && 
                           !_currentToken!.isExpired;
  
  @override
  Stream<bool> get authStateChanges => _authStateController.stream;
  
  void setSession(User user, AuthToken token) {
    _currentUser = user;
    _currentToken = token;
    _authStateController.add(true);
  }
  
  void clearSession() {
    _currentUser = null;
    _currentToken = null;
    _authStateController.add(false);
  }
}

// packages/feature_feed/lib/data/repositories/feed_repository.dart
import 'package:domain/domain.dart'; // Only depends on domain!
import 'package:core/core.dart';

class FeedRepository {
  final SessionProvider sessionProvider; // Interface, not implementation!
  final ApiClient apiClient;
  
  FeedRepository({
    required this.sessionProvider,
    required this.apiClient,
  });
  
  Future<Result<Failure, List<Post>>> fetchFeed() async {
    // Get token from session provider (doesn't know it's from auth feature)
    final token = sessionProvider.getCurrentToken();
    
    if (token == null) {
      return Left(AuthenticationFailure('Not authenticated'));
    }
    
    // Use token to fetch feed
    final response = await apiClient.get(
      '/feed',
      headers: {'Authorization': 'Bearer ${token.accessToken}'},
    );
    
    // ...
  }
}
```

**Dependency graph:**
```
mobile app
  ↓
├─→ feature_auth (provides SessionManager)
│     ↓
│   domain (defines SessionProvider interface)
│     ↓
│   core
│
└─→ feature_feed (uses SessionProvider)
      ↓
    domain (defines SessionProvider interface)
      ↓
    core
```

**Benefits:**
- ✅ Features don't know about each other
- ✅ Both depend on domain (stable contracts)
- ✅ Can swap auth implementation without breaking feed
- ✅ Can test feed with mock SessionProvider

---

## 2. Entity Evolution: When Features Need Extended Data

### Problem: Payment Feature Needs User + Payment Methods

```dart
// Payment feature needs user data + payment info
class PaymentUser extends User {
  final List<PaymentMethod> paymentMethods;
  final String? defaultPaymentMethodId;
  // ...
}
```

### ✅ Solution 2: Composition Over Inheritance

```dart
// packages/domain/lib/entities/user.dart
// Keep base User simple and stable
class User {
  final String id;
  final String email;
  final String name;
  
  const User({required this.id, required this.email, required this.name});
}

// packages/feature_payment/lib/domain/entities/payment_profile.dart
// Payment feature composes with User
class PaymentProfile {
  final User user; // Compose, don't inherit!
  final List<PaymentMethod> paymentMethods;
  final String? defaultPaymentMethodId;
  
  const PaymentProfile({
    required this.user,
    required this.paymentMethods,
    this.defaultPaymentMethodId,
  });
}

// Usage in payment feature
class PaymentRepository {
  Future<Result<Failure, PaymentProfile>> getPaymentProfile() async {
    final user = sessionProvider.getCurrentUser()!;
    final paymentMethods = await fetchPaymentMethods(user.id);
    
    return Right(PaymentProfile(
      user: user,
      paymentMethods: paymentMethods,
    ));
  }
}
```

**Benefits:**
- ✅ User entity stays stable in domain
- ✅ Each feature extends data as needed
- ✅ No tight coupling between features

---

## 3. UI Flexibility: Different Login Flows Per App

### Problem: Different Apps Need Different Login UI

**App A:** Email + Password only  
**App B:** OTP + Social Login  
**App C:** All methods  

### ✅ Solution 3: Separate Domain from Presentation

**Package structure:**
```
packages/
├── domain/                    # Shared contracts
│   
├── feature_auth_domain/       # Business logic only (no UI!)
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│       ├── login_with_email_use_case.dart
│       ├── login_with_otp_use_case.dart
│       ├── login_with_social_use_case.dart
│       └── logout_use_case.dart
│   
├── feature_auth_ui_basic/     # Email + Password UI
│   └── pages/
│       └── email_login_page.dart
│   
├── feature_auth_ui_advanced/  # All methods UI
│   └── pages/
│       ├── email_login_page.dart
│       ├── otp_login_page.dart
│       └── social_login_page.dart
│   
└── feature_auth_ui_custom/    # Your custom designs
    └── pages/
        └── custom_login_page.dart
```

**App A (Simple) uses:**
```yaml
# app_a/pubspec.yaml
dependencies:
  domain:
    path: ../packages/domain
  feature_auth_domain:
    path: ../packages/feature_auth_domain
  feature_auth_ui_basic:  # Only basic UI
    path: ../packages/feature_auth_ui_basic
```

**App B (Advanced) uses:**
```yaml
# app_b/pubspec.yaml
dependencies:
  domain:
    path: ../packages/domain
  feature_auth_domain:
    path: ../packages/feature_auth_domain
  feature_auth_ui_advanced:  # All auth methods
    path: ../packages/feature_auth_ui_advanced
```

**App C (Custom) uses:**
```yaml
# app_c/pubspec.yaml
dependencies:
  domain:
    path: ../packages/domain
  feature_auth_domain:
    path: ../packages/feature_auth_domain
  # No UI package - builds custom UI using domain layer
```

---

### ✅ Solution 4: Feature Flags & Conditional Exports

For a single package with multiple auth methods:

```dart
// packages/feature_auth/lib/feature_auth.dart
/// Main export file - apps import only what they need

// Always export domain layer
export 'domain/entities/user_entity.dart';
export 'domain/usecases/logout_use_case.dart';

// Conditional exports based on app needs
// App decides which to import

// Email auth
export 'domain/usecases/login_with_email_use_case.dart';
export 'presentation/email_login/email_login_page.dart';

// OTP auth (optional)
export 'domain/usecases/login_with_otp_use_case.dart' show LoginWithOTPUseCase;
export 'presentation/otp_login/otp_login_page.dart' show OTPLoginPage;

// Social auth (optional)
export 'domain/usecases/login_with_social_use_case.dart' show LoginWithSocialUseCase;
export 'presentation/social_login/social_login_page.dart' show SocialLoginPage;
```

**App imports only what it needs:**

```dart
// App A - Only email login
import 'package:feature_auth/feature_auth.dart' 
  show 
    User,
    LoginWithEmailUseCase,
    EmailLoginPage,
    LogoutUseCase;

// App B - Email + OTP
import 'package:feature_auth/feature_auth.dart'
  show
    User,
    LoginWithEmailUseCase,
    LoginWithOTPUseCase,
    EmailLoginPage,
    OTPLoginPage,
    LogoutUseCase;
```

---

## 4. Avoiding Code Bloat & Improving Coverage

### Problem: Importing Unused Code

If `feature_auth` has 10 login methods but your app uses only 1, you're importing 9 unused methods.

### ✅ Solution 5: Micro Packages (Granular Dependencies)

```
packages/
├── auth_core/                 # Essential auth logic
│   ├── entities/user.dart
│   ├── session_manager.dart
│   └── logout_use_case.dart
│   
├── auth_email/                # Email login only
│   ├── login_with_email_use_case.dart
│   └── email_login_page.dart
│   
├── auth_otp/                  # OTP login only
│   ├── login_with_otp_use_case.dart
│   └── otp_login_page.dart
│   
├── auth_social/               # Social login only
│   ├── login_with_social_use_case.dart
│   └── social_login_page.dart
│   
└── auth_biometric/            # Biometric login
    ├── login_with_biometric_use_case.dart
    └── biometric_login_widget.dart
```

**App dependencies:**

```yaml
# App that only needs email + OTP
dependencies:
  auth_core:
    path: ../packages/auth_core
  auth_email:
    path: ../packages/auth_email
  auth_otp:
    path: ../packages/auth_otp
  # auth_social - NOT imported (no code bloat!)
  # auth_biometric - NOT imported
```

**Benefits:**
- ✅ Only import what you need
- ✅ Smaller bundle size
- ✅ Better code coverage (no untested unused code)
- ✅ Tree-shaking works better

---

## 5. Real-World Architecture Decision Matrix

| Scenario | Recommended Pattern | Why |
|----------|---------------------|-----|
| **Token/Session sharing** | Domain package with SessionProvider interface | Loose coupling, testable |
| **User data in multiple features** | Composition over inheritance | Each feature extends as needed |
| **Different login UI per app** | Separate domain from UI packages | Reuse logic, customize UI |
| **Multiple auth methods** | Micro packages OR conditional exports | Avoid code bloat |
| **Feature needs data from another** | Domain package with interfaces | No direct feature dependency |
| **Shared UI components** | Separate ui_kit package | Reusable components |
| **Feature A → Feature B communication** | Event bus OR domain services | Decoupled messaging |

---

## 6. Complete Example: E-Commerce App Architecture

```
packages/
├── domain/                           # Shared contracts
│   ├── entities/
│   │   ├── user.dart
│   │   └── auth_token.dart
│   └── services/
│       ├── session_provider.dart     # Interface
│       └── analytics_service.dart    # Interface
│
├── core/                             # Infrastructure
│   ├── error/
│   ├── logging/
│   └── network/
│
├── auth_core/                        # Auth essentials
│   ├── session_manager.dart          # Implements SessionProvider
│   └── logout_use_case.dart
│
├── auth_email/                       # Optional: Email auth
├── auth_otp/                         # Optional: OTP auth
├── auth_social/                      # Optional: Social auth
│
├── feature_product_catalog/          # Product browsing
│   └── depends on: domain, core
│
├── feature_cart/                     # Shopping cart
│   └── depends on: domain, core, auth_core
│
├── feature_checkout/                 # Payment & orders
│   └── depends on: domain, core, auth_core
│
├── feature_user_profile/             # User profile
│   └── depends on: domain, core, auth_core
│
└── ui_kit/                           # Shared UI components
    ├── buttons/
    ├── cards/
    └── theme/

apps/
├── ecommerce_app_basic/              # Simple app
│   └── uses: auth_email only
│
└── ecommerce_app_premium/            # Full-featured app
    └── uses: all auth packages
```

**Dependency flow:**
```
ecommerce_app_basic
  ↓
├─→ auth_core → domain → core
├─→ auth_email → auth_core
├─→ feature_product_catalog → domain
├─→ feature_cart → domain + auth_core
├─→ feature_checkout → domain + auth_core
└─→ ui_kit → core
```

**Key points:**
- Features depend on `domain` (interfaces), not each other
- Auth is split into core + optional methods
- Each feature is independently testable
- App chooses which packages to include

---

## 7. Solution Architect Decision Framework

When designing package architecture, ask:

### 1️⃣ **Is this data/functionality needed by multiple features?**
- **Yes** → Put interface in `domain` package
- **No** → Keep in feature package

### 2️⃣ **Does this feature need another feature's data?**
- ✅ **Use:** Domain interface (SessionProvider, UserProvider)
- ❌ **Don't:** Import feature package directly

### 3️⃣ **Are there multiple UI variations?**
- ✅ **Use:** Separate domain from UI packages
- ❌ **Don't:** Mix business logic with UI

### 4️⃣ **Are some capabilities optional?**
- ✅ **Use:** Micro packages OR conditional exports
- ❌ **Don't:** Force all features into one package

### 5️⃣ **Will this grow significantly?**
- ✅ **Use:** Start modular (easier to maintain)
- ❌ **Don't:** Start monolithic (hard to split later)

---

## 8. Testing Strategy for Loosely Coupled Features

```dart
// Testing feature_feed without feature_auth

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
    // Arrange
    final mockSession = MockSessionProvider();
    mockSession.setMockSession(
      User(id: '1', email: 'test@example.com', name: 'Test'),
      AuthToken(accessToken: 'mock_token', expiresAt: DateTime.now().add(Duration(hours: 1))),
    );
    
    final repository = FeedRepository(
      sessionProvider: mockSession, // Mock, not real auth!
      apiClient: mockApiClient,
    );
    
    // Act
    final result = await repository.fetchFeed();
    
    // Assert
    expect(result.isSuccess, true);
  });
}
```

**No dependency on feature_auth for testing!**

---

## 9. Summary: Architecture Principles

### ✅ DO:
1. **Depend on abstractions (interfaces)**, not implementations
2. **Use domain package** for shared contracts
3. **Separate domain from UI** for flexibility
4. **Create micro packages** for optional features
5. **Compose entities**, don't inherit across features
6. **Test with mocks**, not real dependencies

### ❌ DON'T:
1. Import feature packages directly (feature_a → feature_b)
2. Mix business logic with UI
3. Create god packages with everything
4. Force all apps to import all features
5. Inherit entities across feature boundaries

### 🎯 Golden Rule:
> **Features should depend on contracts (domain), not other features (implementations).**

---

## 10. When to Choose Each Pattern

| Your Situation | Pattern to Use | Example |
|----------------|----------------|---------|
| Simple app, 1-2 features | Monolithic with clean architecture | Keep in mobile/lib/features |
| 3-5 features, some shared logic | Domain + Feature packages | domain + feature_auth + feature_feed |
| Multiple apps with different needs | Micro packages | auth_core + auth_email + auth_otp |
| Complex enterprise app | Full modular architecture | domain + multiple micro features |
| Need rapid prototyping | Start simple, refactor later | Monolithic → Modular when needed |

Start simple, evolve as complexity grows. Don't over-engineer early! 🚀
