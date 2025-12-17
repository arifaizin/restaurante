import 'category.dart';
import 'menus.dart';
import 'customer_review.dart';

class RestaurantDetail {
  String id;
  String name;
  String description;
  String city;
  String address;
  String pictureId;
  double rating;
  List<Category> categories;
  Menus menus;
  List<CustomerReview> customerReviews;

  RestaurantDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.pictureId,
    required this.rating,
    required this.categories,
    required this.menus,
    required this.customerReviews,
  });

  RestaurantDetail.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        name = json['name'] ?? '',
        description = json['description'] ?? '',
        city = json['city'] ?? '',
        address = json['address'] ?? '',
        pictureId = json['pictureId'] ?? '',
        rating = (json['rating'] ?? 0).toDouble(),
        categories = (json['categories'] as List<dynamic>?)
                ?.map((item) => Category.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [],
        menus = Menus.fromJson(json['menus'] as Map<String, dynamic>? ?? {}),
        customerReviews = (json['customerReviews'] as List<dynamic>?)
                ?.map((item) =>
                    CustomerReview.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];

  /// Returns the full image URL for the restaurant picture
  /// Handles both API format (pictureId only) and local JSON format (full URL)
  String get fullImageUrl {
    // If pictureId already contains a full URL (backward compatibility with local JSON)
    if (pictureId.startsWith('http')) {
      return pictureId;
    }
    // For API format, construct the full URL
    return 'https://restaurant-api.dicoding.dev/images/medium/$pictureId';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'city': city,
      'address': address,
      'pictureId': pictureId,
      'rating': rating,
      'categories': categories.map((item) => item.toJson()).toList(),
      'menus': menus.toJson(),
      'customerReviews': customerReviews.map((item) => item.toJson()).toList(),
    };
  }
}
