class CustomerReview {
  String name;
  String review;
  String date;

  CustomerReview({
    required this.name,
    required this.review,
    required this.date,
  });

  CustomerReview.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        review = json['review'] ?? '',
        date = json['date'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'review': review,
      'date': date,
    };
  }
}
