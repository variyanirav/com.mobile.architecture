# **Day 5: Dependency Injection (DI)**

---

## 🎯 Goal

Master Dependency Injection in Flutter by understanding what it is, why it exists, when to use it, and how to implement it correctly. By the end of Day 5, you'll:

* **Understand the problem DI solves** (tight coupling, hard-to-test code)
* **Learn 3 types of dependency injection** (Constructor, Property, Method)
* **Master 2 DI patterns** (Service Locator vs Dependency Injection Container)
* **Implement DI with get_it** (most popular) and **Riverpod** (modern approach)
* **Make informed decisions** about when to use which DI approach
* **Test code with mocked dependencies** easily
* **Avoid common DI anti-patterns**

**Time allocation (60 minutes):**
- 15m: Understand DI problem (tight coupling) and solution
- 20m: Implement DI with get_it for auth feature
- 15m: Compare Riverpod DI approach (if using Riverpod)
- 10m: Create ADR documenting DI choice

---

## 🧠 Step 1: Understanding the Problem (Why DI Exists)

### 📘 What is a Dependency?

A **dependency** is any object that another object needs to function.

**Real-World Analogy:**
Think of making coffee:
- **You** (the object) need **a coffee machine** (dependency)
- You also need **coffee beans** (another dependency)
- And **water** (yet another dependency)

**Code Example:**
```dart
class CoffeeService {
  // Dependencies
  final CoffeeMachine machine;
  final CoffeeBeans beans;
  final Water water;
  
  // CoffeeService depends on these 3 things
}
```

---

### 🔴 The Problem: Tight Coupling (Without DI)

**Scenario:** You're building a login feature.

**❌ BAD: Creating dependencies inside the class**
```dart
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Creating dependencies directly!
  final AuthRepository authRepo = AuthRepositoryImpl();
  final Analytics analytics = FirebaseAnalytics();
  final Logger logger = AppLogger();
  
  Future<void> login(String email, String password) async {
    logger.log('Login attempt');
    final result = await authRepo.login(email, password);
    analytics.logEvent('login_success');
  }
}
```

**🚨 Problems with this approach:**

1. **Hard to Test**
   - How do you test `login()` without calling real Firebase?
   - How do you test without making real API calls?
   - You can't mock `AuthRepositoryImpl` because it's created inside the class!

2. **Tight Coupling**
   - `LoginPage` is **tightly coupled** to `AuthRepositoryImpl`
   - If you want to change the implementation, you must edit `LoginPage`
   - Can't swap implementations (test vs production)

3. **Hard to Change**
   - Want to use a different analytics service? Edit every file!
   - Want to add logging? Edit every file!
   - Violates Open/Closed Principle

4. **Hidden Dependencies**
   - You can't tell what `LoginPage` needs by looking at the constructor
   - Dependencies are created inside methods (hidden)

5. **Singleton Hell**
   - If you create `AuthRepositoryImpl()` in 10 places, you have 10 instances
   - Hard to manage shared state

---

### 🧠 Mental Model 1: The Restaurant Analogy

**Without DI (Bad):**
```
Chef walks to the market to buy ingredients
Chef builds the stove
Chef digs a well for water
Chef makes the plate and utensils
THEN Chef cooks
```
**Problem:** Chef is responsible for EVERYTHING. Can't cook without building tools first!

**With DI (Good):**
```
Restaurant owner provides:
  - Pre-bought ingredients
  - Working stove
  - Running water
  - Plates and utensils
  
Chef receives these and JUST COOKS
```
**Benefit:** Chef focuses on cooking. Tools are provided by someone else.

---

### ✅ The Solution: Dependency Injection

**Dependency Injection** = "Don't create your dependencies, receive them from outside"

**✅ GOOD: Injecting dependencies**
```dart
class LoginPage extends StatefulWidget {
  // Dependencies injected through constructor
  final AuthRepository authRepo;
  final Analytics analytics;
  final Logger logger;
  
  const LoginPage({
    required this.authRepo,
    required this.analytics,
    required this.logger,
  });
  
  // Now whoever creates LoginPage must provide these!
}

class _LoginPageState extends State<LoginPage> {
  Future<void> login(String email, String password) async {
    widget.logger.log('Login attempt');
    final result = await widget.authRepo.login(email, password);
    widget.analytics.logEvent('login_success');
  }
}
```

**✨ Benefits:**

1. **Easy to Test**
   ```dart
   test('login success', () async {
     // Create MOCK dependencies
     final mockRepo = MockAuthRepository();
     final mockAnalytics = MockAnalytics();
     final mockLogger = MockLogger();
     
     // Inject mocks
     final page = LoginPage(
       authRepo: mockRepo,
       analytics: mockAnalytics,
       logger: mockLogger,
     );
     
     // Test without real Firebase or APIs!
   });
   ```

2. **Loose Coupling**
   - `LoginPage` depends on **interfaces** (`AuthRepository`), not implementations
   - Can swap implementations without changing `LoginPage`

3. **Clear Dependencies**
   - Just look at the constructor to see what's needed
   - No hidden dependencies

