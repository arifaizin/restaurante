import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/model/review_submission_response.dart';
import 'package:restaurant_app/model/customer_review.dart';

void main() {
  group('ReviewSubmissionResponse', () {
    test('should create ReviewSubmissionResponse from valid JSON', () {
      // Arrange
      final json = {
        'error': false,
        'message': 'success',
        'customerReviews': [
          {
            'name': 'John Doe',
            'review': 'Great food and service!',
            'date': '13 November 2019'
          },
          {
            'name': 'Jane Smith',
            'review': 'Amazing experience!',
            'date': '14 November 2019'
          }
        ]
      };

      // Act
      final response = ReviewSubmissionResponse.fromJson(json);

      // Assert
      expect(response.error, false);
      expect(response.message, 'success');
      expect(response.customerReviews.length, 2);
      expect(response.isSuccess, true);
      expect(response.hasError, false);

      // Check first review
      expect(response.customerReviews[0].name, 'John Doe');
      expect(response.customerReviews[0].review, 'Great food and service!');
      expect(response.customerReviews[0].date, '13 November 2019');

      // Check second review
      expect(response.customerReviews[1].name, 'Jane Smith');
      expect(response.customerReviews[1].review, 'Amazing experience!');
      expect(response.customerReviews[1].date, '14 November 2019');
    });

    test('should handle error response', () {
      // Arrange
      final json = {
        'error': true,
        'message': 'Validation failed',
        'customerReviews': []
      };

      // Act
      final response = ReviewSubmissionResponse.fromJson(json);

      // Assert
      expect(response.error, true);
      expect(response.message, 'Validation failed');
      expect(response.customerReviews.length, 0);
      expect(response.isSuccess, false);
      expect(response.hasError, true);
    });

    test('should handle missing fields with defaults', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final response = ReviewSubmissionResponse.fromJson(json);

      // Assert
      expect(response.error, false);
      expect(response.message, '');
      expect(response.customerReviews.length, 0);
      expect(response.isSuccess, true);
      expect(response.hasError, false);
    });

    test('should handle null customerReviews array', () {
      // Arrange
      final json = {
        'error': false,
        'message': 'success',
        'customerReviews': null
      };

      // Act
      final response = ReviewSubmissionResponse.fromJson(json);

      // Assert
      expect(response.customerReviews.length, 0);
      expect(response.isSuccess, true);
    });

    test('should handle empty customerReviews array', () {
      // Arrange
      final json = {
        'error': false,
        'message': 'success',
        'customerReviews': []
      };

      // Act
      final response = ReviewSubmissionResponse.fromJson(json);

      // Assert
      expect(response.customerReviews.length, 0);
      expect(response.isSuccess, true);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final reviews = [
        CustomerReview(
          name: 'John Doe',
          review: 'Great food!',
          date: '13 November 2019',
        ),
        CustomerReview(
          name: 'Jane Smith',
          review: 'Amazing!',
          date: '14 November 2019',
        ),
      ];

      final response = ReviewSubmissionResponse(
        error: false,
        message: 'success',
        customerReviews: reviews,
      );

      // Act
      final json = response.toJson();

      // Assert
      expect(json['error'], false);
      expect(json['message'], 'success');
      expect(json['customerReviews'], isA<List>());
      expect((json['customerReviews'] as List).length, 2);

      final reviewsJson = json['customerReviews'] as List;
      expect(reviewsJson[0]['name'], 'John Doe');
      expect(reviewsJson[0]['review'], 'Great food!');
      expect(reviewsJson[0]['date'], '13 November 2019');

      expect(reviewsJson[1]['name'], 'Jane Smith');
      expect(reviewsJson[1]['review'], 'Amazing!');
      expect(reviewsJson[1]['date'], '14 November 2019');
    });

    test('should handle malformed review data gracefully', () {
      // Arrange
      final json = {
        'error': false,
        'message': 'success',
        'customerReviews': [
          {
            'name': 'John Doe',
            'review': 'Great food!',
            'date': '13 November 2019'
          },
          'invalid_review_data', // This should cause an error
        ]
      };

      // Act & Assert
      expect(
        () => ReviewSubmissionResponse.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });

    test('should create response with constructor', () {
      // Arrange
      final reviews = [
        CustomerReview(
          name: 'Test User',
          review: 'Test review',
          date: '15 November 2019',
        ),
      ];

      // Act
      final response = ReviewSubmissionResponse(
        error: false,
        message: 'Test message',
        customerReviews: reviews,
      );

      // Assert
      expect(response.error, false);
      expect(response.message, 'Test message');
      expect(response.customerReviews.length, 1);
      expect(response.customerReviews[0].name, 'Test User');
      expect(response.isSuccess, true);
      expect(response.hasError, false);
    });

    test('should handle reviews with missing fields', () {
      // Arrange
      final json = {
        'error': false,
        'message': 'success',
        'customerReviews': [
          {
            'name': 'John Doe',
            // Missing review and date fields
          },
          {
            'review': 'Great food!',
            // Missing name and date fields
          }
        ]
      };

      // Act
      final response = ReviewSubmissionResponse.fromJson(json);

      // Assert
      expect(response.customerReviews.length, 2);
      expect(response.customerReviews[0].name, 'John Doe');
      expect(response.customerReviews[0].review, ''); // Default empty string
      expect(response.customerReviews[0].date, ''); // Default empty string

      expect(response.customerReviews[1].name, ''); // Default empty string
      expect(response.customerReviews[1].review, 'Great food!');
      expect(response.customerReviews[1].date, ''); // Default empty string
    });
  });
}
