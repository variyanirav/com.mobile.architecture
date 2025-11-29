# Feature Auth Package

Authentication feature for the mobile architecture project.

## Contents

### Domain Layer
- `UserEntity` - Core user model
- `UserRepository` - Interface for user data operations
- `LoginUserUseCase` - Business logic for login

### Data Layer
- `UserModel` - Data model with JSON serialization
- `UserRepositoryImpl` - Repository implementation

### Presentation Layer
- `LoginBloc` - State management for login
- `LoginPage` - Login UI

## Features

- ✅ Email/password login
- ✅ Input validation
- ✅ Error handling
- ✅ Loading states
- ✅ Success/failure feedback

## Usage

```dart
import 'package:feature_auth/feature_auth.dart';

// In your app
BlocProvider(
  create: (context) => LoginBloc(
    loginUserUseCase: LoginUserUseCase(
      repository: UserRepositoryImpl(),
    ),
  ),
  child: LoginPage(),
);
```

## Dependencies

- `core` - Shared infrastructure
- `flutter_bloc` - State management
- `equatable` - Value equality

## Testing

```bash
flutter test
```
