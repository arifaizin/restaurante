# Design Document

## Overview

The restaurant search feature will be implemented as a new screen in the existing Flutter restaurant app. It will integrate with the current architecture using the Provider pattern for state management and the existing ApiService for network requests. The search functionality will provide real-time search capabilities with debouncing to optimize API calls and enhance user experience.

## Architecture

The search feature follows the existing app's architecture pattern:

- **Presentation Layer**: SearchScreen widget with search UI components
- **State Management**: SearchProvider using Provider pattern for reactive state management
- **Data Layer**: Extension of existing ApiService to handle search API calls
- **Models**: New RestaurantSearchResponse model to handle search-specific API responses

### Integration Points

- Extends existing ApiService with search functionality
- Uses existing Restaurant model for consistency
- Integrates with existing navigation structure
- Reuses existing UI components and styling patterns

## Components and Interfaces

### 1. SearchScreen (Presentation Layer)

**Purpose**: Main search interface with text input and results display

**Key Components**:
- Search TextField with debouncing
- Results ListView using existing restaurant item widgets
- Loading states and error handling
- Empty state messaging

**Navigation Integration**:
- Add search tab/option to main navigation
- Maintain existing navigation patterns
- Handle navigation to restaurant detail screen

### 2. SearchProvider (State Management)

**Purpose**: Manages search state, API calls, and UI state updates

**State Properties**:
```dart
class SearchProvider extends ChangeNotifier {
  List<Restaurant> searchResults = [];
  bool isLoading = false;
  String? errorMessage;
  String currentQuery = '';
  Timer? debounceTimer;
}
```

**Key Methods**:
- `searchRestaurants(String query)`: Performs debounced search
- `clearSearch()`: Clears search results and state
- `retry()`: Retries failed search requests

### 3. ApiService Extension

**Purpose**: Extends existing ApiService with search functionality

**New Method**:
```dart
Future<ApiResponse<RestaurantSearchResponse>> searchRestaurants(String query)
```

**Implementation Details**:
- Uses existing error handling patterns
- Maintains consistent timeout and connectivity checks
- Follows existing response parsing structure

### 4. RestaurantSearchResponse Model

**Purpose**: Handles search-specific API response structure

**Properties**:
```dart
class RestaurantSearchResponse {
  final bool error;
  final int founded;
  final List<Restaurant> restaurants;
}
```

## Data Models

### API Response Structure
Based on the provided API response:
```json
{
  "error": false,
  "founded": 2,
  "restaurants": [
    {
      "id": "w9pga3s2tubkfw1e867",
      "name": "Bring Your Phone Cafe",
      "description": "...",
      "pictureId": "03",
      "city": "Surabaya",
      "rating": 4.2
    }
  ]
}
```

### Model Relationships
- **RestaurantSearchResponse**: Contains search metadata and restaurant list
- **Restaurant**: Reuses existing model for consistency
- **ApiResponse<T>**: Wraps search response in existing error handling structure

## Error Handling

### Search-Specific Error Scenarios

1. **Empty Query**: Prevent API calls for queries less than 3 characters
2. **No Results**: Display user-friendly "No restaurants found" message
3. **Network Errors**: Reuse existing network error handling patterns
4. **API Errors**: Handle search-specific API error responses
5. **Timeout Handling**: Apply existing timeout mechanisms

### Error Recovery
- Retry functionality for failed searches
- Graceful degradation with clear error messages
- Maintain search state during error recovery

## Testing Strategy

### Unit Tests
- SearchProvider state management logic
- ApiService search method functionality
- RestaurantSearchResponse model parsing
- Debouncing mechanism validation

### Widget Tests
- SearchScreen UI components
- Search input behavior
- Results list rendering
- Error state displays

### Integration Tests
- End-to-end search flow
- Navigation integration
- API integration testing
- Error scenario handling

### Test Coverage Areas
1. **Search Input Validation**: Minimum character requirements, special characters
2. **Debouncing Logic**: Rapid typing scenarios, timer cancellation
3. **API Integration**: Various response scenarios, network conditions
4. **State Management**: Loading states, error states, success states
5. **UI Responsiveness**: Large result sets, long restaurant names, image loading

## Performance Considerations

### Search Optimization
- **Debouncing**: 500ms delay to reduce API calls during typing
- **Request Cancellation**: Cancel previous requests when new search initiated
- **Caching**: Consider implementing search result caching for repeated queries

### UI Performance
- **Lazy Loading**: Use ListView.builder for efficient scrolling
- **Image Optimization**: Reuse existing image loading and caching mechanisms
- **Memory Management**: Proper disposal of timers and providers

### Network Efficiency
- **Minimum Query Length**: Require 3+ characters before searching
- **Connection Awareness**: Check connectivity before making requests
- **Timeout Handling**: Use existing 10-second timeout configuration

## Implementation Notes

### Debouncing Implementation
```dart
void _onSearchChanged(String query) {
  debounceTimer?.cancel();
  debounceTimer = Timer(Duration(milliseconds: 500), () {
    if (query.length >= 3) {
      searchRestaurants(query);
    }
  });
}
```

### Navigation Integration
- Add search option to main screen navigation
- Maintain existing route naming conventions
- Preserve navigation stack behavior

### Styling Consistency
- Reuse existing theme and styling patterns
- Maintain consistent spacing and typography
- Follow existing card design for restaurant items

### Accessibility
- Proper semantic labels for search input
- Screen reader support for search results
- Keyboard navigation support