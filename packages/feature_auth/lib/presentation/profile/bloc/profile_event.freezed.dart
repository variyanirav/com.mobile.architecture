// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileEvent {
  String get userId => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadProfile,
    required TResult Function(String userId) refreshProfile,
    required TResult Function(String userId) retry,
    required TResult Function(String userId) loadCachedProfile,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadProfile,
    TResult? Function(String userId)? refreshProfile,
    TResult? Function(String userId)? retry,
    TResult? Function(String userId)? loadCachedProfile,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadProfile,
    TResult Function(String userId)? refreshProfile,
    TResult Function(String userId)? retry,
    TResult Function(String userId)? loadCachedProfile,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadProfile value) loadProfile,
    required TResult Function(RefreshProfile value) refreshProfile,
    required TResult Function(RetryProfile value) retry,
    required TResult Function(LoadCachedProfile value) loadCachedProfile,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadProfile value)? loadProfile,
    TResult? Function(RefreshProfile value)? refreshProfile,
    TResult? Function(RetryProfile value)? retry,
    TResult? Function(LoadCachedProfile value)? loadCachedProfile,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadProfile value)? loadProfile,
    TResult Function(RefreshProfile value)? refreshProfile,
    TResult Function(RetryProfile value)? retry,
    TResult Function(LoadCachedProfile value)? loadCachedProfile,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileEventCopyWith<ProfileEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileEventCopyWith<$Res> {
  factory $ProfileEventCopyWith(
    ProfileEvent value,
    $Res Function(ProfileEvent) then,
  ) = _$ProfileEventCopyWithImpl<$Res, ProfileEvent>;
  @useResult
  $Res call({String userId});
}

/// @nodoc
class _$ProfileEventCopyWithImpl<$Res, $Val extends ProfileEvent>
    implements $ProfileEventCopyWith<$Res> {
  _$ProfileEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoadProfileImplCopyWith<$Res>
    implements $ProfileEventCopyWith<$Res> {
  factory _$$LoadProfileImplCopyWith(
    _$LoadProfileImpl value,
    $Res Function(_$LoadProfileImpl) then,
  ) = __$$LoadProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId});
}

/// @nodoc
class __$$LoadProfileImplCopyWithImpl<$Res>
    extends _$ProfileEventCopyWithImpl<$Res, _$LoadProfileImpl>
    implements _$$LoadProfileImplCopyWith<$Res> {
  __$$LoadProfileImplCopyWithImpl(
    _$LoadProfileImpl _value,
    $Res Function(_$LoadProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _$LoadProfileImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$LoadProfileImpl implements LoadProfile {
  const _$LoadProfileImpl({required this.userId});

  @override
  final String userId;

  @override
  String toString() {
    return 'ProfileEvent.loadProfile(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadProfileImplCopyWith<_$LoadProfileImpl> get copyWith =>
      __$$LoadProfileImplCopyWithImpl<_$LoadProfileImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadProfile,
    required TResult Function(String userId) refreshProfile,
    required TResult Function(String userId) retry,
    required TResult Function(String userId) loadCachedProfile,
  }) {
    return loadProfile(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadProfile,
    TResult? Function(String userId)? refreshProfile,
    TResult? Function(String userId)? retry,
    TResult? Function(String userId)? loadCachedProfile,
  }) {
    return loadProfile?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadProfile,
    TResult Function(String userId)? refreshProfile,
    TResult Function(String userId)? retry,
    TResult Function(String userId)? loadCachedProfile,
    required TResult orElse(),
  }) {
    if (loadProfile != null) {
      return loadProfile(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadProfile value) loadProfile,
    required TResult Function(RefreshProfile value) refreshProfile,
    required TResult Function(RetryProfile value) retry,
    required TResult Function(LoadCachedProfile value) loadCachedProfile,
  }) {
    return loadProfile(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadProfile value)? loadProfile,
    TResult? Function(RefreshProfile value)? refreshProfile,
    TResult? Function(RetryProfile value)? retry,
    TResult? Function(LoadCachedProfile value)? loadCachedProfile,
  }) {
    return loadProfile?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadProfile value)? loadProfile,
    TResult Function(RefreshProfile value)? refreshProfile,
    TResult Function(RetryProfile value)? retry,
    TResult Function(LoadCachedProfile value)? loadCachedProfile,
    required TResult orElse(),
  }) {
    if (loadProfile != null) {
      return loadProfile(this);
    }
    return orElse();
  }
}

