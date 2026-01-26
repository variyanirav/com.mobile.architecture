# **Day 7: Data Layer Architecture & Code Generation**

---

## 🎯 Goal

Build a complete data layer with automatic code generation tools. By the end of Day 7, you'll:

* **Understand the data layer architecture** (DTOs, Domain models, Mappers)
* **Set up code generation tools** (freezed, json_serializable, build_runner)
* **Implement Repository pattern** with local + remote data sources
* **Create DTO ↔ Domain model mapping** layer
* **Add Either<Failure, Success>** pattern for error handling
* **Document complete data flow** from API to UI

**Time allocation (60 minutes):**
- 15m: Set up code generation tools and understand concepts
- 20m: Define repository interfaces with data sources
- 15m: Implement Repository pattern with DTO/Domain mapping
- 10m: Add Either pattern and error handling

---

## 🧠 Step 1: Understanding Data Layer Architecture

### 📘 What is the Data Layer?

The **data layer** is responsible for:
- **Fetching data** from APIs (remote data source)
- **Storing data** locally (local data source)
- **Converting API data** into app-friendly formats
- **Handling errors** from network or database
- **Providing clean data** to business logic layer

**Think of it like a restaurant:**
- **Remote Data Source** = Supplier (brings raw ingredients from market)
- **Local Data Source** = Pantry (stores ingredients locally)
- **DTO (Data Transfer Object)** = Raw ingredients in supplier's format
- **Domain Model** = Prepared ingredients ready for cooking
- **Mapper** = Chef who prepares ingredients
- **Repository** = Kitchen manager who coordinates everything

---

### 📘 Why Separate DTOs from Domain Models?

**Example: User from API vs User in App**

**API Response (DTO - Data Transfer Object):**
```json
{
  "user_id": "abc123",
  "email_address": "john@example.com",
  "full_name": "John Doe",
  "profile_pic": "https://example.com/pic.jpg",
  "created_at": "2024-01-15T10:30:00Z",
  "is_active": 1
}
```

**App Needs (Domain Model):**
```dart
class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isActive;
}
```

**Problems if we don't separate:**
1. ❌ API changes `user_id` to `userId` → breaks entire app
2. ❌ API uses `1/0` for boolean → app expects `true/false`
3. ❌ API adds new field `last_login` → app crashes if field is required
4. ❌ Can't work offline → always need exact API format
5. ❌ Hard to test → need real API responses

**Benefits of separation:**
1. ✅ **Isolation**: API changes don't break domain logic
2. ✅ **Flexibility**: Can have multiple DTOs for same domain model
3. ✅ **Testability**: Easy to create domain models for tests
4. ✅ **Type Safety**: Domain models match app needs exactly
5. ✅ **Offline Support**: Store domain models locally, sync later

---

### 📘 Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          PRESENTATION LAYER                      │
│                    (UI, BLoC, ViewModel, etc.)                   │
└───────────────────────────┬─────────────────────────────────────┘
                            │ requests User
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                            │
│                      (Domain Model: User)                        │
└───────────────────────────┬─────────────────────────────────────┘
                            │ calls repository
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                   REPOSITORY (Coordination)                      │
│   decides: get from cache or API? save locally? return domain   │
└──────────────┬────────────────────────────────┬─────────────────┘
               │                                │
               ↓                                ↓
┌──────────────────────────┐     ┌─────────────────────────────┐
│  REMOTE DATA SOURCE      │     │  LOCAL DATA SOURCE          │
│  (API calls)             │     │  (SQLite/Hive)              │
│  returns: UserDTO        │     │  returns: UserDTO           │
└──────────┬───────────────┘     └──────────┬──────────────────┘
           │                                │
           ↓                                ↓
┌──────────────────────────────────────────────────────────────┐
│                      MAPPER                                   │
│        UserDTO.fromJson() → UserDTO → User (domain)          │
│        User (domain) → UserDTO → UserDTO.toJson()            │
└──────────────────────────────────────────────────────────────┘
```

**Step-by-step flow:**
1. UI says: "I need user profile"
2. Repository checks: "Do I have it in cache?"
3. If YES: Get from local data source → map to domain → return
4. If NO: Call remote data source → get DTO → map to domain → save locally → return
5. If ERROR: Return failure with error type

---

## 🛠 Step 2: Setting Up Code Generation Tools

### 📘 What is Code Generation?

**Manual Code (Boring & Error-Prone):**
```dart
class User {
  final String id;
  final String email;
  final String name;
  
  User({required this.id, required this.email, required this.name});
  
  // Manual JSON parsing (100 lines for complex objects!)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
  
  // Manual copyWith (for immutability)
  User copyWith({String? id, String? email, String? name}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
  
  // Manual equality (for testing)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name;
  }
  
  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ name.hashCode;
}
```

**Generated Code (Write Once, Generate Forever):**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
  }) = _User;
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

**That's it! 8 lines vs 50+ lines. Generator creates:**
- ✅ `fromJson` / `toJson` automatically
- ✅ `copyWith` for immutability
- ✅ `==` and `hashCode` for equality
- ✅ `toString()` for debugging
- ✅ Type-safe copying

---

### Task 1: Add Dependencies

**pubspec.yaml:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
```

**Run:**
```bash
flutter pub get
```

**Tool breakdown:**
- **freezed**: Generates immutable classes with copyWith, equality
- **json_serializable**: Generates JSON serialization code
- **build_runner**: Runs code generators
- **freezed_annotation** & **json_annotation**: Annotations (instructions for generators)

---

### Task 2: Create build.yaml

This file tells the generator how to work.

**build.yaml:**
```yaml
targets:
  $default:
    builders:
      freezed:
        generate_for:
          - lib/**/*.dart
          - test/**/*.dart
        options:
          # Generate union types (for Result/Either patterns)
          union_key: 'type'
          # Generate fromJson/toJson
          to_json: true
          from_json: true
      
      json_serializable:
        generate_for:
          - lib/**/*.dart
          - test/**/*.dart
        options:
          # How to handle null fields
          explicit_to_json: true
          # Create _$FooFromJson methods
          any_map: false
          # Check for unknown keys (strict mode)
          checked: true
          # Throw error if required field is null
          disallow_unrecognized_keys: false
```

---

### Task 3: Run Code Generation

**Command:**
```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file save)
dart run build_runner watch --delete-conflicting-outputs
```

**What happens:**
- Finds all files with `@freezed` or `@JsonSerializable` annotations
- Generates `.freezed.dart` and `.g.dart` files
- Updates when you change models

**Add to .gitignore:**
```
# Generated files
*.g.dart
*.freezed.dart
```

---

## 📦 Step 3: Implementing DTOs and Domain Models

### Example: User Feature Data Layer

