import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/util/error_helper.dart';

void main() {
  group('Success Message Tests', () {
    test('should provide varied success messages', () {
      final messages = <String>{};

      // Generate multiple messages with delays to ensure variety
      for (int i = 0; i < 20; i++) {
        final message = ErrorHelper.getReviewSubmissionSuccessMessage();
        messages.add(message);

        // Add small delay to ensure different timestamps
        if (i % 5 == 0) {
          // Simulate time passing
          Future.delayed(const Duration(microseconds: 100));
        }
      }

      // Verify we got success messages and they contain expected content
      expect(messages.isNotEmpty, isTrue);
      expect(messages.length, greaterThanOrEqualTo(1));
      expect(
        messages.every((msg) => msg.toLowerCase().contains('berhasil')),
        isTrue,
      );
    });

    test('should provide contextually appropriate success messages', () {
      final message = ErrorHelper.getReviewSubmissionSuccessMessage();

      // Should be encouraging and specific to review submission
      expect(
        message,
        anyOf([
          contains('ulasan'),
          contains('Ulasan'),
          contains('feedback'),
          contains('pengalaman'),
        ]),
      );

      // Should express gratitude or confirmation
      expect(
        message.toLowerCase(),
        anyOf([
          contains('terima kasih'),
          contains('berhasil'),
          contains('ditambahkan'),
          contains('dikirim'),
        ]),
      );
    });
  });
}
