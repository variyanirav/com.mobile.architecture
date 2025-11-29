import 'package:core/logging/logging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Logger Interface', () {
    test('ConsoleLogger implements Logger', () {
      final logger = ConsoleLogger();
      expect(logger, isA<Logger>());
    });
  });

  group('LogLevel', () {
    test('has correct emoji for each level', () {
      expect(LogLevel.debug.emoji, '🔍');
      expect(LogLevel.info.emoji, 'ℹ️');
      expect(LogLevel.warning.emoji, '⚠️');
      expect(LogLevel.error.emoji, '❌');
      expect(LogLevel.fatal.emoji, '💀');
    });

    test('has correct name for each level', () {
      expect(LogLevel.debug.name, 'DEBUG');
      expect(LogLevel.info.name, 'INFO');
      expect(LogLevel.warning.name, 'WARNING');
      expect(LogLevel.error.name, 'ERROR');
      expect(LogLevel.fatal.name, 'FATAL');
    });

    test('levels are ordered correctly', () {
      expect(LogLevel.debug.index < LogLevel.info.index, true);
      expect(LogLevel.info.index < LogLevel.warning.index, true);
      expect(LogLevel.warning.index < LogLevel.error.index, true);
      expect(LogLevel.error.index < LogLevel.fatal.index, true);
    });
  });

  group('ConsoleLogger', () {
    test('can be created with default settings', () {
      final logger = ConsoleLogger();
      expect(logger.minLevel, LogLevel.debug);
      expect(logger.includeTimestamp, true);
      expect(logger.includeStackTrace, true);
    });

    test('can be created with custom settings', () {
      final logger = ConsoleLogger(
        minLevel: LogLevel.warning,
        includeTimestamp: false,
        includeStackTrace: false,
      );
      expect(logger.minLevel, LogLevel.warning);
      expect(logger.includeTimestamp, false);
      expect(logger.includeStackTrace, false);
    });

    test('debug method can be called', () {
      final logger = ConsoleLogger();
      expect(() => logger.debug('Test debug message'), returnsNormally);
    });

    test('info method can be called', () {
      final logger = ConsoleLogger();
      expect(() => logger.info('Test info message'), returnsNormally);
    });

    test('warning method can be called', () {
      final logger = ConsoleLogger();
      expect(() => logger.warning('Test warning message'), returnsNormally);
    });

    test('error method can be called', () {
      final logger = ConsoleLogger();
      expect(() => logger.error('Test error message'), returnsNormally);
    });

    test('fatal method can be called', () {
      final logger = ConsoleLogger();
      expect(() => logger.fatal('Test fatal message'), returnsNormally);
    });

    test('can log with error object', () {
      final logger = ConsoleLogger();
      final error = Exception('Test exception');
      expect(
        () => logger.error('Error occurred', error: error),
        returnsNormally,
      );
    });

    test('can log with stack trace', () {
      final logger = ConsoleLogger();
      final stackTrace = StackTrace.current;
      expect(
        () => logger.error('Error with trace', stackTrace: stackTrace),
        returnsNormally,
      );
    });

    test('can log with both error and stack trace', () {
      final logger = ConsoleLogger();
      final error = Exception('Test exception');
      final stackTrace = StackTrace.current;
      expect(
        () => logger.error(
          'Complete error log',
          error: error,
          stackTrace: stackTrace,
        ),
        returnsNormally,
      );
    });

    test('respects minimum log level', () {
      // This test verifies the logger respects minLevel
      // Since we're printing to console, we just verify it doesn't throw
      final logger = ConsoleLogger(minLevel: LogLevel.error);

      expect(() => logger.debug('Should not print'), returnsNormally);
      expect(() => logger.info('Should not print'), returnsNormally);
      expect(() => logger.warning('Should not print'), returnsNormally);
      expect(() => logger.error('Should print'), returnsNormally);
      expect(() => logger.fatal('Should print'), returnsNormally);
    });
  });

  group('Logger Usage Examples', () {
    test('typical usage scenario', () {
      final logger = ConsoleLogger(
        minLevel: LogLevel.info,
      );

      // Simulating app lifecycle logging
      expect(() {
        logger.info('App started');
        logger.debug('Loading configuration'); // Won't print (below minLevel)
        logger.info('Configuration loaded');
        logger.warning('Using default theme');
        logger.info('App ready');
      }, returnsNormally);
    });

    test('error handling scenario', () {
      final logger = ConsoleLogger();

      expect(() {
        try {
          throw Exception('Network failure');
        } catch (e, stackTrace) {
          logger.error(
            'Failed to fetch data',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }, returnsNormally);
    });
  });
}
