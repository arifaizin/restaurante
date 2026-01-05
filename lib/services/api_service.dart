import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_response.dart';
import '../model/restaurant.dart';
import '../model/restaurant_detail_response.dart';
import '../model/restaurant_search_response.dart';
import '../model/review_submission_request.dart';
import '../model/review_submission_response.dart';

class ApiService {
  static const baseUrl = 'https://restaurant-api.dicoding.dev';
  static const listEndpoint = '/list';
  static const detailEndpoint = '/detail';
  static const searchEndpoint = '/search';
  static const reviewEndpoint = '/review';
  static const timeoutDuration = Duration(seconds: 10);

  final http.Client _client;
  final Connectivity _connectivity;

  ApiService({http.Client? client, Connectivity? connectivity})
      : _client = client ?? http.Client(),
        _connectivity = connectivity ?? Connectivity();

  /// Fetches the list of restaurants from the API
  Future<ApiResponse<List<Restaurant>>> getRestaurants() async {
    try {
      final uri = Uri.parse('$baseUrl$listEndpoint');

      final response = await _client.get(uri).timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
            'Request timed out. Please check your connection and try again.',
            timeoutDuration,
          );
        },
      );

      return _handleResponse<List<Restaurant>>(
        response,
        (json) => _parseRestaurantList(json),
      );
    } on TimeoutException {
      return ApiResponse.failure(
        'Connection timeout. Please check your internet connection and try again.',
      );
    } on SocketException {
      return ApiResponse.failure(
        'No internet connection. Please check your network settings and try again.',
      );
    } on http.ClientException {
      return ApiResponse.failure(
        'Failed to connect to server. Please check your internet connection and try again later.',
      );
    } on FormatException {
      return ApiResponse.failure(
        'Invalid response format from server. Please try again later.',
      );
    } catch (e) {
      return ApiResponse.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Fetches detailed information for a specific restaurant by ID
  Future<ApiResponse<RestaurantDetailResponse>> getRestaurantDetail(
    String id,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$detailEndpoint/$id');

      final response = await _client.get(uri).timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
            'Request timed out. Please check your connection and try again.',
            timeoutDuration,
          );
        },
      );

      return _handleResponse<RestaurantDetailResponse>(
        response,
        (json) => RestaurantDetailResponse.fromJson(json),
      );
    } on TimeoutException {
      return ApiResponse.failure(
        'Connection timeout. Please check your internet connection and try again.',
      );
    } on SocketException {
      return ApiResponse.failure(
        'No internet connection. Please check your network settings and try again.',
      );
    } on http.ClientException {
      return ApiResponse.failure(
        'Failed to connect to server. Please check your internet connection and try again later.',
      );
    } on FormatException {
      return ApiResponse.failure(
        'Invalid response format from server. Please try again later.',
      );
    } catch (e) {
      return ApiResponse.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Searches for restaurants using the provided query string
  Future<ApiResponse<RestaurantSearchResponse>> searchRestaurants(
    String query,
  ) async {
    try {
      // Validate query parameter
      if (query.trim().isEmpty) {
        return ApiResponse.failure(
          'Search query cannot be empty',
          data: RestaurantSearchResponse(
            error: true,
            founded: 0,
            restaurants: [],
          ),
        );
      }

      // Properly encode the query parameter for URL
      final encodedQuery = Uri.encodeQueryComponent(query.trim());
      final uri = Uri.parse('$baseUrl$searchEndpoint?q=$encodedQuery');

      final response = await _client.get(uri).timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
            'Search request timed out. Please check your connection and try again.',
            timeoutDuration,
          );
        },
      );

      return _handleResponse<RestaurantSearchResponse>(
        response,
        (json) => RestaurantSearchResponse.fromJson(json),
      );
    } on TimeoutException {
      return ApiResponse.failure(
        'Search timeout. Please check your internet connection and try again.',
        data: RestaurantSearchResponse(
          error: true,
          founded: 0,
          restaurants: [],
        ),
      );
    } on SocketException {
      return ApiResponse.failure(
        'No internet connection. Please check your network settings and try again.',
        data: RestaurantSearchResponse(
          error: true,
          founded: 0,
          restaurants: [],
        ),
      );
    } on http.ClientException {
      return ApiResponse.failure(
        'Failed to connect to server. Please check your internet connection and try again later.',
        data: RestaurantSearchResponse(
          error: true,
          founded: 0,
          restaurants: [],
        ),
      );
    } on FormatException {
      return ApiResponse.failure(
        'Invalid search response format from server. Please try again later.',
        data: RestaurantSearchResponse(
          error: true,
          founded: 0,
          restaurants: [],
        ),
      );
    } catch (e) {
      return ApiResponse.failure(
        'An unexpected search error occurred: ${e.toString()}',
        data: RestaurantSearchResponse(
          error: true,
          founded: 0,
          restaurants: [],
        ),
      );
    }
  }

  /// Submits a review for a restaurant
  Future<ApiResponse<ReviewSubmissionResponse>> submitReview(
    ReviewSubmissionRequest request,
  ) async {
    try {
      // Validate request data
      if (!request.isValid()) {
        final validationError = request.getValidationError();
        return ApiResponse.failure(
          validationError ?? 'Invalid review data',
          data: ReviewSubmissionResponse(
            error: true,
            message: validationError ?? 'Invalid review data',
            customerReviews: [],
          ),
        );
      }

      final uri = Uri.parse('$baseUrl$reviewEndpoint');
      final requestBody = json.encode(request.toJson());

      final response = await _client
          .post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      )
          .timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
            'Review submission timed out. Please check your connection and try again.',
            timeoutDuration,
          );
        },
      );

      // Special handling for review submission response
      try {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> jsonData = json.decode(response.body);

          // Check if API returned an error
          if (jsonData['error'] == true) {
            return ApiResponse.failure(
              jsonData['message'] ?? 'API returned an error',
              data: ReviewSubmissionResponse(
                error: true,
                message: jsonData['message'] ?? 'API returned an error',
                customerReviews: [],
              ),
            );
          }

          final reviewResponse = ReviewSubmissionResponse.fromJson(jsonData);

          return ApiResponse.success(
            reviewResponse,
            message: jsonData['message'] ?? 'Success',
          );
        } else {
          return ApiResponse.failure(
            _getHttpErrorMessage(response.statusCode),
            data: ReviewSubmissionResponse(
              error: true,
              message: _getHttpErrorMessage(response.statusCode),
              customerReviews: [],
            ),
          );
        }
      } on FormatException catch (_) {
        return ApiResponse.failure(
          'Invalid response format from server. Please try again later.',
          data: ReviewSubmissionResponse(
            error: true,
            message: 'Invalid response format',
            customerReviews: [],
          ),
        );
      } catch (e) {
        return ApiResponse.failure(
          'Failed to parse server response: $e',
          data: ReviewSubmissionResponse(
            error: true,
            message: 'Failed to parse response',
            customerReviews: [],
          ),
        );
      }
    } on TimeoutException {
      return ApiResponse.failure(
        'Review submission timeout. Please check your internet connection and try again.',
        data: ReviewSubmissionResponse(
          error: true,
          message: 'Connection timeout',
          customerReviews: [],
        ),
      );
    } on SocketException {
      return ApiResponse.failure(
        'No internet connection. Please check your network settings and try again.',
        data: ReviewSubmissionResponse(
          error: true,
          message: 'No internet connection',
          customerReviews: [],
        ),
      );
    } on http.ClientException {
      return ApiResponse.failure(
        'Failed to connect to server. Please check your internet connection and try again later.',
        data: ReviewSubmissionResponse(
          error: true,
          message: 'Connection failed',
          customerReviews: [],
        ),
      );
    } on FormatException {
      return ApiResponse.failure(
        'Invalid response format from server. Please try again later.',
        data: ReviewSubmissionResponse(
          error: true,
          message: 'Invalid response format',
          customerReviews: [],
        ),
      );
    } catch (e) {
      return ApiResponse.failure(
        'An unexpected error occurred: ${e.toString()}',
        data: ReviewSubmissionResponse(
          error: true,
          message: 'Unexpected error: ${e.toString()}',
          customerReviews: [],
        ),
      );
    }
  }

  /// Handles HTTP response and converts to ApiResponse
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Check if API returned an error
        if (jsonData['error'] == true) {
          return ApiResponse.failure(
            jsonData['message'] ?? 'API returned an error',
          );
        }

        final data = parser(jsonData);

        return ApiResponse.success(
          data,
          message: jsonData['message'] ?? 'Success',
        );
      } else {
        return ApiResponse.failure(_getHttpErrorMessage(response.statusCode));
      }
    } on FormatException catch (_) {
      return ApiResponse.failure('Invalid JSON response from server');
    } catch (e) {
      return ApiResponse.failure('Failed to parse server response: $e');
    }
  }

  /// Parses restaurant list from API response
  List<Restaurant> _parseRestaurantList(Map<String, dynamic> json) {
    final List<dynamic> restaurantsJson = json['restaurants'] ?? [];
    return restaurantsJson
        .map((restaurantJson) => Restaurant.fromJson(restaurantJson))
        .toList();
  }

  /// Returns appropriate error message for HTTP status codes
  String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please try again.';
      case 401:
        return 'Unauthorized access.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Restaurant data not found.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Network error (Status: $statusCode). Please try again.';
    }
  }

  /// Checks if the device has internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (_) {
      return false;
    }
  }

  /// Gets the current connectivity status
  Future<ConnectivityResult> getConnectivityStatus() async {
    return await _connectivity.checkConnectivity();
  }

  /// Disposes the HTTP client
  void dispose() {
    _client.close();
  }
}
