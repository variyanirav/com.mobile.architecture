import 'logger.dart';

/// Console implementation of Logger
///
/// Prints log messages to the console with formatting.
/// Useful for development and debugging.
class ConsoleLogger implements Logger {
  /// Minimum log level to display
  final LogLevel minLevel;

  /// Include timestamp in logs
  final bool includeTimestamp;

  /// Include stack trace for errors
  final bool includeStackTrace;

  ConsoleLogger({
    this.minLevel = LogLevel.debug,
    this.includeTimestamp = true,
    this.includeStackTrace = true,
  });

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  @override
  void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, error: error, stackTrace: stackTrace);
  }

  /// Internal method to log messages
  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Filter by minimum level
    if (level.index < minLevel.index) {
      return;
    }

    final buffer = StringBuffer();

    // Add timestamp
    if (includeTimestamp) {
      final now = DateTime.now();
      buffer.write('[${now.toIso8601String()}] ');
    }

    // Add level indicator
    buffer.write('${level.emoji} ${level.name}: ');

    // Add message
    buffer.write(message);

    // Add error if present
    if (error != null) {
      buffer.write('\n  Error: $error');
    }

    // Add stack trace if present and enabled
    if (includeStackTrace && stackTrace != null) {
      buffer.write('\n  StackTrace:\n$stackTrace');
    }

    // Print to console
    // ignore: avoid_print
    print(buffer.toString());
  }
}
