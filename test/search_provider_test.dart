import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/providers/search_provider.dart';
import 'package:restaurant_app/services/api_service.dart';
import 'package:restaurant_app/services/api_response.dart';
import 'package:restaurant_app/model/restaurant.dart';
import 'package:restaurant_app/model/restaurant_search_response.dart';

/// Mock ApiService for testing SearchProvider
class MockApiService extends ApiService {
  bool shouldReturnError = false;
  String errorMessage = 'Test error';
  List<Restaurant> mockRestaurants = [];
  bool shouldTimeout = false;
  Duration? customDelay;

  @override
  Future<ApiResponse<RestaurantSearchResponse>> searchRestaurants(
      String query) async {
    // Simulate network delay
    if (customDelay != null) {
      await Future.delayed(customDelay!);
    }

    if (shouldTimeout) {
      throw TimeoutException('Request timed out', Duration(seconds: 10));
    }

    if (shouldReturnError) {
      return ApiResponse.failure(
        errorMessage,
        data: RestaurantSearchResponse(
          error: true,
          founded: 0,
          restaurants: [],
        ),
      );
    }

    // Simulate search logic - filter mock restaurants by query
    final filteredRestaurants = mockRestaurants
        .where((restaurant) =>
            restaurant.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    final searchResponse = RestaurantSearchResponse(
      error: false,
      founded: filteredRestaurants.length,
      restaurants: filteredRestaurants,
    );

    return ApiResponse.success(
      searchResponse,
      message: 'Search successful',
    );
  }

  @override
  Future<bool> hasInternetConnection() async {
    return !shouldReturnError; // Simulate no connection when error is set
  }

  @override
  void dispose() {
    // Mock implementation - no actual cleanup needed
  }
}

void main() {
  group('SearchProvider', () {
    late SearchProvider searchProvider;
    late MockApiService mockApiService;

    // Sample test data
    final testRestaurants = [
      Restaurant(
        id: '1',
        name: 'Test Cafe',
        description: 'A test cafe',
        pictureId: 'pic1',
        city: 'Test City',
        rating: 4.5,
      ),
      Restaurant(
        id: '2',
        name: 'Pizza Place',
        description: 'Best pizza in town',
        pictureId: 'pic2',
        city: 'Test City',
        rating: 4.2,
      ),
      Restaurant(
        id: '3',
        name: 'Burger Joint',
        description: 'Delicious burgers',
        pictureId: 'pic3',
        city: 'Test City',
        rating: 4.0,
      ),
    ];

    setUp(() {
      mockApiService = MockApiService();
      mockApiService.mockRestaurants = testRestaurants;
      searchProvider = SearchProvider(apiService: mockApiService);
    });

    tearDown(() {
      searchProvider.dispose();
    });

    test('should create SearchProvider instance', () {
      expect(searchProvider, isA<SearchProvider>());
    });

    test('should have initial state values', () {
      expect(searchProvider.searchResults, isEmpty);
      expect(searchProvider.isLoading, isFalse);
      expect(searchProvider.errorMessage, isNull);
      expect(searchProvider.currentQuery, isEmpty);
      expect(searchProvider.hasError, isFalse);
      expect(searchProvider.hasResults, isFalse);
      expect(searchProvider.isEmpty, isTrue);
    });

    test('should not trigger search for queries shorter than 3 characters', () {
      searchProvider.searchRestaurants('ab');

      expect(searchProvider.currentQuery, equals('ab'));
      expect(searchProvider.isLoading, isFalse);
      expect(searchProvider.searchResults, isEmpty);
    });

    test('should clear results when query is too short', () async {
      // First perform a valid search
      searchProvider.searchRestaurants('cafe');
      await Future.delayed(Duration(milliseconds: 600)); // Wait for debounce

      // Then search with short query
      searchProvider.searchRestaurants('ab');

      expect(searchProvider.currentQuery, equals('ab'));
      expect(searchProvider.searchResults, isEmpty);
    });

    test('should perform search with debouncing for valid query', () async {
      searchProvider.searchRestaurants('cafe');

      // Should not be loading immediately due to debouncing
      expect(searchProvider.isLoading, isFalse);
      expect(searchProvider.currentQuery, equals('cafe'));

      // Wait for debounce timer
      await Future.delayed(Duration(milliseconds: 600));

      // Should have completed search
      expect(searchProvider.isLoading, isFalse);
      expect(searchProvider.searchResults, isNotEmpty);
      expect(searchProvider.searchResults.first.name, contains('Cafe'));
    });

    test('should cancel previous search when new search is initiated',
        () async {
      // Start first search
      searchProvider.searchRestaurants('pizza');

      // Immediately start second search before first completes
      searchProvider.searchRestaurants('cafe');

      // Wait for debounce
      await Future.delayed(Duration(milliseconds: 600));

      // Should have results for 'cafe', not 'pizza'
      expect(searchProvider.currentQuery, equals('cafe'));
      expect(searchProvider.searchResults.first.name, contains('Cafe'));
    });

    test('should handle search results correctly', () async {
      searchProvider.searchRestaurants('pizza');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.hasResults, isTrue);
      expect(searchProvider.searchResults.length, equals(1));
      expect(searchProvider.searchResults.first.name, equals('Pizza Place'));
      expect(searchProvider.hasError, isFalse);
    });

    test('should handle empty search results', () async {
      searchProvider.searchRestaurants('nonexistent');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.searchResults, isEmpty);
      expect(searchProvider.hasResults, isFalse);
      expect(searchProvider.hasError, isFalse);
    });

    test('should handle search errors', () async {
      mockApiService.shouldReturnError = true;
      mockApiService.errorMessage = 'Network error';

      searchProvider.searchRestaurants('test');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.hasError, isTrue);
      expect(searchProvider.errorMessage, equals('Network error'));
      expect(searchProvider.searchResults, isEmpty);
      expect(searchProvider.isLoading, isFalse);
    });

