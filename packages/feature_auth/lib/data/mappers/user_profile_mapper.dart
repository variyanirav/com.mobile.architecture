import 'package:core/error/failures_freezed.dart';
import 'package:core/error/result.dart';
import 'package:core/logging/console_logger.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_dto.dart';

/// DEFENSIVE Mapper - validates and converts DTO ↔ Domain
/// Protects app from backend chaos!
class UserProfileMapper {
  static final _logger = ConsoleLogger();

  /// Convert DTO (from API) → Domain Model (for app)
  /// Returns Result to handle invalid data gracefully
  static Result<Failure, UserProfile> toDomain(UserProfileDTO dto) {
    try {
      // VALIDATE: Required fields must exist and be valid
      if (dto.userId == null || dto.userId!.isEmpty) {
        _logger.warning('Invalid DTO: missing userId');
        return const Left(Failure.server('Invalid user data: missing ID'));
      }

      if (dto.emailAddress == null || !_isValidEmail(dto.emailAddress!)) {
        _logger.warning('Invalid DTO: invalid email');
        return const Left(Failure.server('Invalid user data: invalid email'));
      }

      // PARSE: Dates with fallback
      final createdAt = _parseDate(dto.memberSince) ?? DateTime.now();
      final lastLoginAt = _parseDate(dto.lastLoginAt) ?? DateTime.now();

      // PARSE: Boolean from int (0/1) with fallback
      final isActive = dto.isActive == 1;

      // PARSE: Nested preferences with fallbacks
      final theme = dto.preferences?.theme ?? 'light';
      final notificationsEnabled =
          dto.preferences?.notificationsEnabled ?? true;

      // SUCCESS: Create domain model
      return Right(
        UserProfile(
          id: dto.userId!,
          email: dto.emailAddress!,
          name: dto.displayName ?? '',
          avatarUrl: dto.avatarUrl,
          createdAt: createdAt,
          lastLoginAt: lastLoginAt,
          isActive: isActive,
          emailVerified: dto.emailVerified ?? false,
          theme: theme,
          notificationsEnabled: notificationsEnabled,
        ),
      );
    } catch (e, stackTrace) {
      // Something unexpected happened during mapping
      _logger.error('Mapping error', error: e, stackTrace: stackTrace);
      return Left(Failure.unexpected('Failed to parse user profile: $e'));
    }
  }

  /// Convert Domain Model → DTO (for API)
  static UserProfileDTO toDTO(UserProfile profile) {
    return UserProfileDTO(
      userId: profile.id,
      emailAddress: profile.email,
      displayName: profile.name,
      avatarUrl: profile.avatarUrl,
      memberSince: profile.createdAt.toIso8601String(),
      lastLoginAt: profile.lastLoginAt.toIso8601String(),
      isActive: profile.isActive ? 1 : 0, // bool → int
      emailVerified: profile.emailVerified,
      preferences: UserPreferencesDTO(
        theme: profile.theme,
        notificationsEnabled: profile.notificationsEnabled,
      ),
    );
  }

  // DEFENSIVE HELPERS

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      _logger.warning('Invalid date format: $dateString');
      return null;
    }
  }
}