4. **Single Instance Control**
   - Create `AuthRepositoryImpl()` ONCE at app startup
   - Inject the same instance everywhere
   - Easy to manage shared state

---

## 🔧 Step 2: Types of Dependency Injection

### 1️⃣ Constructor Injection (Most Common, Recommended)

**What:** Pass dependencies through the constructor.

```dart
class LoginUseCase {
  final AuthRepository _repository;
  final Logger _logger;
  
  // Constructor injection
  LoginUseCase(this._repository, this._logger);
  
  Future<Result> call(String email, String password) async {
    _logger.log('Login attempt');
    return await _repository.login(email, password);
  }
}

// Usage
final useCase = LoginUseCase(authRepo, logger);
```

**✅ Pros:**
- Dependencies are **immutable** (final)
- Clear what's required
- Can't create instance without dependencies
- Best for required dependencies

**❌ Cons:**
- Constructor gets long if many dependencies (5+ parameters)

---

### 2️⃣ Property Injection (Setter Injection)

**What:** Set dependencies after object creation.

```dart
class LoginUseCase {
  late AuthRepository repository;
  late Logger logger;
  
  // No constructor injection
  
  Future<Result> call(String email, String password) async {
    logger.log('Login attempt');
    return await repository.login(email, password);
  }
}

// Usage
final useCase = LoginUseCase()
  ..repository = authRepo
  ..logger = logger;
```

**✅ Pros:**
- Flexible
- Can change dependencies at runtime

**❌ Cons:**
- Dependencies can be null (late)
- Not clear what's required
- Can forget to set a dependency
- **Rarely used in Flutter**

---

### 3️⃣ Method Injection

**What:** Pass dependencies as method parameters.

```dart
class LoginUseCase {
  Future<Result> call(
    String email,
    String password,
    AuthRepository repository,  // Injected per call
    Logger logger,
  ) async {
    logger.log('Login attempt');
    return await repository.login(email, password);
  }
}

// Usage
final result = await loginUseCase(email, password, authRepo, logger);
```

**✅ Pros:**
- Different dependencies per method call
- Very flexible

**❌ Cons:**
- Method signatures get long
- Repetitive (pass same things everywhere)
- **Rarely used in Flutter**

---

### 🎯 Which Type to Use?

| Type | Use When | Example |
|------|----------|---------|
| **Constructor Injection** | ✅ 95% of the time | Services, Repositories, Use Cases |
| **Property Injection** | ⚠️ Rare, optional dependencies | Feature flags, optional logging |
| **Method Injection** | ⚠️ Very rare | Factories with varying inputs |

**Recommendation:** **Always use Constructor Injection** unless you have a specific reason not to.

---

## 🏗 Step 3: DI Patterns - Service Locator vs DI Container

### Pattern 1: Service Locator (get_it)

**What:** A global registry where you register services and retrieve them by type.

**Mental Model:** A **vending machine** - put services in, get them out by pressing a button.

```dart
// Setup (app startup)
final getIt = GetIt.instance;

void setupDependencies() {
  // Register services
  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  getIt.registerSingleton<Logger>(AppLogger());
  getIt.registerFactory<LoginUseCase>(() => LoginUseCase(
    getIt<AuthRepository>(),
    getIt<Logger>(),
  ));
}

// Usage (anywhere in app)
class LoginBloc {
  final loginUseCase = getIt<LoginUseCase>();  // Pull from service locator
  
  Future<void> login(String email, String password) async {
    await loginUseCase(email, password);
  }
}
```

**How it works:**
1. **Register** all services at app startup
2. **Retrieve** services anywhere using `getIt<Type>()`
3. GetIt manages lifecycle (singleton, factory, lazy)

**✅ Pros:**
- Simple to understand
- No BuildContext needed
- Works anywhere (even in pure Dart classes)
- Popular in Flutter community