abstract class LoadProfile implements ProfileEvent {
  const factory LoadProfile({required final String userId}) = _$LoadProfileImpl;

  @override
  String get userId;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadProfileImplCopyWith<_$LoadProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RefreshProfileImplCopyWith<$Res>
    implements $ProfileEventCopyWith<$Res> {
  factory _$$RefreshProfileImplCopyWith(
    _$RefreshProfileImpl value,
    $Res Function(_$RefreshProfileImpl) then,
  ) = __$$RefreshProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId});
}

/// @nodoc
class __$$RefreshProfileImplCopyWithImpl<$Res>
    extends _$ProfileEventCopyWithImpl<$Res, _$RefreshProfileImpl>
    implements _$$RefreshProfileImplCopyWith<$Res> {
  __$$RefreshProfileImplCopyWithImpl(
    _$RefreshProfileImpl _value,
    $Res Function(_$RefreshProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _$RefreshProfileImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RefreshProfileImpl implements RefreshProfile {
  const _$RefreshProfileImpl({required this.userId});

  @override
  final String userId;

  @override
  String toString() {
    return 'ProfileEvent.refreshProfile(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefreshProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefreshProfileImplCopyWith<_$RefreshProfileImpl> get copyWith =>
      __$$RefreshProfileImplCopyWithImpl<_$RefreshProfileImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadProfile,
    required TResult Function(String userId) refreshProfile,
    required TResult Function(String userId) retry,
    required TResult Function(String userId) loadCachedProfile,
  }) {
    return refreshProfile(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadProfile,
    TResult? Function(String userId)? refreshProfile,
    TResult? Function(String userId)? retry,
    TResult? Function(String userId)? loadCachedProfile,
  }) {
    return refreshProfile?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadProfile,
    TResult Function(String userId)? refreshProfile,
    TResult Function(String userId)? retry,
    TResult Function(String userId)? loadCachedProfile,
    required TResult orElse(),
  }) {
    if (refreshProfile != null) {
      return refreshProfile(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadProfile value) loadProfile,
    required TResult Function(RefreshProfile value) refreshProfile,
    required TResult Function(RetryProfile value) retry,
    required TResult Function(LoadCachedProfile value) loadCachedProfile,
  }) {
    return refreshProfile(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadProfile value)? loadProfile,
    TResult? Function(RefreshProfile value)? refreshProfile,
    TResult? Function(RetryProfile value)? retry,
    TResult? Function(LoadCachedProfile value)? loadCachedProfile,
  }) {
    return refreshProfile?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadProfile value)? loadProfile,
    TResult Function(RefreshProfile value)? refreshProfile,
    TResult Function(RetryProfile value)? retry,
    TResult Function(LoadCachedProfile value)? loadCachedProfile,
    required TResult orElse(),
  }) {
    if (refreshProfile != null) {
      return refreshProfile(this);
    }
    return orElse();
  }
}

abstract class RefreshProfile implements ProfileEvent {
  const factory RefreshProfile({required final String userId}) =
      _$RefreshProfileImpl;

  @override
  String get userId;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefreshProfileImplCopyWith<_$RefreshProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RetryProfileImplCopyWith<$Res>
    implements $ProfileEventCopyWith<$Res> {
  factory _$$RetryProfileImplCopyWith(
    _$RetryProfileImpl value,
    $Res Function(_$RetryProfileImpl) then,
  ) = __$$RetryProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId});
}

