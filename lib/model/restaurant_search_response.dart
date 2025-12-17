import 'restaurant.dart';

/// Response model for the restaurant search API endpoint
/// Handles the specific structure returned by https://restaurant-api.dicoding.dev/search?q={query}
class RestaurantSearchResponse {
  final bool error;
  final int founded;
  final List<Restaurant> restaurants;

  RestaurantSearchResponse({
    required this.error,
    required this.founded,
    required this.restaurants,
  });

  /// Creates a RestaurantSearchResponse from JSON API response
  factory RestaurantSearchResponse.fromJson(Map<String, dynamic> json) {
    try {
      return RestaurantSearchResponse(
        error: json['error'] ?? false,
        founded: json['founded'] ?? 0,
        restaurants:
            (json['restaurants'] as List<dynamic>?)?.map((restaurantJson) {
                  if (restaurantJson is Map<String, dynamic>) {
                    return Restaurant.fromJson(restaurantJson);
                  } else {
                    throw FormatException('Invalid restaurant data format');
                  }
                }).toList() ??
                [],
      );
    } catch (e) {
      throw FormatException('Failed to parse search response: ${e.toString()}');
    }
  }

  /// Returns true if the response is successful (no error)
  bool get isSuccess => !error;

  /// Returns true if the response has an error
  bool get hasError => error;

  /// Returns true if no restaurants were found
  bool get isEmpty => restaurants.isEmpty || founded == 0;

  /// Returns true if restaurants were found
  bool get hasResults => restaurants.isNotEmpty && founded > 0;

  /// Returns the number of restaurants found by the search
  int get foundCount => founded;

  /// Returns the actual number of restaurants in the response
  int get restaurantCount => restaurants.length;

  /// Validates that the response data is consistent
  bool get isValid {
    // Check if founded count matches actual restaurant list length
    // Allow for cases where API might return fewer results than founded count
    return founded >= 0 && restaurants.length <= founded;
  }
}
