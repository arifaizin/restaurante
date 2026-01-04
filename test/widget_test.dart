import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restaurant_app/main.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/providers/search_provider.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Restaurant App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(prefs: prefs));

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Provider setup test', (WidgetTester tester) async {
    // Build our app and verify providers are properly set up
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(prefs: prefs));

    // Find the MultiProvider widget
    expect(find.byType(MultiProvider), findsOneWidget);

    // Verify that all required providers are available in the widget tree
    final BuildContext context = tester.element(find.byType(MaterialApp));

    expect(Provider.of<RestaurantProvider>(context, listen: false), isNotNull);
    expect(Provider.of<RestaurantDetailProvider>(context, listen: false),
        isNotNull);
    expect(Provider.of<SearchProvider>(context, listen: false), isNotNull);
  });
}
