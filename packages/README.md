# Packages Architecture

This directory contains the modular packages that make up the mobile architecture project.

## 📦 Package Structure

```
packages/
├── core/                 # Shared infrastructure and utilities
└── feature_auth/         # Authentication feature module
```

## 🎯 Architecture Principles

### 1. **Package Independence**
Each package can be built and tested independently:
```bash
cd packages/core
flutter test  # Runs without other packages
```

### 2. **Clear Dependency Direction**
```
mobile (app layer)
  ↓
feature_auth (feature layer)
  ↓
core (infrastructure layer)
  ↓
flutter/dart (framework)
```

**Rules:**
- App depends on features
- Features depend on core
- Core depends only on Flutter/Dart
- **Never** create circular dependencies

### 3. **Public API Pattern**
Each package exports only what others need through its main library file:

```dart
// core.dart - Public API
export 'error/failures.dart';
export 'error/result.dart';
export 'logging/logger.dart';
// Internal implementation details are NOT exported
```

## 📚 Package Catalog

### Core Package
**Purpose:** Shared infrastructure and utilities used across all features

**Contents:**
- Error handling (`Result` type, `Failure` classes)
- Logging abstractions (`Logger` interface, `ConsoleLogger`)
- Common utilities

**Dependencies:** None (only Flutter/Dart SDK)

**Used by:** All feature packages and the mobile app

[→ Full Documentation](./core/README.md)

---

### Feature Auth Package
**Purpose:** Complete authentication functionality

**Contents:**
- Domain: `UserEntity`, `UserRepository`, `LoginUserUseCase`
- Data: `UserModel`, `UserRepositoryImpl`
- Presentation: `LoginBloc`, `LoginPage`

**Dependencies:**
- `core` - for error handling and logging
- `flutter_bloc` - for state management
- `equatable` - for value equality

**Used by:** Mobile app

[→ Full Documentation](./feature_auth/README.md)

---

## 🔧 Working with Packages

### Adding a New Package

1. **Create package structure:**
```bash
mkdir -p packages/feature_tasks/{lib,test}
cd packages/feature_tasks
```

2. **Create `pubspec.yaml`:**
```yaml
name: feature_tasks
description: Task management feature
version: 0.1.0
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  core:
    path: ../core
  flutter_bloc: ^9.1.1
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

3. **Create main library file (`lib/feature_tasks.dart`):**
```dart
/// Feature Tasks package
export 'domain/entities/task_entity.dart';
export 'presentation/bloc/tasks_bloc.dart';
export 'presentation/page/tasks_page.dart';
```

4. **Add to mobile app:**
```yaml
# mobile/pubspec.yaml
dependencies:
  feature_tasks:
    path: ../packages/feature_tasks
```

5. **Run pub get:**
```bash
cd ../..
melos bootstrap  # Or flutter pub get in each package
```

### Package Development Workflow

**1. Develop in isolation:**
```bash
cd packages/feature_auth
flutter test --watch  # Test-driven development
```

**2. Verify integration:**
```bash
cd ../../mobile
flutter test
flutter run
```

**3. Check all packages:**
```bash
cd ../..
melos run analyze  # Analyze all packages
melos run test     # Test all packages
```

## 🧪 Testing Strategy

### Unit Tests
Test domain logic in isolation:
```dart
// packages/core/test/error_handling_test.dart
test('Result fold calls onRight for Right', () {
  const result = Right<Failure, String>('Success');
  final output = result.fold(
    (failure) => 'Failed',
    (success) => 'Got: $success',
  );
  expect(output, 'Got: Success');
});
```

### Widget Tests
Test UI components:
```dart
// packages/feature_auth/test/login_page_test.dart
testWidgets('LoginPage displays email and password fields', (tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage()));
  expect(find.byType(TextField), findsNWidgets(2));
});
```

### Integration Tests
Test complete flows in the mobile app:
```dart
// mobile/integration_test/auth_flow_test.dart
testWidgets('Complete login flow', (tester) async {
  // Test full user journey
});
```

## 📊 Package Dependency Graph

```
┌─────────────┐
│   mobile    │  (App Layer)
└──────┬──────┘
       │
       │ imports
       ↓
┌─────────────┐
│feature_auth │  (Feature Layer)
└──────┬──────┘
       │
       │ imports
       ↓
┌─────────────┐
│    core     │  (Infrastructure Layer)
└─────────────┘
       │
       │ imports
       ↓
┌─────────────┐
│flutter/dart │  (Framework)
└─────────────┘
```

## 🚀 Benefits of This Architecture

### 1. **Scalability**
- Add new features without affecting existing ones
- Multiple teams can work on different packages simultaneously
- Clear ownership boundaries

### 2. **Maintainability**
- Changes isolated to specific packages
- Easy to understand package scope
- Reduced merge conflicts

### 3. **Testability**
- Test packages in isolation
- Mock dependencies easily
- Faster test execution

### 4. **Reusability**
- Share packages across multiple apps
- Publish packages to pub.dev if needed
- Extract packages to separate repositories

### 5. **Build Performance**
- Only rebuild changed packages
- Faster CI/CD pipelines
- Incremental compilation

### 6. **Enforced Boundaries**
- Compiler prevents illegal imports
- Architecture rules are structural
- No accidental coupling

## ⚙️ Melos Commands

```bash
# Bootstrap all packages
melos bootstrap

# Analyze all packages
melos run analyze

# Test all packages
melos run test

# Format all code
melos run format

# Clean all packages
melos run clean

# Test only feature packages
melos run test:features
```

## 📖 Further Reading

- [Package Development Guide](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)
- [Melos Documentation](https://melos.invertase.dev/)
- [Clean Architecture in Flutter](../docs/architecture_diagram.md)
- [C4 Architecture Diagrams](../docs/c4/README.md)

## 🤝 Contributing

When adding a new package:

1. Follow the naming convention: `feature_*` or `core_*`
2. Include comprehensive README
3. Add tests (aim for >80% coverage)
4. Export only public API in main library file
5. Document dependencies and usage examples
6. Update this README with the new package
