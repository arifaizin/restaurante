import 'customer_review.dart';

class ReviewSubmissionResponse {
  final bool error;
  final String message;
  final List<CustomerReview> customerReviews;

  ReviewSubmissionResponse({
    required this.error,
    required this.message,
    required this.customerReviews,
  });

  ReviewSubmissionResponse.fromJson(Map<String, dynamic> json)
      : error = json['error'] ?? false,
        message = json['message'] ?? '',
        customerReviews = (json['customerReviews'] as List<dynamic>?)
                ?.map((review) =>
                    CustomerReview.fromJson(review as Map<String, dynamic>))
                .toList() ??
            [];

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'customerReviews':
          customerReviews.map((review) => review.toJson()).toList(),
    };
  }

  /// Returns true if the response is successful (no error)
  bool get isSuccess => !error;

  /// Returns true if the response has an error
  bool get hasError => error;
}
