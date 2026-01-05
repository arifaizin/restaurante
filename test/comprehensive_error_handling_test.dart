import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/review_submission_provider.dart';
import 'package:restaurant_app/widgets/review_submission_form.dart';
import 'package:restaurant_app/services/api_service.dart';
import 'package:restaurant_app/model/review_submission_response.dart';
import 'package:restaurant_app/services/api_response.dart';
import 'package:restaurant_app/model/review_submission_request.dart';
import 'package:restaurant_app/util/error_helper.dart';

// Mock API Service for comprehensive error testing
class MockApiServiceForErrorTesting extends ApiService {
  String? errorToThrow;
  bool shouldSucceed;
  Duration? customDelay;

  MockApiServiceForErrorTesting({
    this.errorToThrow,
    this.shouldSucceed = false,
    this.customDelay,
  });

  @override
  Future<ApiResponse<ReviewSubmissionResponse>> submitReview(
    ReviewSubmissionRequest request,
  ) async {
    if (customDelay != null) {
      await Future.delayed(customDelay!);
    } else {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (shouldSucceed) {
      final response = ReviewSubmissionResponse(
        error: false,
        message: 'Review added successfully',
        customerReviews: [],
      );
      return ApiResponse.success(response, message: 'Success');
    } else {
      if (errorToThrow != null) {
        throw Exception(errorToThrow!);
      }
      final response = ReviewSubmissionResponse(
        error: true,
        message: errorToThrow ?? 'Submission failed',
        customerReviews: [],
      );
      return ApiResponse.failure(
        errorToThrow ?? 'Submission failed',
        data: response,
      );
    }
  }

  @override
  void dispose() {
    // Mock implementation
  }
}

void main() {
  group('Comprehensive Error Handling Tests', () {
    late MockApiServiceForErrorTesting mockApiService;
    late ReviewSubmissionProvider provider;

    setUp(() {
      mockApiService = MockApiServiceForErrorTesting();
      provider = ReviewSubmissionProvider(apiService: mockApiService);
    });

    tearDown(() {
      provider.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ReviewSubmissionProvider>.value(
            value: provider,
            child: const ReviewSubmissionForm(
              restaurantId: 'test-restaurant-id',
            ),
          ),
        ),
      );
    }

    group('Network Error Handling', () {
      testWidgets('should handle SocketException with proper UI feedback', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'SocketException: Connection refused';
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify network error handling
        expect(provider.isNetworkError, isTrue);
        expect(provider.lastErrorType, ErrorType.network);
        expect(provider.submissionError, contains('koneksi internet'));

        // Verify UI shows network-specific error styling
        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
        expect(find.text('Masalah Koneksi'), findsOneWidget);
        expect(find.text('Bantuan'), findsOneWidget);
        expect(find.text('Coba Lagi'), findsOneWidget);
      });

      testWidgets('should show network troubleshooting dialog', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'SocketException: Network unreachable';
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit to trigger network error
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Tap help button
        await tester.tap(find.text('Bantuan'));
        await tester.pump();

        // Verify troubleshooting dialog appears
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.text('Masalah Koneksi'),
          findsNWidgets(2),
        ); // Title in both error and dialog
        expect(
          find.text('Periksa koneksi Wi-Fi atau data seluler'),
          findsOneWidget,
        );
        expect(find.text('Pastikan sinyal internet stabil'), findsOneWidget);
        expect(
          find.text('Coba tutup dan buka kembali aplikasi'),
          findsOneWidget,
        );
        expect(
          find.text('Periksa pengaturan jaringan perangkat'),
          findsOneWidget,
        );
      });

      testWidgets('should retry from troubleshooting dialog', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'SocketException: Network unreachable';
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit to trigger network error
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Open troubleshooting dialog
        await tester.tap(find.text('Bantuan'));
        await tester.pump();

        // Make next attempt succeed
        mockApiService.shouldSucceed = true;
        mockApiService.errorToThrow = null;

        // Tap retry in dialog
        await tester.tap(find.text('Coba Lagi').last);
        await tester.pump(const Duration(milliseconds: 100));

        // Verify success
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });
    });

    group('Timeout Error Handling', () {
      testWidgets('should handle timeout errors with proper UI feedback', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow =
            'TimeoutException: Request timeout after 10 seconds';
        mockApiService.shouldSucceed = false;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify timeout error handling
        expect(provider.lastErrorType, ErrorType.timeout);
        expect(provider.submissionError, contains('lambat'));

        // Verify UI shows timeout-specific styling
        expect(find.byIcon(Icons.access_time), findsOneWidget);
        expect(find.text('Koneksi Lambat'), findsOneWidget);
      });
    });

    group('Server Error Handling', () {
      testWidgets('should handle server errors with proper UI feedback', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'HTTP 500 Internal Server Error';
        mockApiService.shouldSucceed = false;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify server error handling
        expect(provider.lastErrorType, ErrorType.server);
        expect(provider.submissionError, contains('Server'));

        // Verify UI shows server-specific styling
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Masalah Server'), findsOneWidget);
      });

      testWidgets('should handle different server error codes', (
        WidgetTester tester,
      ) async {
        final serverErrors = [
          'HTTP 502 Bad Gateway',
          'HTTP 503 Service Unavailable',
          'Server error occurred',
        ];

        for (final error in serverErrors) {
          mockApiService.errorToThrow = error;
          mockApiService.shouldSucceed = false;
          provider.resetState();

          await tester.pumpWidget(createTestWidget());

          // Fill form and submit
          await tester.enterText(find.byType(TextFormField).first, 'John Doe');
          await tester.enterText(
            find.byType(TextFormField).last,
            'Great restaurant!',
          );
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump(const Duration(milliseconds: 100));

          // Verify server error is detected
          expect(
            provider.lastErrorType,
            ErrorType.server,
            reason: 'Failed for error: $error',
          );
          expect(
            provider.submissionError,
            contains('Server'),
            reason: 'Failed for error: $error',
          );

          // Clear for next iteration
          provider.clearError();
          await tester.pump();
        }
      });
    });

    group('Validation Error Handling', () {
      testWidgets('should handle validation errors with proper UI feedback', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow =
            'Validation failed: Invalid data provided';
        mockApiService.shouldSucceed = false;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify validation error handling
        expect(provider.lastErrorType, ErrorType.validation);
        expect(provider.isValidationError, isTrue);
        expect(provider.submissionError, contains('valid'));

        // Verify UI shows validation-specific styling
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
        expect(find.text('Data Tidak Valid'), findsOneWidget);
      });
    });

    group('Authentication Error Handling', () {
      testWidgets('should handle authentication errors as non-retryable', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'HTTP 401 Unauthorized';
        mockApiService.shouldSucceed = false;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify authentication error handling
        expect(provider.lastErrorType, ErrorType.authentication);
        expect(provider.isRetryable, isFalse);
        expect(provider.submissionError, contains('Akses ditolak'));

        // Verify no retry button is shown for non-retryable errors
        expect(find.text('Coba Lagi'), findsNothing);
        expect(find.text('Kirim Ulang'), findsNothing);

        // Verify guidance message is shown
        expect(find.textContaining('administrator'), findsOneWidget);
      });
    });

    group('Not Found Error Handling', () {
      testWidgets('should handle not found errors as non-retryable', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'HTTP 404 Not Found';
        mockApiService.shouldSucceed = false;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify not found error handling
        expect(provider.lastErrorType, ErrorType.notFound);
        expect(provider.isRetryable, isFalse);
        expect(provider.submissionError, contains('tidak ditemukan'));

        // Verify guidance message is shown
        expect(find.textContaining('tidak tersedia'), findsOneWidget);
      });
    });

    group('Format Error Handling', () {
      testWidgets('should handle format/parsing errors', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'FormatException: Invalid JSON format';
        mockApiService.shouldSucceed = false;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify format error handling
        expect(provider.lastErrorType, ErrorType.format);
        expect(provider.submissionError, contains('valid'));
      });
    });

    group('Security Error Handling', () {
      testWidgets('should handle SSL/certificate errors', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow =
            'HandshakeException: SSL certificate error';
        mockApiService.shouldSucceed = false;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify security error handling
        expect(provider.lastErrorType, ErrorType.security);
        expect(provider.submissionError, contains('keamanan'));
      });
    });

    group('Success Message Variations', () {
      testWidgets('should show varied success messages', (
        WidgetTester tester,
      ) async {
        mockApiService.shouldSucceed = true;
        final successMessages = <String>{};

        // Test multiple submissions to collect different success messages
        for (int i = 0; i < 10; i++) {
          provider.resetState();
          await tester.pumpWidget(createTestWidget());

          // Fill form and submit
          await tester.enterText(find.byType(TextFormField).first, 'John Doe');
          await tester.enterText(
            find.byType(TextFormField).last,
            'Great restaurant!',
          );
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump(const Duration(milliseconds: 100));

          // Collect success message
          if (provider.successMessage != null) {
            successMessages.add(provider.successMessage!);
          }

          // Clear form for next iteration
          provider.clearSuccessMessage();
          await tester.pump();

          // Add small delay to ensure different timestamps
          await Future.delayed(const Duration(milliseconds: 10));
        }

        // Verify we got varied success messages
        expect(successMessages.length, greaterThan(1));
        expect(
          successMessages.every((msg) => msg.contains('berhasil')),
          isTrue,
        );
      });
    });

    group('Error Message Clearing', () {
      testWidgets('should clear error when user starts typing', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'Network error';
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit to trigger error
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify error is shown
        expect(provider.hasSubmissionError, isTrue);
        expect(find.textContaining('koneksi'), findsOneWidget);

        // Start typing in name field
        await tester.enterText(find.byType(TextFormField).first, 'Jane Doe');
        await tester.pump();

        // Verify error is cleared
        expect(provider.hasSubmissionError, isFalse);
        expect(find.textContaining('koneksi'), findsNothing);
      });

      testWidgets('should clear error when close button is tapped', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'Server error';
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit to trigger error
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify error is shown
        expect(provider.hasSubmissionError, isTrue);

        // Tap close button
        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();

        // Verify error is cleared
        expect(provider.hasSubmissionError, isFalse);
      });
    });

    group('Retry Functionality', () {
      testWidgets('should retry submission from error banner', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'Network timeout';
        mockApiService.shouldSucceed = false;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit to trigger error
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify error is shown with retry button
        expect(provider.hasSubmissionError, isTrue);
        expect(find.text('Coba Lagi'), findsOneWidget);

        // Make next attempt succeed
        mockApiService.shouldSucceed = true;
        mockApiService.errorToThrow = null;

        // Tap retry button
        await tester.tap(find.text('Coba Lagi'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify success
        expect(provider.hasSuccessMessage, isTrue);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should maintain form data during retry', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'Temporary error';
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit to trigger error
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant experience!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify error and form data preservation
        expect(provider.hasSubmissionError, isTrue);
        expect(provider.reviewerName, 'John Doe');
        expect(provider.reviewText, 'Great restaurant experience!');

        // Verify form fields still contain data
        final nameField = tester.widget<TextFormField>(
          find.byType(TextFormField).first,
        );
        final reviewField = tester.widget<TextFormField>(
          find.byType(TextFormField).last,
        );

        expect(nameField.controller?.text, 'John Doe');
        expect(reviewField.controller?.text, 'Great restaurant experience!');
      });
    });

    group('Visual Feedback and Styling', () {
      testWidgets('should use appropriate colors for different error types', (
        WidgetTester tester,
      ) async {
        final errorTests = {
          'SocketException: Network error': {
            'type': ErrorType.network,
            'icon': Icons.wifi_off,
          },
          'TimeoutException: Timeout': {
            'type': ErrorType.timeout,
            'icon': Icons.access_time,
          },
          'HTTP 500 Server Error': {
            'type': ErrorType.server,
            'icon': Icons.error_outline,
          },
          'Validation failed': {
            'type': ErrorType.validation,
            'icon': Icons.info_outline,
          },
        };

        for (final entry in errorTests.entries) {
          final errorMessage = entry.key;
          final expectedType = entry.value['type'] as ErrorType;
          final expectedIcon = entry.value['icon'] as IconData;

          mockApiService.errorToThrow = errorMessage;
          mockApiService.shouldSucceed = false;
          provider.resetState();

          await tester.pumpWidget(createTestWidget());

          // Fill form and submit
          await tester.enterText(find.byType(TextFormField).first, 'John Doe');
          await tester.enterText(
            find.byType(TextFormField).last,
            'Great restaurant!',
          );
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump(const Duration(milliseconds: 100));

          // Verify correct error type and icon
          expect(
            provider.lastErrorType,
            expectedType,
            reason: 'Failed for error: $errorMessage',
          );
          expect(
            find.byIcon(expectedIcon),
            findsOneWidget,
            reason: 'Failed for error: $errorMessage',
          );

          // Clear for next iteration
          provider.clearError();
          await tester.pump();
        }
      });

      testWidgets('should show enhanced success feedback with animation', (
        WidgetTester tester,
      ) async {
        mockApiService.shouldSucceed = true;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify success snackbar with proper styling
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.text('Berhasil!'), findsOneWidget);

        // Verify snackbar has proper styling
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.green.shade600);
        expect(snackBar.behavior, SnackBarBehavior.floating);
        expect(snackBar.duration, const Duration(seconds: 4));
      });
    });

    group('Accessibility and User Experience', () {
      testWidgets(
        'should provide proper accessibility labels for error states',
        (WidgetTester tester) async {
          mockApiService.errorToThrow = 'Network error';
          await tester.pumpWidget(createTestWidget());

          // Fill form and submit to trigger error
          await tester.enterText(find.byType(TextFormField).first, 'John Doe');
          await tester.enterText(
            find.byType(TextFormField).last,
            'Great restaurant!',
          );
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump(const Duration(milliseconds: 100));

          // Verify error message is accessible
          expect(find.text('Masalah Koneksi'), findsOneWidget);
          expect(find.byIcon(Icons.wifi_off), findsOneWidget);

          // Verify retry button is accessible
          expect(find.text('Coba Lagi'), findsOneWidget);
        },
      );

      testWidgets('should handle rapid successive submissions gracefully', (
        WidgetTester tester,
      ) async {
        mockApiService.customDelay = const Duration(milliseconds: 200);
        mockApiService.shouldSucceed = true;
        await tester.pumpWidget(createTestWidget());

        // Fill form
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );

        // Tap submit button once
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 50));

        // Verify submission is in progress
        expect(provider.isSubmitting, isTrue);
        expect(find.text('Mengirim...'), findsOneWidget);

        // Verify button is disabled (can't tap it again)
        final submitButton = find.byType(ElevatedButton);
        final buttonWidget = tester.widget<ElevatedButton>(submitButton);
        expect(buttonWidget.onPressed, isNull);

        // Wait for submission to complete
        await tester.pump(const Duration(milliseconds: 300));

        // Verify submission completed properly
        expect(provider.isSubmitting, isFalse);
      });
    });

    group('Edge Cases and Error Recovery', () {
      testWidgets('should handle null or empty error messages gracefully', (
        WidgetTester tester,
      ) async {
        // Test with null error
        mockApiService.errorToThrow = null;
        mockApiService.shouldSucceed = false;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify generic error handling
        expect(provider.hasSubmissionError, isTrue);
        expect(provider.submissionError, contains('Gagal mengirim ulasan'));
      });

      testWidgets('should recover from error state when form is cleared', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToThrow = 'Network error';
        mockApiService.shouldSucceed = false;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit to trigger error
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify error state
        expect(provider.hasSubmissionError, isTrue);

        // Clear form programmatically
        provider.clearForm();
        await tester.pump();

        // Verify form is cleared but error state remains until user interaction
        expect(provider.reviewerName, isEmpty);
        expect(provider.reviewText, isEmpty);
        expect(provider.hasSubmissionError, isTrue);

        // Start typing to clear error
        await tester.enterText(find.byType(TextFormField).first, 'Jane');
        await tester.pump();

        // Verify error is cleared
        expect(provider.hasSubmissionError, isFalse);
      });
    });
  });
}
