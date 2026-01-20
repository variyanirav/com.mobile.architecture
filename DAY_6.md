# **Day 6: Feature-First Architecture & Navigation**

---

## 🎯 Goal

Build a complete end-to-end feature with proper navigation architecture. By the end of Day 6, you'll:

* **Understand feature-first architecture** (vertical slices)
* **Implement declarative navigation** with go_router or Navigator 2.0
* **Set up deep linking** for authenticated routes
* **Build a complete login flow** with DI and state management
* **Create route guards** for protected pages
* **Write unit tests** for business logic
* **Document navigation patterns** for your team

**Time allocation (60 minutes):**
- 25m: Set up declarative navigation architecture (go_router)
- 25m: Implement end-to-end login feature with navigation
- 10m: Configure deep linking and route guards

---

## 🧠 Step 1: Understanding Feature-First Architecture

### 📘 What is Feature-First Architecture?

Feature-first (vertical slice) architecture organizes code by **features** rather than technical layers.

**Traditional Layer-First (Horizontal):**
```
lib/
  ├── models/          # All models together
  │   ├── user.dart
  │   ├── task.dart
  │   └── project.dart
  ├── repositories/    # All repos together
  │   ├── user_repo.dart
  │   ├── task_repo.dart
  │   └── project_repo.dart
  ├── blocs/           # All blocs together
  └── pages/           # All pages together
```

**❌ Problems:**
- Hard to find related code (scattered across folders)
- Difficult to work on one feature (touch many folders)
- Merge conflicts when multiple people work on different features
- Can't easily extract/reuse features

**Feature-First (Vertical Slice):**
```
lib/features/
  ├── auth/
  │   ├── domain/
  │   ├── data/
  │   └── presentation/
  ├── tasks/
  │   ├── domain/
  │   ├── data/
  │   └── presentation/
  └── projects/
      ├── domain/
      ├── data/
      └── presentation/
```

**✅ Benefits:**
- All related code in one place
- Easy to work on independently
- Clear feature boundaries
- Can extract as package later
- Minimal merge conflicts

---

## 🧭 Step 2: Understanding Navigation Architecture

### 📘 Navigation Evolution in Flutter

#### **1. Navigator 1.0 (Imperative)**
```dart
// Push page
Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));

// Pop page
Navigator.pop(context);
```

**❌ Problems:**
- Imperative (hard to test)
- No type safety
- Can't deep link easily
- Browser back button doesn't work (web)
- Hard to persist navigation state

#### **2. Navigator 2.0 (Declarative)**
```dart
// Define routes declaratively
MaterialApp.router(
  routerConfig: router,
);
```

**✅ Benefits:**
- Declarative (easier to reason about)
- Deep linking support
- Browser integration
- State-driven navigation
- Better testability

#### **3. go_router (Navigator 2.0 wrapper)**
```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomePage()),
    GoRoute(path: '/login', builder: (_, __) => LoginPage()),
  ],
);
```

**✅ Benefits of go_router:**
- Simpler API than raw Navigator 2.0
- Type-safe route parameters
- Nested navigation
- Redirects and guards
- Deep linking out of the box

---

## 💻 Step 3: Setting Up Navigation Architecture

### Task 1: Add go_router Dependency

**pubspec.yaml:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0  # Check latest version
  flutter_riverpod: ^2.5.1  # If using Riverpod
