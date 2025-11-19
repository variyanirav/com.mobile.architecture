import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/error/result.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/repository/user_repository.dart';

class LoginUserUseCase {
  final UserRepository repository;

  LoginUserUseCase(this.repository);

  Future<Result<Failure, UserEntity>> call(
    String email,
    String password,
  ) async {
    // Add validation
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }
    if (!email.contains('@')) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    return await repository.login(email, password);
  }
}
