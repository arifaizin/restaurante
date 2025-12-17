import 'menu_item.dart';

class Menus {
  List<MenuItem> foods;
  List<MenuItem> drinks;

  Menus({
    required this.foods,
    required this.drinks,
  });

  Menus.fromJson(Map<String, dynamic> json)
      : foods = (json['foods'] as List<dynamic>?)
                ?.map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [],
        drinks = (json['drinks'] as List<dynamic>?)
                ?.map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];

  Map<String, dynamic> toJson() {
    return {
      'foods': foods.map((item) => item.toJson()).toList(),
      'drinks': drinks.map((item) => item.toJson()).toList(),
    };
  }
}
