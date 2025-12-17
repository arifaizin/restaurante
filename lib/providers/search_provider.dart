import 'dart:async';
import 'package:flutter/foundation.dart';
import '../model/restaurant.dart';
import '../services/api_service.dart';

/// Error types for categorizing different search failures
enum SearchErrorType {
  network,
  timeout,
  api,
  server,
  unknown,
}

/// Provider class for managing restaurant search state
class SearchProvider extends ChangeNotifier {
  final ApiService _apiService;

  // Private state variables
  List<Restaurant> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  SearchErrorType? _errorType;
  String _currentQuery = '';
  Timer? _debounceTimer;

  // Debounce configuration
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const int _minQueryLength = 3;

  SearchProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Getters for accessing state properties
  List<Restaurant> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SearchErrorType? get errorType => _errorType;
  String get currentQuery => _currentQuery;
  bool get hasError => _errorMessage != null;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get isEmpty =>
      _searchResults.isEmpty && !_isLoading && _errorMessage == null;

  /// Returns true if the error is network-related
  bool get isNetworkError => _errorType == SearchErrorType.network;

  /// Returns true if the error is timeout-related
  bool get isTimeoutError => _errorType == SearchErrorType.timeout;

  /// Returns true if the error is API-related
  bool get isApiError => _errorType == SearchErrorType.api;

  /// Returns true if the error is server-related
  bool get isServerError => _errorType == SearchErrorType.server;

  /// Performs restaurant search with debouncing logic
  /// Only triggers search if query has minimum required length
  void searchRestaurants(String query) {
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();

    // Update current query immediately for UI feedback
    _currentQuery = query.trim();

    // Clear results if query is too short
    if (_currentQuery.length < _minQueryLength) {
      _clearResults();
      return;
    }

    // Set up debounced search
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(_currentQuery);
    });
  }

  /// Performs the actual search API call
  Future<void> _performSearch(String query) async {
    if (query.length < _minQueryLength) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.searchRestaurants(query);

      if (response.isSuccess) {
        final searchResponse = response.data;

        if (searchResponse.isSuccess) {
          _searchResults = searchResponse.restaurants;
          _clearError();
        } else {
          _setError(
            'Search failed: ${response.message}',
            _categorizeErrorType(response.message),
          );
          _searchResults = [];
        }
      } else {
        _setError(
          response.message,
          _categorizeErrorType(response.message),
        );
        _searchResults = [];
      }
    } catch (e) {
      _setError(
        'An unexpected error occurred: ${e.toString()}',
        SearchErrorType.unknown,
      );
      _searchResults = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Clears search results and resets state
  void clearSearch() {
    _debounceTimer?.cancel();
    _currentQuery = '';
    _searchResults = [];
    _clearError();
    _setLoading(false);
  }

  /// Retries the last search query with error recovery
  Future<void> retry() async {
    if (_currentQuery.isNotEmpty && _currentQuery.length >= _minQueryLength) {
      // Check connectivity before retrying if it was a network error
      if (_errorType == SearchErrorType.network) {
        final hasConnection = await _apiService.hasInternetConnection();
        if (!hasConnection) {
          _setError(
            'No internet connection. Please check your network settings and try again.',
            SearchErrorType.network,
          );
          return;
        }
      }

      await _performSearch(_currentQuery);
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

  /// Gets user-friendly error message based on error type
  String getUserFriendlyErrorMessage() {
    if (_errorMessage == null) return '';

    switch (_errorType) {
      case SearchErrorType.network:
        return 'No internet connection. Please check your network settings and try again.';
      case SearchErrorType.timeout:
        return 'Request timed out. Please check your connection and try again.';
      case SearchErrorType.api:
        return 'Search service is currently unavailable. Please try again later.';
      case SearchErrorType.server:
        return 'Server error occurred. Please try again in a few moments.';
      case SearchErrorType.unknown:
      default:
        return _errorMessage ??
            'An unexpected error occurred. Please try again.';
    }
  }

  /// Gets appropriate icon for error type
  String getErrorIcon() {
    switch (_errorType) {
      case SearchErrorType.network:
        return 'wifi_off';
      case SearchErrorType.timeout:
        return 'access_time';
      case SearchErrorType.api:
      case SearchErrorType.server:
        return 'cloud_off';
      case SearchErrorType.unknown:
      default:
        return 'error_outline';
    }
  }

  /// Categorizes error type based on error message
  SearchErrorType _categorizeErrorType(String errorMessage) {
    final message = errorMessage.toLowerCase();

    if (message.contains('internet') ||
        message.contains('network') ||
        message.contains('connection') ||
        message.contains('connectivity')) {
      return SearchErrorType.network;
    }

    if (message.contains('timeout') || message.contains('timed out')) {
      return SearchErrorType.timeout;
    }

    if (message.contains('server') ||
        message.contains('502') ||
        message.contains('503') ||
        message.contains('500')) {
      return SearchErrorType.server;
    }

    if (message.contains('api') ||
        message.contains('service') ||
        message.contains('unavailable')) {
      return SearchErrorType.api;
    }

    return SearchErrorType.unknown;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error, SearchErrorType errorType) {
    _errorMessage = error;
    _errorType = errorType;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _errorType = null;
    notifyListeners();
  }

  void _clearResults() {
    if (_searchResults.isNotEmpty) {
      _searchResults = [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _apiService.dispose();
    super.dispose();
  }
}
