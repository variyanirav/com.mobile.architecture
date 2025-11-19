import 'package:equatable/equatable.dart';

/// A Result type that represents either a success value or a failure
/// This is similar to Either from functional programming
///
/// Example usage:
/// ```dart
/// Result result = await loginUser();
/// result.fold(
///   (failure) => print('Error: \${failure.message}'),
///   (user) => print('Success: \${user.email}'),
/// );
/// ```
sealed class Result<L, R> extends Equatable {
  const Result();

  /// Fold the result into a single value
  /// If this is a Left (failure), [onLeft] is called
  /// If this is a Right (success), [onRight] is called
  T fold<T>(T Function(L failure) onLeft, T Function(R success) onRight);

  /// Check if this is a success
  bool get isSuccess => this is Right<L, R>;

  /// Check if this is a failure
  bool get isFailure => this is Left<L, R>;

  /// Get the success value if present, otherwise throw
  R getSuccess() {
    return fold(
      (failure) => throw Exception('Called getSuccess on a Left'),
      (success) => success,
    );
  }

  /// Get the failure value if present, otherwise throw
  L getFailure() {
    return fold(
      (failure) => failure,
      (success) => throw Exception('Called getFailure on a Right'),
    );
  }

  /// Get the success value if present, otherwise return null
  R? getSuccessOrNull() {
    return fold((failure) => null, (success) => success);
  }

  /// Get the failure value if present, otherwise return null
  L? getFailureOrNull() {
    return fold((failure) => failure, (success) => null);
  }

  @override
  List<Object?> get props => [];
}

/// Represents a successful result (Right side)
class Right<L, R> extends Result<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(T Function(L failure) onLeft, T Function(R success) onRight) {
    return onRight(value);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Right($value)';
}

/// Represents a failed result (Left side)
class Left<L, R> extends Result<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(T Function(L failure) onLeft, T Function(R success) onRight) {
    return onLeft(value);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Left($value)';
}
