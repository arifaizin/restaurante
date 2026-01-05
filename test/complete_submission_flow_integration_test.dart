import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/review_submission_provider.dart';
import 'package:restaurant_app/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/widgets/review_submission_form.dart';
import 'package:restaurant_app/screens/detail_screen.dart';
import 'package:restaurant_app/services/api_service.dart';
import 'package:restaurant_app/model/review_submission_request.dart';
import 'package:restaurant_app/model/review_submission_response.dart';
import 'package:restaurant_app/model/restaurant_detail.dart';
import 'package:restaurant_app/model/restaurant_detail_response.dart';
import 'package:restaurant_app/model/customer_review.dart';
import 'package:restaurant_app/model/menus.dart';
import 'package:restaurant_app/model/menu_item.dart';
import 'package:restaurant_app/model/category.dart';
import 'package:restaurant_app/services/api_response.dart';

class MockApiService extends ApiService {
  bool shouldFailSubmission = false;
  bool shouldFailRefresh = false;
  String? failureMessage;
  List<CustomerReview> mockReviews = [];

  @override
  Future<ApiResponse<ReviewSubmissionResponse>> submitReview(
    ReviewSubmissionRequest request,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldFailSubmission) {
      throw Exception(failureMessage ?? 'Network error');
    }

    // Add the new review to mock reviews
    final newReview = CustomerReview(
      name: request.name,
      review: request.review,
      date: DateTime.now().toIso8601String(),
    );
    mockReviews.add(newReview);

    final response = ReviewSubmissionResponse(
      error: false,
      message: 'Review added successfully',
      customerReviews: List.from(mockReviews),
    );

    return ApiResponse.success(response);
  }

  @override
  Future<ApiResponse<RestaurantDetailResponse>> getRestaurantDetail(
    String id,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldFailRefresh) {
      throw Exception('Failed to refresh data');
    }

    final restaurant = RestaurantDetail(
      id: id,
      name: 'Test Restaurant',
      description: 'Test Description',
      city: 'Test City',
      address: 'Test Address',
      pictureId: 'test-picture',
      categories: [Category(name: 'Test Category')],
      menus: Menus(
        foods: [MenuItem(name: 'Test Food')],
        drinks: [MenuItem(name: 'Test Drink')],
      ),
      rating: 4.5,
      customerReviews: List.from(mockReviews),
    );

    final response = RestaurantDetailResponse(
      error: false,
      message: 'Success',
      restaurant: restaurant,
    );

    return ApiResponse.success(response);
  }

  @override
  Future<void> dispose() async {}

  void reset() {
    shouldFailSubmission = false;
    shouldFailRefresh = false;
    failureMessage = null;
    mockReviews.clear();
  }
}