**❌ Cons:**
- **Global state** (can be accessed anywhere)
- **Runtime errors** (typo in type = crash)
- **Hidden dependencies** (can't tell what a class needs)
- Harder to test (must reset GetIt between tests)

---

### Pattern 2: Dependency Injection Container (Riverpod)

**What:** Providers that explicitly declare dependencies and automatically inject them.

**Mental Model:** A **smart butler** - knows what each room needs and delivers it automatically.

```dart
// Setup (define providers)
final loggerProvider = Provider<Logger>((ref) => AppLogger());

final authRepoProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  // Riverpod automatically injects dependencies
  return LoginUseCase(
    ref.watch(authRepoProvider),
    ref.watch(loggerProvider),
  );
});

// Usage (in widgets)
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod injects automatically
    final loginUseCase = ref.watch(loginUseCaseProvider);
    return ElevatedButton(
      onPressed: () => loginUseCase(email, password),
      child: Text('Login'),
    );
  }
}
```

**How it works:**
1. **Define providers** (blueprints for creating services)
2. **Watch providers** (`ref.watch`) to get instances
3. Riverpod handles lifecycle and dependencies automatically

**✅ Pros:**
- **Type-safe** (compile-time errors, not runtime)
- **Explicit dependencies** (can see what depends on what)
- **Easy to test** (override providers in tests)
- **No global state** (scoped to ProviderScope)
- **Automatic disposal** (cleans up when not needed)

**❌ Cons:**
- Learning curve (need to understand providers)
- Requires `BuildContext` or `WidgetRef` (not pure Dart)
- More boilerplate initially

---

## 🔄 Step 4: Comparison - get_it vs Riverpod

### Side-by-Side Example

**Scenario:** Login feature needs `AuthRepository` and `Logger`.

#### Using get_it (Service Locator)

**Setup (main.dart):**
```dart
void main() {
  setupDependencies();
  runApp(MyApp());
}

void setupDependencies() {
  final getIt = GetIt.instance;
  
  // Register logger
  getIt.registerSingleton<Logger>(AppLogger());
  
  // Register repository
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      apiClient: getIt<ApiClient>(),  // Pull dependency
    ),
  );
  
  // Register use case
  getIt.registerFactory<LoginUseCase>(
    () => LoginUseCase(
      getIt<AuthRepository>(),  // Pull dependencies
      getIt<Logger>(),
    ),
  );
}
```

**Usage (bloc):**
```dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  // Pull from service locator
  final loginUseCase = getIt<LoginUseCase>();
  
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }
  
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    final result = await loginUseCase(event.email, event.password);
    // Handle result
  }
}
```

**Testing:**
```dart
void main() {
  setUp(() {
    // Reset GetIt
    GetIt.instance.reset();
    
    // Register mocks
    GetIt.instance.registerSingleton<LoginUseCase>(MockLoginUseCase());
  });
  
  blocTest<LoginBloc, LoginState>(
    'login success',
    build: () => LoginBloc(),  // Uses GetIt internally
    act: (bloc) => bloc.add(LoginSubmitted('email', 'pass')),
    expect: () => [LoginLoading(), LoginSuccess()],
  );
}
```

---

#### Using Riverpod (DI Container)

**Setup (providers.dart):**
```dart
// Define providers
final loggerProvider = Provider<Logger>((ref) => AppLogger());

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),  // Watch dependency
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(
    ref.watch(authRepoProvider),  // Watch dependencies
    ref.watch(loggerProvider),
  );
});
```

**Usage (bloc):**
```dart
// Define bloc provider that depends on use case
final loginBlocProvider = StateNotifierProvider<LoginBloc, LoginState>((ref) {
  return LoginBloc(
    ref.watch(loginUseCaseProvider),  // Riverpod injects automatically
  );
});

class LoginBloc extends StateNotifier<LoginState> {
  final LoginUseCase _loginUseCase;
  
  // Constructor injection (clean!)
  LoginBloc(this._loginUseCase) : super(LoginInitial());
  
  Future<void> login(String email, String password) async {
    state = LoginLoading();
    final result = await _loginUseCase(email, password);
    // Handle result
  }
}
```

**Testing:**
```dart
void main() {
  test('login success', () async {
    // Create container with overridden providers
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(MockLoginUseCase()),
      ],
    );
    
    final bloc = container.read(loginBlocProvider.notifier);
    await bloc.login('email', 'pass');
    
    expect(container.read(loginBlocProvider), isA<LoginSuccess>());
    container.dispose();
  });
}
```

---

### 📊 Comparison Table

| Feature | get_it (Service Locator) | Riverpod (DI Container) |
|---------|-------------------------|------------------------|
| **Type Safety** | ❌ Runtime errors | ✅ Compile-time safety |
| **Explicit Dependencies** | ❌ Hidden (inside methods) | ✅ Clear (in provider definition) |
| **Testing** | ⚠️ Must reset GetIt | ✅ Override providers easily |
| **Global State** | ❌ Yes (GetIt.instance) | ✅ No (scoped to ProviderScope) |
| **Learning Curve** | ✅ Easy (like a map) | ⚠️ Medium (provider concepts) |
| **Boilerplate** | ✅ Low | ⚠️ Medium |
| **Pure Dart Support** | ✅ Yes (works outside Flutter) | ❌ Needs WidgetRef/ProviderContainer |
| **Automatic Disposal** | ❌ Manual | ✅ Automatic |
| **Dependency Graph** | ❌ Not visible | ✅ Clear in provider definitions |
| **Best For** | Simple apps, quick setup | Complex apps, strict architecture |

---

## 🎯 Step 5: When to Use Which?

### Decision Matrix

```
START
  │
  ├─ Need to work in pure Dart (no Flutter)?
  │   └─ YES → get_it
  │   └─ NO → Continue
  │
  ├─ Already using Riverpod for state management?
  │   └─ YES → Riverpod DI (consistency)
  │   └─ NO → Continue
  │
  ├─ Complex app with many dependencies?
  │   └─ YES → Riverpod (better dependency tracking)
  │   └─ NO → Continue
  │
  ├─ Team familiar with service locators?
  │   └─ YES → get_it
  │   └─ NO → Continue
  │
  └─ Default → get_it (easier to learn)
```

### Use get_it If:
- ✅ Simple to medium app (< 20 dependencies)
- ✅ Team new to DI concepts
- ✅ Need DI in pure Dart code (backend, CLI)
- ✅ Want minimal setup
- ✅ Prototyping or MVP

### Use Riverpod DI If:
- ✅ Already using Riverpod for state management
- ✅ Complex app (20+ dependencies)
- ✅ Want compile-time safety
- ✅ Need explicit dependency graphs
- ✅ High test coverage requirements

### Use Both (Hybrid):
- ✅ get_it for services (Logger, Analytics)
- ✅ Riverpod for state management
- ⚠️ Be consistent! Document which is used where

---

## 💻 Step 6: Hands-On Implementation

### Scenario: Add DI to Auth Feature

**Goal:** Refactor auth feature to use DI with both get_it and Riverpod.

---

### Implementation 1: Using get_it

**Step 1: Add Dependencies**
```yaml
# pubspec.yaml
dependencies:
  get_it: ^7.6.0
```

**Step 2: Define Interfaces**
```dart
// lib/core/services/logger.dart
abstract class Logger {
  void log(String message);
  void error(String message, [Object? error, StackTrace? stackTrace]);
}

// lib/core/services/analytics.dart
abstract class Analytics {
  void logEvent(String name, [Map<String, dynamic>? parameters]);
  void setUserId(String userId);
}

// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Result<User>> login(String email, String password);
  Future<Result<void>> logout();
  Future<User?> getCurrentUser();
}
```

**Step 3: Implement Concrete Classes**
```dart
// lib/core/services/app_logger.dart
class AppLogger implements Logger {
  @override
  void log(String message) => print('[LOG] $message');
  
  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    print('[ERROR] $message');
    if (error != null) print(error);
    if (stackTrace != null) print(stackTrace);
  }
}

// lib/core/services/firebase_analytics.dart
class FirebaseAnalyticsService implements Analytics {
  @override
  void logEvent(String name, [Map<String, dynamic>? parameters]) {
    // Firebase Analytics implementation
    print('[ANALYTICS] $name: $parameters');
  }
  
  @override
  void setUserId(String userId) {
    print('[ANALYTICS] User ID: $userId');
  }
}

// lib/features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _storage;
  final Logger _logger;
  
  AuthRepositoryImpl({
    required ApiClient apiClient,
    required SecureStorage storage,
    required Logger logger,
  })  : _apiClient = apiClient,
        _storage = storage,
        _logger = logger;
  
  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      _logger.log('Login attempt for: $email');
      final response = await _apiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });
      final user = User.fromJson(response.data);
      await _storage.write('auth_token', response.data['token']);
      return Result.success(user);
    } catch (e, stack) {
      _logger.error('Login failed', e, stack);
      return Result.failure(Failure('Login failed'));
    }
  }
  
  // Other methods...
}
```

**Step 4: Setup GetIt (Service Locator)**
```dart
// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core services (Singletons - created once, live forever)
  getIt.registerSingleton<Logger>(AppLogger());
  getIt.registerSingleton<Analytics>(FirebaseAnalyticsService());
  getIt.registerSingleton<SecureStorage>(FlutterSecureStorageImpl());
  
  // API Client (Singleton)
  getIt.registerSingleton<ApiClient>(
    ApiClient(baseUrl: 'https://api.example.com'),
  );
  
  // Repositories (Singletons - but could be Lazy)
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiClient: getIt<ApiClient>(),
      storage: getIt<SecureStorage>(),
      logger: getIt<Logger>(),
    ),
  );
  
  // Use Cases (Factories - new instance each time)
  getIt.registerFactory<LoginUseCase>(
    () => LoginUseCase(
      repository: getIt<AuthRepository>(),
      analytics: getIt<Analytics>(),
      logger: getIt<Logger>(),
    ),
  );
  
  getIt.registerFactory<LogoutUseCase>(
    () => LogoutUseCase(
      repository: getIt<AuthRepository>(),
      analytics: getIt<Analytics>(),
    ),
  );
}
```

**Step 5: Initialize in main.dart**
```dart
// lib/main.dart
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup DI
  await setupDependencies();
  
  runApp(MyApp());
}
```

**Step 6: Use in BLoC**
```dart
// lib/features/auth/presentation/bloc/login_bloc.dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  // Retrieve from GetIt
  final LoginUseCase _loginUseCase = getIt<LoginUseCase>();
  final Analytics _analytics = getIt<Analytics>();
  
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }
  
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    
    final result = await _loginUseCase(event.email, event.password);
    
    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (user) {
        _analytics.logEvent('login_success', {'user_id': user.id});
        emit(LoginSuccess(user));
      },
    );
  }
}
```

**Step 7: Provide BLoC to UI**
```dart
// lib/features/auth/presentation/pages/login_page.dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create bloc (which uses GetIt internally)
      create: (_) => LoginBloc(),
      child: LoginView(),
    );
  }
}
```

**Step 8: Testing with get_it**
```dart
// test/features/auth/presentation/bloc/login_bloc_test.dart
void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockAnalytics mockAnalytics;
  
  setUp(() {
    // Reset GetIt before each test
    GetIt.instance.reset();
    
    // Create mocks
    mockLoginUseCase = MockLoginUseCase();
    mockAnalytics = MockAnalytics();
    
    // Register mocks in GetIt
    GetIt.instance.registerSingleton<LoginUseCase>(mockLoginUseCase);
    GetIt.instance.registerSingleton<Analytics>(mockAnalytics);
  });
  
  tearDown(() {
    GetIt.instance.reset();
  });
  
  blocTest<LoginBloc, LoginState>(
    'emits [LoginLoading, LoginSuccess] when login succeeds',
    build: () => LoginBloc(),  // Uses GetIt internally
    act: (bloc) => bloc.add(LoginSubmitted('test@test.com', 'password')),
    expect: () => [
      LoginLoading(),
      isA<LoginSuccess>(),
    ],
    verify: (_) {
      verify(() => mockLoginUseCase('test@test.com', 'password')).called(1);
      verify(() => mockAnalytics.logEvent('login_success', any())).called(1);
    },
  );
}
```

---

### Implementation 2: Using Riverpod

**Step 1: Add Dependencies**
```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.5.1
```

**Step 2: Define Providers**
```dart
// lib/core/providers/core_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core service providers
final loggerProvider = Provider<Logger>((ref) => AppLogger());

final analyticsProvider = Provider<Analytics>((ref) => FirebaseAnalyticsService());

final secureStorageProvider = Provider<SecureStorage>((ref) => FlutterSecureStorageImpl());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: 'https://api.example.com');
});
```

**Step 3: Define Repository Providers**
```dart
// lib/features/auth/presentation/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageProvider),
    logger: ref.watch(loggerProvider),
  );
});
```

**Step 4: Define Use Case Providers**
```dart
// lib/features/auth/presentation/providers/auth_providers.dart
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(
    repository: ref.watch(authRepositoryProvider),
    analytics: ref.watch(analyticsProvider),
    logger: ref.watch(loggerProvider),
  );
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(
    repository: ref.watch(authRepositoryProvider),
    analytics: ref.watch(analyticsProvider),
  );
});
```

**Step 5: Define BLoC Provider**
```dart
// lib/features/auth/presentation/providers/auth_providers.dart
final loginBlocProvider = StateNotifierProvider<LoginBloc, LoginState>((ref) {
  return LoginBloc(
    loginUseCase: ref.watch(loginUseCaseProvider),
    analytics: ref.watch(analyticsProvider),
  );
});
```

**Step 6: Update BLoC to Use Constructor Injection**
```dart
// lib/features/auth/presentation/bloc/login_bloc.dart
class LoginBloc extends StateNotifier<LoginState> {
  final LoginUseCase _loginUseCase;
  final Analytics _analytics;
  
  // Constructor injection (explicit dependencies!)
  LoginBloc({
    required LoginUseCase loginUseCase,
    required Analytics analytics,
  })  : _loginUseCase = loginUseCase,
        _analytics = analytics,
        super(LoginInitial());
  
  Future<void> login(String email, String password) async {
    state = LoginLoading();
    
    final result = await _loginUseCase(email, password);
    
    result.fold(
      (failure) => state = LoginError(failure.message),
      (user) {
        _analytics.logEvent('login_success', {'user_id': user.id});
        state = LoginSuccess(user);
      },
    );
  }
}
```

**Step 7: Wrap App with ProviderScope**
```dart
// lib/main.dart
void main() {
  runApp(
    ProviderScope(  // Required for Riverpod
      child: MyApp(),
    ),
  );
}
```

**Step 8: Use in UI**
```dart
// lib/features/auth/presentation/pages/login_page.dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginBlocProvider);
    final loginBloc = ref.watch(loginBlocProvider.notifier);
    
    return Scaffold(
      body: Column(
        children: [
          if (loginState is LoginLoading)
            CircularProgressIndicator(),
          
          if (loginState is LoginError)
            Text('Error: ${loginState.message}'),
          
          ElevatedButton(
            onPressed: () => loginBloc.login(email, password),
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

**Step 9: Testing with Riverpod**
```dart
// test/features/auth/presentation/bloc/login_bloc_test.dart
void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockAnalytics mockAnalytics;
  
  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockAnalytics = MockAnalytics();
  });
  
  test('emits [LoginLoading, LoginSuccess] when login succeeds', () async {
    // Create container with overridden providers
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        analyticsProvider.overrideWithValue(mockAnalytics),
      ],
    );
    
    // Setup mock behavior
    when(() => mockLoginUseCase('test@test.com', 'password'))
        .thenAnswer((_) async => Result.success(mockUser));
    
    // Get bloc
    final bloc = container.read(loginBlocProvider.notifier);
    
    // Act
    await bloc.login('test@test.com', 'password');
    
    // Assert
    expect(container.read(loginBlocProvider), isA<LoginSuccess>());
    
    verify(() => mockLoginUseCase('test@test.com', 'password')).called(1);
    verify(() => mockAnalytics.logEvent('login_success', any())).called(1);
    
    container.dispose();
  });
}
```

---

## 🎯 Step 7: DI Best Practices

### ✅ DO:

1. **Inject Through Constructors**
   ```dart
   // ✅ GOOD
   class LoginUseCase {
     final AuthRepository _repository;
     LoginUseCase(this._repository);
   }
   ```

2. **Depend on Abstractions, Not Implementations**
   ```dart
   // ✅ GOOD
   class LoginBloc {
     final AuthRepository _repo;  // Interface
     LoginBloc(this._repo);
   }
   
   // ❌ BAD
   class LoginBloc {
     final AuthRepositoryImpl _repo;  // Implementation
     LoginBloc(this._repo);
   }
   ```

3. **Register All Dependencies at Startup**
   ```dart
   // ✅ GOOD
   void main() async {
     await setupDependencies();  // All at once
     runApp(MyApp());
   }
   ```

4. **Use Singletons for Stateful Services**
   ```dart
   // ✅ GOOD - Singleton (shared state)
   getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl());
   ```

5. **Use Factories for Stateless Services**
   ```dart
   // ✅ GOOD - Factory (new instance each time)
   getIt.registerFactory<LoginUseCase>(() => LoginUseCase(getIt()));
   ```

---

### ❌ DON'T:

1. **Don't Create Dependencies Inside Classes**
   ```dart
   // ❌ BAD
   class LoginBloc {
     final authRepo = AuthRepositoryImpl();  // Created inside!
   }
   ```

2. **Don't Use Service Locator in Domain Layer**
   ```dart
   // ❌ BAD
   class LoginUseCase {
     Future<Result> call() {
       final repo = getIt<AuthRepository>();  // Pulling from service locator!
       return repo.login();
     }
   }
   
   // ✅ GOOD
   class LoginUseCase {
     final AuthRepository _repository;
     LoginUseCase(this._repository);  // Injected
     
     Future<Result> call() => _repository.login();
   }
   ```

3. **Don't Have Circular Dependencies**
   ```dart
   // ❌ BAD
   class ServiceA {
     final ServiceB b;
     ServiceA(this.b);
   }
   
   class ServiceB {
     final ServiceA a;
     ServiceB(this.a);  // Circular!
   }
   ```

4. **Don't Register Too Late**
   ```dart
   // ❌ BAD
   void main() {
     runApp(MyApp());  // App starts before DI setup!
     setupDependencies();  // Too late!
   }
   ```

5. **Don't Mix DI Patterns Randomly**
   ```dart
   // ❌ BAD - Confusing!
   class LoginBloc {
     final authRepo = getIt<AuthRepository>();  // Service locator
     final Analytics analytics;  // Constructor injection
     LoginBloc(this.analytics);
   }
   ```

---

## 🧩 Step 8: Common DI Patterns & Scenarios

### Pattern 1: Lazy Initialization

**Problem:** Some services are expensive to create but rarely used.

**Solution:** Use `registerLazySingleton`

```dart
// Only creates when first requested
getIt.registerLazySingleton<ExpensiveService>(
  () => ExpensiveService(),
);

