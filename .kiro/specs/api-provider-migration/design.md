# Design Document

## Overview

This design outlines the migration from local JSON data to API-based data fetching with Provider state management. The solution will implement a clean architecture pattern with separation of concerns, making the app more maintainable and scalable.

## Architecture

### High-Level Architecture
```
UI Layer (Widgets)
    ↓
Provider Layer (State Management)
    ↓
Service Layer (API Calls)
    ↓
Model Layer (Data Models)
```

### Key Components
- **RestaurantProvider**: Manages restaurant data state and API interactions
- **ApiService**: Handles HTTP requests to the restaurant API
- **Restaurant Model**: Updated to handle API response structure
- **UI Components**: Modified to consume Provider state

## Components and Interfaces

### 1. API Service Layer

**ApiService Class**
```dart
class ApiService {
  static const String baseUrl = 'https://restaurant-api.dicoding.dev';
  static const String listEndpoint = '/list';
  
  Future<ApiResponse<List<Restaurant>>> getRestaurants();
}
```

**ApiResponse Model**
```dart
class ApiResponse<T> {
  final bool error;
  final String message;
  final int? count;
  final T data;
}
```

### 2. Provider State Management

**RestaurantProvider Class**
```dart
class RestaurantProvider extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Methods
  Future<void> fetchRestaurants();
  void retry();
}
```

### 3. Updated Data Models

**Restaurant Model Updates**
- Update parsing to handle API response structure
- Handle nested `restaurants` array from API response
- Update image URL construction to use API base URL + pictureId

**API Response Structure Analysis**
```json
{
  "error": false,
  "message": "success", 
  "count": 20,
  "restaurants": [
    {
      "id": "rqdv5juczeskfw1e867",
      "name": "Melting Pot",
      "description": "...",
      "pictureId": "14",
      "city": "Medan", 
      "rating": 4.2
    }
  ]
}
```

### 4. UI Layer Updates

**MainScreen Modifications**
- Replace FutureBuilder with Consumer<RestaurantProvider>
- Handle loading, error, and success states through Provider
- Add retry functionality for failed requests

**App Initialization**
- Wrap MaterialApp with MultiProvider
- Initialize RestaurantProvider at app startup

## Data Models

### Updated Restaurant Model
```dart
class Restaurant {
  String id;
  String name;
  String description;
  String city;
  double rating;
  String pictureId;
  
  // Updated constructor and fromJson to handle API structure
  Restaurant.fromJson(Map<String, dynamic> json);
  
  // Helper method to get full image URL
  String get imageUrl => 'https://restaurant-api.dicoding.dev/images/medium/$pictureId';
}
```

### API Response Models
```dart
class RestaurantListResponse {
  final bool error;
  final String message;
  final int count;
  final List<Restaurant> restaurants;
  
  RestaurantListResponse.fromJson(Map<String, dynamic> json);
}
```

## Error Handling

### Error Types and Handling Strategy

1. **Network Connectivity Errors**
   - Detect no internet connection
   - Show user-friendly message with retry option
   - Use connectivity_plus package for network status

2. **API Response Errors**
   - Handle HTTP status codes (404, 500, etc.)
   - Parse API error messages from response
   - Provide specific error messages to users

3. **Data Parsing Errors**
   - Handle malformed JSON responses
   - Validate required fields in API response
   - Fallback to empty state with error message

4. **Timeout Errors**
   - Set reasonable timeout duration (10 seconds)
   - Show timeout-specific error message
   - Provide retry functionality

### Error State Management
```dart
enum ApiState { loading, success, error, empty }

class RestaurantProvider {
  ApiState _state = ApiState.loading;
  String? _errorMessage;
  
  void _handleError(Exception error) {
    _state = ApiState.error;
    _errorMessage = _getErrorMessage(error);
    notifyListeners();
  }
}
```

## Testing Strategy

### Unit Tests
1. **ApiService Tests**
   - Test successful API calls
   - Test error handling for different HTTP status codes
   - Test network connectivity issues
   - Mock HTTP client for consistent testing

2. **RestaurantProvider Tests**
   - Test state changes during API calls
   - Test error handling and retry functionality
   - Test data transformation and caching
   - Mock ApiService for isolated testing

3. **Model Tests**
   - Test JSON parsing with valid API responses
   - Test error handling with malformed JSON
   - Test image URL construction
   - Test edge cases with missing fields

### Widget Tests
1. **MainScreen Tests**
   - Test loading state display
   - Test successful data display
   - Test error state display with retry button
   - Test navigation to detail screen

2. **Provider Integration Tests**
   - Test Provider state changes in UI
   - Test Consumer widget updates
   - Test error handling in UI components

### Integration Tests
1. **End-to-End API Integration**
   - Test complete flow from API call to UI display
   - Test error scenarios with real network conditions
   - Test app behavior with slow network connections

## Dependencies

### New Dependencies to Add
```yaml
dependencies:
  http: ^1.1.0                    # For API calls
  connectivity_plus: ^5.0.2       # For network connectivity checking
  
dev_dependencies:
  mockito: ^5.4.4                 # For mocking in tests
  http_mock_adapter: ^0.6.1       # For HTTP mocking
```

### Existing Dependencies
- provider: ^6.1.5 (already included)
- flutter_test (for testing)

## Implementation Considerations

### Performance Optimizations
1. **Caching Strategy**
   - Cache restaurant data in Provider
   - Implement pull-to-refresh functionality
   - Consider local storage for offline access

2. **Image Loading**
   - Use cached_network_image for better image performance
   - Implement proper error handling for image loading failures

3. **API Efficiency**
   - Implement proper HTTP client configuration
   - Add request timeouts and retry logic
   - Consider implementing pagination if API supports it

### Security Considerations
1. **API Security**
   - Validate API responses before processing
   - Handle potential XSS in restaurant descriptions
   - Implement proper error logging without exposing sensitive data

2. **Network Security**
   - Use HTTPS for all API calls (already provided by API)
   - Validate SSL certificates
   - Handle man-in-the-middle attack scenarios