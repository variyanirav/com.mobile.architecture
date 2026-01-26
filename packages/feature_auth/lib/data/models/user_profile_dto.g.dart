// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileDTOImpl _$$UserProfileDTOImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileDTOImpl(
      userId: json['user_id'] as String?,
      emailAddress: json['email_address'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      memberSince: json['member_since'] as String?,
      lastLoginAt: json['last_login_at'] as String?,
      isActive: (json['is_active'] as num?)?.toInt(),
      emailVerified: json['email_verified'] as bool?,
      preferences: json['preferences'] == null
          ? null
          : UserPreferencesDTO.fromJson(
              json['preferences'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$UserProfileDTOImplToJson(
  _$UserProfileDTOImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'email_address': instance.emailAddress,
  'display_name': instance.displayName,
  'avatar_url': instance.avatarUrl,
  'member_since': instance.memberSince,
  'last_login_at': instance.lastLoginAt,
  'is_active': instance.isActive,
  'email_verified': instance.emailVerified,
  'preferences': instance.preferences,
};

_$UserPreferencesDTOImpl _$$UserPreferencesDTOImplFromJson(
  Map<String, dynamic> json,
) => _$UserPreferencesDTOImpl(
  theme: json['theme'] as String?,
  notificationsEnabled: json['notifications_enabled'] as bool?,
);

Map<String, dynamic> _$$UserPreferencesDTOImplToJson(
  _$UserPreferencesDTOImpl instance,
) => <String, dynamic>{
  'theme': instance.theme,
  'notifications_enabled': instance.notificationsEnabled,
};