// Or with Riverpod
final expensiveServiceProvider = Provider<ExpensiveService>((ref) {
  ref.onDispose(() {
    // Cleanup when no longer needed
  });
  return ExpensiveService();
});
```

---

### Pattern 2: Environment-Specific Dependencies

**Problem:** Need different implementations for dev/staging/prod.

**Solution:** Register based on environment.

```dart
void setupDependencies() {
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  
  if (env == 'prod') {
    getIt.registerSingleton<ApiClient>(
      ProdApiClient(baseUrl: 'https://api.prod.com'),
    );
  } else {
    getIt.registerSingleton<ApiClient>(
      MockApiClient(),  // For dev/test
    );
  }
  
  // Rest of setup...
}
```

---

### Pattern 3: Optional Dependencies

**Problem:** Some features are optional (analytics, crash reporting).

**Solution:** Use nullable types or default implementations.

```dart
abstract class Analytics {
  void logEvent(String name);
}

class NoOpAnalytics implements Analytics {
  @override
  void logEvent(String name) {
    // Do nothing (disabled)
  }
}

void setupDependencies({bool enableAnalytics = true}) {
  if (enableAnalytics) {
    getIt.registerSingleton<Analytics>(FirebaseAnalytics());
  } else {
    getIt.registerSingleton<Analytics>(NoOpAnalytics());
  }
}
```

---

### Pattern 4: Feature Modules

**Problem:** Large app with many features, each with its own dependencies.

**Solution:** Module-based registration.

```dart
// lib/features/auth/di/auth_module.dart
class AuthModule {
  static void register() {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        apiClient: getIt(),
        storage: getIt(),
      ),
    );
    
    getIt.registerFactory<LoginUseCase>(
      () => LoginUseCase(getIt()),
    );
  }
}

