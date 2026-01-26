// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProfileDTO _$UserProfileDTOFromJson(Map<String, dynamic> json) {
  return _UserProfileDTO.fromJson(json);
}

/// @nodoc
mixin _$UserProfileDTO {
  // Manual snake_case mapping for each field
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_address')
  String? get emailAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String? get displayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_since')
  String? get memberSince => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_login_at')
  String? get lastLoginAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  int? get isActive => throw _privateConstructorUsedError; // API sends 0/1
  @JsonKey(name: 'email_verified')
  bool? get emailVerified => throw _privateConstructorUsedError; // Nested preferences object
  UserPreferencesDTO? get preferences => throw _privateConstructorUsedError;

  /// Serializes this UserProfileDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileDTOCopyWith<UserProfileDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileDTOCopyWith<$Res> {
  factory $UserProfileDTOCopyWith(
    UserProfileDTO value,
    $Res Function(UserProfileDTO) then,
  ) = _$UserProfileDTOCopyWithImpl<$Res, UserProfileDTO>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'email_address') String? emailAddress,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'member_since') String? memberSince,
    @JsonKey(name: 'last_login_at') String? lastLoginAt,
    @JsonKey(name: 'is_active') int? isActive,
    @JsonKey(name: 'email_verified') bool? emailVerified,
    UserPreferencesDTO? preferences,
  });

  $UserPreferencesDTOCopyWith<$Res>? get preferences;
}

/// @nodoc
class _$UserProfileDTOCopyWithImpl<$Res, $Val extends UserProfileDTO>
    implements $UserProfileDTOCopyWith<$Res> {
  _$UserProfileDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? emailAddress = freezed,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? memberSince = freezed,
    Object? lastLoginAt = freezed,
    Object? isActive = freezed,
    Object? emailVerified = freezed,
    Object? preferences = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailAddress: freezed == emailAddress
                ? _value.emailAddress
                : emailAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            memberSince: freezed == memberSince
                ? _value.memberSince
                : memberSince // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastLoginAt: freezed == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as int?,
            emailVerified: freezed == emailVerified
                ? _value.emailVerified
                : emailVerified // ignore: cast_nullable_to_non_nullable
                      as bool?,
            preferences: freezed == preferences
                ? _value.preferences
                : preferences // ignore: cast_nullable_to_non_nullable
                      as UserPreferencesDTO?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserProfileDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesDTOCopyWith<$Res>? get preferences {
    if (_value.preferences == null) {
      return null;
    }

    return $UserPreferencesDTOCopyWith<$Res>(_value.preferences!, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileDTOImplCopyWith<$Res>
    implements $UserProfileDTOCopyWith<$Res> {
  factory _$$UserProfileDTOImplCopyWith(
    _$UserProfileDTOImpl value,
    $Res Function(_$UserProfileDTOImpl) then,
  ) = __$$UserProfileDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'email_address') String? emailAddress,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'member_since') String? memberSince,
    @JsonKey(name: 'last_login_at') String? lastLoginAt,
    @JsonKey(name: 'is_active') int? isActive,
    @JsonKey(name: 'email_verified') bool? emailVerified,
    UserPreferencesDTO? preferences,
  });

  @override
  $UserPreferencesDTOCopyWith<$Res>? get preferences;
}

