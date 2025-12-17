import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/search_provider.dart';
import 'package:restaurant_app/screens/search_screen.dart';
import 'package:restaurant_app/services/api_service.dart';
import 'package:restaurant_app/services/api_response.dart';
import 'package:restaurant_app/model/restaurant_search_response.dart';

/// Mock ApiService for testing error scenarios
class MockErrorApiService extends ApiService {
  String errorMessage;

  MockErrorApiService(this.errorMessage);

  @override
  Future<ApiResponse<RestaurantSearchResponse>> searchRestaurants(
      String query) async {
    return ApiResponse.failure(
      errorMessage,
      data: RestaurantSearchResponse(
        error: true,
        founded: 0,
        restaurants: [],
      ),
    );
  }

  @override
  Future<bool> hasInternetConnection() async {
    return !errorMessage.toLowerCase().contains('internet');
  }

  @override
  void dispose() {}
}

void main() {
  group('SearchScreen Error Handling', () {
    testWidgets('should display network error UI correctly',
        (WidgetTester tester) async {
      final mockApiService = MockErrorApiService('No internet connection');
      final searchProvider = SearchProvider(apiService: mockApiService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SearchProvider>.value(
            value: searchProvider,
            child: SearchScreen(),
          ),
        ),
      );

      // Trigger a search to cause error
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump(Duration(milliseconds: 600)); // Wait for debounce
      await tester.pump(); // Allow error state to update

      // Verify error UI elements
      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Retry Search'), findsOneWidget);
      expect(find.text('Check Connection'), findsOneWidget);
      expect(find.text('New Search'), findsOneWidget);
    });

    testWidgets('should display timeout error UI correctly',
        (WidgetTester tester) async {
      final mockApiService = MockErrorApiService('Request timed out');
      final searchProvider = SearchProvider(apiService: mockApiService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SearchProvider>.value(
            value: searchProvider,
            child: SearchScreen(),
          ),
        ),
      );

      // Trigger a search to cause error
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump(Duration(milliseconds: 600)); // Wait for debounce
      await tester.pump(); // Allow error state to update

      // Verify error UI elements
      expect(find.text('Request Timed Out'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.text('Retry Search'), findsOneWidget);
    });

    testWidgets('should display server error UI correctly',
        (WidgetTester tester) async {
      final mockApiService = MockErrorApiService('Server error 500');
      final searchProvider = SearchProvider(apiService: mockApiService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SearchProvider>.value(
            value: searchProvider,
            child: SearchScreen(),
          ),
        ),
      );

      // Trigger a search to cause error
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump(Duration(milliseconds: 600)); // Wait for debounce
      await tester.pump(); // Allow error state to update

      // Verify error UI elements
      expect(find.text('Server Error'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('Retry Search'), findsOneWidget);
    });

    testWidgets('should handle retry button tap', (WidgetTester tester) async {
      final mockApiService = MockErrorApiService('Network error');
      final searchProvider = SearchProvider(apiService: mockApiService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SearchProvider>.value(
            value: searchProvider,
            child: SearchScreen(),
          ),
        ),
      );

      // Trigger a search to cause error
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump(Duration(milliseconds: 600)); // Wait for debounce
      await tester.pump(); // Allow error state to update

      // Tap retry button
      await tester.tap(find.text('Retry Search'));
      await tester.pump();

      // Verify retry was attempted (error should still be there since mock always fails)
      expect(find.text('Retry Search'), findsOneWidget);
    });

    testWidgets('should handle new search button tap',
        (WidgetTester tester) async {
      final mockApiService = MockErrorApiService('Network error');
      final searchProvider = SearchProvider(apiService: mockApiService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SearchProvider>.value(
            value: searchProvider,
            child: SearchScreen(),
          ),
        ),
      );

      // Trigger a search to cause error
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump(Duration(milliseconds: 600)); // Wait for debounce
      await tester.pump(); // Allow error state to update

      // Tap new search button
      await tester.tap(find.text('New Search'));
      await tester.pump();

      // Verify search field was cleared and error state reset
      expect(find.text('Search for restaurants'), findsOneWidget);
    });
  });
}