// lib/features/profile/di/profile_module.dart
class ProfileModule {
  static void register() {
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt()),
    );
  }
}

// lib/main.dart
void main() async {
  // Register core first
  CoreModule.register();
  
  // Then features
  AuthModule.register();
  ProfileModule.register();
  
  runApp(MyApp());
}
```

---

## 🔍 Step 9: Debugging DI Issues

### Common Errors & Solutions

#### Error 1: "GetIt: Object/factory with type X is not registered"

**Cause:** Trying to retrieve a service before registering it.

**Solution:**
```dart
// Make sure registration happens first
void main() async {
  await setupDependencies();  // Register first!
  runApp(MyApp());
}

void setupDependencies() {
  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  // Register BEFORE using!
}
```

---

#### Error 2: Circular Dependencies

**Cause:** ServiceA depends on ServiceB, which depends on ServiceA.

**Solution:** Break the cycle with an interface or event bus.

```dart
// ❌ BAD - Circular
class UserService {
  final OrderService orderService;
  UserService(this.orderService);
}

class OrderService {
  final UserService userService;  // Circular!
  OrderService(this.userService);
}

// ✅ GOOD - Break with interface
abstract class UserProvider {
  User getUser();
}

class UserService implements UserProvider {
  @override
  User getUser() => currentUser;
}