/// @nodoc
class __$$UserProfileDTOImplCopyWithImpl<$Res>
    extends _$UserProfileDTOCopyWithImpl<$Res, _$UserProfileDTOImpl>
    implements _$$UserProfileDTOImplCopyWith<$Res> {
  __$$UserProfileDTOImplCopyWithImpl(
    _$UserProfileDTOImpl _value,
    $Res Function(_$UserProfileDTOImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfileDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? emailAddress = freezed,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? memberSince = freezed,
    Object? lastLoginAt = freezed,
    Object? isActive = freezed,
    Object? emailVerified = freezed,
    Object? preferences = freezed,
  }) {
    return _then(
      _$UserProfileDTOImpl(
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailAddress: freezed == emailAddress
            ? _value.emailAddress
            : emailAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        memberSince: freezed == memberSince
            ? _value.memberSince
            : memberSince // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastLoginAt: freezed == lastLoginAt
            ? _value.lastLoginAt
            : lastLoginAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as int?,
        emailVerified: freezed == emailVerified
            ? _value.emailVerified
            : emailVerified // ignore: cast_nullable_to_non_nullable
                  as bool?,
        preferences: freezed == preferences
            ? _value.preferences
            : preferences // ignore: cast_nullable_to_non_nullable
                  as UserPreferencesDTO?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileDTOImpl implements _UserProfileDTO {
  const _$UserProfileDTOImpl({
    @JsonKey(name: 'user_id') this.userId,
    @JsonKey(name: 'email_address') this.emailAddress,
    @JsonKey(name: 'display_name') this.displayName,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
    @JsonKey(name: 'member_since') this.memberSince,
    @JsonKey(name: 'last_login_at') this.lastLoginAt,
    @JsonKey(name: 'is_active') this.isActive,
    @JsonKey(name: 'email_verified') this.emailVerified,
    this.preferences,
  });

  factory _$UserProfileDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileDTOImplFromJson(json);

  // Manual snake_case mapping for each field
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'email_address')
  final String? emailAddress;
  @override
  @JsonKey(name: 'display_name')
  final String? displayName;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  @JsonKey(name: 'member_since')
  final String? memberSince;
  @override
  @JsonKey(name: 'last_login_at')
  final String? lastLoginAt;
  @override
  @JsonKey(name: 'is_active')
  final int? isActive;
  // API sends 0/1
  @override
  @JsonKey(name: 'email_verified')
  final bool? emailVerified;
  // Nested preferences object
  @override
  final UserPreferencesDTO? preferences;

  @override
  String toString() {
    return 'UserProfileDTO(userId: $userId, emailAddress: $emailAddress, displayName: $displayName, avatarUrl: $avatarUrl, memberSince: $memberSince, lastLoginAt: $lastLoginAt, isActive: $isActive, emailVerified: $emailVerified, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileDTOImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.emailAddress, emailAddress) ||
                other.emailAddress == emailAddress) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.memberSince, memberSince) ||
                other.memberSince == memberSince) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.emailVerified, emailVerified) ||
                other.emailVerified == emailVerified) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    emailAddress,
    displayName,
    avatarUrl,
    memberSince,
    lastLoginAt,
    isActive,
    emailVerified,
    preferences,
  );

  /// Create a copy of UserProfileDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileDTOImplCopyWith<_$UserProfileDTOImpl> get copyWith =>
      __$$UserProfileDTOImplCopyWithImpl<_$UserProfileDTOImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileDTOImplToJson(this);
  }
}

abstract class _UserProfileDTO implements UserProfileDTO {
  const factory _UserProfileDTO({
    @JsonKey(name: 'user_id') final String? userId,
    @JsonKey(name: 'email_address') final String? emailAddress,
    @JsonKey(name: 'display_name') final String? displayName,
    @JsonKey(name: 'avatar_url') final String? avatarUrl,
    @JsonKey(name: 'member_since') final String? memberSince,
    @JsonKey(name: 'last_login_at') final String? lastLoginAt,
    @JsonKey(name: 'is_active') final int? isActive,
    @JsonKey(name: 'email_verified') final bool? emailVerified,
    final UserPreferencesDTO? preferences,
  }) = _$UserProfileDTOImpl;

  factory _UserProfileDTO.fromJson(Map<String, dynamic> json) =
      _$UserProfileDTOImpl.fromJson;

  // Manual snake_case mapping for each field
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  @JsonKey(name: 'email_address')
  String? get emailAddress;
  @override
  @JsonKey(name: 'display_name')
  String? get displayName;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  @JsonKey(name: 'member_since')
  String? get memberSince;
  @override
  @JsonKey(name: 'last_login_at')
  String? get lastLoginAt;
  @override
  @JsonKey(name: 'is_active')
  int? get isActive; // API sends 0/1
  @override
  @JsonKey(name: 'email_verified')
  bool? get emailVerified; // Nested preferences object
  @override
  UserPreferencesDTO? get preferences;

  /// Create a copy of UserProfileDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileDTOImplCopyWith<_$UserProfileDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserPreferencesDTO _$UserPreferencesDTOFromJson(Map<String, dynamic> json) {
  return _UserPreferencesDTO.fromJson(json);
}

