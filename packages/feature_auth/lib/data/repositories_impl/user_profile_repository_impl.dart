import 'package:core/error/failures_freezed.dart';
import 'package:core/error/result.dart';
import 'package:core/logging/console_logger.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repository/user_profile_repository.dart';
import '../datasources/user_profile_local_datasource.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../mappers/user_profile_mapper.dart';

/// Repository implementation with DEFENSIVE coding and multi-layer error handling
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final UserProfileLocalDataSource localDataSource;
  final logger = ConsoleLogger();

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<Failure, UserProfile>> getProfile(String userId) async {
    // STRATEGY: Cache-first for better performance and offline support
    try {
      // 1. Try cache first (fast + offline support)
      final cached = await localDataSource.getCachedProfile(userId);
      if (cached != null) {
        logger.info('Profile loaded from cache');

        // Validate cached data before using
        final profileResult = UserProfileMapper.toDomain(cached);
        if (profileResult.isSuccess) {
          return profileResult;
        } else {
          // Cached data is corrupt, clear it
          logger.warning('Cached profile is invalid, clearing cache');
          await localDataSource.clearProfile(userId);
        }
      }

      // 2. Cache miss or invalid - fetch from API
      return await refreshProfile(userId);
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error in getProfile',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(Failure.unexpected('Failed to load profile'));
    }
  }

  @override
  Future<Result<Failure, UserProfile>> refreshProfile(String userId) async {
    try {
      logger.info('Fetching profile from API');

      // 1. Call remote API
      final dto = await remoteDataSource.getProfile(userId);

      // 2. DEFENSIVE: Validate DTO with mapper
      final profileResult = UserProfileMapper.toDomain(dto);

      if (profileResult.isFailure) {
        // Backend sent garbage! Don't cache it.
        logger.error('Backend returned invalid profile data');
        return profileResult; // Return the validation failure
      }

      // 3. Valid data - cache it for offline access
      try {
        await localDataSource.cacheProfile(userId, dto);
        logger.info('Profile cached successfully');
      } catch (cacheError) {
        // Cache failure is not critical - log and continue
        logger.warning('Failed to cache profile', error: cacheError);
      }

      // 4. Return success
      return profileResult;
    } on NetworkException catch (e) {
      // Network error - user might be offline or timeout
      logger.warning('Network error loading profile', error: e);
      return const Left(Failure.network('Check your internet connection'));
    } on ServerException catch (e) {
      // Server error (500, 503, etc.) - backend issues
      logger.error('Server error loading profile', error: e);

      if (e.statusCode != null && e.statusCode! >= 500) {
        return const Left(Failure.server('Server is temporarily unavailable'));
      } else {
        return Left(Failure.server('Failed to load profile: ${e.message}'));
      }
    } catch (e, stackTrace) {
      // Unknown error - log everything for debugging
      logger.error(
        'Unexpected error in refreshProfile',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(Failure.unexpected('Something went wrong: $e'));
    }
  }

  @override
  Future<Result<Failure, UserProfile>> getCachedProfile(String userId) async {
    try {
      logger.info('Getting cached profile only');

      final cached = await localDataSource.getCachedProfile(userId);

      if (cached == null) {
        return const Left(Failure.cache('No cached profile found'));
      }

      // Validate cached data
      return UserProfileMapper.toDomain(cached);
    } on CacheException catch (e) {
      logger.error('Cache error', error: e);
      return Left(Failure.cache(e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error in getCachedProfile',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(Failure.unexpected('Failed to load cached profile'));
    }
  }
}