class OrderService {
  final UserProvider userProvider;  // Depends on interface
  OrderService(this.userProvider);
}
```

---

#### Error 3: Dependencies Not Cleaned Up

**Cause:** Singletons living forever, even when not needed.

**Solution:** Use `registerLazySingleton` or Riverpod (auto-disposes).

```dart
// get_it
getIt.registerLazySingleton<ExpensiveService>(
  () => ExpensiveService(),
  dispose: (service) => service.dispose(),  // Cleanup
);

// Riverpod (automatic)
final serviceProvider = Provider<ExpensiveService>((ref) {
  final service = ExpensiveService();
  ref.onDispose(() => service.dispose());  // Auto cleanup
  return service;
});
```

---

## 📚 Step 10: Mental Models for DI

### Mental Model 1: The Restaurant

**Without DI:**
```
Chef → Goes to market to buy ingredients
Chef → Builds the stove
Chef → Digs a well for water
Chef → Finally cooks
```

**With DI:**
```
Restaurant Owner → Buys ingredients
Restaurant Owner → Installs stove
Restaurant Owner → Connects water
Chef → Receives all tools → Just cooks!
```

**Lesson:** Separate **creation** (owner) from **usage** (chef).

---

### Mental Model 2: The Car Factory

**Without DI:**
```dart
class Car {
  final Engine engine = Engine();  // Car builds its own engine!
  final Wheels wheels = Wheels();  // Car builds its own wheels!
}
```
**Problem:** Can't test Car with a mock engine!

**With DI:**
```dart
class Car {
  final Engine engine;
  final Wheels wheels;
  Car(this.engine, this.wheels);  // Factory provides parts
}