```

**Run:**
```bash
flutter pub get
```

---

### Task 2: Define Route Paths

Create a routes file for type-safe navigation:

**lib/core/routes/app_routes.dart:**
```dart
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // App routes (require auth)
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Deep link routes
  static String resetPassword(String token) => '/reset-password/$token';
  static String productDetail(String id) => '/product/$id';
}
```

**Benefits:**
- ✅ No magic strings
- ✅ Autocomplete in IDE
- ✅ Refactor-safe
- ✅ Easy to find all routes

---

### Task 3: Create Router Configuration

**lib/core/routes/app_router.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'app_routes.dart';

// Provider for auth state (used for redirects)
final authStateProvider = StateProvider<bool>((ref) => false);

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    
    // Redirect logic (route guards)
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      
      // Not authenticated and not going to login? Redirect to login
      if (!isAuthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }
      
      // Authenticated and going to login? Redirect to home
      if (isAuthenticated && isLoggingIn) {
        return AppRoutes.home;
      }
      
      return null; // No redirect needed
    },
    
    routes: [
      // Splash / Landing
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      
      // Auth routes (public)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Deep link: Reset password with token
      GoRoute(
        path: '/reset-password/:token',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return ResetPasswordPage(token: token);
        },
      ),
      
      // App routes (require auth)
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
        routes: [
          // Nested routes under home
          GoRoute(
            path: 'profile',  // Full path: /home/profile
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    
    // Error page (404)
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});
```

**Key Concepts:**
- **redirect**: Global navigation guard (route protection)
- **pathParameters**: Extract URL parameters (`/user/:id`)
- **queryParameters**: Extract query params (`/search?q=flutter`)
- **routes**: Nested routes (parent/child structure)
- **errorBuilder**: Custom 404 page

---

### Task 4: Integrate Router in Main App

**lib/main.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Flutter Architecture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,  // Use go_router
    );
  }
}
```

---

## 🔒 Step 4: Deep Linking Configuration

### iOS Deep Linking

**ios/Runner/Info.plist:**
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>com.example.app</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

**Handles:** `myapp://reset-password/abc123`

---

### Android Deep Linking

**android/app/src/main/AndroidManifest.xml:**
```xml
<activity android:name=".MainActivity">
  <!-- Existing intent filters -->
  
  <!-- Deep linking -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <!-- Custom scheme -->
    <data android:scheme="myapp" />
    
    <!-- HTTPS domain (for App Links) -->
    <data
      android:scheme="https"
      android:host="example.com"
      android:pathPrefix="/app" />
  </intent-filter>
</activity>
```

**Handles:**
- `myapp://reset-password/abc123`
- `https://example.com/app/reset-password/abc123`

---

### Web Deep Linking

Works automatically with go_router! URL bar navigation just works.

**Test:**
```
http://localhost:8080/#/reset-password/abc123
```

---

## 🏗 Step 5: Building Complete Login Feature

### Feature Structure

```
packages/feature_auth/
  lib/
    ├── domain/
    │   ├── entities/
    │   │   └── user_entity.dart
    │   ├── repositories/
    │   │   └── auth_repository.dart
    │   └── usecases/
    │       └── login_usecase.dart
    ├── data/
    │   ├── models/
    │   │   └── user_model.dart
    │   └── repositories/
    │       └── auth_repository_impl.dart
    └── presentation/
        ├── blocs/
        │   ├── auth_bloc.dart
        │   ├── auth_event.dart
        │   └── auth_state.dart
        └── pages/
            └── login_page.dart
```

---

### Implementation: Domain Layer

**domain/entities/user_entity.dart:**
```dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });
  
  @override
  List<Object?> get props => [id, email, name, avatarUrl];
}
```

**domain/repositories/auth_repository.dart:**
```dart
import 'package:core/core.dart';  // Result type from core package
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> login(String email, String password);
  Future<Result<void>> logout();
  Future<Result<UserEntity>> getCurrentUser();
}
```

**domain/usecases/login_usecase.dart:**
```dart
import 'package:core/core.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  
  LoginUseCase(this._repository);
  
  Future<Result<UserEntity>> call(String email, String password) async {
    // Input validation
    if (email.isEmpty) {
      return Result.failure(Failure.validation('Email is required'));
    }
    if (password.isEmpty) {
      return Result.failure(Failure.validation('Password is required'));
    }
    if (!_isValidEmail(email)) {
      return Result.failure(Failure.validation('Invalid email format'));
    }
    
    // Delegate to repository
    return _repository.login(email, password);
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
```

---

