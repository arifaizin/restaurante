class Restaurant {
  String id;
  String name;
  String description;
  String city;
  double rating;
  String pictureId;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.rating,
    required this.pictureId,
  });

  Restaurant.fromJson(Map<String, dynamic> restaurant)
      : id = restaurant['id'] ?? '',
        name = restaurant['name'] ?? '',
        description = restaurant['description'] ?? '',
        city = restaurant['city'] ?? '',
        rating = (restaurant['rating'] ?? 0).toDouble(),
        pictureId = restaurant['pictureId'] ?? '';

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
}
