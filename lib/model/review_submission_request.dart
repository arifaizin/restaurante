class ReviewSubmissionRequest {
  final String id;
  final String name;
  final String review;

  ReviewSubmissionRequest({
    required this.id,
    required this.name,
    required this.review,
  });

  /// Validates the request data
  bool isValid() {
    return id.isNotEmpty && name.trim().isNotEmpty && review.trim().isNotEmpty;
  }

  /// Gets validation error message if data is invalid
  String? getValidationError() {
    if (id.isEmpty) {
      return 'Restaurant ID is required';
    }
    if (name.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (review.trim().isEmpty) {
      return 'Ulasan tidak boleh kosong';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.trim(),
      'review': review.trim(),
    };
  }
}
