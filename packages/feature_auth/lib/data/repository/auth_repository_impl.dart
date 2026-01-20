import 'package:core/core.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../models/user_model.dart';

/// Implementation of AuthRepository
/// Simulates API calls for authentication
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Result<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication logic
      if (email == 'test@example.com' && password == 'password123') {
        final user = UserModel(
          id: '123',
          email: email,
          name: 'Test User',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
        );
        return Right(user.toEntity());
      }

      // Mock failure for invalid credentials
      return const Left(AuthenticationFailure('Invalid email or password'));
    } catch (e) {
      return Left(UnknownFailure('Login failed: $e'));
    }
  }

  @override
  Future<Result<Failure, void>> logout() async {
    try {
      // Simulate logout logic
      await Future.delayed(const Duration(milliseconds: 500));
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Logout failed: $e'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    // Mock implementation - always returns false
    return false;
  }

  @override
  Future<Result<Failure, UserEntity>> getCurrentUser() async {
    // Simulate checking stored session
    return const Left(AuthenticationFailure('Not logged in'));
  }
}
