class MenuItem {
  String name;

  MenuItem({
    required this.name,
  });

  MenuItem.fromJson(Map<String, dynamic> json) : name = json['name'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