    test('should categorize network errors correctly', () async {
      mockApiService.shouldReturnError = true;
      mockApiService.errorMessage = 'No internet connection';

      searchProvider.searchRestaurants('test');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.hasError, isTrue);
      expect(searchProvider.isNetworkError, isTrue);
      expect(searchProvider.errorType, equals(SearchErrorType.network));
    });

    test('should categorize timeout errors correctly', () async {
      mockApiService.shouldReturnError = true;
      mockApiService.errorMessage = 'Request timed out';

      searchProvider.searchRestaurants('test');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.hasError, isTrue);
      expect(searchProvider.isTimeoutError, isTrue);
      expect(searchProvider.errorType, equals(SearchErrorType.timeout));
    });

    test('should categorize server errors correctly', () async {
      mockApiService.shouldReturnError = true;
      mockApiService.errorMessage = 'Server error 500';

      searchProvider.searchRestaurants('test');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.hasError, isTrue);
      expect(searchProvider.isServerError, isTrue);
      expect(searchProvider.errorType, equals(SearchErrorType.server));
    });

    test('should categorize API errors correctly', () async {
      mockApiService.shouldReturnError = true;
      mockApiService.errorMessage = 'API service unavailable';

      searchProvider.searchRestaurants('test');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.hasError, isTrue);
      expect(searchProvider.isApiError, isTrue);
      expect(searchProvider.errorType, equals(SearchErrorType.api));
    });

    test('should provide user-friendly error messages', () async {
      mockApiService.shouldReturnError = true;
      mockApiService.errorMessage = 'No internet connection';

      searchProvider.searchRestaurants('test');
      await Future.delayed(Duration(milliseconds: 600));

      final userMessage = searchProvider.getUserFriendlyErrorMessage();
      expect(userMessage, contains('network settings'));
      expect(userMessage, isNot(equals(mockApiService.errorMessage)));
    });

    test('should provide appropriate error icons', () async {
      mockApiService.shouldReturnError = true;
      mockApiService.errorMessage = 'No internet connection';

      searchProvider.searchRestaurants('test');
      await Future.delayed(Duration(milliseconds: 600));

      final errorIcon = searchProvider.getErrorIcon();
      expect(errorIcon, equals('wifi_off'));
    });

    test('should check connectivity before retrying network errors', () async {
      mockApiService.shouldReturnError = true;
      mockApiService.errorMessage = 'No internet connection';

      // Perform search that will fail with network error
      searchProvider.searchRestaurants('test');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.isNetworkError, isTrue);

      // Retry should check connectivity first
      await searchProvider.retry();

      // Should still have error since mock service returns false for hasInternetConnection
      expect(searchProvider.hasError, isTrue);
      expect(searchProvider.errorMessage, contains('network settings'));
    });

    test('should set loading state during search', () async {
      // Add delay to mock service to test loading state
      mockApiService.customDelay = Duration(milliseconds: 100);

      searchProvider.searchRestaurants('test');
      await Future.delayed(Duration(milliseconds: 600)); // Wait for debounce

      // Should be loading during API call
      expect(searchProvider.isLoading, isTrue);

      // Wait for API call to complete
      await Future.delayed(Duration(milliseconds: 200));

      expect(searchProvider.isLoading, isFalse);
    });

    test('should clear search results and state', () async {
      // First perform a search
      searchProvider.searchRestaurants('cafe');
      await Future.delayed(Duration(milliseconds: 600));

      // Verify search has results
      expect(searchProvider.hasResults, isTrue);
      expect(searchProvider.currentQuery, isNotEmpty);

      // Clear search
      searchProvider.clearSearch();

      expect(searchProvider.searchResults, isEmpty);
      expect(searchProvider.currentQuery, isEmpty);
      expect(searchProvider.errorMessage, isNull);
      expect(searchProvider.isLoading, isFalse);
      expect(searchProvider.isEmpty, isTrue);
    });

    test('should retry last search query', () async {
      // Set up error condition
      mockApiService.shouldReturnError = true;

      // Perform search that will fail
      searchProvider.searchRestaurants('cafe');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.hasError, isTrue);

      // Fix error condition and retry
      mockApiService.shouldReturnError = false;
      await searchProvider.retry();

      expect(searchProvider.hasError, isFalse);
      expect(searchProvider.hasResults, isTrue);
    });

    test('should not retry if no previous query exists', () async {
      await searchProvider.retry();

      expect(searchProvider.searchResults, isEmpty);
      expect(searchProvider.isLoading, isFalse);
    });

    test('should not retry if previous query was too short', () async {
      searchProvider.searchRestaurants('ab'); // Too short
      await searchProvider.retry();

      expect(searchProvider.searchResults, isEmpty);
      expect(searchProvider.isLoading, isFalse);
    });

    test('should clear error state', () async {
      // Set up error condition
      mockApiService.shouldReturnError = true;

      searchProvider.searchRestaurants('test');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.hasError, isTrue);

      // Clear error
      searchProvider.clearError();

      expect(searchProvider.hasError, isFalse);
      expect(searchProvider.errorMessage, isNull);
    });

    test('should check connectivity', () async {
      final hasConnection = await searchProvider.checkConnectivity();
      expect(hasConnection, isTrue);

      // Simulate no connection
      mockApiService.shouldReturnError = true;
      final hasConnectionError = await searchProvider.checkConnectivity();
      expect(hasConnectionError, isFalse);
    });

    test('should handle timeout exceptions', () async {
      mockApiService.shouldTimeout = true;

      searchProvider.searchRestaurants('test');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.hasError, isTrue);
      expect(searchProvider.errorMessage, contains('unexpected error'));
    });

    test('should notify listeners on state changes', () async {
      int notificationCount = 0;

      searchProvider.addListener(() {
        notificationCount++;
      });

      // Perform search
      searchProvider.searchRestaurants('cafe');
      await Future.delayed(Duration(milliseconds: 600));

      // Should have notified listeners multiple times (loading start, loading end, results)
      expect(notificationCount, greaterThan(0));
    });

    test('should properly dispose resources', () {
      // Create a separate provider for this test to avoid double disposal
      final testProvider = SearchProvider(apiService: mockApiService);

      // This test ensures dispose doesn't throw exceptions
      expect(() => testProvider.dispose(), returnsNormally);
    });

    test('should trim query strings', () {
      searchProvider.searchRestaurants('  cafe  ');
      expect(searchProvider.currentQuery, equals('cafe'));
    });

    test('should handle case-insensitive search', () async {
      searchProvider.searchRestaurants('CAFE');
      await Future.delayed(Duration(milliseconds: 600));

      expect(searchProvider.hasResults, isTrue);
      expect(searchProvider.searchResults.first.name, contains('Cafe'));
    });
  });
}
