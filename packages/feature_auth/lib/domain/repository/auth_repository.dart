import 'package:core/core.dart';
import '../entities/user_entity.dart';

/// Repository contract for authentication operations
///
/// This defines the interface that data layer must implement.
/// Clean Architecture principle: domain defines contracts, data implements them.
abstract class AuthRepository {
  /// Login with email and password
  ///
  /// Returns:
  /// - Right(UserEntity) on successful authentication
  /// - Left(AuthenticationFailure) on invalid credentials
  /// - Left(NetworkFailure) on connection errors
  Future<Result<Failure, UserEntity>> login(String email, String password);

  /// Logout the current user
  Future<Result<Failure, void>> logout();

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();

  /// Get the current authenticated user
  Future<Result<Failure, UserEntity>> getCurrentUser();
}
