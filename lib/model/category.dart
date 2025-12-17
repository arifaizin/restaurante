class Category {
  String name;

  Category({
    required this.name,
  });

  Category.fromJson(Map<String, dynamic> json) : name = json['name'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
