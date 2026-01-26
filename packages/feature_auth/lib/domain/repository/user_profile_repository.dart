import 'package:core/error/failures_freezed.dart';
import 'package:core/error/result.dart';
import '../entities/user_profile.dart';

/// Repository interface for user profile operations
/// Domain layer doesn't care HOW data is fetched (API, cache, etc.)
abstract class UserProfileRepository {
  /// Get user profile by ID
  /// Returns Result<Failure, UserProfile>
  Future<Result<Failure, UserProfile>> getProfile(String userId);

  /// Refresh user profile (force fetch from API)
  Future<Result<Failure, UserProfile>> refreshProfile(String userId);

  /// Get cached profile (offline-first)
  Future<Result<Failure, UserProfile>> getCachedProfile(String userId);
}
