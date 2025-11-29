/// Base class for all failures in the application
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Network/connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
