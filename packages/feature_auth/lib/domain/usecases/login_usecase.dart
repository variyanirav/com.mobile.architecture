import 'package:core/core.dart';
import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';

/// Use case for logging in a user
/// Handles validation and delegates to repository
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login with email and password
  /// Returns Result<Failure, UserEntity> - Left for errors, Right for success
  Future<Result<Failure, UserEntity>> call(
    String email,
    String password,
  ) async {
    // Input validation
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email is required'));
    }
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password is required'));
    }
    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    // Delegate to repository
    return _repository.login(email, password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
