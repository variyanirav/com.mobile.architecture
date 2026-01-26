import 'package:core/error/failures_freezed.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/user_profile.dart';

part 'profile_state.freezed.dart';

/// States for Profile BLoC with comprehensive error information
@freezed
class ProfileState with _$ProfileState {
  /// Initial state
  const factory ProfileState.initial() = ProfileInitial;

  /// Loading profile
  const factory ProfileState.loading() = ProfileLoading;

  /// Profile loaded successfully
  const factory ProfileState.loaded(UserProfile profile) = ProfileLoaded;

  /// Retrying after error
  const factory ProfileState.retrying({
    required int attempt,
    required int maxAttempts,
  }) = ProfileRetrying;

  /// Error loading profile with rich context
  const factory ProfileState.error({
    required Failure failure,
    required String userMessage,
    @Default(false) bool canRetry,
    @Default(0) int retryCount,
    @Default(3) int maxRetries,
    String? technicalDetails,
    @Default(false) bool shouldShowOfflineMode,
    @Default(false) bool shouldContactSupport,
    String? supportReference,
  }) = ProfileError;
}

/// Extension for easy state checks
extension ProfileStateX on ProfileState {
  bool get isLoading => this is ProfileLoading || this is ProfileRetrying;
  bool get isError => this is ProfileError;
  bool get isLoaded => this is ProfileLoaded;

  UserProfile? get profileOrNull =>
      maybeWhen(loaded: (profile) => profile, orElse: () => null);
}
