import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/model/review_submission_request.dart';

void main() {
  group('ReviewSubmissionRequest', () {
    test('should create ReviewSubmissionRequest with valid data', () {
      // Arrange
      const id = 'restaurant123';
      const name = 'John Doe';
      const review = 'Great food and service!';

      // Act
      final request = ReviewSubmissionRequest(
        id: id,
        name: name,
        review: review,
      );

      // Assert
      expect(request.id, id);
      expect(request.name, name);
      expect(request.review, review);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final request = ReviewSubmissionRequest(
        id: 'restaurant123',
        name: '  John Doe  ',
        review: '  Great food and service!  ',
      );

      // Act
      final json = request.toJson();

      // Assert
      expect(json['id'], 'restaurant123');
      expect(json['name'], 'John Doe'); // Should be trimmed
      expect(json['review'], 'Great food and service!'); // Should be trimmed
    });

    test('should validate valid request data', () {
      // Arrange
      final request = ReviewSubmissionRequest(
        id: 'restaurant123',
        name: 'John Doe',
        review: 'Great food!',
      );

      // Act & Assert
      expect(request.isValid(), true);
      expect(request.getValidationError(), null);
    });

    test('should invalidate empty restaurant ID', () {
      // Arrange
      final request = ReviewSubmissionRequest(
        id: '',
        name: 'John Doe',
        review: 'Great food!',
      );

      // Act & Assert
      expect(request.isValid(), false);
      expect(request.getValidationError(), 'Restaurant ID is required');
    });

    test('should invalidate empty name', () {
      // Arrange
      final request = ReviewSubmissionRequest(
        id: 'restaurant123',
        name: '',
        review: 'Great food!',
      );

      // Act & Assert
      expect(request.isValid(), false);
      expect(request.getValidationError(), 'Nama tidak boleh kosong');
    });

    test('should invalidate whitespace-only name', () {
      // Arrange
      final request = ReviewSubmissionRequest(
        id: 'restaurant123',
        name: '   ',
        review: 'Great food!',
      );

      // Act & Assert
      expect(request.isValid(), false);
      expect(request.getValidationError(), 'Nama tidak boleh kosong');
    });

    test('should invalidate name shorter than 2 characters', () {
      // Arrange
      final request = ReviewSubmissionRequest(
        id: 'restaurant123',
        name: 'A',
        review: 'Great food!',
      );

      // Act & Assert
      expect(request.isValid(), false);
      expect(request.getValidationError(), 'Nama minimal 2 karakter');
    });

    test('should validate name with exactly 2 characters', () {
      // Arrange
      final request = ReviewSubmissionRequest(
        id: 'restaurant123',
        name: 'Jo',
        review: 'Great food!',
      );

      // Act & Assert
      expect(request.isValid(), true);
      expect(request.getValidationError(), null);
    });

    test('should invalidate empty review', () {
      // Arrange
      final request = ReviewSubmissionRequest(
        id: 'restaurant123',
        name: 'John Doe',
        review: '',
      );

      // Act & Assert
      expect(request.isValid(), false);
      expect(request.getValidationError(), 'Ulasan tidak boleh kosong');
    });

    test('should invalidate whitespace-only review', () {
      // Arrange
      final request = ReviewSubmissionRequest(
        id: 'restaurant123',
        name: 'John Doe',
        review: '   ',
      );

      // Act & Assert
      expect(request.isValid(), false);
      expect(request.getValidationError(), 'Ulasan tidak boleh kosong');
    });

    test(
      'should handle name with leading/trailing whitespace in validation',
      () {
        // Arrange
        final request = ReviewSubmissionRequest(
          id: 'restaurant123',
          name: '  Jo  ',
          review: 'Great food!',
        );

        // Act & Assert
        expect(request.isValid(), true);
        expect(request.getValidationError(), null);
      },
    );

    test(
      'should handle review with leading/trailing whitespace in validation',
      () {
        // Arrange
        final request = ReviewSubmissionRequest(
          id: 'restaurant123',
          name: 'John Doe',
          review: '  Great food!  ',
        );

        // Act & Assert
        expect(request.isValid(), true);
        expect(request.getValidationError(), null);
      },
    );

    test('should return first validation error encountered', () {
      // Arrange
      final request = ReviewSubmissionRequest(id: '', name: '', review: '');

      // Act & Assert
      expect(request.isValid(), false);
      expect(request.getValidationError(), 'Restaurant ID is required');
    });
  });
}
