import 'dart:convert';

class Restaurant {
  String id;
  String name;
  String description;
  String city;
  double rating;
  String pictureId;

  Restaurant({
    this.id,
    this.name,
    this.description,
    this.city,
    this.rating,
    this.pictureId,
  });

  Restaurant.fromJson(Map<String, dynamic> restaurant) {
    id = restaurant['id'];
    name = restaurant['name'];
    description = restaurant['description'];
    city = restaurant['city'];
    rating = restaurant['rating'];
    pictureId = restaurant['pictureId'];
  }
}

List<Restaurant> parseRestaurant(String json) {
  if (json == null) {
    return [];
  }
  final List parsed = jsonDecode(json);
  return parsed.map((json) => Restaurant.fromJson(json)).toList();
}