**Directory structure:**
```
packages/feature_auth/
  lib/
    ├── domain/
    │   ├── entities/
    │   │   └── user.dart              ← Domain model (what app uses)
    │   └── repositories/
    │       └── auth_repository.dart   ← Interface
    ├── data/
    │   ├── models/
    │   │   └── user_dto.dart          ← DTO (API format)
    │   ├── datasources/
    │   │   ├── auth_remote_datasource.dart
    │   │   └── auth_local_datasource.dart
    │   ├── mappers/
    │   │   └── user_mapper.dart       ← Converts DTO ↔ Domain
    │   └── repositories/
    │       └── auth_repository_impl.dart
```

---

### Implementation: Domain Model

**domain/entities/user.dart:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Domain model - what the app uses internally
/// This represents the "business concept" of a User
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    required DateTime createdAt,
    @Default(true) bool isActive,
  }) = _User;
}
```

**Benefits:**
- ✅ Immutable (can't accidentally change)
- ✅ Easy to copy (`user.copyWith(name: 'New Name')`)
- ✅ Equality works (`user1 == user2`)
- ✅ Perfect for BLoC/Riverpod (value objects)

**Run generator:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Generated file `user.freezed.dart` includes:**
```dart
// copyWith
final updated = user.copyWith(name: 'New Name');

// Equality
if (user1 == user2) { ... }

// toString for debugging
print(user); // User(id: abc123, email: john@example.com, ...)
```

---

### Implementation: DTO (Data Transfer Object)

**data/models/user_dto.dart:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// DTO - matches API response format exactly
/// This is the "transport format" from server
@freezed
class UserDTO with _$UserDTO {
  const factory UserDTO({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'email_address') required String emailAddress,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'profile_pic') String? profilePic,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'is_active') required int isActive,
  }) = _UserDTO;
  
  factory UserDTO.fromJson(Map<String, dynamic> json) => 
      _$UserDTOFromJson(json);
}
```

**Key points:**
- `@JsonKey(name: 'user_id')` → maps API field name to Dart field name
- `String createdAt` → API sends string, we'll parse to DateTime in mapper
- `int isActive` → API sends 0/1, we'll convert to bool in mapper

**Run generator again:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Generated file `user_dto.g.dart` includes:**
```dart
UserDTO _$UserDTOFromJson(Map<String, dynamic> json) {
  return UserDTO(
    userId: json['user_id'] as String,
    emailAddress: json['email_address'] as String,
    fullName: json['full_name'] as String,
    profilePic: json['profile_pic'] as String?,
    createdAt: json['created_at'] as String,
    isActive: json['is_active'] as int,
  );
}

Map<String, dynamic> _$UserDTOToJson(UserDTO instance) => {
  'user_id': instance.userId,
  'email_address': instance.emailAddress,
  'full_name': instance.fullName,
  'profile_pic': instance.profilePic,
  'created_at': instance.createdAt,
  'is_active': instance.isActive,
};
```

---

### Implementation: Mapper

**data/mappers/user_mapper.dart:**
```dart
import '../../domain/entities/user.dart';
import '../models/user_dto.dart';

/// Mapper - converts between DTO and Domain
/// This is where we handle API format differences
class UserMapper {
  /// Convert DTO (from API) → Domain Model (for app)
  static User toDomain(UserDTO dto) {
    return User(
      id: dto.userId,
      email: dto.emailAddress,
      name: dto.fullName,
      avatarUrl: dto.profilePic,
      createdAt: DateTime.parse(dto.createdAt),  // String → DateTime
      isActive: dto.isActive == 1,                // int → bool
    );
  }
  
  /// Convert Domain Model (from app) → DTO (for API)
  static UserDTO toDTO(User user) {
    return UserDTO(
      userId: user.id,
      emailAddress: user.email,
      fullName: user.name,
      profilePic: user.avatarUrl,
      createdAt: user.createdAt.toIso8601String(),  // DateTime → String
      isActive: user.isActive ? 1 : 0,              // bool → int
    );
  }
}
```

**Why mapper is separate:**
- ✅ Single responsibility (only does conversion)
- ✅ Easy to test (pure functions)
- ✅ Reusable (used by both remote and local data sources)
- ✅ Handles complex conversions (dates, nested objects, etc.)

---

## 🔄 Step 4: Implementing Data Sources

### 📘 What are Data Sources?

**Data sources** are the "workers" that actually fetch/store data:

- **Remote Data Source** → talks to API (network)
- **Local Data Source** → talks to database/cache (device storage)

**Repository** coordinates them → "Try cache first, then API" logic

---

### Implementation: Remote Data Source

**data/datasources/auth_remote_datasource.dart:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<UserDTO> login(String email, String password);
  Future<void> logout(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  
  AuthRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'https://api.example.com',
  });
  
  @override
  Future<UserDTO> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UserDTO.fromJson(json['data']);
    } else if (response.statusCode == 401) {
      throw AuthenticationException('Invalid credentials');
    } else {
      throw ServerException('Server error: ${response.statusCode}');
    }
  }
  
  @override
  Future<void> logout(String token) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode != 200) {
      throw ServerException('Logout failed');
    }
  }
}

// Custom exceptions (we'll handle these in repository)
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}
```

---

### Implementation: Local Data Source

**data/datasources/auth_local_datasource.dart:**
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_dto.dart';

abstract class AuthLocalDataSource {
  Future<UserDTO?> getCachedUser();
  Future<void> cacheUser(UserDTO user);
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String cachedUserKey = 'CACHED_USER';
  
  AuthLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<UserDTO?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(cachedUserKey);
    
    if (jsonString != null) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserDTO.fromJson(json);
    }
    
    return null;
  }
  
  @override
  Future<void> cacheUser(UserDTO user) async {
    final jsonString = jsonEncode(user.toJson());
    await sharedPreferences.setString(cachedUserKey, jsonString);
  }
  
  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(cachedUserKey);
  }
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}
```

---

## 🏛 Step 5: Implementing Repository with Either Pattern

### 📘 What is Either<Failure, Success>?

**Problem with traditional error handling:**
```dart
try {
  final user = await api.login(email, password);
  return user;  // Success
} catch (e) {
  return null;  // Error... but what kind of error?
}
```

**Problems:**
- ❌ Lost error information (network? auth? server?)
- ❌ Can't show specific error message to user
- ❌ Hard to test different error scenarios
- ❌ Mixing exceptions with return values

**Solution: Either<Failure, Success>**
```dart
// Returns EITHER Failure OR User (never both, never null)
Future<Either<Failure, User>> login(String email, String password);

// Usage
final result = await repository.login(email, password);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('Success: ${user.name}'),
);
```

