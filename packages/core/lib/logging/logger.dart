/// Abstract logger interface
///
/// Defines the contract for logging in the application.
/// Implementations can log to console, file, remote service, etc.
abstract class Logger {
  /// Log debug information
  void debug(String message, {Object? error, StackTrace? stackTrace});

  /// Log informational messages
  void info(String message, {Object? error, StackTrace? stackTrace});

  /// Log warning messages
  void warning(String message, {Object? error, StackTrace? stackTrace});

  /// Log error messages
  void error(String message, {Object? error, StackTrace? stackTrace});

  /// Log fatal errors
  void fatal(String message, {Object? error, StackTrace? stackTrace});
}

/// Log levels for filtering
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal;

  /// Returns the emoji representation of the log level
  String get emoji {
    switch (this) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.fatal:
        return '💀';
    }
  }

  /// Returns the name of the log level
  String get name {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }
}