void main() {
  group('Complete Submission Flow Integration Tests', () {
    late ReviewSubmissionProvider reviewProvider;
    late RestaurantDetailProvider detailProvider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      reviewProvider = ReviewSubmissionProvider(apiService: mockApiService);
      detailProvider = RestaurantDetailProvider(apiService: mockApiService);
    });

    tearDown(() {
      mockApiService.reset();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ReviewSubmissionProvider>.value(
            value: reviewProvider,
          ),
          ChangeNotifierProvider<RestaurantDetailProvider>.value(
            value: detailProvider,
          ),
        ],
        child: const MaterialApp(
          home: DetailScreen(restaurantId: 'test-restaurant-id'),
        ),
      );
    }

    testWidgets(
      'should complete successful submission flow with data refresh',
      (WidgetTester tester) async {
        // Setup initial restaurant data
        await detailProvider.fetchRestaurantDetail('test-restaurant-id');
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify form is present
        expect(find.byType(ReviewSubmissionForm), findsOneWidget);

        // Fill in the form
        final nameField = find.widgetWithText(TextFormField, 'Nama Anda');
        final reviewField = find.widgetWithText(TextFormField, 'Ulasan Anda');

        await tester.enterText(nameField, 'Test User');
        await tester.enterText(reviewField, 'Great restaurant experience!');
        await tester.pumpAndSettle();

        // Submit the form
        final submitButton = find.text('Kirim Ulasan');
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Verify loading state is shown
        expect(find.text('Mengirim...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for submission to complete
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Verify success message is shown
        expect(find.text('Ulasan berhasil ditambahkan'), findsOneWidget);

        // Verify form is cleared
        expect(reviewProvider.reviewerName, isEmpty);
        expect(reviewProvider.reviewText, isEmpty);

        // Verify restaurant data is refreshed with new review
        expect(
          detailProvider.restaurantDetail?.customerReviews.length,
          equals(1),
        );
        expect(
          detailProvider.restaurantDetail?.customerReviews.first.name,
          equals('Test User'),
        );
        expect(
          detailProvider.restaurantDetail?.customerReviews.first.review,
          equals('Great restaurant experience!'),
        );
      },
    );

    testWidgets('should handle submission failure with error display', (
      WidgetTester tester,
    ) async {
      // Setup API to fail
      mockApiService.shouldFailSubmission = true;
      mockApiService.failureMessage = 'Network connection failed';

      // Setup initial restaurant data
      await detailProvider.fetchRestaurantDetail('test-restaurant-id');
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill in the form
      final nameField = find.widgetWithText(TextFormField, 'Nama Anda');
      final reviewField = find.widgetWithText(TextFormField, 'Ulasan Anda');

      await tester.enterText(nameField, 'Test User');
      await tester.enterText(reviewField, 'Great restaurant!');
      await tester.pumpAndSettle();

      // Submit the form
      final submitButton = find.text('Kirim Ulasan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Wait for submission to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify error message is displayed
      expect(
        find.text('Terjadi kesalahan: Exception: Network connection failed'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Verify form data is preserved
      expect(reviewProvider.reviewerName, equals('Test User'));
      expect(reviewProvider.reviewText, equals('Great restaurant!'));

      // Verify retry button is present
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('should handle retry functionality after failure', (
      WidgetTester tester,
    ) async {
      // Setup API to fail initially
      mockApiService.shouldFailSubmission = true;
      mockApiService.failureMessage = 'Temporary network error';

      // Setup initial restaurant data
      await detailProvider.fetchRestaurantDetail('test-restaurant-id');
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill in the form
      final nameField = find.widgetWithText(TextFormField, 'Nama Anda');
      final reviewField = find.widgetWithText(TextFormField, 'Ulasan Anda');

      await tester.enterText(nameField, 'Retry User');
      await tester.enterText(reviewField, 'Testing retry functionality');
      await tester.pumpAndSettle();

      // Submit the form (should fail)
      final submitButton = find.text('Kirim Ulasan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify error is shown
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Fix the API to succeed
      mockApiService.shouldFailSubmission = false;

      // Tap retry button
      final retryButton = find.text('Coba Lagi');
      await tester.tap(retryButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify success message is shown
      expect(find.text('Ulasan berhasil ditambahkan'), findsOneWidget);

      // Verify form is cleared
      expect(reviewProvider.reviewerName, isEmpty);
      expect(reviewProvider.reviewText, isEmpty);

      // Verify restaurant data is updated
      expect(
        detailProvider.restaurantDetail?.customerReviews.length,
        equals(1),
      );
    });

    testWidgets('should handle form validation errors properly', (
      WidgetTester tester,
    ) async {
      // Setup initial restaurant data
      await detailProvider.fetchRestaurantDetail('test-restaurant-id');
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to submit empty form
      final submitButton = find.text('Kirim Ulasan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify validation errors are shown
      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
      expect(find.text('Ulasan tidak boleh kosong'), findsOneWidget);

      // Verify no API call was made (no loading state)
      expect(find.text('Mengirim...'), findsNothing);

      // Fill in only name field
      final nameField = find.widgetWithText(TextFormField, 'Nama Anda');
      await tester.enterText(nameField, 'A'); // Too short
      await tester.pumpAndSettle();

      // Try to submit again
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify name length validation
      expect(find.text('Nama minimal 2 karakter'), findsOneWidget);
      expect(find.text('Ulasan tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should maintain form state during submission process', (
      WidgetTester tester,
    ) async {
      // Setup initial restaurant data
      await detailProvider.fetchRestaurantDetail('test-restaurant-id');
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill in the form
      final nameField = find.widgetWithText(TextFormField, 'Nama Anda');
      final reviewField = find.widgetWithText(TextFormField, 'Ulasan Anda');

      await tester.enterText(nameField, 'State Test User');
      await tester.enterText(reviewField, 'Testing state management');
      await tester.pumpAndSettle();

      // Verify provider state is updated
      expect(reviewProvider.reviewerName, equals('State Test User'));
      expect(reviewProvider.reviewText, equals('Testing state management'));

      // Start submission
      final submitButton = find.text('Kirim Ulasan');
      await tester.tap(submitButton);

      // Verify form is disabled during submission
      expect(reviewProvider.isSubmitting, isTrue);

      // Wait for completion
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify form is cleared after successful submission
      expect(reviewProvider.reviewerName, isEmpty);
      expect(reviewProvider.reviewText, isEmpty);
      expect(reviewProvider.isSubmitting, isFalse);
    });

    testWidgets('should handle data refresh failure gracefully', (
      WidgetTester tester,
    ) async {
      // Setup initial restaurant data
      await detailProvider.fetchRestaurantDetail('test-restaurant-id');
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Setup API to fail refresh but succeed submission
      mockApiService.shouldFailRefresh = true;

      // Fill in and submit form
      final nameField = find.widgetWithText(TextFormField, 'Nama Anda');
      final reviewField = find.widgetWithText(TextFormField, 'Ulasan Anda');

      await tester.enterText(nameField, 'Refresh Test');
      await tester.enterText(reviewField, 'Testing refresh failure');
      await tester.pumpAndSettle();

      final submitButton = find.text('Kirim Ulasan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify success message is still shown even if refresh fails
      expect(find.text('Ulasan berhasil ditambahkan'), findsOneWidget);

      // Verify form is still cleared
      expect(reviewProvider.reviewerName, isEmpty);
      expect(reviewProvider.reviewText, isEmpty);
    });

    testWidgets('should clear error messages when form is modified', (
      WidgetTester tester,
    ) async {
      // Setup API to fail
      mockApiService.shouldFailSubmission = true;

      // Setup initial restaurant data
      await detailProvider.fetchRestaurantDetail('test-restaurant-id');
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill in and submit form to generate error
      final nameField = find.widgetWithText(TextFormField, 'Nama Anda');
      final reviewField = find.widgetWithText(TextFormField, 'Ulasan Anda');

      await tester.enterText(nameField, 'Error Test');
      await tester.enterText(reviewField, 'Testing error clearing');
      await tester.pumpAndSettle();

      final submitButton = find.text('Kirim Ulasan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify error is shown
      expect(reviewProvider.hasSubmissionError, isTrue);

      // Modify form field
      await tester.enterText(nameField, 'Error Test Modified');
      await tester.pumpAndSettle();

      // Verify error is cleared
      expect(reviewProvider.hasSubmissionError, isFalse);
    });

    testWidgets('should handle multiple rapid submissions properly', (
      WidgetTester tester,
    ) async {
      // Setup initial restaurant data
      await detailProvider.fetchRestaurantDetail('test-restaurant-id');
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill in the form
      final nameField = find.widgetWithText(TextFormField, 'Nama Anda');
      final reviewField = find.widgetWithText(TextFormField, 'Ulasan Anda');

      await tester.enterText(nameField, 'Rapid Test');
      await tester.enterText(reviewField, 'Testing rapid submissions');
      await tester.pumpAndSettle();

      // Try to submit multiple times rapidly
      final submitButton = find.text('Kirim Ulasan');
      await tester.tap(submitButton);
      await tester.tap(submitButton); // Second tap should be ignored
      await tester.tap(submitButton); // Third tap should be ignored

      // Verify only one submission is processed
      expect(reviewProvider.isSubmitting, isTrue);

      // Wait for completion
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify only one review was added
      expect(
        detailProvider.restaurantDetail?.customerReviews.length,
        equals(1),
      );
    });
  });
}
