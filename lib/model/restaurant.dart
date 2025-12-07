import 'dart:convert';

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
      : id = restaurant['id'],
        name = restaurant['name'],
        description = restaurant['description'],
        city = restaurant['city'],
        rating = restaurant['rating'].toDouble(),
        pictureId = restaurant['pictureId'];
}

List<Restaurant> parseRestaurant(String? json) {
  if (json == null) {
    return [];
  }
  final List parsed = jsonDecode(json);
  return parsed.map((json) => Restaurant.fromJson(json)).toList();
}