**Benefits:**
- ✅ Explicit error handling (can't ignore errors)
- ✅ Type-safe (compiler ensures you handle both cases)
- ✅ Clear error types (NetworkFailure, AuthFailure, etc.)
- ✅ Easy to test

---

### Implementation: Failure Types

**core/lib/errors/failures.dart:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.authentication(String message) = AuthFailure;
  const factory Failure.cache(String message) = CacheFailure;
  const factory Failure.validation(String message) = ValidationFailure;
  const factory Failure.unexpected(String message) = UnexpectedFailure;
}
```

**Usage with pattern matching:**
```dart
failure.when(
  server: (msg) => Text('Server error: $msg'),
  network: (msg) => Text('No internet: $msg'),
  authentication: (msg) => Text('Login failed: $msg'),
  cache: (msg) => Text('Cache error: $msg'),
  validation: (msg) => Text('Invalid input: $msg'),
  unexpected: (msg) => Text('Unknown error: $msg'),
);
```

---

### Implementation: Either Type

**core/lib/utils/either.dart:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'either.freezed.dart';

/// Either<L, R> represents a value that is EITHER Left OR Right
/// Convention: Left = Error/Failure, Right = Success
@freezed
class Either<L, R> with _$Either<L, R> {
  const factory Either.left(L value) = Left<L, R>;
  const factory Either.right(R value) = Right<L, R>;
  
  // Helper constructors
  factory Either.failure(L failure) = Left<L, R>;
  factory Either.success(R success) = Right<L, R>;
}

/// Extensions for convenient usage
extension EitherX<L, R> on Either<L, R> {
  /// Execute function based on Left or Right
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return when(
      left: onLeft,
      right: onRight,
    );
  }
  
  /// Check if Either is Right (success)
  bool get isRight => this is Right<L, R>;
  
  /// Check if Either is Left (failure)
  bool get isLeft => this is Left<L, R>;
  
  /// Get Right value or throw
  R getOrThrow() {
    return fold(
      (left) => throw Exception('Called getOrThrow on Left: $left'),
      (right) => right,
    );
  }
  
  /// Get Right value or return default
  R getOrElse(R defaultValue) {
    return fold(
      (left) => defaultValue,
      (right) => right,
    );
  }
}
```

---

### Implementation: Repository Interface

**domain/repositories/auth_repository.dart:**
```dart
import 'package:core/core.dart';  // Either, Failure
import '../entities/user.dart';

abstract class AuthRepository {
  /// Login with email and password
  /// Returns Either<Failure, User>
  Future<Either<Failure, User>> login(String email, String password);
  
  /// Logout current user
  Future<Either<Failure, void>> logout();
  
  /// Get currently logged in user from cache
  Future<Either<Failure, User>> getCurrentUser();
}
```

---

### Implementation: Repository Implementation

**data/repositories/auth_repository_impl.dart:**
```dart
import 'package:core/core.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      // 1. Call remote API
      final userDTO = await remoteDataSource.login(email, password);
      
      // 2. Convert DTO → Domain
      final user = UserMapper.toDomain(userDTO);
      
      // 3. Cache locally for offline access
      await localDataSource.cacheUser(userDTO);
      
      // 4. Return success
      return Either.success(user);
      
    } on AuthenticationException catch (e) {
      // Wrong credentials
      return Either.failure(Failure.authentication(e.message));
      
    } on ServerException catch (e) {
      // Server error (500, 503, etc.)
      return Either.failure(Failure.server(e.message));
      
    } catch (e) {
      // Network error, timeout, etc.
      return Either.failure(Failure.network('Check your internet connection'));
    }
  }
  
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try to get from cache
      final userDTO = await localDataSource.getCachedUser();
      
      if (userDTO != null) {
        final user = UserMapper.toDomain(userDTO);
        return Either.success(user);
      } else {
        return Either.failure(Failure.cache('No cached user found'));
      }
      
    } on CacheException catch (e) {
      return Either.failure(Failure.cache(e.message));
      
    } catch (e) {
      return Either.failure(Failure.unexpected('Unexpected error: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear cache
      await localDataSource.clearCache();
      
      // Optionally notify server
      // await remoteDataSource.logout(token);
      
      return Either.success(null);
      
    } catch (e) {
      return Either.failure(Failure.unexpected('Logout failed: $e'));
    }
  }
}
```

**Key logic:**
1. **Try remote first** → get fresh data
2. **Cache locally** → for offline access
3. **Map DTO to Domain** → clean separation
4. **Return Either** → type-safe error handling
5. **Handle each exception type** → specific error messages

---

## 🧪 Step 6: Testing the Data Layer

### Test: Mapper

**test/data/mappers/user_mapper_test.dart:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:feature_auth/data/mappers/user_mapper.dart';
import 'package:feature_auth/data/models/user_dto.dart';
import 'package:feature_auth/domain/entities/user.dart';

void main() {
  group('UserMapper', () {
    test('should convert UserDTO to User domain model', () {
      // Arrange
      final dto = UserDTO(
        userId: '123',
        emailAddress: 'test@example.com',
        fullName: 'Test User',
        profilePic: 'https://example.com/pic.jpg',
        createdAt: '2024-01-15T10:30:00Z',
        isActive: 1,
      );
      
      // Act
      final user = UserMapper.toDomain(dto);
      
      // Assert
      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.avatarUrl, 'https://example.com/pic.jpg');
      expect(user.createdAt, DateTime.parse('2024-01-15T10:30:00Z'));
      expect(user.isActive, true);  // 1 → true
    });
    
    test('should convert User to UserDTO', () {
      // Arrange
      final user = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        avatarUrl: 'https://example.com/pic.jpg',
        createdAt: DateTime.parse('2024-01-15T10:30:00Z'),
        isActive: false,
      );
      
      // Act
      final dto = UserMapper.toDTO(user);
      
      // Assert
      expect(dto.userId, '123');
      expect(dto.emailAddress, 'test@example.com');
      expect(dto.fullName, 'Test User');
      expect(dto.isActive, 0);  // false → 0
    });
  });
}
```

---

### Test: Remote Data Source

**test/data/datasources/auth_remote_datasource_test.dart:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:feature_auth/data/datasources/auth_remote_datasource.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late AuthRemoteDataSource dataSource;
  late MockHttpClient mockClient;
  
  setUp(() {
    mockClient = MockHttpClient();
    dataSource = AuthRemoteDataSourceImpl(client: mockClient);
  });
  
  group('login', () {
    test('should return UserDTO on successful login', () async {
      // Arrange
      when(() => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => http.Response(
        '{"data": {"user_id": "123", "email_address": "test@example.com", "full_name": "Test", "created_at": "2024-01-15T10:30:00Z", "is_active": 1}}',
        200,
      ));
      
      // Act
      final result = await dataSource.login('test@example.com', 'password');
      
      // Assert
      expect(result.userId, '123');
      expect(result.emailAddress, 'test@example.com');
    });
    
    test('should throw AuthenticationException on 401', () async {
      // Arrange
      when(() => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => http.Response('Unauthorized', 401));
      
      // Act & Assert
      expect(
        () => dataSource.login('test@example.com', 'wrong'),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });
}
```

