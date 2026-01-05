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

// Mock API Service for enhanced error testing
class MockApiServiceForEnhancedTesting extends ApiService {
  String? errorToReturn;
  bool shouldSucceed;

  MockApiServiceForEnhancedTesting({
    this.errorToReturn,
    this.shouldSucceed = false,
  });

  @override
  Future<ApiResponse<ReviewSubmissionResponse>> submitReview(
    ReviewSubmissionRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));

    if (shouldSucceed) {
      final response = ReviewSubmissionResponse(
        error: false,
        message: 'Review added successfully',
        customerReviews: [],
      );
      return ApiResponse.success(response, message: 'Success');
    } else {
      final response = ReviewSubmissionResponse(
        error: true,
        message: errorToReturn ?? 'Submission failed',
        customerReviews: [],
      );
      return ApiResponse.failure(
        errorToReturn ?? 'Submission failed',
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
  group('Enhanced Error Handling Tests', () {
    late MockApiServiceForEnhancedTesting mockApiService;
    late ReviewSubmissionProvider provider;

    setUp(() {
      mockApiService = MockApiServiceForEnhancedTesting();
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

    group('Error Type Detection and User Feedback', () {
      testWidgets(
        'should detect network errors and show appropriate feedback',
        (WidgetTester tester) async {
          mockApiService.errorToReturn = 'SocketException: Connection refused';
          mockApiService.shouldSucceed = false;

          await tester.pumpWidget(createTestWidget());

          // Fill form and submit
          await tester.enterText(find.byType(TextFormField).first, 'John Doe');
          await tester.enterText(
            find.byType(TextFormField).last,
            'Great restaurant experience!',
          );
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump(const Duration(milliseconds: 100));

          // Verify network error detection
          expect(provider.lastErrorType, ErrorType.network);
          expect(provider.isNetworkError, isTrue);
          expect(provider.getErrorTitle(), 'Masalah Koneksi');
          expect(provider.shouldShowTroubleshooting(), isTrue);

          // Verify UI shows network-specific elements
          expect(find.byIcon(Icons.wifi_off), findsOneWidget);
          expect(find.text('Masalah Koneksi'), findsOneWidget);
          expect(find.text('Bantuan'), findsOneWidget);
        },
      );

      testWidgets(
        'should detect timeout errors and show appropriate feedback',
        (WidgetTester tester) async {
          mockApiService.errorToReturn = 'TimeoutException: Request timeout';
          mockApiService.shouldSucceed = false;

          await tester.pumpWidget(createTestWidget());

          // Fill form and submit
          await tester.enterText(find.byType(TextFormField).first, 'John Doe');
          await tester.enterText(
            find.byType(TextFormField).last,
            'Great restaurant experience!',
          );
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump(const Duration(milliseconds: 100));

          // Verify timeout error detection
          expect(provider.lastErrorType, ErrorType.timeout);
          expect(provider.getErrorTitle(), 'Koneksi Lambat');
          expect(provider.shouldShowTroubleshooting(), isTrue);

          // Verify UI shows timeout-specific elements
          expect(find.byIcon(Icons.access_time), findsOneWidget);
          expect(find.text('Koneksi Lambat'), findsOneWidget);
        },
      );

      testWidgets('should detect server errors and show appropriate feedback', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToReturn = 'HTTP 500 Internal Server Error';
        mockApiService.shouldSucceed = false;

        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant experience!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify server error detection
        expect(provider.lastErrorType, ErrorType.server);
        expect(provider.getErrorTitle(), 'Masalah Server');
        expect(provider.isRetryable, isTrue);

        // Verify UI shows server-specific elements
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Masalah Server'), findsOneWidget);
      });

      testWidgets(
        'should detect validation errors and show appropriate feedback',
        (WidgetTester tester) async {
          mockApiService.errorToReturn = 'Validation failed: Invalid data';
          mockApiService.shouldSucceed = false;

          await tester.pumpWidget(createTestWidget());

          // Fill form and submit
          await tester.enterText(find.byType(TextFormField).first, 'John Doe');
          await tester.enterText(
            find.byType(TextFormField).last,
            'Great restaurant experience!',
          );
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump(const Duration(milliseconds: 100));

          // Verify validation error detection
          expect(provider.lastErrorType, ErrorType.validation);
          expect(provider.getErrorTitle(), 'Data Tidak Valid');
          expect(provider.isValidationError, isTrue);

          // Verify UI shows validation-specific elements
          expect(find.byIcon(Icons.info_outline), findsOneWidget);
          expect(find.text('Data Tidak Valid'), findsOneWidget);
        },
      );
    });

    group('Enhanced User Feedback', () {
      testWidgets(
        'should show contextual troubleshooting dialog for network errors',
        (WidgetTester tester) async {
          mockApiService.errorToReturn = 'SocketException: Network unreachable';
          mockApiService.shouldSucceed = false;

          await tester.pumpWidget(createTestWidget());

          // Fill form and submit to trigger network error
          await tester.enterText(find.byType(TextFormField).first, 'John Doe');
          await tester.enterText(
            find.byType(TextFormField).last,
            'Great restaurant experience!',
          );
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump(const Duration(milliseconds: 100));

          // Tap help button
          await tester.tap(find.text('Bantuan'));
          await tester.pump();

          // Verify troubleshooting dialog appears with network-specific content
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
        },
      );

      testWidgets('should provide varied success messages', (
        WidgetTester tester,
      ) async {
        mockApiService.shouldSucceed = true;
        final successMessages = <String>{};

        // Test multiple submissions to collect different success messages
        for (int i = 0; i < 5; i++) {
          provider.resetState();
          await tester.pumpWidget(createTestWidget());

          // Fill form and submit
          await tester.enterText(
            find.byType(TextFormField).first,
            'John Doe $i',
          );
          await tester.enterText(
            find.byType(TextFormField).last,
            'Great restaurant experience!',
          );
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump(const Duration(milliseconds: 100));

          // Collect success message
          if (provider.successMessage != null) {
            successMessages.add(provider.successMessage!);
          }

          // Add delay to ensure different timestamps
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // Verify we got success messages and they contain expected content
        expect(successMessages.isNotEmpty, isTrue);
        expect(
          successMessages.every((msg) => msg.contains('berhasil')),
          isTrue,
        );
      });

      testWidgets('should show enhanced success snackbar with proper styling', (
        WidgetTester tester,
      ) async {
        mockApiService.shouldSucceed = true;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant experience!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify success snackbar appears with proper elements
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.text('Berhasil!'), findsOneWidget);
        expect(find.text('Tutup'), findsOneWidget); // Close action
      });
    });

    group('Error Recovery and Retry Functionality', () {
      testWidgets('should clear errors when user starts typing', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToReturn = 'Network error';
        mockApiService.shouldSucceed = false;

        await tester.pumpWidget(createTestWidget());

        // Fill form and submit to trigger error
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant experience!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify error is shown
        expect(provider.hasSubmissionError, isTrue);

        // Start typing in name field
        await tester.enterText(find.byType(TextFormField).first, 'Jane Doe');
        await tester.pump();

        // Verify error is cleared
        expect(provider.hasSubmissionError, isFalse);
      });

      testWidgets('should provide retry functionality for retryable errors', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToReturn = 'Network timeout';
        mockApiService.shouldSucceed = false;

        await tester.pumpWidget(createTestWidget());

        // Fill form and submit to trigger error
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant experience!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify error is shown with retry capability
        expect(provider.hasSubmissionError, isTrue);
        expect(provider.isRetryable, isTrue);
        expect(find.textContaining('Coba Lagi'), findsOneWidget);

        // Make next attempt succeed
        mockApiService.shouldSucceed = true;

        // Tap retry button
        await tester.tap(find.textContaining('Coba Lagi'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify success
        expect(provider.hasSuccessMessage, isTrue);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should handle non-retryable errors appropriately', (
        WidgetTester tester,
      ) async {
        mockApiService.errorToReturn = 'HTTP 401 Unauthorized';
        mockApiService.shouldSucceed = false;

        await tester.pumpWidget(createTestWidget());

        // Fill form and submit to trigger error
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant experience!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify error is shown as non-retryable
        expect(provider.hasSubmissionError, isTrue);
        expect(provider.lastErrorType, ErrorType.authentication);
        expect(provider.isRetryable, isFalse);

        // Verify no retry button is shown
        expect(find.textContaining('Coba Lagi'), findsNothing);
        expect(find.textContaining('Kirim Ulang'), findsNothing);
      });
    });

    group('Validation Error Enhancements', () {
      testWidgets(
        'should provide specific validation messages for name field',
        (WidgetTester tester) async {
          await tester.pumpWidget(createTestWidget());

          // Test empty name validation
          await tester.enterText(find.byType(TextFormField).first, '');
          await tester.enterText(
            find.byType(TextFormField).last,
            'Great restaurant experience!',
          );
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump();

          expect(
            find.textContaining('Nama tidak boleh kosong'),
            findsOneWidget,
          );
          expect(find.textContaining('Masukkan nama Anda'), findsOneWidget);

          // Test short name validation
          await tester.enterText(find.byType(TextFormField).first, 'A');
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump();

          expect(find.textContaining('terlalu pendek'), findsOneWidget);
          expect(find.textContaining('minimal 2 karakter'), findsOneWidget);
        },
      );

      testWidgets(
        'should provide specific validation messages for review field',
        (WidgetTester tester) async {
          await tester.pumpWidget(createTestWidget());

          // Test empty review validation
          await tester.enterText(find.byType(TextFormField).first, 'John Doe');
          await tester.enterText(find.byType(TextFormField).last, '');
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump();

          expect(
            find.textContaining('Ulasan tidak boleh kosong'),
            findsOneWidget,
          );
          expect(find.textContaining('Bagikan pengalaman'), findsOneWidget);

          // Test short review validation
          await tester.enterText(find.byType(TextFormField).last, 'Good');
          await tester.tap(find.text('Kirim Ulasan'));
          await tester.pump();

          expect(find.textContaining('terlalu pendek'), findsOneWidget);
          expect(find.textContaining('minimal 10 karakter'), findsOneWidget);
        },
      );
    });

    group('Error Helper Functionality', () {
      test('should provide contextual error guidance', () {
        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Great restaurant experience!');

        // Simulate network error
        provider.submitReview('test-id');

        final guidance = provider.getErrorGuidance();
        expect(guidance, isNotNull);
        expect(guidance!.isNotEmpty, isTrue);
      });

      test('should provide troubleshooting steps for network errors', () {
        mockApiService.errorToReturn = 'SocketException: Connection refused';
        mockApiService.shouldSucceed = false;

        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Great restaurant experience!');
        provider.submitReview('test-id');

        expect(provider.shouldShowTroubleshooting(), isTrue);
        final steps = provider.getTroubleshootingSteps();
        expect(steps.isNotEmpty, isTrue);
        expect(steps.any((step) => step.contains('Wi-Fi')), isTrue);
      });

      test(
        'should provide appropriate error titles for different error types',
        () {
          final errorTypes = {
            'SocketException: Connection failed': 'Masalah Koneksi',
            'TimeoutException: Request timeout': 'Koneksi Lambat',
            'HTTP 500 Internal Server Error': 'Masalah Server',
            'Validation failed': 'Data Tidak Valid',
            'HTTP 401 Unauthorized': 'Akses Ditolak',
          };

          errorTypes.forEach((errorMessage, expectedTitle) {
            mockApiService.errorToReturn = errorMessage;
            mockApiService.shouldSucceed = false;

            provider.resetState();
            provider.updateReviewerName('John Doe');
            provider.updateReviewText('Great restaurant experience!');
            provider.submitReview('test-id');

            expect(
              provider.getErrorTitle(),
              expectedTitle,
              reason: 'Failed for error: $errorMessage',
            );
          });
        },
      );
    });

    group('User Experience Enhancements', () {
      testWidgets('should disable submit button during submission', (
        WidgetTester tester,
      ) async {
        mockApiService.shouldSucceed = true;
        await tester.pumpWidget(createTestWidget());

        // Fill form
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant experience!',
        );

        // Tap submit button
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 25));

        // Verify button is disabled during submission
        expect(provider.isSubmitting, isTrue);
        expect(find.text('Mengirim...'), findsOneWidget);

        final submitButton = find.byType(ElevatedButton);
        final buttonWidget = tester.widget<ElevatedButton>(submitButton);
        expect(buttonWidget.onPressed, isNull);
      });

      testWidgets('should clear form after successful submission', (
        WidgetTester tester,
      ) async {
        mockApiService.shouldSucceed = true;
        await tester.pumpWidget(createTestWidget());

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'Great restaurant experience!',
        );
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify form is cleared
        expect(provider.reviewerName, isEmpty);
        expect(provider.reviewText, isEmpty);

        // Verify form fields are cleared in UI
        final nameField = tester.widget<TextFormField>(
          find.byType(TextFormField).first,
        );
        final reviewField = tester.widget<TextFormField>(
          find.byType(TextFormField).last,
        );
        expect(nameField.controller?.text, isEmpty);
        expect(reviewField.controller?.text, isEmpty);
      });
    });
  });
}