// Usage
final car = Car(V8Engine(), SportWheels());  // Factory decides
final testCar = Car(MockEngine(), MockWheels());  // Test decides
```

**Lesson:** **Inject** dependencies, don't **create** them.

---

### Mental Model 3: The Plugin System

Think of DI as a **plugin system**:
- **Interfaces** = Plugin slots
- **Implementations** = Plugins
- **DI Container** = Plugin manager

```dart
// Plugin slot
abstract class PaymentGateway {
  Future<void> pay(double amount);
}

// Plugin A
class StripeGateway implements PaymentGateway {
  Future<void> pay(double amount) => // Stripe logic
}

// Plugin B
class PayPalGateway implements PaymentGateway {
  Future<void> pay(double amount) => // PayPal logic
}

// Plugin manager (DI)
getIt.registerSingleton<PaymentGateway>(StripeGateway());
// Switch to PayPal? Just change this line!
```

**Lesson:** DI lets you **swap implementations** without changing code.

---

## ✅ Definition of Done (Day 5)

By the end of Day 5, you should have:

- [x] Understood **what DI is** and **why it exists**
- [x] Learned **3 types of DI** (Constructor, Property, Method)
- [x] Implemented DI with **get_it**
- [x] Implemented DI with **Riverpod**
- [x] **Refactored auth feature** to use DI
- [x] Written **tests with mocked dependencies**
- [x] Created **ADR for DI choice**
- [x] Understood **when to use which pattern**

---

## 📝 Tasks

### Task 1: Setup get_it DI (60 min)
1. Add `get_it` dependency
2. Create `injection.dart` with setup function
3. Register services (Logger, Analytics, ApiClient)
4. Register repositories (AuthRepository)
5. Register use cases (LoginUseCase)
6. Initialize in `main.dart`
7. Test that services can be retrieved

### Task 2: Refactor Auth Feature (90 min)
1. Update `LoginBloc` to retrieve from get_it
2. Remove direct instantiation (`new AuthRepositoryImpl()`)
3. Test login flow still works
4. Write unit test with mocked dependencies
5. Compare: before DI vs after DI

### Task 3: Implement Riverpod DI (60 min)
1. Create providers for all dependencies
2. Update BLoC to use constructor injection
3. Wrap app with `ProviderScope`
4. Test with overridden providers
5. Compare: get_it vs Riverpod

### Task 4: Create ADR (30 min)
1. Use `ADR_TEMPLATE.md`
2. Document DI choice (get_it or Riverpod)
3. List pros/cons of each
4. Explain decision criteria
5. Save as `docs/adr/002-dependency-injection-choice.md`

### Task 5: Update Documentation (20 min)
1. Add DI section to `README.md`
2. Document how to add new dependencies
3. Create DI architecture diagram
4. Update `LEARNING.md` with Day 5 notes

---

## 🎓 Success Criteria

You've completed Day 5 successfully if you can answer YES to:

1. Can I explain what Dependency Injection is?
2. Can I explain why DI is important (testability, loose coupling)?
3. Have I implemented DI with get_it?
4. Have I implemented DI with Riverpod?
5. Can I test my code with mocked dependencies?
6. Do I understand when to use get_it vs Riverpod?
7. Have I created an ADR documenting my DI choice?
8. Can I add a new dependency without breaking existing code?

---

## 🚀 What's Next (Day 6)?

* Implement end-to-end login flow
* Wire everything together (DI + State Management + Clean Architecture)
* Add unit tests for all layers
* Add widget tests for login UI

---

## 💡 Pro Tips

**Tip 1: Start with get_it**
If you're new to DI, start with get_it. It's simpler and more intuitive.

**Tip 2: Don't Over-Register**
Not everything needs to be in DI. Simple value objects (models) don't need registration.

**Tip 3: Register Once, Use Everywhere**
Register dependencies at app startup. Don't register in widgets or business logic.

**Tip 4: Test Your DI Setup**
Write a test that verifies all dependencies can be retrieved without errors.

**Tip 5: Document Your Choices**
Always create an ADR explaining why you chose get_it or Riverpod.

---

## ❓ FAQ

### Q1: Do I need DI for small apps?

**Answer:** Not necessarily. For very small apps (< 5 screens, no complex logic), manual dependency passing might be sufficient.

**Rule of Thumb:**
- **< 5 dependencies:** Manual passing OK
- **5-15 dependencies:** Consider get_it
- **15+ dependencies:** Use DI (get_it or Riverpod)

---

### Q2: Can I use both get_it and Riverpod?

**Answer:** Technically yes, but **not recommended**. Pick one pattern for consistency.

**Exception:** Use get_it for services and Riverpod for state management, but document this clearly.

---

### Q3: How do I handle database dependencies (SQLite, Hive)?

**Answer:** Register database instances as singletons.

```dart
getIt.registerSingletonAsync<Database>(() async {
  return await openDatabase('app.db');
});

