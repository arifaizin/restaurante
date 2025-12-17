import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/model/restaurant_search_response.dart';

void main() {
  group('RestaurantSearchResponse', () {
    test('should create RestaurantSearchResponse from valid JSON', () {
      // Arrange
      final json = {
        'error': false,
        'founded': 2,
        'restaurants': [
          {
            'id': 'w9pga3s2tubkfw1e867',
            'name': 'Bring Your Phone Cafe',
            'description': 'Quisque rutrum. Aenean imperdiet...',
            'pictureId': '03',
            'city': 'Surabaya',
            'rating': 4.2
          },
          {
            'id': 'abc123',
            'name': 'Test Restaurant',
            'description': 'Test description',
            'pictureId': '01',
            'city': 'Jakarta',
            'rating': 4.5
          }
        ]
      };

      // Act
      final response = RestaurantSearchResponse.fromJson(json);

      // Assert
      expect(response.error, false);
      expect(response.founded, 2);
      expect(response.restaurants.length, 2);
      expect(response.isSuccess, true);
      expect(response.hasError, false);
      expect(response.isEmpty, false);
      expect(response.hasResults, true);
      expect(response.foundCount, 2);
      expect(response.restaurantCount, 2);
      expect(response.isValid, true);
    });

    test('should handle empty search results', () {
      // Arrange
      final json = {'error': false, 'founded': 0, 'restaurants': []};

      // Act
      final response = RestaurantSearchResponse.fromJson(json);

      // Assert
      expect(response.error, false);
      expect(response.founded, 0);
      expect(response.restaurants.length, 0);
      expect(response.isEmpty, true);
      expect(response.hasResults, false);
      expect(response.isValid, true);
    });

    test('should handle error response', () {
      // Arrange
      final json = {'error': true, 'founded': 0, 'restaurants': []};

      // Act
      final response = RestaurantSearchResponse.fromJson(json);

      // Assert
      expect(response.error, true);
      expect(response.hasError, true);
      expect(response.isSuccess, false);
    });

    test('should handle missing fields with defaults', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final response = RestaurantSearchResponse.fromJson(json);

      // Assert
      expect(response.error, false);
      expect(response.founded, 0);
      expect(response.restaurants.length, 0);
      expect(response.isEmpty, true);
    });

    test('should throw FormatException for malformed restaurant data', () {
      // Arrange
      final json = {
        'error': false,
        'founded': 1,
        'restaurants': ['invalid_data'] // Invalid format
      };

      // Act & Assert
      expect(
        () => RestaurantSearchResponse.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should handle null restaurants array', () {
      // Arrange
      final json = {'error': false, 'founded': 0, 'restaurants': null};

      // Act
      final response = RestaurantSearchResponse.fromJson(json);

      // Assert
      expect(response.restaurants.length, 0);
      expect(response.isEmpty, true);
    });

    test('should validate consistency between founded and restaurant count',
        () {
      // Arrange - Case where API returns fewer results than founded count
      final json = {
        'error': false,
        'founded': 5,
        'restaurants': [
          {
            'id': 'test1',
            'name': 'Test Restaurant',
            'description': 'Test description',
            'pictureId': '01',
            'city': 'Jakarta',
            'rating': 4.5
          }
        ]
      };

      // Act
      final response = RestaurantSearchResponse.fromJson(json);

      // Assert
      expect(response.isValid,
          true); // Should be valid as restaurant count <= founded
      expect(response.foundCount, 5);
      expect(response.restaurantCount, 1);
    });
  });
}
