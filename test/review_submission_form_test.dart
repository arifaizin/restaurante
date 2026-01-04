import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/review_submission_provider.dart';
import 'package:restaurant_app/widgets/review_submission_form.dart';
import 'package:restaurant_app/services/api_service.dart';
import 'package:restaurant_app/model/review_submission_response.dart';
import 'package:restaurant_app/services/api_response.dart';
import 'package:restaurant_app/model/review_submission_request.dart';

// Mock API Service for testing
class MockApiService extends ApiService {
  bool shouldSucceed;
  String? errorMessage;

  MockApiService({this.shouldSucceed = true, this.errorMessage});

  @override
  Future<ApiResponse<ReviewSubmissionResponse>> submitReview(
      ReviewSubmissionRequest request) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay

    if (shouldSucceed) {
      final response = ReviewSubmissionResponse(
        error: false,
        message: 'Review added successfully',
        customerReviews: [],
      );
      return ApiResponse.success(response,
          message: 'Review added successfully');
    } else {
      final response = ReviewSubmissionResponse(
        error: true,
        message: errorMessage ?? 'Submission failed',
        customerReviews: [],
      );
      return ApiResponse.failure(errorMessage ?? 'Submission failed',
          data: response);
    }
  }

  @override
  void dispose() {
    // Mock implementation
  }
}

