import 'restaurant.dart';

/// Response model for the restaurant list API endpoint
/// Handles the specific structure returned by https://restaurant-api.dicoding.dev/list
class RestaurantListResponse {
  final bool error;
  final String message;
  final int count;
  final List<Restaurant> restaurants;

  RestaurantListResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.restaurants,
  });

  /// Creates a RestaurantListResponse from JSON API response
  factory RestaurantListResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantListResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      restaurants: (json['restaurants'] as List<dynamic>?)
              ?.map((restaurantJson) => Restaurant.fromJson(restaurantJson))
              .toList() ??
          [],
    );
  }

  /// Returns true if the response is successful (no error)
  bool get isSuccess => !error;

  /// Returns true if the response has an error
  bool get hasError => error;

  /// Returns true if the restaurant list is empty
  bool get isEmpty => restaurants.isEmpty;

  /// Returns the number of restaurants in the response
  int get restaurantCount => restaurants.length;
}
