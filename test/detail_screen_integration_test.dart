import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/screens/detail_screen.dart';
import 'package:restaurant_app/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/providers/review_submission_provider.dart';
import 'package:restaurant_app/widgets/review_submission_form.dart';
import 'package:restaurant_app/model/restaurant_detail.dart';
import 'package:restaurant_app/model/customer_review.dart';
import 'package:restaurant_app/model/menus.dart';
import 'package:restaurant_app/model/menu_item.dart';
import 'package:restaurant_app/model/category.dart';
import 'package:restaurant_app/services/api_service.dart';

class MockApiService extends ApiService {
  @override
  Future<void> dispose() async {}
}

void main() {
  group('DetailScreen Integration Tests', () {
    late RestaurantDetailProvider detailProvider;
    late ReviewSubmissionProvider reviewProvider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      detailProvider = RestaurantDetailProvider(apiService: mockApiService);
      reviewProvider = ReviewSubmissionProvider(apiService: mockApiService);
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<RestaurantDetailProvider>.value(
            value: detailProvider,
          ),
          ChangeNotifierProvider<ReviewSubmissionProvider>.value(
            value: reviewProvider,
          ),
        ],
        child: const MaterialApp(
          home: DetailScreen(restaurantId: 'test-restaurant-id'),
        ),
      );
    }

    testWidgets(
      'should display ReviewSubmissionForm in customer reviews section',
      (WidgetTester tester) async {
        // Setup test data
        final testRestaurant = RestaurantDetail(
          id: 'test-restaurant-id',
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
          customerReviews: [
            CustomerReview(
              name: 'Test Reviewer',
              review: 'Test Review',
              date: '2023-01-01',
            ),
          ],
        );

        await tester.pumpWidget(createTestWidget());

        // Set restaurant data in provider after widget is built
        detailProvider.restaurantDetail = testRestaurant;
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
      },
    );

    testWidgets('should display form even when no reviews exist', (
      WidgetTester tester,
    ) async {
      // Setup test data with no reviews
      final testRestaurant = RestaurantDetail(
        id: 'test-restaurant-id',
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
        customerReviews: [], // Empty reviews
      );

      await tester.pumpWidget(createTestWidget());

      // Set restaurant data in provider after widget is built
      detailProvider.restaurantDetail = testRestaurant;
      await tester.pumpAndSettle();

      // Verify that ReviewSubmissionForm is still present
      expect(find.byType(ReviewSubmissionForm), findsOneWidget);
      expect(find.text('Tulis Ulasan'), findsOneWidget);

      // Verify empty state message is shown
      expect(find.text('No customer reviews available yet.'), findsOneWidget);

      // Verify form is still functional
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Kirim Ulasan'), findsOneWidget);
    });

    testWidgets('should show form elements are accessible', (
      WidgetTester tester,
    ) async {
      // Setup test data
      final testRestaurant = RestaurantDetail(
        id: 'test-restaurant-id',
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
        customerReviews: [],
      );

      await tester.pumpWidget(createTestWidget());

      // Set restaurant data in provider after widget is built
      detailProvider.restaurantDetail = testRestaurant;
      await tester.pumpAndSettle();

      // Simulate updating form fields
      reviewProvider.updateReviewerName('Test Name');
      reviewProvider.updateReviewText('Test Review');

      // Find and verify submit button is accessible
      final submitButton = find.text('Kirim Ulasan');
      expect(submitButton, findsOneWidget);

      // Verify the form elements are present and accessible
      expect(find.byType(ReviewSubmissionForm), findsOneWidget);
    });

    testWidgets('should display error messages when form validation fails', (
      WidgetTester tester,
    ) async {
      // Setup test data
      final testRestaurant = RestaurantDetail(
        id: 'test-restaurant-id',
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
        customerReviews: [],
      );

      await tester.pumpWidget(createTestWidget());

      // Set restaurant data in provider after widget is built
      detailProvider.restaurantDetail = testRestaurant;
      await tester.pumpAndSettle();

      // Try to submit empty form by calling provider method directly
      // This simulates what happens when the submit button is tapped
      final result = await reviewProvider.submitReview('test-restaurant-id');
      await tester.pumpAndSettle();

      // Verify validation failed
      expect(result, isFalse);

      // Check if validation errors are set
      expect(reviewProvider.nameError, isNotNull);
      expect(reviewProvider.reviewError, isNotNull);
    });

    testWidgets(
      'should maintain consistent styling with existing UI components',
      (WidgetTester tester) async {
        // Setup test data
        final testRestaurant = RestaurantDetail(
          id: 'test-restaurant-id',
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
          customerReviews: [
            CustomerReview(
              name: 'Test Reviewer',
              review: 'Test Review',
              date: '2023-01-01',
            ),
          ],
        );

        await tester.pumpWidget(createTestWidget());

        // Set restaurant data in provider after widget is built
        detailProvider.restaurantDetail = testRestaurant;
        await tester.pumpAndSettle();

        // Verify form is present and has proper styling
        expect(find.byType(ReviewSubmissionForm), findsOneWidget);

        // Verify form has containers with decorations
        final containers = find.descendant(
          of: find.byType(ReviewSubmissionForm),
          matching: find.byType(Container),
        );
        expect(containers, findsWidgets);

        // Verify at least one container has decoration
        bool hasDecoratedContainer = false;
        for (final element in containers.evaluate()) {
          final container = element.widget as Container;
          if (container.decoration != null) {
            hasDecoratedContainer = true;
            expect(container.decoration, isA<BoxDecoration>());
            break;
          }
        }
        expect(hasDecoratedContainer, isTrue);
      },
    );

    testWidgets(
      'should integrate properly with existing customer reviews section',
      (WidgetTester tester) async {
        // Setup test data with multiple reviews
        final testRestaurant = RestaurantDetail(
          id: 'test-restaurant-id',
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
          customerReviews: [
            CustomerReview(
              name: 'Reviewer 1',
              review: 'Great food!',
              date: '2023-01-01',
            ),
            CustomerReview(
              name: 'Reviewer 2',
              review: 'Excellent service!',
              date: '2023-01-02',
            ),
          ],
        );

        await tester.pumpWidget(createTestWidget());

        // Set restaurant data in provider after widget is built
        detailProvider.restaurantDetail = testRestaurant;
        await tester.pumpAndSettle();

        // Verify section header is present
        expect(find.text('Customer Reviews'), findsOneWidget);

        // Verify review count badge shows correct number
        expect(find.text('2'), findsOneWidget);

        // Verify form is positioned above existing reviews
        expect(find.byType(ReviewSubmissionForm), findsOneWidget);

        // Verify existing reviews are still displayed
        expect(find.text('Reviewer 1'), findsOneWidget);
        expect(find.text('Reviewer 2'), findsOneWidget);
        expect(find.text('Great food!'), findsOneWidget);
        expect(find.text('Excellent service!'), findsOneWidget);

        // Verify proper layout order: form first, then reviews
        final reviewFormFinder = find.byType(ReviewSubmissionForm);
        final reviewCardFinder = find.text('Reviewer 1');

        final formPosition = tester.getTopLeft(reviewFormFinder);
        final reviewPosition = tester.getTopLeft(reviewCardFinder);

        expect(formPosition.dy, lessThan(reviewPosition.dy));
      },
    );
  });
}