/// @nodoc
mixin _$UserPreferencesDTO {
  String? get theme => throw _privateConstructorUsedError;
  @JsonKey(name: 'notifications_enabled')
  bool? get notificationsEnabled => throw _privateConstructorUsedError;

  /// Serializes this UserPreferencesDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferencesDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesDTOCopyWith<UserPreferencesDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesDTOCopyWith<$Res> {
  factory $UserPreferencesDTOCopyWith(
    UserPreferencesDTO value,
    $Res Function(UserPreferencesDTO) then,
  ) = _$UserPreferencesDTOCopyWithImpl<$Res, UserPreferencesDTO>;
  @useResult
  $Res call({
    String? theme,
    @JsonKey(name: 'notifications_enabled') bool? notificationsEnabled,
  });
}

/// @nodoc
class _$UserPreferencesDTOCopyWithImpl<$Res, $Val extends UserPreferencesDTO>
    implements $UserPreferencesDTOCopyWith<$Res> {
  _$UserPreferencesDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferencesDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? theme = freezed, Object? notificationsEnabled = freezed}) {
    return _then(
      _value.copyWith(
            theme: freezed == theme
                ? _value.theme
                : theme // ignore: cast_nullable_to_non_nullable
                      as String?,
            notificationsEnabled: freezed == notificationsEnabled
                ? _value.notificationsEnabled
                : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserPreferencesDTOImplCopyWith<$Res>
    implements $UserPreferencesDTOCopyWith<$Res> {
  factory _$$UserPreferencesDTOImplCopyWith(
    _$UserPreferencesDTOImpl value,
    $Res Function(_$UserPreferencesDTOImpl) then,
  ) = __$$UserPreferencesDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? theme,
    @JsonKey(name: 'notifications_enabled') bool? notificationsEnabled,
  });
}

/// @nodoc
class __$$UserPreferencesDTOImplCopyWithImpl<$Res>
    extends _$UserPreferencesDTOCopyWithImpl<$Res, _$UserPreferencesDTOImpl>
    implements _$$UserPreferencesDTOImplCopyWith<$Res> {
  __$$UserPreferencesDTOImplCopyWithImpl(
    _$UserPreferencesDTOImpl _value,
    $Res Function(_$UserPreferencesDTOImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserPreferencesDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? theme = freezed, Object? notificationsEnabled = freezed}) {
    return _then(
      _$UserPreferencesDTOImpl(
        theme: freezed == theme
            ? _value.theme
            : theme // ignore: cast_nullable_to_non_nullable
                  as String?,
        notificationsEnabled: freezed == notificationsEnabled
            ? _value.notificationsEnabled
            : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesDTOImpl implements _UserPreferencesDTO {
  const _$UserPreferencesDTOImpl({
    this.theme,
    @JsonKey(name: 'notifications_enabled') this.notificationsEnabled,
  });

  factory _$UserPreferencesDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesDTOImplFromJson(json);

  @override
  final String? theme;
  @override
  @JsonKey(name: 'notifications_enabled')
  final bool? notificationsEnabled;

  @override
  String toString() {
    return 'UserPreferencesDTO(theme: $theme, notificationsEnabled: $notificationsEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesDTOImpl &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, theme, notificationsEnabled);

  /// Create a copy of UserPreferencesDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesDTOImplCopyWith<_$UserPreferencesDTOImpl> get copyWith =>
      __$$UserPreferencesDTOImplCopyWithImpl<_$UserPreferencesDTOImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesDTOImplToJson(this);
  }
}

abstract class _UserPreferencesDTO implements UserPreferencesDTO {
  const factory _UserPreferencesDTO({
    final String? theme,
    @JsonKey(name: 'notifications_enabled') final bool? notificationsEnabled,
  }) = _$UserPreferencesDTOImpl;

  factory _UserPreferencesDTO.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesDTOImpl.fromJson;

  @override
  String? get theme;
  @override
  @JsonKey(name: 'notifications_enabled')
  bool? get notificationsEnabled;

  /// Create a copy of UserPreferencesDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesDTOImplCopyWith<_$UserPreferencesDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
