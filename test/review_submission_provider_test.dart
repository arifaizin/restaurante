import 'package:flutter_test/flutter_test.dart';

import 'package:restaurant_app/providers/review_submission_provider.dart';
import 'package:restaurant_app/services/api_service.dart';
import 'package:restaurant_app/model/review_submission_request.dart';
import 'package:restaurant_app/model/review_submission_response.dart';
import 'package:restaurant_app/services/api_response.dart';
import 'package:restaurant_app/util/error_helper.dart';

// Mock API Service for testing
class MockApiService extends ApiService {
  bool shouldSucceed = true;
  String errorMessage = 'Test error';
  ReviewSubmissionResponse? mockResponse;

  @override
  Future<ApiResponse<ReviewSubmissionResponse>> submitReview(
    ReviewSubmissionRequest request,
  ) async {
    if (shouldSucceed) {
      final response =
          mockResponse ??
          ReviewSubmissionResponse(
            error: false,
            message: 'Review added successfully',
            customerReviews: [],
          );
      return ApiResponse.success(response, message: 'Success');
    } else {
      final errorResponse = ReviewSubmissionResponse(
        error: true,
        message: errorMessage,
        customerReviews: [],
      );
      return ApiResponse.failure(errorMessage, data: errorResponse);
    }
  }

  @override
  void dispose() {
    // Mock implementation - do nothing
  }
}