### Implementation: Data Layer

**data/models/user_model.dart:**
```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarUrl,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  // Convert to domain entity
  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    name: name,
    avatarUrl: avatarUrl,
  );
}
```

**data/repositories/auth_repository_impl.dart:**
```dart
import 'package:core/core.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Result<UserEntity>> login(String email, String password) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock success
      if (email == 'test@example.com' && password == 'password123') {
        final user = UserModel(
          id: '123',
          email: email,
          name: 'Test User',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
        );
        return Result.success(user.toEntity());
      }
      
      // Mock failure
      return Result.failure(Failure.authentication('Invalid credentials'));
    } catch (e) {
      return Result.failure(Failure.unexpected('Login failed: $e'));
    }
  }
  
  @override
  Future<Result<void>> logout() async {
    // Implement logout logic
    return Result.success(null);
  }
  
  @override
  Future<Result<UserEntity>> getCurrentUser() async {
    // Implement get current user logic
    return Result.failure(Failure.authentication('Not logged in'));
  }
}
```

---

### Implementation: Presentation Layer (BLoC)

**presentation/blocs/auth_event.dart:**
```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  AuthLoginRequested(this.email, this.password);
  
  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
```

**presentation/blocs/auth_state.dart:**
```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  
  AuthAuthenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

**presentation/blocs/auth_bloc.dart:**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  
  AuthBloc(this._loginUseCase) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }
  
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _loginUseCase(event.email, event.password);
    
    result.when(
      success: (user) => emit(AuthAuthenticated(user)),
      failure: (error) => emit(AuthError(error.message)),
    );
  }
  
  void _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthUnauthenticated());
  }
  
  void _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) {
    // Check if user is logged in (from secure storage)
    emit(AuthUnauthenticated());
  }
}
```

---

### Implementation: Login Page UI

**presentation/pages/login_page.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to home on success
            context.go('/home');
          } else if (state is AuthError) {
            // Show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('Don\'t have an account? Register'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          _emailController.text,
          _passwordController.text,
        ),
      );
    }
  }
}
```

---

## 🧪 Step 6: Testing

### Unit Test: LoginUseCase

**test/domain/usecases/login_usecase_test.dart:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:feature_auth/domain/usecases/login_usecase.dart';
import 'package:feature_auth/domain/repositories/auth_repository.dart';
import 'package:feature_auth/domain/entities/user_entity.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    test('should return validation failure when email is empty', () async {
      // Act
      final result = await useCase('', 'password123');

      // Assert
      expect(result.isFailure, true);
      result.when(
        success: (_) => fail('Should not succeed'),
        failure: (error) {
          expect(error.message, contains('Email is required'));
        },
      );
      
      verifyNever(() => mockRepository.login(any(), any()));
    });

    test('should return validation failure when email is invalid', () async {
      // Act
      final result = await useCase('invalid-email', 'password123');

      // Assert
      expect(result.isFailure, true);
      verifyNever(() => mockRepository.login(any(), any()));
    });

    test('should call repository when inputs are valid', () async {
      // Arrange
      const user = UserEntity(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
      );
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Result.success(user));

      // Act
      await useCase('test@example.com', 'password123');

      // Assert
      verify(() => mockRepository.login('test@example.com', 'password123'))
          .called(1);
    });

    test('should return user on successful login', () async {
      // Arrange
      const user = UserEntity(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
      );
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Result.success(user));

      // Act
      final result = await useCase('test@example.com', 'password123');

      // Assert
      expect(result.isSuccess, true);
      result.when(
        success: (returnedUser) {
          expect(returnedUser, equals(user));
        },
        failure: (_) => fail('Should not fail'),
      );
    });
  });
}
```

### BLoC Test

