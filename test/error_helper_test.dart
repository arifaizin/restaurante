import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/util/error_helper.dart';

void main() {
  group('ErrorHelper', () {
    group('getUserFriendlyMessage', () {
      test('should return generic message for null error', () {
        final message = ErrorHelper.getUserFriendlyMessage(null);
        expect(message, 'Terjadi kesalahan yang tidak diketahui');
      });

      test('should return generic message for empty error', () {
        final message = ErrorHelper.getUserFriendlyMessage('');
        expect(message, 'Terjadi kesalahan yang tidak diketahui');
      });

      test('should identify network errors', () {
        final testCases = [
          'SocketException: Failed to connect',
          'No internet connection available',
          'Network error occurred',
          'Host lookup failed',
          'No address associated with hostname',
        ];

        for (final error in testCases) {
          final message = ErrorHelper.getUserFriendlyMessage(error);
          expect(message, contains('koneksi internet'));
        }
      });

      test('should identify timeout errors', () {
        final testCases = [
          'TimeoutException: Connection timeout',
          'Request timed out',
          'Deadline exceeded',
        ];

        for (final error in testCases) {
          final message = ErrorHelper.getUserFriendlyMessage(error);
          expect(message, contains('lambat'));
        }
      });

      test('should identify server errors', () {
        final testCases = [
          'HTTP 500 Internal Server Error',
          'Server error occurred',
          'HTTP 502 Bad Gateway',
          'HTTP 503 Service Unavailable',
        ];

        for (final error in testCases) {
          final message = ErrorHelper.getUserFriendlyMessage(error);
          expect(message, contains('Server'));
        }
      });

      test('should identify validation errors', () {
        final testCases = [
          'Validation failed',
          'Invalid data provided',
          'Required field missing',
          'Nama tidak boleh kosong',
        ];

        for (final error in testCases) {
          final message = ErrorHelper.getUserFriendlyMessage(error);
          expect(message, contains('valid'));
        }
      });

      test('should identify format errors', () {
        final testCases = [
          'FormatException: Invalid JSON',
          'Failed to parse response',
          'Invalid format',
        ];

        for (final error in testCases) {
          final message = ErrorHelper.getUserFriendlyMessage(error);
          expect(message, contains('valid'));
        }
      });
    });

    group('getErrorInfo', () {
      test('should return correct error type for network errors', () {
        final errorInfo = ErrorHelper.getErrorInfo('SocketException: Failed');
        expect(errorInfo.type, ErrorType.network);
        expect(errorInfo.isRetryable, true);
        expect(errorInfo.actionGuidance, isNotNull);
      });

      test('should return correct error type for timeout errors', () {
        final errorInfo = ErrorHelper.getErrorInfo('TimeoutException');
        expect(errorInfo.type, ErrorType.timeout);
        expect(errorInfo.isRetryable, true);
      });

      test('should return correct error type for server errors', () {
        final errorInfo = ErrorHelper.getErrorInfo('HTTP 500 Error');
        expect(errorInfo.type, ErrorType.server);
        expect(errorInfo.isRetryable, true);
      });

      test('should return correct error type for validation errors', () {
        final errorInfo = ErrorHelper.getErrorInfo('Validation failed');
        expect(errorInfo.type, ErrorType.validation);
        expect(errorInfo.isRetryable, true);
      });

      test('should return correct error type for not found errors', () {
        final errorInfo = ErrorHelper.getErrorInfo('HTTP 404 Not Found');
        expect(errorInfo.type, ErrorType.notFound);
        expect(errorInfo.isRetryable, false);
      });

      test('should return correct error type for authentication errors', () {
        final errorInfo = ErrorHelper.getErrorInfo('HTTP 401 Unauthorized');
        expect(errorInfo.type, ErrorType.authentication);
        expect(errorInfo.isRetryable, false);
      });

      test('should include technical message in error info', () {
        const technicalError = 'SocketException: Connection refused';
        final errorInfo = ErrorHelper.getErrorInfo(technicalError);
        expect(errorInfo.technicalMessage, technicalError);
      });
    });

    group('isNetworkError', () {
      test('should return true for network errors', () {
        expect(ErrorHelper.isNetworkError('SocketException'), true);
        expect(ErrorHelper.isNetworkError('No internet connection'), true);
        expect(ErrorHelper.isNetworkError('Network error'), true);
      });

      test('should return false for non-network errors', () {
        expect(ErrorHelper.isNetworkError('HTTP 500 Error'), false);
        expect(ErrorHelper.isNetworkError('Validation failed'), false);
        expect(ErrorHelper.isNetworkError(null), false);
      });
    });

    group('isRetryableError', () {
      test('should return true for retryable errors', () {
        expect(ErrorHelper.isRetryableError('SocketException'), true);
        expect(ErrorHelper.isRetryableError('TimeoutException'), true);
        expect(ErrorHelper.isRetryableError('HTTP 500 Error'), true);
      });

      test('should return false for non-retryable errors', () {
        expect(ErrorHelper.isRetryableError('HTTP 404 Not Found'), false);
        expect(ErrorHelper.isRetryableError('HTTP 401 Unauthorized'), false);
      });

      test('should return true for null error', () {
        expect(ErrorHelper.isRetryableError(null), true);
      });
    });

    group('getReviewSubmissionErrorMessage', () {
      test('should return specific message for network errors', () {
        final message = ErrorHelper.getReviewSubmissionErrorMessage(
            'SocketException: Connection failed');
        expect(message, contains('koneksi internet'));
        expect(message, contains('ulasan'));
      });

      test('should return specific message for timeout errors', () {
        final message =
            ErrorHelper.getReviewSubmissionErrorMessage('TimeoutException');
        expect(message, contains('lambat'));
        expect(message, contains('ulasan'));
      });

      test('should return specific message for server errors', () {
        final message =
            ErrorHelper.getReviewSubmissionErrorMessage('HTTP 500 Error');
        expect(message, contains('Server'));
        expect(message, contains('Ulasan'));
      });

      test('should return specific message for validation errors', () {
        final message =
            ErrorHelper.getReviewSubmissionErrorMessage('Validation failed');
        expect(message, contains('valid'));
        expect(message, contains('ulasan'));
      });

      test('should return generic message for null error', () {
        final message = ErrorHelper.getReviewSubmissionErrorMessage(null);
        expect(message, contains('Gagal mengirim ulasan'));
      });
    });

    group('getReviewSubmissionSuccessMessage', () {
      test('should return a success message', () {
        final message = ErrorHelper.getReviewSubmissionSuccessMessage();
        expect(message, isNotEmpty);
        expect(message, contains('berhasil'));
      });

      test('should return varied success messages', () {
        final messages = <String>{};
        // Generate multiple messages to check for variety
        for (int i = 0; i < 100; i++) {
          messages.add(ErrorHelper.getReviewSubmissionSuccessMessage());
          // Add small delay to ensure different microsecond values
          if (i % 10 == 0) {
            Future.delayed(const Duration(microseconds: 1));
          }
        }
        // Should have at least 2 different messages
        expect(messages.length, greaterThan(1));
      });
    });

    group('getValidationErrorMessage', () {
      test('should return error for empty name', () {
        final message = ErrorHelper.getValidationErrorMessage('name', '');
        expect(message, contains('Nama'));
        expect(message, contains('kosong'));
      });

      test('should return error for short name', () {
        final message = ErrorHelper.getValidationErrorMessage('name', 'A');
        expect(message, contains('pendek'));
        expect(message, contains('2 karakter'));
      });

      test('should return error for long name', () {
        final message = ErrorHelper.getValidationErrorMessage('name', 'A' * 51);
        expect(message, contains('panjang'));
        expect(message, contains('50 karakter'));
      });

      test('should return error for empty review', () {
        final message = ErrorHelper.getValidationErrorMessage('review', '');
        expect(message, contains('Ulasan'));
        expect(message, contains('kosong'));
      });

      test('should return error for short review', () {
        final message = ErrorHelper.getValidationErrorMessage('review', 'Good');
        expect(message, contains('pendek'));
        expect(message, contains('10 karakter'));
      });

      test('should return error for long review', () {
        final message =
            ErrorHelper.getValidationErrorMessage('review', 'A' * 501);
        expect(message, contains('panjang'));
        expect(message, contains('500 karakter'));
      });

      test('should handle case-insensitive field names', () {
        final message1 = ErrorHelper.getValidationErrorMessage('NAME', '');
        final message2 = ErrorHelper.getValidationErrorMessage('name', '');
        expect(message1, message2);
      });

      test('should return generic error for unknown field', () {
        final message = ErrorHelper.getValidationErrorMessage('unknown', '');
        expect(message, contains('tidak valid'));
      });
    });

    group('ErrorInfo', () {
      test('should create error info with all properties', () {
        const errorInfo = ErrorInfo(
          type: ErrorType.network,
          userMessage: 'Test message',
          technicalMessage: 'Technical details',
          isRetryable: true,
          actionGuidance: 'Try again',
        );

        expect(errorInfo.type, ErrorType.network);
        expect(errorInfo.userMessage, 'Test message');
        expect(errorInfo.technicalMessage, 'Technical details');
        expect(errorInfo.isRetryable, true);
        expect(errorInfo.actionGuidance, 'Try again');
      });

      test('should create error info with default values', () {
        const errorInfo = ErrorInfo(
          type: ErrorType.unknown,
          userMessage: 'Test message',
        );

        expect(errorInfo.type, ErrorType.unknown);
        expect(errorInfo.userMessage, 'Test message');
        expect(errorInfo.technicalMessage, null);
        expect(errorInfo.isRetryable, true);
        expect(errorInfo.actionGuidance, null);
      });
    });

    group('ErrorType enum', () {
      test('should have all expected error types', () {
        expect(ErrorType.values, contains(ErrorType.network));
        expect(ErrorType.values, contains(ErrorType.timeout));
        expect(ErrorType.values, contains(ErrorType.server));
        expect(ErrorType.values, contains(ErrorType.validation));
        expect(ErrorType.values, contains(ErrorType.authentication));
        expect(ErrorType.values, contains(ErrorType.notFound));
        expect(ErrorType.values, contains(ErrorType.format));
        expect(ErrorType.values, contains(ErrorType.security));
        expect(ErrorType.values, contains(ErrorType.unknown));
      });
    });

    group('Edge Cases and Advanced Error Handling', () {
      test('should handle mixed case error messages', () {
        final testCases = [
          'SOCKETEXCEPTION: CONNECTION FAILED',
          'Network Error Occurred',
          'HTTP 500 INTERNAL SERVER ERROR',
          'TimeOut Exception',
        ];

        for (final error in testCases) {
          final errorInfo = ErrorHelper.getErrorInfo(error);
          expect(errorInfo.type, isNot(ErrorType.unknown),
              reason: 'Should identify error type for: $error');
          expect(errorInfo.userMessage, isNotEmpty,
              reason: 'Should have user message for: $error');
        }
      });

      test('should handle error messages with special characters', () {
        final testCases = [
          'SocketException: Connection failed (OS Error: Connection refused, errno = 111)',
          'TimeoutException after 0:00:10.000000: Future not completed',
          'FormatException: Unexpected character (at character 1)\n{"error": true}\n^',
        ];

        for (final error in testCases) {
          final errorInfo = ErrorHelper.getErrorInfo(error);
          expect(errorInfo.userMessage, isNotEmpty,
              reason: 'Should handle special characters in: $error');
          expect(errorInfo.technicalMessage, equals(error),
              reason: 'Should preserve technical message for: $error');
        }
      });

      test('should provide actionable guidance for all error types', () {
        final errorTypes = {
          'SocketException': ErrorType.network,
          'TimeoutException': ErrorType.timeout,
          'HTTP 500': ErrorType.server,
          'HTTP 404': ErrorType.notFound,
          'HTTP 401': ErrorType.authentication,
          'Validation failed': ErrorType.validation,
          'FormatException': ErrorType.format,
          'Certificate error': ErrorType.security,
        };

        errorTypes.forEach((errorMessage, expectedType) {
          final errorInfo = ErrorHelper.getErrorInfo(errorMessage);
          expect(errorInfo.type, equals(expectedType),
              reason: 'Should identify correct type for: $errorMessage');
          expect(errorInfo.actionGuidance, isNotNull,
              reason: 'Should provide guidance for: $errorMessage');
          expect(errorInfo.actionGuidance!.isNotEmpty, isTrue,
              reason: 'Should provide non-empty guidance for: $errorMessage');
        });
      });

      test('should handle very long error messages', () {
        final longError = 'SocketException: ${'A' * 1000}';
        final errorInfo = ErrorHelper.getErrorInfo(longError);

        expect(errorInfo.type, ErrorType.network);
        expect(errorInfo.userMessage, isNotEmpty);
        expect(errorInfo.technicalMessage, equals(longError));
      });

      test('should handle error messages with newlines and tabs', () {
        const errorWithWhitespace =
            'Network\terror\noccurred\t\nConnection failed';
        final errorInfo = ErrorHelper.getErrorInfo(errorWithWhitespace);

        expect(errorInfo.type, ErrorType.network);
        expect(errorInfo.userMessage, contains('koneksi internet'));
      });
    });

    group('Review Submission Error Message Variations', () {
      test('should provide context-specific messages for review submission',
          () {
        final errorScenarios = {
          'SocketException: No route to host': 'koneksi internet',
          'TimeoutException: Connection timeout': 'lambat',
          'HTTP 500 Internal Server Error': 'Server',
          'HTTP 503 Service Unavailable': 'Server',
          'Validation failed: Name required': 'valid',
          'HTTP 401 Unauthorized': 'Akses ditolak',
          'FormatException: Invalid JSON': 'memproses',
          'Certificate verify failed': 'keamanan',
        };

        errorScenarios.forEach((errorMessage, expectedText) {
          final message =
              ErrorHelper.getReviewSubmissionErrorMessage(errorMessage);
          expect(message.toLowerCase(),
              anyOf([contains('ulasan'), contains('Ulasan')]),
              reason: 'Should mention review for: $errorMessage');
          expect(message, contains(expectedText),
              reason: 'Should contain expected text for: $errorMessage');
        });
      });

      test('should provide helpful guidance in review submission errors', () {
        final networkError = ErrorHelper.getReviewSubmissionErrorMessage(
            'SocketException: Connection refused');
        expect(networkError, contains('Periksa koneksi'));
        expect(networkError, contains('coba lagi'));

        final timeoutError = ErrorHelper.getReviewSubmissionErrorMessage(
            'TimeoutException: Request timeout');
        expect(timeoutError, contains('beberapa saat'));

        final serverError = ErrorHelper.getReviewSubmissionErrorMessage(
            'HTTP 500 Internal Server Error');
        expect(serverError, contains('nanti'));
      });
    });

    group('Validation Error Message Enhancements', () {
      test('should provide specific guidance for name validation', () {
        final emptyNameError =
            ErrorHelper.getValidationErrorMessage('name', '');
        expect(emptyNameError, contains('Nama tidak boleh kosong'));
        expect(emptyNameError, contains('Masukkan nama Anda'));

        final shortNameError =
            ErrorHelper.getValidationErrorMessage('name', 'A');
        expect(shortNameError, contains('terlalu pendek'));
        expect(shortNameError, contains('minimal 2 karakter'));

        final longNameError =
            ErrorHelper.getValidationErrorMessage('name', 'A' * 51);
        expect(longNameError, contains('terlalu panjang'));
        expect(longNameError, contains('Maksimal 50 karakter'));
      });

      test('should provide specific guidance for review validation', () {
        final emptyReviewError =
            ErrorHelper.getValidationErrorMessage('review', '');
        expect(emptyReviewError, contains('Ulasan tidak boleh kosong'));
        expect(emptyReviewError, contains('Bagikan pengalaman'));

        final shortReviewError =
            ErrorHelper.getValidationErrorMessage('review', 'Good');
        expect(shortReviewError, contains('terlalu pendek'));
        expect(shortReviewError, contains('minimal 10 karakter'));
        expect(shortReviewError, contains('feedback yang berguna'));

        final longReviewError =
            ErrorHelper.getValidationErrorMessage('review', 'A' * 501);
        expect(longReviewError, contains('terlalu panjang'));
        expect(longReviewError, contains('Maksimal 500 karakter'));
      });

      test('should handle whitespace-only input correctly', () {
        final whitespaceNameError =
            ErrorHelper.getValidationErrorMessage('name', '   ');
        expect(whitespaceNameError, contains('tidak boleh kosong'));

        final whitespaceReviewError =
            ErrorHelper.getValidationErrorMessage('review', '\t\n  ');
        expect(whitespaceReviewError, contains('tidak boleh kosong'));
      });
    });

    group('Success Message Variations and Quality', () {
      test('should provide varied and engaging success messages', () {
        final messages = <String>{};

        // Generate multiple messages to test variety with delays
        for (int i = 0; i < 100; i++) {
          messages.add(ErrorHelper.getReviewSubmissionSuccessMessage());
          // Add small delay to ensure different microsecond values
          if (i % 10 == 0) {
            Future.delayed(const Duration(microseconds: 1));
          }
        }

        // Should have multiple different messages
        expect(messages.length, greaterThanOrEqualTo(2));

        // All messages should be positive and contain key terms
        for (final message in messages) {
          expect(message, contains('berhasil'));
          expect(message.length, greaterThan(20)); // Should be descriptive
          expect(
              message,
              anyOf([
                contains('Terima kasih'),
                contains('ditambahkan'),
                contains('dikirim'),
                contains('feedback'),
                contains('pengalaman'),
              ]));
        }
      });

      test('should provide contextually appropriate success messages', () {
        final message = ErrorHelper.getReviewSubmissionSuccessMessage();

        // Should be encouraging and specific to review submission
        expect(
            message,
            anyOf([
              contains('ulasan'),
              contains('Ulasan'),
              contains('feedback'),
              contains('pengalaman'),
            ]));

        // Should express gratitude or confirmation
        expect(
            message,
            anyOf([
              contains('Terima kasih'),
              contains('berhasil'),
              contains('ditambahkan'),
              contains('dikirim'),
            ]));
      });
    });

    group('Error Helper Utility Methods', () {
      test('should correctly identify network errors', () {
        final networkErrors = [
          'SocketException: Connection refused',
          'No internet connection available',
          'Network unreachable',
          'Host lookup failed',
          'No address associated with hostname',
        ];

        for (final error in networkErrors) {
          expect(ErrorHelper.isNetworkError(error), isTrue,
              reason: 'Should identify as network error: $error');
        }

        final nonNetworkErrors = [
          'HTTP 500 Server Error',
          'TimeoutException',
          'Validation failed',
          null,
          '',
        ];

        for (final error in nonNetworkErrors) {
          expect(ErrorHelper.isNetworkError(error), isFalse,
              reason: 'Should not identify as network error: $error');
        }
      });

      test('should correctly identify retryable errors', () {
        final retryableErrors = [
          'SocketException: Connection refused',
          'TimeoutException: Request timeout',
          'HTTP 500 Internal Server Error',
          'HTTP 502 Bad Gateway',
          'HTTP 503 Service Unavailable',
          'FormatException: Invalid JSON',
          'Certificate error',
          null, // null should be retryable by default
        ];

        for (final error in retryableErrors) {
          expect(ErrorHelper.isRetryableError(error), isTrue,
              reason: 'Should be retryable: $error');
        }

        final nonRetryableErrors = [
          'HTTP 404 Not Found',
          'HTTP 401 Unauthorized',
          'HTTP 403 Forbidden',
        ];

        for (final error in nonRetryableErrors) {
          expect(ErrorHelper.isRetryableError(error), isFalse,
              reason: 'Should not be retryable: $error');
        }
      });
    });
  });
}
