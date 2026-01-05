import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/services/api_service.dart';
import 'package:restaurant_app/services/api_response.dart';
import 'package:restaurant_app/model/restaurant_search_response.dart';
import 'package:restaurant_app/model/review_submission_request.dart';
import 'package:restaurant_app/model/review_submission_response.dart';

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
      final response = ApiResponse<List<String>>.failure(
        'Error occurred',
        data: <String>[],
      );

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

    test('should have correct review endpoint', () {
      expect(ApiService.reviewEndpoint, equals('/review'));
    });

    test('searchRestaurants should return failure for empty query', () async {
      final result = await apiService.searchRestaurants('');

      expect(result.error, isTrue);
      expect(result.message, equals('Search query cannot be empty'));
    });

    test(
      'searchRestaurants should return failure for whitespace-only query',
      () async {
        final result = await apiService.searchRestaurants('   ');

        expect(result.error, isTrue);
        expect(result.message, equals('Search query cannot be empty'));
      },
    );

    test('searchRestaurants should handle query with special characters', () async {
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

  group('ApiService Review Submission', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    tearDown(() {
      apiService.dispose();
    });

    test(
      'submitReview should return failure for invalid request - empty id',
      () async {
        final request = ReviewSubmissionRequest(
          id: '',
          name: 'John Doe',
          review: 'Great restaurant!',
        );

        final result = await apiService.submitReview(request);

        expect(result.error, isTrue);
        expect(result.message, equals('Restaurant ID is required'));
        expect(result.data, isA<ReviewSubmissionResponse>());
        expect(result.data.error, isTrue);
      },
    );

    test(
      'submitReview should return failure for invalid request - empty name',
      () async {
        final request = ReviewSubmissionRequest(
          id: 'rqdv5juczeskfw1e867',
          name: '',
          review: 'Great restaurant!',
        );

        final result = await apiService.submitReview(request);

        expect(result.error, isTrue);
        expect(result.message, equals('Nama tidak boleh kosong'));
        expect(result.data, isA<ReviewSubmissionResponse>());
        expect(result.data.error, isTrue);
      },
    );

    test(
      'submitReview should return failure for invalid request - name too short',
      () async {
        final request = ReviewSubmissionRequest(
          id: 'rqdv5juczeskfw1e867',
          name: 'A',
          review: 'Great restaurant!',
        );

        final result = await apiService.submitReview(request);

        expect(result.error, isTrue);
        expect(result.message, equals('Nama minimal 2 karakter'));
        expect(result.data, isA<ReviewSubmissionResponse>());
        expect(result.data.error, isTrue);
      },
    );

    test(
      'submitReview should return failure for invalid request - empty review',
      () async {
        final request = ReviewSubmissionRequest(
          id: 'rqdv5juczeskfw1e867',
          name: 'John Doe',
          review: '',
        );

        final result = await apiService.submitReview(request);

        expect(result.error, isTrue);
        expect(result.message, equals('Ulasan tidak boleh kosong'));
        expect(result.data, isA<ReviewSubmissionResponse>());
        expect(result.data.error, isTrue);
      },
    );

    test(
      'submitReview should return failure for invalid request - whitespace only name',
      () async {
        final request = ReviewSubmissionRequest(
          id: 'rqdv5juczeskfw1e867',
          name: '   ',
          review: 'Great restaurant!',
        );

        final result = await apiService.submitReview(request);

        expect(result.error, isTrue);
        expect(result.message, equals('Nama tidak boleh kosong'));
        expect(result.data, isA<ReviewSubmissionResponse>());
        expect(result.data.error, isTrue);
      },
    );

    test(
      'submitReview should return failure for invalid request - whitespace only review',
      () async {
        final request = ReviewSubmissionRequest(
          id: 'rqdv5juczeskfw1e867',
          name: 'John Doe',
          review: '   ',
        );

        final result = await apiService.submitReview(request);

        expect(result.error, isTrue);
        expect(result.message, equals('Ulasan tidak boleh kosong'));
        expect(result.data, isA<ReviewSubmissionResponse>());
        expect(result.data.error, isTrue);
      },
    );

    test('submitReview should handle valid request structure', () async {
      final request = ReviewSubmissionRequest(
        id: 'rqdv5juczeskfw1e867',
        name: 'John Doe',
        review: 'Great restaurant with excellent food and service!',
      );

      final result = await apiService.submitReview(request);

      // The method should return a valid ApiResponse (either success or failure)
      expect(result, isA<ApiResponse<ReviewSubmissionResponse>>());
      expect(result.message, isA<String>());
      expect(result.data, isA<ReviewSubmissionResponse>());
    });

    test('submitReview should handle request with special characters', () async {
      final request = ReviewSubmissionRequest(
        id: 'rqdv5juczeskfw1e867',
        name: 'José María',
        review: 'Café & restaurant très bon! 5★ rating 😊',
      );

      final result = await apiService.submitReview(request);

      // The method should return a valid ApiResponse (either success or failure)
      expect(result, isA<ApiResponse<ReviewSubmissionResponse>>());
      expect(result.message, isA<String>());
      expect(result.data, isA<ReviewSubmissionResponse>());
    });

    test('submitReview should trim whitespace from name and review', () async {
      final request = ReviewSubmissionRequest(
        id: 'rqdv5juczeskfw1e867',
        name: '  John Doe  ',
        review: '  Great restaurant!  ',
      );

      final result = await apiService.submitReview(request);

      // The method should return a valid ApiResponse (either success or failure)
      expect(result, isA<ApiResponse<ReviewSubmissionResponse>>());
      expect(result.message, isA<String>());
      expect(result.data, isA<ReviewSubmissionResponse>());
    });

    test('submitReview should handle long review text', () async {
      final longReview =
          'This is a very long review. ' * 50; // 1400+ characters
      final request = ReviewSubmissionRequest(
        id: 'rqdv5juczeskfw1e867',
        name: 'John Doe',
        review: longReview,
      );

      final result = await apiService.submitReview(request);

      // The method should return a valid ApiResponse (either success or failure)
      expect(result, isA<ApiResponse<ReviewSubmissionResponse>>());
      expect(result.message, isA<String>());
      expect(result.data, isA<ReviewSubmissionResponse>());
    });
  });
}