---

### Test: Repository

**test/data/repositories/auth_repository_impl_test.dart:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:feature_auth/data/repositories/auth_repository_impl.dart';
import 'package:feature_auth/data/datasources/auth_remote_datasource.dart';
import 'package:feature_auth/data/datasources/auth_local_datasource.dart';
import 'package:feature_auth/data/models/user_dto.dart';

class MockRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;
  
  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });
  
  group('login', () {
    final userDTO = UserDTO(
      userId: '123',
      emailAddress: 'test@example.com',
      fullName: 'Test User',
      createdAt: '2024-01-15T10:30:00Z',
      isActive: 1,
    );
    
    test('should return User on successful login', () async {
      // Arrange
      when(() => mockRemote.login(any(), any()))
          .thenAnswer((_) async => userDTO);
      when(() => mockLocal.cacheUser(any()))
          .thenAnswer((_) async => {});
      
      // Act
      final result = await repository.login('test@example.com', 'password');
      
      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Should be success'),
        (user) {
          expect(user.id, '123');
          expect(user.email, 'test@example.com');
          expect(user.isActive, true);
        },
      );
      
      // Verify cache was called
      verify(() => mockLocal.cacheUser(userDTO)).called(1);
    });
    
    test('should return AuthFailure on authentication error', () async {
      // Arrange
      when(() => mockRemote.login(any(), any()))
          .thenThrow(AuthenticationException('Invalid credentials'));
      
      // Act
      final result = await repository.login('test@example.com', 'wrong');
      
      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (user) => fail('Should be failure'),
      );
    });
  });
}
```

---

## 📖 Step 7: Documenting Data Flow

### Create Documentation

**docs/DATA_LAYER_ARCHITECTURE.md:**
```markdown
# Data Layer Architecture

## Overview

The data layer is responsible for managing data from multiple sources (API, database, cache) and providing clean, type-safe data to the domain layer.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│                  (UI, BLoC, ViewModel)                       │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│                    (Entities, Use Cases)                     │
│                    Uses: Domain Models                       │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                    REPOSITORY                                │
│  • Coordinates data sources                                  │
│  • Implements caching strategy                               │
│  • Handles error mapping                                     │
│  • Returns Either<Failure, Success>                          │
└──────────┬──────────────────────────────┬───────────────────┘
           │                              │
           ↓                              ↓
┌─────────────────────┐         ┌─────────────────────────┐
│ REMOTE DATA SOURCE  │         │ LOCAL DATA SOURCE       │
│ • API calls         │         │ • SQLite/Hive           │
│ • Network requests  │         │ • SharedPreferences     │
│ • Returns DTOs      │         │ • Returns DTOs          │
└─────────┬───────────┘         └──────────┬──────────────┘
          │                                │
          └────────────┬───────────────────┘
                       ↓
              ┌─────────────────┐
              │     MAPPER      │
              │ DTO ↔ Domain   │
              └─────────────────┘
