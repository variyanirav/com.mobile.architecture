import 'package:core/error/failures.dart';
import 'package:core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failures', () {
    test('ServerFailure can be created', () {
      const failure = ServerFailure('Server error');
      expect(failure.message, 'Server error');
      expect(failure.code, null);
    });

    test('ServerFailure with code', () {
      const failure = ServerFailure('Server error', code: '500');
      expect(failure.message, 'Server error');
      expect(failure.code, '500');
    });

    test('NetworkFailure can be created', () {
      const failure = NetworkFailure('No internet connection');
      expect(failure.message, 'No internet connection');
    });

    test('AuthenticationFailure can be created', () {
      const failure = AuthenticationFailure('Invalid credentials');
      expect(failure.message, 'Invalid credentials');
    });

    test('ValidationFailure can be created', () {
      const failure = ValidationFailure('Email is required');
      expect(failure.message, 'Email is required');
    });

    test('CacheFailure can be created', () {
      const failure = CacheFailure('Failed to read cache');
      expect(failure.message, 'Failed to read cache');
    });

    test('UnknownFailure can be created', () {
      const failure = UnknownFailure('Something went wrong');
      expect(failure.message, 'Something went wrong');
    });

    test('Failure toString includes message', () {
      const failure = ValidationFailure('Email is required');
      expect(failure.toString(), contains('Email is required'));
    });

    test('Failure toString includes code when present', () {
      const failure = ServerFailure('Error', code: 'ERR_500');
      expect(failure.toString(), contains('ERR_500'));
    });
  });

  group('Result - Right (Success)', () {
    test('can create Right with value', () {
      const result = Right<Failure, String>('Success');
      expect(result.value, 'Success');
    });

    test('isSuccess returns true for Right', () {
      const result = Right<Failure, String>('Success');
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
    });

    test('fold calls onRight for Right', () {
      const result = Right<Failure, String>('Success');
      final output = result.fold(
        (failure) => 'Failed',
        (success) => 'Got: $success',
      );
      expect(output, 'Got: Success');
    });

    test('getSuccess returns value for Right', () {
      const result = Right<Failure, String>('Success');
      expect(result.getSuccess(), 'Success');
    });

    test('getSuccessOrNull returns value for Right', () {
      const result = Right<Failure, String>('Success');
      expect(result.getSuccessOrNull(), 'Success');
    });

    test('getFailure throws for Right', () {
      const result = Right<Failure, String>('Success');
      expect(() => result.getFailure(), throwsException);
    });

    test('getFailureOrNull returns null for Right', () {
      const result = Right<Failure, String>('Success');
      expect(result.getFailureOrNull(), null);
    });
  });

  group('Result - Left (Failure)', () {
    test('can create Left with failure', () {
      const failure = ValidationFailure('Error');
      const result = Left<Failure, String>(failure);
      expect(result.value, failure);
    });

    test('isFailure returns true for Left', () {
      const result = Left<Failure, String>(ValidationFailure('Error'));
      expect(result.isFailure, true);
      expect(result.isSuccess, false);
    });

    test('fold calls onLeft for Left', () {
      const result = Left<Failure, String>(ValidationFailure('Error'));
      final output = result.fold(
        (failure) => 'Error: ${failure.message}',
        (success) => 'Success: $success',
      );
      expect(output, 'Error: Error');
    });

    test('getFailure returns value for Left', () {
      const failure = ValidationFailure('Error');
      const result = Left<Failure, String>(failure);
      expect(result.getFailure(), failure);
    });

    test('getFailureOrNull returns value for Left', () {
      const failure = ValidationFailure('Error');
      const result = Left<Failure, String>(failure);
      expect(result.getFailureOrNull(), failure);
    });

    test('getSuccess throws for Left', () {
      const result = Left<Failure, String>(ValidationFailure('Error'));
      expect(() => result.getSuccess(), throwsException);
    });

    test('getSuccessOrNull returns null for Left', () {
      const result = Left<Failure, String>(ValidationFailure('Error'));
      expect(result.getSuccessOrNull(), null);
    });
  });

  group('Result - Equality', () {
    test('two Rights with same value are equal', () {
      const result1 = Right<Failure, String>('Success');
      const result2 = Right<Failure, String>('Success');
      expect(result1, equals(result2));
    });

    test('two Lefts with same failure are equal', () {
      const failure = ValidationFailure('Error');
      const result1 = Left<Failure, String>(failure);
      const result2 = Left<Failure, String>(failure);
      expect(result1, equals(result2));
    });

    test('Right and Left are not equal', () {
      const right = Right<Failure, String>('Success');
      const left = Left<Failure, String>(ValidationFailure('Error'));
      expect(right, isNot(equals(left)));
    });
  });

  group('Result - Real-world Scenarios', () {
    test('simulating successful login', () {
      Result<Failure, String> result = const Right('user@example.com');

      final message = result.fold(
        (failure) => 'Login failed: ${failure.message}',
        (email) => 'Logged in as: $email',
      );

      expect(message, 'Logged in as: user@example.com');
      expect(result.isSuccess, true);
    });

    test('simulating failed login - validation', () {
      Result<Failure, String> result =
          const Left(ValidationFailure('Email is required'));

      final message = result.fold(
        (failure) => 'Login failed: ${failure.message}',
        (email) => 'Logged in as: $email',
      );

      expect(message, 'Login failed: Email is required');
      expect(result.isFailure, true);
    });

    test('simulating failed login - authentication', () {
      Result<Failure, String> result =
          const Left(AuthenticationFailure('Invalid credentials'));

      final message = result.fold(
        (failure) => 'Login failed: ${failure.message}',
        (email) => 'Logged in as: $email',
      );

      expect(message, 'Login failed: Invalid credentials');
      expect(result.isFailure, true);
    });

    test('simulating network error', () {
      Result<Failure, String> result =
          const Left(NetworkFailure('No internet connection'));

      if (result.isFailure) {
        final failure = result.getFailure();
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, 'No internet connection');
      }
    });

    test('chaining operations with Result', () {
      Result<Failure, int> step1 = const Right(5);

      final result = step1.fold(
        (failure) => Left<Failure, int>(failure),
        (value) => Right<Failure, int>(value * 2),
      );

      expect(result.getSuccess(), 10);
    });
  });
}
