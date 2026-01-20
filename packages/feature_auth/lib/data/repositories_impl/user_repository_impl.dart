import 'package:core/core.dart';
import 'package:feature_auth/data/entities/user_entity.dart';
import 'package:feature_auth/domain/entities/user_entity.dart';
import 'package:feature_auth/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<Result<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      // Mock network call
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate authentication logic
      if (password.length < 6) {
        return const Left(
          AuthenticationFailure('Password must be at least 6 characters'),
        );
      }

      // Simulate successful login
      final user = UserModel(id: '123', email: email, name: '');
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Login failed: ${e.toString()}'));
    }
  }
}