// Wait for async singletons
await getIt.allReady();
```

---

### Q4: What's the difference between Singleton and Factory?

**Answer:**

| Type | When Created | How Many Instances | Use For |
|------|--------------|-------------------|---------|
| **Singleton** | Once, at registration or first use | 1 (shared) | Repositories, Services, Database |
| **Factory** | Every time retrieved | Many (new each time) | Use Cases, ViewModels |
| **LazySingleton** | First time retrieved | 1 (shared, lazy) | Expensive services |

```dart
// Singleton - Created immediately
getIt.registerSingleton<AuthRepo>(AuthRepoImpl());

// LazySingleton - Created on first use
getIt.registerLazySingleton<Database>(() => openDb());

// Factory - New instance each time
getIt.registerFactory<LoginUseCase>(() => LoginUseCase(getIt()));
```

---

### Q5: How do I handle async initialization?

**Answer:** Use `registerSingletonAsync` and wait for completion.

```dart
void setupDependencies() async {
  // Async singleton
  getIt.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );
  
  // Wait for all async registrations
  await getIt.allReady();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();  // Wait for async!
  runApp(MyApp());
}
```

---

### Q6: Should I put DI in domain layer?

**Answer:** **NO!** Domain layer should be **pure Dart**, no frameworks.

```dart
// ❌ BAD - Domain layer knows about DI
class LoginUseCase {
  Future<Result> call() {
    final repo = getIt<AuthRepository>();  // Framework dependency!
    return repo.login();
  }
}

// ✅ GOOD - Domain layer is pure
class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);  // Pure constructor injection
  
  Future<Result> call() => _repository.login();
}
```

**Rule:** DI **setup** happens in presentation/infrastructure layers. Domain **receives** dependencies through constructors.

---

## 📖 Further Reading

* [get_it Documentation](https://pub.dev/packages/get_it)
* [Riverpod DI Guide](https://riverpod.dev/docs/concepts/providers)
* [Dependency Injection Principles (Martin Fowler)](https://martinfowler.com/articles/injection.html)
* [SOLID Principles - Dependency Inversion](https://en.wikipedia.org/wiki/Dependency_inversion_principle)

---

## 🧠 Key Takeaways

1. **DI solves tight coupling** - Makes code testable and flexible
2. **Constructor injection is best** - Clear, explicit, immutable
3. **get_it is simpler** - Service locator pattern, easy to learn
4. **Riverpod is safer** - Compile-time safety, explicit dependencies
5. **Register at startup** - Setup DI before running app
6. **Test with mocks** - DI makes testing trivial
7. **Document your choice** - ADR explains why you chose a pattern

**The Golden Rule:**
> **Don't create your dependencies, receive them from outside.**

---

Remember: DI is not about the tool (get_it vs Riverpod), it's about the **principle** - separating object creation from object usage. Master the principle, and you can apply it anywhere!
