import 'package:flutter/foundation.dart';
import '../model/restaurant_detail.dart';
import '../services/api_service.dart';

/// Provider class for managing restaurant detail data state
class RestaurantDetailProvider extends ChangeNotifier {
  final ApiService _apiService;

  // Private state variables
  RestaurantDetail? _restaurantDetail;
  bool _isLoading = false;
  String? _errorMessage;

  RestaurantDetailProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Getters for accessing state properties
  RestaurantDetail? get restaurantDetail => _restaurantDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasData => _restaurantDetail != null;

  // Setter for testing purposes
  set restaurantDetail(RestaurantDetail? restaurant) {
    _restaurantDetail = restaurant;
    _errorMessage = null; // Clear any existing error when setting data
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Store the last restaurant ID for retry functionality
  String? _lastRestaurantId;

  /// Fetches restaurant detail from the API with loading state management
  Future<void> fetchRestaurantDetail(String id) async {
    _lastRestaurantId = id;
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getRestaurantDetail(id);

      if (response.isSuccess) {
        _restaurantDetail = response.data.restaurant;
        _clearError();
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Clears the current error state
  void clearError() {
    _clearError();
  }

  /// Retries the last failed operation
  Future<void> retry() async {
    if (_lastRestaurantId != null) {
      await fetchRestaurantDetail(_lastRestaurantId!);
    }
  }

  /// Refreshes restaurant data after successful review submission
  /// This method updates the restaurant detail state with new review data
  Future<void> refreshAfterReviewSubmission() async {
    // Always clear error state at the beginning of refresh
    _clearError();

    if (_lastRestaurantId != null && _restaurantDetail != null) {
      // Don't show loading state for refresh to avoid UI flicker
      try {
        final response = await _apiService.getRestaurantDetail(
          _lastRestaurantId!,
        );

        if (response.isSuccess) {
          _restaurantDetail = response.data.restaurant;
          notifyListeners();
        } else {
          // For refresh operations, we don't want to show errors prominently
          // as the user has already successfully submitted a review
          if (kDebugMode) {
            print('Failed to refresh restaurant data: ${response.message}');
          }
        }
      } catch (e) {
        // Silent error handling for refresh operations
        if (kDebugMode) {
          print('Error refreshing restaurant data: ${e.toString()}');
        }
      }
    }
  }

  /// Force refresh restaurant data - useful for manual refresh after review submission
  /// This method will show loading state and handle errors appropriately
  Future<void> forceRefresh() async {
    if (_lastRestaurantId != null) {
      await fetchRestaurantDetail(_lastRestaurantId!);
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
