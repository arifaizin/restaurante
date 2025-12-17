import 'package:flutter/foundation.dart';
import '../model/restaurant.dart';
import '../services/api_service.dart';

/// Provider class for managing restaurant data state
class RestaurantProvider extends ChangeNotifier {
  final ApiService _apiService;

  // Private state variables
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  RestaurantProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Getters for accessing state properties
  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasData => _restaurants.isNotEmpty;

  /// Fetches restaurants from the API with loading state management
  Future<void> fetchRestaurants() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getRestaurants();

      if (response.isSuccess) {
        _restaurants = response.data;
        _retryCount = 0; // Reset retry count on success
        _clearError();
      } else {
        _setError(response.message);
        // Auto-retry for certain types of errors
        if (_shouldAutoRetry(response.message)) {
          await _retryWithBackoff();
        }
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Retries the last failed operation
  Future<void> retry() async {
    _retryCount = 0; // Reset retry count for manual retry
    await fetchRestaurants();
  }

  /// Retries with exponential backoff
  Future<void> _retryWithBackoff() async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = Duration(seconds: _retryCount * 2); // 2, 4, 6 seconds
      await Future.delayed(delay);
      await fetchRestaurants();
    }
  }

  /// Clears the current error state
  void clearError() {
    _clearError();
  }

  /// Checks if device has internet connectivity
  Future<bool> checkConnectivity() async {
    return await _apiService.hasInternetConnection();
  }

  /// Determines if we should auto-retry based on the error message
  bool _shouldAutoRetry(String errorMessage) {
    final retryableErrors = [
      'timeout',
      'server error',
      'service unavailable',
      'bad gateway',
    ];

    return retryableErrors
            .any((error) => errorMessage.toLowerCase().contains(error)) &&
        _retryCount < _maxRetries;
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

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
