import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_dto.freezed.dart';
part 'user_profile_dto.g.dart';

/// DTO - matches API response format EXACTLY
/// This is the "transport format" from server
/// Includes JSON serialization
@freezed
class UserProfileDTO with _$UserProfileDTO {
  const factory UserProfileDTO({
    // Manual snake_case mapping for each field
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'email_address') String? emailAddress,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'member_since') String? memberSince,
    @JsonKey(name: 'last_login_at') String? lastLoginAt,
    @JsonKey(name: 'is_active') int? isActive, // API sends 0/1
    @JsonKey(name: 'email_verified') bool? emailVerified,
    // Nested preferences object
    UserPreferencesDTO? preferences,
  }) = _UserProfileDTO;

  factory UserProfileDTO.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDTOFromJson(json);
}

/// Nested DTO for user preferences
@freezed
class UserPreferencesDTO with _$UserPreferencesDTO {
  const factory UserPreferencesDTO({
    String? theme,
    @JsonKey(name: 'notifications_enabled') bool? notificationsEnabled,
  }) = _UserPreferencesDTO;

  factory UserPreferencesDTO.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesDTOFromJson(json);
}
