import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/services/api_service.dart';
import 'package:restaurant_app/services/api_response.dart';
import 'package:restaurant_app/model/restaurant.dart';

/// Mock ApiService for testing RestaurantProvider
class MockApiService extends ApiService {
  bool shouldReturnError = false;
  String errorMessage = 'Test error';
  List<Restaurant> mockRestaurants = [];

  @override
  Future<ApiResponse<List<Restaurant>>> getRestaurants() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldReturnError) {
      return ApiResponse.failure(errorMessage, data: <Restaurant>[]);
    }

    return ApiResponse.success(mockRestaurants, message: 'Success');
  }

  @override
  Future<bool> hasInternetConnection() async {
    return !shouldReturnError;
  }

  @override
  void dispose() {
    // Mock implementation - no actual cleanup needed
  }
}

void main() {
  group('RestaurantProvider', () {
    late RestaurantProvider restaurantProvider;
    late MockApiService mockApiService;

    // Sample test data
    final testRestaurants = [
      Restaurant(
        id: '1',
        name: 'Test Restaurant 1',
        description: 'A test restaurant',
        pictureId: 'pic1',
        city: 'Test City',
        rating: 4.5,
      ),
      Restaurant(
        id: '2',
        name: 'Test Restaurant 2',
        description: 'Another test restaurant',
        pictureId: 'pic2',
        city: 'Test City',
        rating: 4.2,
      ),
      Restaurant(
        id: '3',
        name: 'Test Restaurant 3',
        description: 'Third test restaurant',
        pictureId: 'pic3',
        city: 'Test City',
        rating: 4.0,
      ),
    ];

    setUp(() {
      mockApiService = MockApiService();
      mockApiService.mockRestaurants = testRestaurants;
      restaurantProvider = RestaurantProvider(apiService: mockApiService);
    });

    tearDown(() {
      restaurantProvider.dispose();
    });

    /// Skenario 1: Memastikan state awal provider harus didefinisikan
    test('should have defined initial state', () {
      // Verify that the provider has proper initial state
      expect(restaurantProvider.restaurants, isEmpty);
      expect(restaurantProvider.isLoading, isFalse);
      expect(restaurantProvider.errorMessage, isNull);
      expect(restaurantProvider.hasError, isFalse);
      expect(restaurantProvider.hasData, isFalse);
    });

    /// Skenario 2: Memastikan harus mengembalikan daftar restoran ketika pengambilan data API berhasil
    test(
      'should return restaurant list when API fetch is successful',
      () async {
        // Ensure mock API will return success
        mockApiService.shouldReturnError = false;

        // Fetch restaurants
        await restaurantProvider.fetchRestaurants();

        // Verify that restaurants were fetched successfully
        expect(restaurantProvider.restaurants, isNotEmpty);
        expect(restaurantProvider.restaurants.length, equals(3));
        expect(restaurantProvider.restaurants, equals(testRestaurants));
        expect(restaurantProvider.hasData, isTrue);
        expect(restaurantProvider.isLoading, isFalse);
        expect(restaurantProvider.hasError, isFalse);
        expect(restaurantProvider.errorMessage, isNull);
      },
    );

    /// Skenario 3: Memastikan harus mengembalikan kesalahan ketika pengambilan data API gagal
    test('should return error when API fetch fails', () async {
      // Set up mock API to return error
      mockApiService.shouldReturnError = true;
      mockApiService.errorMessage = 'Failed to fetch restaurants';

      // Fetch restaurants
      await restaurantProvider.fetchRestaurants();

      // Verify that error was handled correctly
      expect(restaurantProvider.hasError, isTrue);
      expect(
        restaurantProvider.errorMessage,
        equals('Failed to fetch restaurants'),
      );
      expect(restaurantProvider.restaurants, isEmpty);
      expect(restaurantProvider.hasData, isFalse);
      expect(restaurantProvider.isLoading, isFalse);
    });

    // Additional tests for better coverage

    test('should set loading state during fetch', () async {
      mockApiService.shouldReturnError = false;

      // Start fetching (don't await yet)
      final fetchFuture = restaurantProvider.fetchRestaurants();

      // Give it a moment to start
      await Future.delayed(const Duration(milliseconds: 10));

      // Should be loading
      expect(restaurantProvider.isLoading, isTrue);

      // Wait for completion
      await fetchFuture;

      // Should no longer be loading
      expect(restaurantProvider.isLoading, isFalse);
    });

    test('should clear error on successful retry', () async {
      // First, cause an error
      mockApiService.shouldReturnError = true;
      await restaurantProvider.fetchRestaurants();

      expect(restaurantProvider.hasError, isTrue);

      // Fix the error condition and retry
      mockApiService.shouldReturnError = false;
      await restaurantProvider.retry();

      // Error should be cleared
      expect(restaurantProvider.hasError, isFalse);
      expect(restaurantProvider.errorMessage, isNull);
      expect(restaurantProvider.hasData, isTrue);
    });

    test('should notify listeners on state changes', () async {
      int notificationCount = 0;

      restaurantProvider.addListener(() {
        notificationCount++;
      });

      await restaurantProvider.fetchRestaurants();

      // Should have notified listeners multiple times
      // (loading start, loading end, data update)
      expect(notificationCount, greaterThan(0));
    });

    test('should check connectivity', () async {
      final hasConnection = await restaurantProvider.checkConnectivity();
      expect(hasConnection, isTrue);

      // Simulate no connection
      mockApiService.shouldReturnError = true;
      final hasConnectionError = await restaurantProvider.checkConnectivity();
      expect(hasConnectionError, isFalse);
    });

    test('should clear error state manually', () async {
      // Cause an error
      mockApiService.shouldReturnError = true;
      await restaurantProvider.fetchRestaurants();

      expect(restaurantProvider.hasError, isTrue);

      // Clear error manually
      restaurantProvider.clearError();

      expect(restaurantProvider.hasError, isFalse);
      expect(restaurantProvider.errorMessage, isNull);
    });
  });
}