**test/presentation/blocs/auth_bloc_test.dart:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:feature_auth/domain/usecases/login_usecase.dart';
import 'package:feature_auth/domain/entities/user_entity.dart';
import 'package:feature_auth/presentation/blocs/auth_bloc.dart';
import 'package:feature_auth/presentation/blocs/auth_event.dart';
import 'package:feature_auth/presentation/blocs/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    bloc = AuthBloc(mockLoginUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(bloc.state, AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        const user = UserEntity(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
        );
        when(() => mockLoginUseCase(any(), any()))
            .thenAnswer((_) async => Result.success(user));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested('test@example.com', 'password123')),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(const UserEntity(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
        )),
      ],
      verify: (_) {
        verify(() => mockLoginUseCase('test@example.com', 'password123'))
            .called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on login failure',
      build: () {
        when(() => mockLoginUseCase(any(), any()))
            .thenAnswer((_) async => Result.failure(
                  Failure.authentication('Invalid credentials'),
                ));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested('test@example.com', 'wrong')),
      expect: () => [
        AuthLoading(),
        AuthError('Invalid credentials'),
      ],
    );
  });
}
```

---

## 📊 Step 7: Navigation Architecture Document

Create `docs/NAVIGATION_ARCHITECTURE.md`:

```markdown
# Navigation Architecture

## Strategy: Declarative Navigation with go_router

### Why go_router?
- Declarative routing (state-driven)
- Type-safe route parameters
- Deep linking support
- Route guards for authentication
- Works seamlessly on web

### Route Structure

#### Public Routes (No Auth Required)
- `/` - Splash screen
- `/login` - Login page
- `/register` - Registration
- `/forgot-password` - Password reset request
- `/reset-password/:token` - Password reset with token

#### Protected Routes (Auth Required)
- `/home` - Home page
- `/home/profile` - User profile (nested)
- `/settings` - App settings

### Deep Linking Configuration

**iOS:** Custom scheme `myapp://`  
**Android:** Custom scheme + App Links  
**Web:** URL-based routing (automatic)

### Route Guards

Global redirect logic in router:
1. If not authenticated → redirect to `/login`
2. If authenticated and trying to access `/login` → redirect to `/home`

### Navigation Patterns

**Navigate to route:**
```dart
context.go('/home');
```

**Navigate with pushing (can go back):**
```dart
context.push('/profile');
```

**Navigate with parameters:**
```dart
context.go('/user/${userId}');
```

**Navigate back:**
```dart
context.pop();
```

### Testing Navigation

Mock GoRouter in tests:
```dart
final mockRouter = MockGoRouter();
when(() => mockRouter.go(any())).thenReturn(null);
```

## Future Enhancements

- [ ] Bottom tab navigation with nested routes
- [ ] Transition animations
- [ ] Route analytics tracking
- [ ] Offline route handling
```

---

## ✅ Definition of Done (Day 6)

By the end of Day 6, you should have:

- [x] go_router integrated with type-safe routes
- [x] Complete login feature (domain + data + presentation)
- [x] Route guards protecting authenticated pages
- [x] Deep linking configured (iOS + Android + Web)
- [x] Unit tests for LoginUseCase
- [x] BLoC tests for AuthBloc
- [x] Navigation architecture documented

**Test Credentials:**
- Email: `test@example.com`
- Password: `password123`

---

## 📝 Deliverables

1. ✅ Working login flow with navigation
2. ✅ Navigation configuration with route guards
3. ✅ Deep link configuration files
4. ✅ Unit tests (LoginUseCase)
5. ✅ BLoC tests (AuthBloc)
6. ✅ `docs/NAVIGATION_ARCHITECTURE.md`
7. ✅ Updated architecture diagram showing navigation layer

---

## 📚 Resources

- [go_router Documentation](https://pub.dev/packages/go_router)
- [Flutter Deep Linking Guide](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [Navigator 2.0 Explanation](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)

---

## 💡 Pro Tips

1. **Always use named routes** - easier to refactor
2. **Keep navigation logic in router** - not in widgets
3. **Test navigation separately** - mock router in widget tests
4. **Document deep link formats** - for backend team
5. **Use redirect for auth guards** - cleaner than per-route checks
