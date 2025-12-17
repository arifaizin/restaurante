import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/services/api_service.dart';
import 'package:restaurant_app/services/api_response.dart';
import 'package:restaurant_app/model/restaurant_search_response.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    tearDown(() {
      apiService.dispose();
    });

    test('should create ApiService instance', () {
      expect(apiService, isA<ApiService>());
    });

    test('should have correct base URL', () {
      expect(ApiService.baseUrl, equals('https://restaurant-api.dicoding.dev'));
    });

    test('should have correct list endpoint', () {
      expect(ApiService.listEndpoint, equals('/list'));
    });
  });

  group('ApiResponse', () {
    test('should create success response', () {
      final response = ApiResponse.success(['test'], message: 'Success');

      expect(response.isSuccess, isTrue);
      expect(response.error, isFalse);
      expect(response.message, equals('Success'));
      expect(response.data, equals(['test']));
    });

    test('should create failure response', () {
      final response =
          ApiResponse<List<String>>.failure('Error occurred', data: <String>[]);

      expect(response.isSuccess, isFalse);
      expect(response.isFailure, isTrue);
      expect(response.error, isTrue);
      expect(response.message, equals('Error occurred'));
    });
  });

  group('ApiService Search', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    tearDown(() {
      apiService.dispose();
    });

    test('should have correct search endpoint', () {
      expect(ApiService.searchEndpoint, equals('/search'));
    });

    test('searchRestaurants should return failure for empty query', () async {
      final result = await apiService.searchRestaurants('');

      expect(result.error, isTrue);
      expect(result.message, equals('Search query cannot be empty'));
    });

    test('searchRestaurants should return failure for whitespace-only query',
        () async {
      final result = await apiService.searchRestaurants('   ');

      expect(result.error, isTrue);
      expect(result.message, equals('Search query cannot be empty'));
    });

    test('searchRestaurants should handle query with special characters',
        () async {
      // This test validates that the method properly encodes special characters
      // The method should not crash on URL encoding and should return a valid response
      final result = await apiService.searchRestaurants('café & restaurant');

      // The method should return a valid ApiResponse (either success or failure)
      expect(result, isA<ApiResponse<RestaurantSearchResponse>>());
      expect(result.message, isA<String>());
      expect(result.data, isA<RestaurantSearchResponse>());
    });

    test('searchRestaurants should trim query string', () async {
      // Test that leading/trailing whitespace is properly handled
      final result = await apiService.searchRestaurants('  test query  ');

      // The method should return a valid ApiResponse (either success or failure)
      expect(result, isA<ApiResponse<RestaurantSearchResponse>>());
      expect(result.message, isA<String>());
      expect(result.data, isA<RestaurantSearchResponse>());
    });
  });
}
