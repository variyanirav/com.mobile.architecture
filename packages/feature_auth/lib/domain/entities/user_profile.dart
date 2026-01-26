import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

/// Domain model - represents the business concept of a User Profile
/// This is what the app uses internally
/// No JSON serialization - this is pure domain logic
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    required DateTime createdAt,
    required DateTime lastLoginAt,
    @Default(true) bool isActive,
    @Default(false) bool emailVerified,
    // Preferences flattened (not nested)
    @Default('light') String theme,
    @Default(true) bool notificationsEnabled,
  }) = _UserProfile;

  const UserProfile._();

  /// Business logic: Check if profile needs update
  bool get needsUpdate {
    final daysSinceLogin = DateTime.now().difference(lastLoginAt).inDays;
    return daysSinceLogin > 30; // Stale if no login in 30 days
  }

  /// Business logic: Get display name
  String get displayName => name.isEmpty ? email.split('@').first : name;
}