void main() {
  group('ReviewSubmissionProvider', () {
    late ReviewSubmissionProvider provider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      provider = ReviewSubmissionProvider(apiService: mockApiService);
    });

    tearDown(() {
      provider.dispose();
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(provider.isSubmitting, false);
        expect(provider.submissionError, null);
        expect(provider.successMessage, null);
        expect(provider.hasSubmissionError, false);
        expect(provider.hasSuccessMessage, false);
        expect(provider.lastErrorType, null);
        expect(provider.isRetryable, true);
        expect(provider.isNetworkError, false);
        expect(provider.isValidationError, false);
        expect(provider.reviewerName, '');
        expect(provider.reviewText, '');
        expect(provider.nameError, null);
        expect(provider.reviewError, null);
        expect(provider.hasNameError, false);
        expect(provider.hasReviewError, false);
        expect(provider.hasValidationErrors, false);
      });
    });

    group('Form State Management', () {
      test('should update reviewer name and validate', () {
        // Test valid name
        provider.updateReviewerName('John Doe');
        expect(provider.reviewerName, 'John Doe');
        expect(provider.nameError, null);
        expect(provider.hasNameError, false);

        // Test empty name
        provider.updateReviewerName('');
        expect(provider.reviewerName, '');
        expect(provider.nameError, contains('Nama'));
        expect(provider.nameError, contains('kosong'));
        expect(provider.hasNameError, true);

        // Test name too short
        provider.updateReviewerName('A');
        expect(provider.reviewerName, 'A');
        expect(provider.nameError, contains('pendek'));
        expect(provider.hasNameError, true);

        // Test name with only spaces
        provider.updateReviewerName('   ');
        expect(provider.reviewerName, '   ');
        expect(provider.nameError, contains('kosong'));
        expect(provider.hasNameError, true);

        // Test name too long
        provider.updateReviewerName('A' * 51);
        expect(provider.reviewerName, 'A' * 51);
        expect(provider.nameError, contains('panjang'));
        expect(provider.hasNameError, true);
      });

      test('should update review text and validate', () {
        // Test valid review
        provider.updateReviewText('Great food and service!');
        expect(provider.reviewText, 'Great food and service!');
        expect(provider.reviewError, null);
        expect(provider.hasReviewError, false);

        // Test empty review
        provider.updateReviewText('');
        expect(provider.reviewText, '');
        expect(provider.reviewError, contains('Ulasan'));
        expect(provider.reviewError, contains('kosong'));
        expect(provider.hasReviewError, true);

        // Test review with only spaces
        provider.updateReviewText('   ');
        expect(provider.reviewText, '   ');
        expect(provider.reviewError, contains('kosong'));
        expect(provider.hasReviewError, true);

        // Test review too short
        provider.updateReviewText('Good');
        expect(provider.reviewText, 'Good');
        expect(provider.reviewError, contains('pendek'));
        expect(provider.hasReviewError, true);

        // Test review too long
        provider.updateReviewText('A' * 501);
        expect(provider.reviewText, 'A' * 501);
        expect(provider.reviewError, contains('panjang'));
        expect(provider.hasReviewError, true);
      });
    });

    group('Form Validation', () {
      test('should validate entire form correctly', () {
        // Test invalid form
        provider.updateReviewerName('');
        provider.updateReviewText('');
        expect(provider.validateForm(), false);
        expect(provider.hasValidationErrors, true);

        // Test partially valid form
        provider.updateReviewerName('John');
        provider.updateReviewText('');
        expect(provider.validateForm(), false);
        expect(provider.hasValidationErrors, true);

        // Test valid form
        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Great restaurant!');
        expect(provider.validateForm(), true);
        expect(provider.hasValidationErrors, false);
      });

      test('should handle edge cases in validation', () {
        // Test name with exactly 2 characters
        provider.updateReviewerName('Jo');
        provider.updateReviewText('Good');
        expect(provider.validateForm(), true);

        // Test name with spaces that trim to valid length
        provider.updateReviewerName('  John  ');
        provider.updateReviewText('  Great food  ');
        expect(provider.validateForm(), true);
        expect(provider.nameError, null);
        expect(provider.reviewError, null);
      });
    });

    group('Review Submission', () {
      test('should submit review successfully', () async {
        // Setup
        const restaurantId = 'test-restaurant-id';
        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Excellent food and service!');

        mockApiService.shouldSucceed = true;

        // Execute
        final result = await provider.submitReview(restaurantId);

        // Verify
        expect(result, true);
        expect(provider.successMessage, isNotNull);
        expect(provider.successMessage, contains('berhasil'));
        expect(provider.submissionError, null);
        expect(provider.lastErrorType, null);
        expect(provider.reviewerName, ''); // Form should be cleared
        expect(provider.reviewText, ''); // Form should be cleared
        expect(provider.isSubmitting, false);
      });

      test('should handle submission failure', () async {
        // Setup
        const restaurantId = 'test-restaurant-id';
        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Great food and excellent service!');

        mockApiService.shouldSucceed = false;
        mockApiService.errorMessage = 'Network error';

        // Execute
        final result = await provider.submitReview(restaurantId);

        // Verify
        expect(result, false);
        expect(provider.submissionError, isNotNull);
        expect(provider.submissionError, contains('ulasan'));
        expect(provider.successMessage, null);
        expect(provider.lastErrorType, isNotNull);
        expect(provider.isRetryable, true);
        expect(provider.reviewerName, 'John Doe'); // Form should not be cleared
        expect(
          provider.reviewText,
          'Great food and excellent service!',
        ); // Form should not be cleared
        expect(provider.isSubmitting, false);
      });

      test('should not submit if form validation fails', () async {
        // Setup
        const restaurantId = 'test-restaurant-id';
        provider.updateReviewerName(''); // Invalid name
        provider.updateReviewText('Great food and excellent service!');

        // Execute
        final result = await provider.submitReview(restaurantId);

        // Verify
        expect(result, false);
        expect(provider.hasValidationErrors, true);
        expect(provider.nameError, contains('kosong'));
      });
    });

    group('State Management Methods', () {
      test('should clear form correctly', () {
        // Setup form with data and errors
        provider.updateReviewerName('John');
        provider.updateReviewText('Great food');
        provider.updateReviewerName(''); // This will set name error
        provider.updateReviewText(''); // This will set review error

        // Clear form
        provider.clearForm();

        // Verify
        expect(provider.reviewerName, '');
        expect(provider.reviewText, '');
        expect(provider.nameError, null);
        expect(provider.reviewError, null);
        expect(provider.hasValidationErrors, false);
      });

      test('should reset state correctly', () {
        // Setup state with various values
        provider.updateReviewerName('John');
        provider.updateReviewText('Great food');

        // Reset state
        provider.resetState();

        // Verify everything is reset
        expect(provider.reviewerName, '');
        expect(provider.reviewText, '');
        expect(provider.nameError, null);
        expect(provider.reviewError, null);
        expect(provider.submissionError, null);
        expect(provider.successMessage, null);
        expect(provider.isSubmitting, false);
      });

      test('should clear error message only', () {
        // Setup with error by simulating failed submission
        provider.updateReviewerName('John');
        provider.updateReviewText('Great food');

        mockApiService.shouldSucceed = false;
        mockApiService.errorMessage = 'Test error';

        // Submit to create error state
        provider.submitReview('test-id').then((_) {
          // Clear only error
          provider.clearError();

          // Verify only error is cleared, other state remains
          expect(provider.submissionError, null);
          expect(provider.reviewerName, 'John');
          expect(provider.reviewText, 'Great food');
        });
      });

      test('should clear success message only', () {
        // Setup success state
        provider.updateReviewerName('John');
        provider.updateReviewText('Great food');

        // Clear success message
        provider.clearSuccessMessage();

        // Verify
        expect(provider.successMessage, null);
      });
    });

    group('Enhanced Error Handling', () {
      test('should identify network errors correctly', () async {
        // Setup
        const restaurantId = 'test-restaurant-id';
        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Great food and excellent service!');

        mockApiService.shouldSucceed = false;
        mockApiService.errorMessage = 'SocketException: Connection failed';

        // Execute
        final result = await provider.submitReview(restaurantId);

        // Verify
        expect(result, false);
        expect(provider.lastErrorType, ErrorType.network);
        expect(provider.isNetworkError, true);
        expect(provider.isRetryable, true);
        expect(provider.submissionError, contains('koneksi internet'));
      });

      test('should identify timeout errors correctly', () async {
        // Setup
        const restaurantId = 'test-restaurant-id';
        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Great food and excellent service!');

        mockApiService.shouldSucceed = false;
        mockApiService.errorMessage = 'TimeoutException: Request timeout';

        // Execute
        final result = await provider.submitReview(restaurantId);

        // Verify
        expect(result, false);
        expect(provider.lastErrorType, ErrorType.timeout);
        expect(provider.isRetryable, true);
        expect(provider.submissionError, contains('lambat'));
      });

      test('should identify server errors correctly', () async {
        // Setup
        const restaurantId = 'test-restaurant-id';
        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Great food and excellent service!');

        mockApiService.shouldSucceed = false;
        mockApiService.errorMessage = 'HTTP 500 Internal Server Error';

        // Execute
        final result = await provider.submitReview(restaurantId);

        // Verify
        expect(result, false);
        expect(provider.lastErrorType, ErrorType.server);
        expect(provider.isRetryable, true);
        expect(provider.submissionError, contains('Server'));
      });

      test('should identify validation errors correctly', () async {
        // Setup
        const restaurantId = 'test-restaurant-id';
        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Great food and excellent service!');

        mockApiService.shouldSucceed = false;
        mockApiService.errorMessage = 'Validation failed: Invalid data';

        // Execute
        final result = await provider.submitReview(restaurantId);

        // Verify
        expect(result, false);
        expect(provider.lastErrorType, ErrorType.validation);
        expect(provider.isValidationError, true);
        expect(provider.isRetryable, true);
        expect(provider.submissionError, contains('valid'));
      });

      test('should clear error type when clearing error', () async {
        // Setup error state
        const restaurantId = 'test-restaurant-id';
        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Great food and excellent service!');

        mockApiService.shouldSucceed = false;
        mockApiService.errorMessage = 'Network error';

        await provider.submitReview(restaurantId);
        expect(provider.lastErrorType, isNotNull);

        // Clear error
        provider.clearError();

        // Verify
        expect(provider.submissionError, null);
        expect(provider.lastErrorType, null);
        expect(provider.isRetryable, true);
      });

      test('should clear error type when clearing messages', () async {
        // Setup error state
        const restaurantId = 'test-restaurant-id';
        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Great food and excellent service!');

        mockApiService.shouldSucceed = false;
        mockApiService.errorMessage = 'Network error';

        await provider.submitReview(restaurantId);
        expect(provider.lastErrorType, isNotNull);

        // Clear messages
        provider.updateReviewerName('Jane Doe'); // This triggers _clearMessages

        // Verify
        expect(provider.submissionError, null);
        expect(provider.lastErrorType, null);
      });

      test('should use enhanced success messages', () async {
        // Setup
        const restaurantId = 'test-restaurant-id';
        provider.updateReviewerName('John Doe');
        provider.updateReviewText('Great food and excellent service!');

        mockApiService.shouldSucceed = true;

        // Execute
        final result = await provider.submitReview(restaurantId);

        // Verify
        expect(result, true);
        expect(provider.successMessage, isNotNull);
        expect(provider.successMessage, contains('berhasil'));
        // Should be one of the enhanced success messages
        final possibleMessages = [
          'Ulasan berhasil ditambahkan! Terima kasih atas feedback Anda.',
          'Ulasan Anda telah berhasil dikirim dan akan segera tampil.',
          'Terima kasih! Ulasan Anda berhasil ditambahkan ke restoran ini.',
          'Ulasan berhasil dikirim! Pengalaman Anda akan membantu pengguna lain.',
        ];
        expect(
          possibleMessages.any((msg) => provider.successMessage == msg),
          true,
        );
      });
    });

    group('Enhanced Validation', () {
      test('should validate name length limits', () {
        // Test minimum length
        provider.updateReviewerName('Jo');
        expect(provider.nameError, null);

        // Test maximum length
        provider.updateReviewerName('A' * 50);
        expect(provider.nameError, null);

        // Test over maximum length
        provider.updateReviewerName('A' * 51);
        expect(provider.nameError, contains('panjang'));
      });

      test('should validate review length limits', () {
        // Test minimum length
        provider.updateReviewText('Great food!');
        expect(provider.reviewError, null);

        // Test maximum length
        provider.updateReviewText('A' * 500);
        expect(provider.reviewError, null);

        // Test over maximum length
        provider.updateReviewText('A' * 501);
        expect(provider.reviewError, contains('panjang'));

        // Test under minimum length
        provider.updateReviewText('Good');
        expect(provider.reviewError, contains('pendek'));
      });
    });

    group('Listener Notifications', () {
      test('should notify listeners when state changes', () {
        int notificationCount = 0;
        provider.addListener(() {
          notificationCount++;
        });

        // Test various state changes
        provider.updateReviewerName('John'); // Should notify
        provider.updateReviewText(
          'Great food and excellent service!',
        ); // Should notify
        provider.clearForm(); // Should notify
        provider.resetState(); // Should notify

        expect(notificationCount, greaterThan(0));
      });
    });
  });
}
