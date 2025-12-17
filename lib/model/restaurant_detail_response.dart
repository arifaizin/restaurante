import 'restaurant_detail.dart';

class RestaurantDetailResponse {
  bool error;
  String message;
  RestaurantDetail restaurant;

  RestaurantDetailResponse({
    required this.error,
    required this.message,
    required this.restaurant,
  });

  RestaurantDetailResponse.fromJson(Map<String, dynamic> json)
      : error = json['error'] ?? false,
        message = json['message'] ?? '',
        restaurant = RestaurantDetail.fromJson(
            json['restaurant'] as Map<String, dynamic>? ?? {});

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'restaurant': restaurant.toJson(),
    };
  }
}
