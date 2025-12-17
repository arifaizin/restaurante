# Design Document

## Overview

The restaurant detail display feature will extend the existing API infrastructure to fetch and display comprehensive restaurant information. It will use the detail API endpoint to retrieve extended data including menus and customer reviews, presenting this information in a well-organized, scrollable detail screen.

## Architecture

The feature will follow the existing Provider pattern established in the app:

```
DetailScreen (UI) 
    ↓ consumes
RestaurantDetailProvider (State Management)
    ↓ uses
ApiService (Network Layer)
    ↓ calls
Restaurant Detail API Endpoint
```

The architecture leverages the existing `ApiService` class and follows the same error handling and loading state patterns used in the restaurant list feature.

## Components and Interfaces

### 1. RestaurantDetailProvider

A new Provider class that manages the state for restaurant detail data:

```dart
class RestaurantDetailProvider extends ChangeNotifier {
  RestaurantDetail? _restaurantDetail;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  RestaurantDetail? get restaurantDetail => _restaurantDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Methods
  Future<void> fetchRestaurantDetail(String id);
  void clearError();
  void retry(String id);
}
```

### 2. API Service Extension

Extend the existing `ApiService` class with a new method:

```dart
Future<ApiResponse<RestaurantDetailResponse>> getRestaurantDetail(String id);
```

### 3. Updated DetailScreen

Transform the existing `DetailScreen` to use Provider instead of receiving restaurant data as a parameter:

```dart
class DetailScreen extends StatelessWidget {
  final String restaurantId;
  
  // Uses Consumer<RestaurantDetailProvider> for reactive UI updates
}
```

## Data Models

### 1. RestaurantDetailResponse

Wrapper for the API response:

```dart
class RestaurantDetailResponse {
  final bool error;
  final String message;
  final RestaurantDetail restaurant;
}
```

### 2. Enhanced Restaurant Model

Extend the existing `Restaurant` model or create a new `RestaurantDetail` model with additional fields:

```dart
class RestaurantDetail {
  final String id;
  final String name;
  final String description;
  final String city;
  final String address;
  final String pictureId;
  final double rating;
  final List<Category> categories;
  final Menus menus;
  final List<CustomerReview> customerReviews;
}
```

### 3. Supporting Models

```dart
class Category {
  final String name;
}

class Menus {
  final List<MenuItem> foods;
  final List<MenuItem> drinks;
}

class MenuItem {
  final String name;
}

class CustomerReview {
  final String name;
  final String review;
  final String date;
}
```

## Error Handling

The feature will implement comprehensive error handling following the established patterns:

### Network Errors
- Connection timeout: "Connection timed out. Please check your internet connection."
- No internet: "No internet connection. Please check your network settings."
- Server errors: "Unable to load restaurant details. Please try again later."

### Data Errors
- Invalid restaurant ID: "Restaurant not found."
- Malformed response: "Unable to process restaurant data."

### Error Recovery
- Retry functionality for failed requests
- Clear error states when retrying
- Graceful fallback UI states

## Testing Strategy

### Unit Tests

1. **RestaurantDetailProvider Tests**
   - Test successful API calls and state updates
   - Test error handling and error state management
   - Test loading state transitions
   - Mock API responses for consistent testing

2. **Data Model Tests**
   - Test JSON parsing for RestaurantDetailResponse
   - Test model creation with various data scenarios
   - Test edge cases (empty menus, no reviews)

3. **ApiService Tests**
   - Test detail endpoint integration
   - Test error response handling
   - Mock HTTP client for reliable testing

### Integration Tests

1. **End-to-End Flow Tests**
   - Test navigation from list to detail screen
   - Test complete data loading and display cycle
   - Test error scenarios with network simulation

2. **UI Tests**
   - Test loading state display
   - Test error state display with retry functionality
   - Test successful data display formatting

## UI Layout Structure

The detail screen will be organized into logical sections:

### 1. Header Section
- Restaurant image (full width, aspect ratio maintained)
- Restaurant name overlay or below image
- Rating display with stars/numeric value

### 2. Basic Information Section
- Description text
- Location information (city, address)
- Categories as chips or tags

### 3. Menus Section
- Expandable or tabbed interface for Foods/Drinks
- List view of menu items
- Clear section headers

### 4. Reviews Section
- List of customer reviews
- Review cards showing name, date, and review text
- Proper date formatting

### 5. Error/Loading States
- Loading spinner during API calls
- Error messages with retry buttons
- Empty state messages when appropriate

## Navigation Integration

The feature integrates with existing navigation:

1. **From Restaurant List**: Pass restaurant ID to DetailScreen
2. **Provider Initialization**: Automatically fetch detail data on screen load
3. **Back Navigation**: Maintain existing back button functionality
4. **Deep Linking**: Support direct navigation to restaurant details via ID