```

## Data Flow: Login Example

### Step-by-step flow:

1. **User taps login button** → LoginPage
2. **BLoC receives event** → AuthBloc.add(LoginRequested)
3. **Use case validates** → LoginUseCase checks email format
4. **Use case calls repository** → repository.login(email, password)
5. **Repository calls remote source** → remoteDataSource.login()
6. **Remote source makes API call** → POST /auth/login
7. **API returns JSON** → {"user_id": "123", ...}
8. **JSON → DTO** → UserDTO.fromJson(json)
9. **DTO → Domain** → UserMapper.toDomain(dto)
10. **Save to cache** → localDataSource.cacheUser(dto)
11. **Return to use case** → Either.success(user)
12. **BLoC emits state** → AuthAuthenticated(user)
13. **UI updates** → Navigate to home

## Key Components

### 1. Domain Model (Entity)
- Represents business concept
- Used throughout app
- Never depends on API format
- Immutable (using Freezed)

### 2. DTO (Data Transfer Object)
- Matches API format exactly
- Used only in data layer
- Has JSON serialization
- Immutable (using Freezed)

### 3. Mapper
- Converts DTO ↔ Domain
- Handles type conversions
- Pure functions (easy to test)

### 4. Data Sources
- **Remote**: Network calls (http, dio)
- **Local**: Database/cache (sqflite, hive, shared_preferences)

### 5. Repository
- Implements domain interface
- Coordinates data sources
- Implements caching strategy
- Converts exceptions → Failures

## Error Handling Strategy (Multi-Layer Defense)

### 🎯 The Golden Rule

**Error handling happens in LAYERS:**
1. **Repository Layer** → Catches technical errors (network, parsing, API)
2. **BLoC/ViewModel Layer** → Handles business logic & user context
3. **UI Layer** → Shows appropriate messages & recovery options

**Each layer protects the next layer from chaos!**

---

### 📘 Layer 1: Repository (Technical Error Defense)

**Responsibility:** Catch ALL technical errors from backend/network/cache

**What it handles:**
- Network failures (timeout, no internet)
- API errors (500, 503, 404)
- JSON parsing failures (backend sent garbage)
- Null safety violations (missing required fields)
- Authentication errors (401, 403)

**What it returns:** `Either<Failure, Success>` (NEVER throws exceptions)

#### Example: Payment Repository with Defensive Coding

```dart
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final PaymentLocalDataSource localDataSource;
  
  @override
  Future<Either<Failure, PaymentResult>> processPayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      // 1. Validate before calling API (don't trust backend)
      if (amount <= 0) {
        return Either.failure(
          Failure.validation('Invalid amount: must be greater than 0'),
        );
      }
      
      if (orderId.isEmpty) {
        return Either.failure(
          Failure.validation('Order ID is required'),
        );
      }
      
      // 2. Call remote API
      final paymentDTO = await remoteDataSource.processPayment(
        orderId: orderId,
        amount: amount,
        paymentMethod: paymentMethod,
      );
      
      // 3. DEFENSIVE: Check if backend returned nonsense
      if (paymentDTO.transactionId == null || paymentDTO.transactionId!.isEmpty) {
        // Backend didn't give us transaction ID - that's bad!
        return Either.failure(
          Failure.server('Payment processed but no transaction ID received'),
        );
      }
      
      // 4. Parse status safely (backend might send unexpected values)
      final status = _parsePaymentStatus(paymentDTO.status);
      if (status == PaymentStatus.unknown) {
        // Backend sent status we don't recognize
        return Either.failure(
          Failure.server('Unknown payment status: ${paymentDTO.status}'),
        );
      }
      
      // 5. Convert to domain model
      final result = PaymentMapper.toDomain(paymentDTO);
      
      // 6. Cache for offline access / retry
      await localDataSource.cachePayment(paymentDTO);
      
      // 7. Success!
      return Either.success(result);
      
    } on PaymentDeclinedException catch (e) {
      // Card declined - user needs to know
      return Either.failure(Failure.payment(e.message));
      
    } on InsufficientFundsException catch (e) {
      // Not enough money
      return Either.failure(Failure.payment('Insufficient funds'));
      
    } on NetworkException catch (e) {
      // No internet - maybe retry?
      return Either.failure(Failure.network('Check your internet connection'));
      
    } on TimeoutException catch (e) {
      // Request took too long
      return Either.failure(Failure.network('Request timeout - try again'));
      
    } on JsonParsingException catch (e) {
      // Backend sent malformed JSON
      return Either.failure(
        Failure.server('Server response invalid: ${e.message}'),
      );
      
    } on ServerException catch (e) {
      // 500, 503, etc.
      return Either.failure(Failure.server(e.message));
      
    } catch (e, stackTrace) {
      // Something totally unexpected happened
      // Log to crash reporting (Sentry, Firebase Crashlytics)
      logger.error('Unexpected payment error', error: e, stackTrace: stackTrace);
      
      return Either.failure(
        Failure.unexpected('Payment failed unexpectedly. Please contact support.'),
      );
    }
  }
  
  /// DEFENSIVE: Parse payment status safely
  PaymentStatus _parsePaymentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'approved':
        return PaymentStatus.success;
        
      case 'pending':
      case 'processing':
        return PaymentStatus.pending;
        
      case 'failed':
      case 'declined':
      case 'rejected':
        return PaymentStatus.failed;
        
      case 'refunded':
        return PaymentStatus.refunded;
        
      default:
        // Backend sent something unexpected
        return PaymentStatus.unknown;
    }
  }
}
```

**Key Points:**
- ✅ **Validate inputs** before API call
- ✅ **Check backend response** for nonsense
- ✅ **Parse enums safely** (backend might change values)
- ✅ **Catch specific exceptions** first, then general
- ✅ **Never throw** - always return Either
- ✅ **Log unexpected errors** for debugging

---

### 📘 Layer 2: BLoC/ViewModel (Business Logic & User Context)

**Responsibility:** Decide what to do based on failure type + current state

**What it handles:**
- Business rules (can user retry? should we show offline mode?)
- User context (is this their first attempt? 3rd retry?)
- State transitions (loading → error → retry → success)
- Side effects (show snackbar, navigate, log analytics)

**What it returns:** UI States that UI can render

#### Example: Payment BLoC with Smart Error Handling

```dart
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;
  final AnalyticsService analytics;
  
  int _retryCount = 0;
  static const int maxRetries = 3;
  
  PaymentBloc({
    required this.paymentRepository,
    required this.analytics,
  }) : super(PaymentInitial()) {
    on<PaymentRequested>(_onPaymentRequested);
    on<PaymentRetryRequested>(_onPaymentRetryRequested);
  }
  
  Future<void> _onPaymentRequested(
    PaymentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    // Reset retry count for new payment
    _retryCount = 0;
    
    emit(PaymentProcessing());
    
    final result = await paymentRepository.processPayment(
      orderId: event.orderId,
      amount: event.amount,
      paymentMethod: event.paymentMethod,
    );
    
    // Handle result based on failure type
    result.fold(
      (failure) => _handlePaymentFailure(failure, emit, event),
      (paymentResult) {
        // Success!
        analytics.logEvent('payment_success', {
          'order_id': event.orderId,
          'amount': event.amount,
        });
        
        emit(PaymentSuccess(paymentResult));
      },
    );
  }
  
  /// SMART ERROR HANDLING - Different actions for different failures
  void _handlePaymentFailure(
    Failure failure,
    Emitter<PaymentState> emit,
    PaymentRequested event,
  ) {
    failure.when(
      // Network failure - can retry
      network: (message) {
        analytics.logEvent('payment_network_error', {
          'retry_count': _retryCount,
        });
        
        emit(PaymentError(
          message: message,
          canRetry: true,
          retryCount: _retryCount,
          shouldShowOfflineMode: true,
          originalEvent: event, // Save for retry
        ));
      },
      
      // Payment declined - user needs different card
      payment: (message) {
        analytics.logEvent('payment_declined');
        
        emit(PaymentError(
          message: message,
          canRetry: false, // Don't retry - card is declined
          suggestedAction: 'Try a different payment method',
          shouldShowAlternativePayments: true,
        ));
      },
      
      // Server error - maybe retry once
      server: (message) {
        _retryCount++;
        
        analytics.logEvent('payment_server_error', {
          'retry_count': _retryCount,
        });
        
        if (_retryCount < maxRetries) {
          // Auto-retry for server errors
          emit(PaymentRetrying(retryCount: _retryCount));
          add(PaymentRetryRequested(event));
        } else {
          // Max retries reached
          emit(PaymentError(
            message: 'Our payment system is temporarily unavailable',
            canRetry: false,
            suggestedAction: 'Please try again in a few minutes',
            shouldContactSupport: true,
          ));
        }
      },
      
      // Validation error - user input problem
      validation: (message) {
        analytics.logEvent('payment_validation_error');
        
        emit(PaymentError(
          message: message,
          canRetry: false,
          suggestedAction: 'Please check your payment details',
          shouldHighlightInvalidFields: true,
        ));
      },
      
      // Authentication error - session expired
      authentication: (message) {
        analytics.logEvent('payment_auth_error');
        
        emit(PaymentError(
          message: 'Your session has expired',
          canRetry: false,
          shouldNavigateToLogin: true,
        ));
      },
      
      // Unexpected error - something really bad
      unexpected: (message) {
        analytics.logEvent('payment_unexpected_error', {
          'error': message,
        });
        
        emit(PaymentError(
          message: 'Something went wrong. Our team has been notified.',
          canRetry: true,
          shouldContactSupport: true,
          supportReference: DateTime.now().millisecondsSinceEpoch.toString(),
        ));
      },
      
      // Cache error - not critical for payment
      cache: (message) {
        // Log but don't show to user
        analytics.logEvent('payment_cache_error');
        // Continue with payment anyway
      },
    );
  }
  
  Future<void> _onPaymentRetryRequested(
    PaymentRetryRequested event,
    Emitter<PaymentState> emit,
  ) async {
    _retryCount++;
    
    if (_retryCount > maxRetries) {
      emit(PaymentError(
        message: 'Maximum retry attempts reached',
        canRetry: false,
        shouldContactSupport: true,
      ));
      return;
    }
    
    // Wait a bit before retrying (exponential backoff)
    await Future.delayed(Duration(seconds: 2 * _retryCount));
    
    // Retry original payment
    add(event.originalPaymentEvent);
  }
}

