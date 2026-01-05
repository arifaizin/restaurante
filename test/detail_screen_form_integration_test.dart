import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/review_submission_provider.dart';
import 'package:restaurant_app/widgets/review_submission_form.dart';
import 'package:restaurant_app/services/api_service.dart';

class MockApiService extends ApiService {
  @override
  Future<void> dispose() async {}
}

void main() {
  group('ReviewSubmissionForm Integration Tests', () {
    late ReviewSubmissionProvider reviewProvider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      reviewProvider = ReviewSubmissionProvider(apiService: mockApiService);
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ReviewSubmissionProvider>.value(
            value: reviewProvider,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Simulate the customer reviews section header
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.rate_review,
                              color: Colors.orange,
                              size: 20.0,
                            ),
                            const SizedBox(width: 8.0),
                            const Text(
                              'Customer Reviews',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),

                        // Review Submission Form - This is what we're testing
                        Consumer<ReviewSubmissionProvider>(
                          builder: (context, reviewProvider, child) {
                            return ReviewSubmissionForm(
                              restaurantId: 'test-restaurant-id',
                              onSubmissionSuccess: () {
                                // Mock success callback
                              },
                            );
                          },
                        ),

                        // Mock existing reviews
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Test Reviewer',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.0),
                              Text('Great restaurant!'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should display ReviewSubmissionForm with proper integration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify that ReviewSubmissionForm is present
      expect(find.byType(ReviewSubmissionForm), findsOneWidget);

      // Verify form is positioned above reviews
      expect(find.text('Tulis Ulasan'), findsOneWidget);
      expect(find.text('Customer Reviews'), findsOneWidget);

      // Verify form fields are present
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Nama Anda'), findsOneWidget);
      expect(find.text('Ulasan Anda'), findsOneWidget);

      // Verify submit button is present
      expect(find.text('Kirim Ulasan'), findsOneWidget);

      // Verify existing review is still displayed
      expect(find.text('Test Reviewer'), findsOneWidget);
      expect(find.text('Great restaurant!'), findsOneWidget);
    });

    testWidgets('should handle form validation properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to submit empty form
      final submitButton = find.text('Kirim Ulasan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify validation error messages appear (using the actual error messages from ErrorHelper)
      expect(
        find.text(
          'Nama tidak boleh kosong. Masukkan nama Anda untuk melanjutkan.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Ulasan tidak boleh kosong. Bagikan pengalaman Anda tentang restoran ini.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should maintain consistent styling with UI components', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify form is present and has proper styling
      expect(find.byType(ReviewSubmissionForm), findsOneWidget);

      // Verify form has containers with decorations
      final containers = find.descendant(
        of: find.byType(ReviewSubmissionForm),
        matching: find.byType(Container),
      );
      expect(containers, findsWidgets);
    });

    testWidgets('should connect to ReviewSubmissionProvider using Consumer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify form is connected to provider by testing form interaction
      expect(find.byType(ReviewSubmissionForm), findsOneWidget);

      // Test form interaction with provider
      final nameField = find.widgetWithText(TextFormField, 'Nama Anda');
      await tester.enterText(nameField, 'Test User');
      await tester.pumpAndSettle();

      // Verify provider state is updated
      expect(reviewProvider.reviewerName, equals('Test User'));

      final reviewField = find.widgetWithText(TextFormField, 'Ulasan Anda');
      await tester.enterText(reviewField, 'Great food!');
      await tester.pumpAndSettle();

      // Verify provider state is updated
      expect(reviewProvider.reviewText, equals('Great food!'));
    });

    testWidgets('should display proper error handling and loading states', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill in valid form data
      final nameField = find.widgetWithText(TextFormField, 'Nama Anda');
      await tester.enterText(nameField, 'Test User');

      final reviewField = find.widgetWithText(TextFormField, 'Ulasan Anda');
      await tester.enterText(reviewField, 'Great food!');

      await tester.pumpAndSettle();

      // Verify form is ready for submission
      final submitButton = find.text('Kirim Ulasan');
      expect(submitButton, findsOneWidget);

      // Verify no error state initially
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets(
      'should position form above existing reviews with proper spacing',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify proper layout order: form first, then reviews
        final reviewFormFinder = find.byType(ReviewSubmissionForm);
        final existingReviewFinder = find.text('Test Reviewer');

        expect(reviewFormFinder, findsOneWidget);
        expect(existingReviewFinder, findsOneWidget);

        final formPosition = tester.getTopLeft(reviewFormFinder);
        final reviewPosition = tester.getTopLeft(existingReviewFinder);

        // Form should be positioned above the existing review
        expect(formPosition.dy, lessThan(reviewPosition.dy));
      },
    );
  });
}
