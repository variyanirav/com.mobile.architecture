import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures_freezed.freezed.dart';

/// Freezed-based Failure types with pattern matching support
/// This provides type-safe error handling with exhaustive checking
@freezed
class Failure with _$Failure {
  /// Server error (500, 503, etc.)
  const factory Failure.server(String message, {String? code}) = ServerFailure;

  /// Network error (timeout, no connection)
  const factory Failure.network(String message, {String? code}) =
      NetworkFailure;

  /// Authentication error (401, 403, invalid credentials)
  const factory Failure.authentication(String message, {String? code}) =
      AuthenticationFailure;

  /// Validation error (invalid input)
  const factory Failure.validation(String message, {String? code}) =
      ValidationFailure;

  /// Cache error (local storage failure)
  const factory Failure.cache(String message, {String? code}) = CacheFailure;

  /// Unexpected error (unknown/unhandled)
  const factory Failure.unexpected(String message, {String? code}) =
      UnexpectedFailure;
}

/// Extension methods for user-friendly error messages
extension FailureX on Failure {
  /// Get user-friendly error message
  String get userMessage {
    return when(
      server: (msg, code) =>
          'Server is temporarily unavailable. Please try again later.',
      network: (msg, code) => 'Please check your internet connection.',
      authentication: (msg, code) =>
          'Authentication failed. Please log in again.',
      validation: (msg, code) => msg, // Show actual validation message
      cache: (msg, code) => 'Unable to load cached data.',
      unexpected: (msg, code) => 'Something went wrong. Please try again.',
    );
  }

  /// Get technical error message (for logging)
  String get technicalMessage {
    return when(
      server: (msg, code) =>
          'Server error: $msg${code != null ? ' (code: $code)' : ''}',
      network: (msg, code) =>
          'Network error: $msg${code != null ? ' (code: $code)' : ''}',
      authentication: (msg, code) =>
          'Auth error: $msg${code != null ? ' (code: $code)' : ''}',
      validation: (msg, code) =>
          'Validation error: $msg${code != null ? ' (code: $code)' : ''}',
      cache: (msg, code) =>
          'Cache error: $msg${code != null ? ' (code: $code)' : ''}',
      unexpected: (msg, code) =>
          'Unexpected error: $msg${code != null ? ' (code: $code)' : ''}',
    );
  }

  /// Check if error is retryable
  bool get canRetry {
    return when(
      server: (_, __) => true, // Server errors might be temporary
      network: (_, __) => true, // Network might recover
      authentication: (_, __) => false, // Need to re-authenticate
      validation: (_, __) => false, // Fix input first
      cache: (_, __) => true, // Can retry cache operation
      unexpected: (_, __) => true, // Unknown, allow retry
    );
  }
}
