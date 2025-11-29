# Core Package

Shared infrastructure and utilities for the mobile architecture project.

## Contents

### Error Handling
- `Result<L, R>` - Functional error handling type (Left/Right pattern)
- `Failure` - Base class for all errors in the system
- Failure types: ValidationFailure, AuthenticationFailure, NetworkFailure, ServerFailure, CacheFailure, UnknownFailure

### Logging
- `Logger` - Abstract logging interface
- `ConsoleLogger` - Console implementation for development

### Usage

```dart
import 'package:core/core.dart';

// Using Result type
Result<Failure, User> result = await userRepository.login(email, password);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('Success: ${user.email}'),
);

// Using Logger
final logger = ConsoleLogger();
logger.info('User logged in');
logger.error('Failed to fetch data', error: exception);
```

## Dependencies

- `equatable` - For value equality
- `flutter` - Flutter SDK

## Testing

```bash
flutter test
```
