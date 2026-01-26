import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/error/failures_freezed.dart';
import '../../../domain/repository/user_profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Profile BLoC with SMART error handling
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserProfileRepository repository;

  int _retryCount = 0;
  static const int _maxRetries = 3;

  ProfileBloc({required this.repository}) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onRefreshProfile);
    on<RetryProfile>(_onRetry);
    on<LoadCachedProfile>(_onLoadCachedProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    _retryCount = 0;

    emit(const ProfileLoading());

    final result = await repository.getProfile(event.userId);

    result.fold(
      (failure) => _handleFailure(failure, emit, event.userId),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    _retryCount = 0;

    emit(const ProfileLoading());

    final result = await repository.refreshProfile(event.userId);

    result.fold(
      (failure) => _handleFailure(failure, emit, event.userId),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onLoadCachedProfile(
    LoadCachedProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await repository.getCachedProfile(event.userId);

    result.fold(
      (failure) =>
          _handleFailure(failure, emit, event.userId, isOfflineMode: true),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onRetry(RetryProfile event, Emitter<ProfileState> emit) async {
    _retryCount++;

    if (_retryCount > _maxRetries) {
      emit(
        ProfileError(
          failure: const Failure.unexpected('Max retries exceeded'),
          userMessage: 'Unable to load profile after multiple attempts',
          canRetry: false,
          retryCount: _retryCount,
          shouldContactSupport: true,
          supportReference: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      );
      return;
    }

    // Exponential backoff
    await Future.delayed(Duration(seconds: 2 * _retryCount));

    emit(ProfileRetrying(attempt: _retryCount, maxAttempts: _maxRetries));

    final result = await repository.getProfile(event.userId);

    result.fold((failure) => _handleFailure(failure, emit, event.userId), (
      profile,
    ) {
      _retryCount = 0; // Reset on success
      emit(ProfileLoaded(profile));
    });
  }

  /// SMART error handling - different actions for different failures
  void _handleFailure(
    Failure failure,
    Emitter<ProfileState> emit,
    String userId, {
    bool isOfflineMode = false,
  }) {
    // Use freezed pattern matching for type-safe handling
    failure.when(
      network: (message, code) {
        emit(
          ProfileError(
            failure: failure,
            userMessage: failure.userMessage,
            canRetry: true,
            retryCount: _retryCount,
            maxRetries: _maxRetries,
            technicalDetails: failure.technicalMessage,
            shouldShowOfflineMode: !isOfflineMode,
          ),
        );
      },
      server: (message, code) {
        // Server errors - retry automatically but limit attempts
        if (_retryCount < _maxRetries && !isOfflineMode) {
          // Auto-retry for server errors
          add(RetryProfile(userId: userId));
        } else {
          emit(
            ProfileError(
              failure: failure,
              userMessage: failure.userMessage,
              canRetry: _retryCount < _maxRetries,
              retryCount: _retryCount,
              maxRetries: _maxRetries,
              technicalDetails: failure.technicalMessage,
              shouldContactSupport: true,
            ),
          );
        }
      },
      authentication: (message, code) {
        // Auth error - can't retry, need to re-login
        emit(
          ProfileError(
            failure: failure,
            userMessage: 'Please log in again',
            canRetry: false,
            technicalDetails: failure.technicalMessage,
          ),
        );
      },
      validation: (message, code) {
        // Validation error (bad data from backend)
        emit(
          ProfileError(
            failure: failure,
            userMessage: 'Unable to load profile data',
            canRetry: true,
            retryCount: _retryCount,
            maxRetries: _maxRetries,
            technicalDetails: failure.technicalMessage,
            shouldContactSupport: true,
          ),
        );
      },
      cache: (message, code) {
        // Cache error - try remote
        if (!isOfflineMode) {
          add(RefreshProfile(userId: userId));
        } else {
          emit(
            ProfileError(
              failure: failure,
              userMessage: 'No offline data available',
              canRetry: true,
              technicalDetails: failure.technicalMessage,
            ),
          );
        }
      },
      unexpected: (message, code) {
        emit(
          ProfileError(
            failure: failure,
            userMessage: failure.userMessage,
            canRetry: true,
            retryCount: _retryCount,
            maxRetries: _maxRetries,
            technicalDetails: failure.technicalMessage,
            shouldContactSupport: true,
            supportReference: DateTime.now().millisecondsSinceEpoch.toString(),
          ),
        );
      },
    );
  }
}