/// @nodoc
class __$$RetryProfileImplCopyWithImpl<$Res>
    extends _$ProfileEventCopyWithImpl<$Res, _$RetryProfileImpl>
    implements _$$RetryProfileImplCopyWith<$Res> {
  __$$RetryProfileImplCopyWithImpl(
    _$RetryProfileImpl _value,
    $Res Function(_$RetryProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _$RetryProfileImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RetryProfileImpl implements RetryProfile {
  const _$RetryProfileImpl({required this.userId});

  @override
  final String userId;

  @override
  String toString() {
    return 'ProfileEvent.retry(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RetryProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RetryProfileImplCopyWith<_$RetryProfileImpl> get copyWith =>
      __$$RetryProfileImplCopyWithImpl<_$RetryProfileImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadProfile,
    required TResult Function(String userId) refreshProfile,
    required TResult Function(String userId) retry,
    required TResult Function(String userId) loadCachedProfile,
  }) {
    return retry(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadProfile,
    TResult? Function(String userId)? refreshProfile,
    TResult? Function(String userId)? retry,
    TResult? Function(String userId)? loadCachedProfile,
  }) {
    return retry?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadProfile,
    TResult Function(String userId)? refreshProfile,
    TResult Function(String userId)? retry,
    TResult Function(String userId)? loadCachedProfile,
    required TResult orElse(),
  }) {
    if (retry != null) {
      return retry(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadProfile value) loadProfile,
    required TResult Function(RefreshProfile value) refreshProfile,
    required TResult Function(RetryProfile value) retry,
    required TResult Function(LoadCachedProfile value) loadCachedProfile,
  }) {
    return retry(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadProfile value)? loadProfile,
    TResult? Function(RefreshProfile value)? refreshProfile,
    TResult? Function(RetryProfile value)? retry,
    TResult? Function(LoadCachedProfile value)? loadCachedProfile,
  }) {
    return retry?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadProfile value)? loadProfile,
    TResult Function(RefreshProfile value)? refreshProfile,
    TResult Function(RetryProfile value)? retry,
    TResult Function(LoadCachedProfile value)? loadCachedProfile,
    required TResult orElse(),
  }) {
    if (retry != null) {
      return retry(this);
    }
    return orElse();
  }
}

abstract class RetryProfile implements ProfileEvent {
  const factory RetryProfile({required final String userId}) =
      _$RetryProfileImpl;

  @override
  String get userId;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RetryProfileImplCopyWith<_$RetryProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadCachedProfileImplCopyWith<$Res>
    implements $ProfileEventCopyWith<$Res> {
  factory _$$LoadCachedProfileImplCopyWith(
    _$LoadCachedProfileImpl value,
    $Res Function(_$LoadCachedProfileImpl) then,
  ) = __$$LoadCachedProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId});
}

/// @nodoc
class __$$LoadCachedProfileImplCopyWithImpl<$Res>
    extends _$ProfileEventCopyWithImpl<$Res, _$LoadCachedProfileImpl>
    implements _$$LoadCachedProfileImplCopyWith<$Res> {
  __$$LoadCachedProfileImplCopyWithImpl(
    _$LoadCachedProfileImpl _value,
    $Res Function(_$LoadCachedProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _$LoadCachedProfileImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$LoadCachedProfileImpl implements LoadCachedProfile {
  const _$LoadCachedProfileImpl({required this.userId});

  @override
  final String userId;

  @override
  String toString() {
    return 'ProfileEvent.loadCachedProfile(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadCachedProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadCachedProfileImplCopyWith<_$LoadCachedProfileImpl> get copyWith =>
      __$$LoadCachedProfileImplCopyWithImpl<_$LoadCachedProfileImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadProfile,
    required TResult Function(String userId) refreshProfile,
    required TResult Function(String userId) retry,
    required TResult Function(String userId) loadCachedProfile,
  }) {
    return loadCachedProfile(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadProfile,
    TResult? Function(String userId)? refreshProfile,
    TResult? Function(String userId)? retry,
    TResult? Function(String userId)? loadCachedProfile,
  }) {
    return loadCachedProfile?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadProfile,
    TResult Function(String userId)? refreshProfile,
    TResult Function(String userId)? retry,
    TResult Function(String userId)? loadCachedProfile,
    required TResult orElse(),
  }) {
    if (loadCachedProfile != null) {
      return loadCachedProfile(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadProfile value) loadProfile,
    required TResult Function(RefreshProfile value) refreshProfile,
    required TResult Function(RetryProfile value) retry,
    required TResult Function(LoadCachedProfile value) loadCachedProfile,
  }) {
    return loadCachedProfile(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadProfile value)? loadProfile,
    TResult? Function(RefreshProfile value)? refreshProfile,
    TResult? Function(RetryProfile value)? retry,
    TResult? Function(LoadCachedProfile value)? loadCachedProfile,
  }) {
    return loadCachedProfile?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadProfile value)? loadProfile,
    TResult Function(RefreshProfile value)? refreshProfile,
    TResult Function(RetryProfile value)? retry,
    TResult Function(LoadCachedProfile value)? loadCachedProfile,
    required TResult orElse(),
  }) {
    if (loadCachedProfile != null) {
      return loadCachedProfile(this);
    }
    return orElse();
  }
}

abstract class LoadCachedProfile implements ProfileEvent {
  const factory LoadCachedProfile({required final String userId}) =
      _$LoadCachedProfileImpl;

  @override
  String get userId;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadCachedProfileImplCopyWith<_$LoadCachedProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