/// Enhanced Payment States with Error Context
@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = PaymentInitial;
  const factory PaymentState.processing() = PaymentProcessing;
  const factory PaymentState.retrying({required int retryCount}) = PaymentRetrying;
  
  const factory PaymentState.success(PaymentResult result) = PaymentSuccess;
  
  const factory PaymentState.error({
    required String message,
    @Default(false) bool canRetry,
    @Default(0) int retryCount,
    String? suggestedAction,
    @Default(false) bool shouldShowOfflineMode,
    @Default(false) bool shouldShowAlternativePayments,
    @Default(false) bool shouldContactSupport,
    @Default(false) bool shouldNavigateToLogin,
    @Default(false) bool shouldHighlightInvalidFields,
    String? supportReference,
    PaymentRequested? originalEvent,
  }) = PaymentError;
}
```

**Key Points:**
- ✅ **Different actions for different failures** (retry vs show alternatives)
- ✅ **Track retry count** (don't retry forever)
- ✅ **Provide user guidance** (what to do next)
- ✅ **Log analytics** (understand failure patterns)
- ✅ **Save context** (original event for retry)
- ✅ **Exponential backoff** (don't spam server)

---

### 📘 Layer 3: UI (User-Friendly Messages & Recovery)

**Responsibility:** Show appropriate UI based on error state

**What it handles:**
- User-friendly error messages
- Retry buttons
- Alternative actions
- Contact support options
- Offline mode toggle

#### Example: Payment UI with Smart Error Handling

```dart
class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) {
        // Handle navigation/side effects
        state.maybeWhen(
          error: (
            message,
            canRetry,
            retryCount,
            suggestedAction,
            shouldShowOfflineMode,
            shouldShowAlternativePayments,
            shouldContactSupport,
            shouldNavigateToLogin,
            shouldHighlightInvalidFields,
            supportReference,
            originalEvent,
          ) {
            // Navigate to login if session expired
            if (shouldNavigateToLogin) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.when(
          initial: () => _buildPaymentForm(context),
          
          processing: () => _buildProcessingView(),
          
          retrying: (retryCount) => _buildRetryingView(retryCount),
          
          success: (result) => _buildSuccessView(result),
          
          error: (
            message,
            canRetry,
            retryCount,
            suggestedAction,
            shouldShowOfflineMode,
            shouldShowAlternativePayments,
            shouldContactSupport,
            shouldNavigateToLogin,
            shouldHighlightInvalidFields,
            supportReference,
            originalEvent,
          ) => _buildErrorView(
            context,
            message: message,
            canRetry: canRetry,
            retryCount: retryCount,
            suggestedAction: suggestedAction,
            shouldShowOfflineMode: shouldShowOfflineMode,
            shouldShowAlternativePayments: shouldShowAlternativePayments,
            shouldContactSupport: shouldContactSupport,
            supportReference: supportReference,
            originalEvent: originalEvent,
          ),
        );
      },
    );
  }
  
  Widget _buildErrorView(
    BuildContext context, {
    required String message,
    required bool canRetry,
    required int retryCount,
    String? suggestedAction,
    required bool shouldShowOfflineMode,
    required bool shouldShowAlternativePayments,
    required bool shouldContactSupport,
    String? supportReference,
    PaymentRequested? originalEvent,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon (different based on error type)
            Icon(
              _getErrorIcon(canRetry, shouldContactSupport),
              size: 64,
              color: canRetry ? Colors.orange : Colors.red,
            ),
            
            const SizedBox(height: 24),
            
            // Error message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            
            const SizedBox(height: 16),
            
            // Suggested action (if any)
            if (suggestedAction != null) ...[
              Text(
                suggestedAction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Retry button (if applicable)
            if (canRetry && originalEvent != null) ...[
              ElevatedButton.icon(
                onPressed: () {
                  context.read<PaymentBloc>().add(
                    PaymentRetryRequested(originalEvent),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: Text(
                  retryCount > 0 ? 'Retry ($retryCount/3)' : 'Try Again',
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Alternative payment methods
            if (shouldShowAlternativePayments) ...[
              OutlinedButton.icon(
                onPressed: () {
                  // Show payment method picker
                  _showPaymentMethodPicker(context);
                },
                icon: const Icon(Icons.credit_card),
                label: const Text('Try Different Payment Method'),
              ),
              const SizedBox(height: 16),
            ],
            
            // Offline mode toggle
            if (shouldShowOfflineMode) ...[
              TextButton.icon(
                onPressed: () {
                  // Enable offline mode
                  _enableOfflineMode(context);
                },
                icon: const Icon(Icons.cloud_off),
                label: const Text('Continue in Offline Mode'),
              ),
              const SizedBox(height: 16),
            ],
            
            // Contact support
            if (shouldContactSupport) ...[
              TextButton.icon(
                onPressed: () {
                  _contactSupport(context, supportReference);
                },
                icon: const Icon(Icons.support_agent),
                label: const Text('Contact Support'),
              ),
              if (supportReference != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Reference: $supportReference',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
            
            // Cancel button (always available)
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getErrorIcon(bool canRetry, bool shouldContactSupport) {
    if (shouldContactSupport) return Icons.error;
    if (canRetry) return Icons.warning;
    return Icons.info;
  }
  
  void _showPaymentMethodPicker(BuildContext context) {
    // Show bottom sheet with payment methods
    showModalBottomSheet(
      context: context,
      builder: (context) => PaymentMethodPicker(),
    );
  }
  
  void _enableOfflineMode(BuildContext context) {
    // Enable offline mode (save for later sync)
    context.read<PaymentBloc>().add(EnableOfflineMode());
  }
  
  void _contactSupport(BuildContext context, String? reference) {
    // Open support chat or email with pre-filled reference
    Navigator.pushNamed(
      context,
      '/support',
      arguments: {'reference': reference},
    );
  }
}
```

---

### 🛡️ Defensive DTO Parsing (Protecting from Backend Chaos)

#### Problem: Backend sends unexpected data

```json
{
  "user_id": null,           ← Should never be null!
  "email": 123,              ← Should be string!
  "status": "SUPER_ACTIVE",  ← We don't know this status!
  "created_at": "yesterday"  ← Not a valid date!
}
```

#### Solution: Defensive DTO with Fallbacks

```dart
@freezed
class UserDTO with _$UserDTO {
  const UserDTO._();  // Private constructor for custom methods
  
  const factory UserDTO({
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _UserDTO;
  
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    try {
      return _$UserDTOFromJson(json);
    } catch (e) {
      // JSON parsing failed - log and return safe defaults
      logger.error('Failed to parse UserDTO', error: e, json: json);
      
      // Return DTO with safe fallbacks
      return UserDTO(
        userId: json['user_id']?.toString(),
        email: json['email']?.toString(),
        status: json['status']?.toString() ?? 'unknown',
        createdAt: json['created_at']?.toString(),
      );
    }
  }
}

/// Mapper with VALIDATION
class UserMapper {
  static Either<Failure, User> toDomain(UserDTO dto) {
    // VALIDATE: Required fields must exist
    if (dto.userId == null || dto.userId!.isEmpty) {
      return Either.failure(
        Failure.server('Invalid user data: missing user ID'),
      );
    }
    
    if (dto.email == null || !_isValidEmail(dto.email!)) {
      return Either.failure(
        Failure.server('Invalid user data: invalid email'),
      );
    }
    
    // PARSE: Date with fallback
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(dto.createdAt ?? '');
    } catch (e) {
      // Backend sent invalid date - use current time
      logger.warn('Invalid date format: ${dto.createdAt}');
      createdAt = DateTime.now();
    }
    
    // PARSE: Status with fallback
    final isActive = _parseStatus(dto.status);
    
    // SUCCESS: Create domain model
    return Either.success(User(
      id: dto.userId!,
      email: dto.email!,
      createdAt: createdAt,
      isActive: isActive,
    ));
  }
  
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
      case 'enabled':
      case 'super_active':  // Handle unexpected but valid values
        return true;
      case 'inactive':
      case 'disabled':
      case 'banned':
        return false;
      default:
        // Unknown status - log and default to inactive (safe choice)
        logger.warn('Unknown user status: $status, defaulting to inactive');
        return false;
    }
  }
}
```

---

### 🎯 Complete Error Handling Flow (Real Payment Example)

```
USER TAPS "PAY NOW"
        ↓
┌─────────────────────────────────────────────────┐
│ UI Layer: PaymentPage                           │
│ • Shows loading spinner                         │
│ • Disables pay button                           │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│ BLoC Layer: PaymentBloc                         │
│ • Emits PaymentProcessing state                 │
│ • Calls repository.processPayment()             │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│ Repository Layer: PaymentRepositoryImpl         │
│ • Validates input (amount > 0)                  │
│ • Calls remoteDataSource.processPayment()       │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│ Remote Data Source: PaymentRemoteDataSourceImpl│
│ • Makes HTTP POST to /api/payment               │
│ • Receives response                             │
└─────────────────┬───────────────────────────────┘
                  ↓
        ⚠️ ERROR SCENARIOS ⚠️
                  
┌─────────────────────────────────────────────────┐
│ SCENARIO 1: Network Timeout                     │
├─────────────────────────────────────────────────┤
│ Remote DS: Throws TimeoutException              │
│        ↓                                         │
│ Repository: Catches → Failure.network()         │
│        ↓                                         │
│ BLoC: Receives Left(NetworkFailure)             │
│       → Emits PaymentError(canRetry: true)      │
│        ↓                                         │
│ UI: Shows retry button + offline mode option    │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ SCENARIO 2: Card Declined                       │
├─────────────────────────────────────────────────┤
│ API Response: 402 "INSUFFICIENT_FUNDS"          │
│        ↓                                         │
│ Remote DS: Throws PaymentDeclinedException      │
│        ↓                                         │
│ Repository: Catches → Failure.payment()         │
│        ↓                                         │
│ BLoC: Receives Left(PaymentFailure)             │
│       → Emits PaymentError(canRetry: false,     │
│                shouldShowAlternativePayments)   │
│        ↓                                         │
│ UI: Shows "Try different payment method" button │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ SCENARIO 3: Backend Returns Garbage             │
├─────────────────────────────────────────────────┤
│ API Response: {"transaction_id": null}          │
│        ↓                                         │
│ Remote DS: Returns PaymentDTO(txId: null)       │
│        ↓                                         │
│ Repository: Checks txId → null!                 │
│             → Returns Failure.server()          │
│        ↓                                         │
│ BLoC: Receives Left(ServerFailure)              │
│       → Retries once (auto-retry for server)    │
│       → If still fails, show error              │
│        ↓                                         │
│ UI: Shows "System unavailable" + support button │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ SCENARIO 4: Session Expired During Payment      │
├─────────────────────────────────────────────────┤
│ API Response: 401 "TOKEN_EXPIRED"               │
│        ↓                                         │
│ Remote DS: Throws AuthenticationException       │
│        ↓                                         │
│ Repository: Catches → Failure.authentication()  │
│        ↓                                         │
│ BLoC: Receives Left(AuthFailure)                │
│       → Emits PaymentError(shouldNavigateLogin) │
│        ↓                                         │
│ UI: Navigates to login (BlocListener)           │
│     Shows "Session expired, please login again" │
└─────────────────────────────────────────────────┘
```

---

### Exception → Failure Mapping

```dart
try {
  // Data source call
} on AuthenticationException {
  return Failure.authentication();
} on ServerException {
  return Failure.server();
} on SocketException {
  return Failure.network();
} catch (e) {
  return Failure.unexpected();
}
```

### Failure Types

- **NetworkFailure**: No internet, timeout
- **ServerFailure**: 500, 503, etc.
- **AuthFailure**: 401, invalid credentials
- **CacheFailure**: Local storage error
- **ValidationFailure**: Invalid input
- **UnexpectedFailure**: Unknown error
- **PaymentFailure**: Payment-specific errors (NEW)

---

## 🎓 Error Handling Best Practices

### 1. Repository Level
```dart
✅ DO: Return Either<Failure, Success>
✅ DO: Validate backend responses
✅ DO: Log unexpected errors
✅ DO: Provide specific failure types
❌ DON'T: Throw exceptions to upper layers
❌ DON'T: Return null
```

### 2. BLoC Level
```dart
✅ DO: Handle each failure type differently
✅ DO: Provide retry logic
✅ DO: Track retry count
✅ DO: Log analytics
✅ DO: Provide user guidance
❌ DON'T: Show technical error messages
❌ DON'T: Retry forever
```

### 3. UI Level
```dart
✅ DO: Show user-friendly messages
✅ DO: Provide recovery options
✅ DO: Show appropriate icons
✅ DO: Include contact support for critical errors
❌ DON'T: Show stack traces
❌ DON'T: Say "Error" without context
```

---

## 💡 Pro Tips for Error Handling

1. **Always validate DTO → Domain conversion**
   - Backend WILL send garbage eventually
   
2. **Use retry with exponential backoff**
   - Don't spam the server
   
3. **Different errors need different actions**
   - Network → Retry
   - Payment declined → Different card
   - Server error → Contact support
   
4. **Log everything for debugging**
   - You can't fix what you can't see
   
5. **Test error scenarios**
   - Mock every failure type
   
6. **Provide support references**
   - Users can quote when contacting support
   
7. **Never show technical details to users**
   - "Check your internet" not "SocketException: Connection refused"
   
8. **Cache failed requests for retry**
   - Offline-first approach
   
9. **Track error patterns in analytics**
   - Which errors happen most?
   
10. **Have a fallback for everything**
    - App should never crash from bad data

## Caching Strategy

### Read Pattern (Cache-First)
```
1. Try local cache
2. If found → return domain model
3. If not found → call API
4. Save to cache
5. Return domain model
```

### Write Pattern
```
1. Call API
2. If success → update cache
3. Return result
```

### Offline-First Pattern
```
1. Save to local queue
2. Return success immediately
3. Sync in background
4. Retry on failure
```

## Code Generation

### Tools Used
- **freezed**: Immutable classes, copyWith, equality
- **json_serializable**: JSON parsing
- **build_runner**: Runs generators

### Commands
```bash
# Generate once
dart run build_runner build --delete-conflicting-outputs

# Watch mode
dart run build_runner watch --delete-conflicting-outputs
```

## Testing Strategy

### 1. Mapper Tests
- Test DTO → Domain conversion
- Test Domain → DTO conversion
- Test edge cases (null values, dates)

### 2. Data Source Tests
- Mock HTTP client
- Test successful responses
- Test error responses
- Test exception handling

### 3. Repository Tests
- Mock data sources
- Test success path (remote + cache)
- Test failure paths (each exception type)
- Verify caching behavior

## Best Practices

1. ✅ **Always separate DTO from Domain**
2. ✅ **Use code generation** (less boilerplate)
3. ✅ **Return Either<Failure, Success>** from repositories
4. ✅ **Test each layer** independently
5. ✅ **Cache strategically** (balance freshness vs performance)
6. ✅ **Handle all exception types** explicitly
7. ✅ **Use freezed for immutability**
8. ✅ **Document data flow** for team
```

---

## 🎯 Practical Exercise

### Build: User Profile Repository

**Requirements:**
1. Create `UserProfileDTO` with fields from mock API
2. Create `UserProfile` domain model
3. Create mapper between them
4. Implement remote + local data sources
5. Implement repository with Either pattern
6. Write tests for each component

**Mock API Response:**
```json
{
  "user_profile": {
    "id": "usr_123",
    "display_name": "John Doe",
    "email_verified": true,
    "avatar_url": "https://example.com/pic.jpg",
    "member_since": "2024-01-15T10:30:00Z",
    "preferences": {
      "theme": "dark",
      "notifications_enabled": true
    }
  }
}
```

**Tasks:**
1. Generate DTO with nested `PreferencesDTO`
2. Flatten to domain model (no nested objects)
3. Test mapper with complex nesting
4. Implement cache with expiration (5 minutes)

---

## ✅ Definition of Done (Day 7)

By the end of Day 7, you should have:

- [x] Code generation tools set up (freezed, json_serializable)
- [x] `build.yaml` configured
- [x] Domain models created with Freezed
- [x] DTOs created with JSON serialization
- [x] Mappers for DTO ↔ Domain conversion
- [x] Remote data source with API calls
- [x] Local data source with caching
- [x] Repository with Either<Failure, Success>
- [x] Comprehensive error handling (all Failure types)
- [x] Unit tests for mapper, data sources, repository
- [x] Data flow documentation (`DATA_LAYER_ARCHITECTURE.md`)

**Verify:**
```bash
# Run tests
flutter test

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Check coverage
flutter test --coverage
```

---

## 📝 Deliverables

1. ✅ Complete AuthRepository with remote + local data sources
2. ✅ DTOs with JSON serialization (`.g.dart` files)
3. ✅ Domain models with Freezed (`.freezed.dart` files)
4. ✅ Mappers for all models
5. ✅ Either<Failure, Success> pattern implementation
6. ✅ Mock implementation for testing
7. ✅ Unit tests (mapper, data sources, repository)
8. ✅ `docs/DATA_LAYER_ARCHITECTURE.md`
9. ✅ `build.yaml` configuration

---

## 📚 Resources

- [Freezed Documentation](https://pub.dev/packages/freezed)
- [json_serializable Guide](https://pub.dev/packages/json_serializable)
- [build_runner Commands](https://pub.dev/packages/build_runner)
- [Repository Pattern Explained](https://martinfowler.com/eaaCatalog/repository.html)
- [Either Type (Functional Programming)](https://dev.to/gcanti/getting-started-with-fp-ts-either-vs-validation-5eja)
- [Clean Architecture Data Layer](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## 💡 Pro Tips

1. **Run build_runner in watch mode** while developing
   ```bash
   flutter pub run build_runner watch
   ```

2. **Keep DTOs close to API** - they should mirror API exactly

3. **Keep Domain models clean** - they should match app needs exactly

4. **Test mappers thoroughly** - they're critical conversion points

5. **Cache strategically** - not everything needs caching

6. **Use Either everywhere** - makes error handling explicit

7. **Generate code, don't write** - use freezed for all models

8. **Document data flow** - helps team understand architecture

9. **Add .gitignore for generated files**:
   ```
   *.g.dart
   *.freezed.dart
   ```

10. **Version lock dependencies** in pubspec.yaml for consistency
---

## 🎓 Key Takeaways

### What You Learned:

1. **Data layer architecture**: Remote + Local + Repository
2. **DTO vs Domain separation**: API format vs App format
3. **Code generation**: freezed + json_serializable
4. **Either pattern**: Type-safe error handling
5. **Mapper pattern**: Clean data conversion
6. **Caching strategy**: When and what to cache
7. **Comprehensive error handling**: Specific failure types

### Real-World Benefits:

- ✅ **API changes don't break app** (isolated in DTOs)
- ✅ **Easy to test** (mock each layer independently)
- ✅ **Offline support** (local data source)
- ✅ **Type safety** (compiler catches errors)
- ✅ **Less boilerplate** (code generation)
- ✅ **Clear error handling** (Either pattern)
- ✅ **Team scalability** (clear boundaries)

### Interview Talking Points:

1. "I separate DTOs from domain models to isolate API changes"
2. "I use Either<Failure, Success> for type-safe error handling"
3. "I implement Repository pattern with remote and local data sources"
4. "I use code generation to reduce boilerplate and errors"
5. "I test each layer independently with clear boundaries"

---