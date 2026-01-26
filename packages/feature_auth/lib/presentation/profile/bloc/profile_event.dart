import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_event.freezed.dart';

/// Events for Profile BLoC
@freezed
class ProfileEvent with _$ProfileEvent {
  /// Load user profile (cache-first)
  const factory ProfileEvent.loadProfile({required String userId}) =
      LoadProfile;

  /// Refresh profile (force fetch from API)
  const factory ProfileEvent.refreshProfile({required String userId}) =
      RefreshProfile;

  /// Retry after error
  const factory ProfileEvent.retry({required String userId}) = RetryProfile;

  /// Load cached profile only (offline mode)
  const factory ProfileEvent.loadCachedProfile({required String userId}) =
      LoadCachedProfile;
}
