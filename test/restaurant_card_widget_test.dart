import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/model/restaurant.dart';
import 'package:restaurant_app/widgets/restaurant_card.dart';

void main() {
  final restaurant = Restaurant(
    id: 's1k7u6ckteco39xp6v',
    name: 'Melting Pot',
    description: 'Lorem ipsum dolor sit amet...',
    city: 'Medan',
    rating: 4.2,
    pictureId: '14',
  );

  testWidgets('Should display restaurant name and city', (
    WidgetTester tester,
  ) async {
    // Provide the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RestaurantCard(restaurant: restaurant)),
      ),
    );

    // Verify name and city are displayed
    expect(find.text(restaurant.name), findsOneWidget);
    expect(find.text(restaurant.city), findsOneWidget);
  });
}