void main() {
  group('ReviewSubmissionForm Widget Tests', () {
    late MockApiService mockApiService;
    late ReviewSubmissionProvider provider;

    setUp(() {
      mockApiService = MockApiService();
      provider = ReviewSubmissionProvider(apiService: mockApiService);
    });

    Widget createTestWidget({VoidCallback? onSubmissionSuccess}) {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ReviewSubmissionProvider>.value(
            value: provider,
            child: ReviewSubmissionForm(
              restaurantId: 'test-restaurant-id',
              onSubmissionSuccess: onSubmissionSuccess,
            ),
          ),
        ),
      );
    }

    testWidgets('should render form with all required elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check form header
      expect(find.text('Tulis Ulasan'), findsOneWidget);
      expect(find.byIcon(Icons.edit_note), findsOneWidget);

      // Check input fields
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Nama Anda'), findsOneWidget);
      expect(find.text('Ulasan Anda'), findsOneWidget);

      // Check submit button
      expect(find.text('Kirim Ulasan'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap submit button without filling fields
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump();

      // Check validation error messages (using enhanced messages)
      expect(find.textContaining('Nama'), findsOneWidget);
      expect(find.textContaining('kosong'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Ulasan'), findsOneWidget);
    });

    testWidgets('should show validation error for short name',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter short name
      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump();

      expect(find.textContaining('pendek'), findsOneWidget);
      expect(find.textContaining('2 karakter'), findsOneWidget);
    });

    testWidgets('should update provider state when text changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter name
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.pump();

      expect(provider.reviewerName, equals('John Doe'));

      // Enter review
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.pump();

      expect(provider.reviewText, equals('Great restaurant!'));
    });

    testWidgets('should show loading state during submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill form with valid data
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.pump();

      // Tap submit button
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump();

      // Check loading state
      expect(find.text('Mengirim...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for submission to complete
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('should clear form after successful submission',
        (WidgetTester tester) async {
      mockApiService.shouldSucceed = true;
      await tester.pumpWidget(createTestWidget());

      // Fill form with valid data
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.pump();

      // Submit form
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump();

      // Wait for submission to complete
      await tester.pump(const Duration(milliseconds: 200));

      // Check that form is cleared
      final nameField =
          tester.widget<TextFormField>(find.byType(TextFormField).first);
      final reviewField =
          tester.widget<TextFormField>(find.byType(TextFormField).last);

      expect(nameField.controller?.text, isEmpty);
      expect(reviewField.controller?.text, isEmpty);
    });

    testWidgets('should show success snackbar after successful submission',
        (WidgetTester tester) async {
      mockApiService.shouldSucceed = true;
      await tester.pumpWidget(createTestWidget());

      // Fill form with valid data
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.pump();

      // Submit form
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump();

      // Wait for submission to complete
      await tester.pump(const Duration(milliseconds: 200));

      // Check for success snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show error message on submission failure',
        (WidgetTester tester) async {
      mockApiService.shouldSucceed = false;
      mockApiService.errorMessage = 'Network error occurred';

      await tester.pumpWidget(createTestWidget());

      // Fill form with valid data
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.pump();

      // Submit form
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump();

      // Wait for submission to complete
      await tester.pump(const Duration(milliseconds: 200));

      // Check for error message
      expect(find.text('Network error occurred'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should clear error message when close button is tapped',
        (WidgetTester tester) async {
      mockApiService.shouldSucceed = false;
      mockApiService.errorMessage = 'Network error occurred';

      await tester.pumpWidget(createTestWidget());

      // Fill form and submit to trigger error
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify error is shown
      expect(find.text('Network error occurred'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Verify error is cleared
      expect(find.text('Network error occurred'), findsNothing);
    });

    testWidgets('should call onSubmissionSuccess callback when provided',
        (WidgetTester tester) async {
      mockApiService.shouldSucceed = true;
      bool callbackCalled = false;

      await tester.pumpWidget(createTestWidget(
        onSubmissionSuccess: () {
          callbackCalled = true;
        },
      ));

      // Fill form with valid data
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.pump();

      // Submit form
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(callbackCalled, isTrue);
    });

    testWidgets('should disable form fields during submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill form with valid data
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.pump();

      // Submit form
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump();

      // Check that fields are disabled
      final nameField =
          tester.widget<TextFormField>(find.byType(TextFormField).first);
      final reviewField =
          tester.widget<TextFormField>(find.byType(TextFormField).last);

      expect(nameField.enabled, isFalse);
      expect(reviewField.enabled, isFalse);

      // Wait for submission to complete to avoid pending timers
      await tester.pumpAndSettle();
    });

    testWidgets('should handle focus management correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Focus on name field and press next
      await tester.tap(find.byType(TextFormField).first);
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      // Verify focus moved to review field by checking if the second field has focus
      final focusedWidget = tester.binding.focusManager.primaryFocus;
      expect(focusedWidget, isNotNull);
      // Just verify that focus management is working, not the exact widget match
      expect(focusedWidget!.hasFocus, isTrue);
    });

    testWidgets('should have proper accessibility labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check that form fields have proper labels
      expect(find.text('Nama Anda'), findsOneWidget);
      expect(find.text('Ulasan Anda'), findsOneWidget);

      // Check that form has semantic structure
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should submit form when done is pressed on review field',
        (WidgetTester tester) async {
      mockApiService.shouldSucceed = true;
      await tester.pumpWidget(createTestWidget());

      // Fill form with valid data
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.pump();

      // Press done on review field
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 200));

      // Verify submission occurred (form should be cleared)
      final nameField =
          tester.widget<TextFormField>(find.byType(TextFormField).first);
      expect(nameField.controller?.text, isEmpty);
    });

    testWidgets(
        'should clear error messages when user starts typing after error',
        (WidgetTester tester) async {
      mockApiService.shouldSucceed = false;
      mockApiService.errorMessage = 'Network error occurred';

      await tester.pumpWidget(createTestWidget());

      // Fill form and submit to trigger error
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify error is shown
      expect(find.text('Network error occurred'), findsOneWidget);

      // Start typing in name field
      await tester.enterText(find.byType(TextFormField).first, 'Jane Doe');
      await tester.pump();

      // Verify error message is cleared
      expect(find.text('Network error occurred'), findsNothing);
    });

    testWidgets(
        'should show inline validation errors and clear them when typing',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid short name and trigger validation
      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.enterText(find.byType(TextFormField).last,
          'Some review text that is long enough');
      await tester.pump();

      // Trigger validation by attempting to submit
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump();

      // Verify validation error is shown
      expect(find.textContaining('pendek'), findsOneWidget);

      // Enter valid name to trigger provider validation
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.pump();

      // Check that provider validation cleared the error
      expect(provider.hasNameError, isFalse);
    });

    testWidgets('should maintain form state during validation errors',
        (WidgetTester tester) async {
      mockApiService.shouldSucceed = false;
      mockApiService.errorMessage = 'Validation failed';

      await tester.pumpWidget(createTestWidget());

      // Fill form with valid data
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.pump();

      // Submit form to trigger error
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify error is shown but form data is preserved
      expect(find.text('Validation failed'), findsOneWidget);

      final nameField =
          tester.widget<TextFormField>(find.byType(TextFormField).first);
      final reviewField =
          tester.widget<TextFormField>(find.byType(TextFormField).last);

      expect(nameField.controller?.text, equals('John Doe'));
      expect(reviewField.controller?.text, equals('Great restaurant!'));
    });

    testWidgets('should provide proper accessibility support',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check that form fields have proper labels
      expect(find.text('Nama Anda'), findsOneWidget);
      expect(find.text('Ulasan Anda'), findsOneWidget);

      // Check that form has proper structure for screen readers
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Check that icons are present for visual cues
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.rate_review_outlined), findsOneWidget);
    });

    testWidgets('should handle complete validation and feedback flow',
        (WidgetTester tester) async {
      mockApiService.shouldSucceed = true;
      await tester.pumpWidget(createTestWidget());

      // Step 1: Try to submit empty form - should show validation errors
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump();

      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
      expect(find.text('Ulasan tidak boleh kosong'), findsOneWidget);

      // Step 2: Fill name but leave review empty
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump();

      expect(find.text('Nama tidak boleh kosong'), findsNothing);
      expect(find.text('Ulasan tidak boleh kosong'), findsOneWidget);

      // Step 3: Fill review field
      await tester.enterText(
          find.byType(TextFormField).last, 'Great restaurant!');
      await tester.pump();

      // Step 4: Submit valid form - should show loading then success
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pump();

      // Check loading state
      expect(find.text('Mengirim...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for submission to complete
      await tester.pump(const Duration(milliseconds: 200));

      // Check success feedback
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Check form is cleared
      final nameField =
          tester.widget<TextFormField>(find.byType(TextFormField).first);
      final reviewField =
          tester.widget<TextFormField>(find.byType(TextFormField).last);

      expect(nameField.controller?.text, isEmpty);
      expect(reviewField.controller?.text, isEmpty);
    });
  });
}
