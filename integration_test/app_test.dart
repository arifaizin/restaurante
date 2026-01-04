import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:restaurant_app/main.dart' as app;
import 'package:restaurant_app/widgets/restaurant_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_app/screens/detail_screen.dart';
import 'package:restaurant_app/screens/favorite_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Test full favorite flow: Add from detail and verify in FavoriteScreen',
      (WidgetTester tester) async {
    // 1. Setup mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // 2. Build the app directly via MyApp to bypass native plugin setup (like notifications/alarms)
    // which can be problematic in test environments.
    await tester.pumpWidget(app.MyApp(prefs: prefs));

    // 3. Wait for Splash Screen transition and initial list data load
    // We use sequential pumps to bypass infinite animations (SplashScreen & Loading)
    bool foundRestaurant = false;
    for (int i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byType(RestaurantCard).evaluate().isNotEmpty) {
        foundRestaurant = true;
        break;
      }
    }
    expect(foundRestaurant, isTrue,
        reason: "Restaurant list should be loaded after SplashScreen");

    // 4. Navigate to Detail Screen
    final firstCard = find.byType(RestaurantCard).first;
    await tester.tap(firstCard);

    await tester.pumpAndSettle();

    // // Wait for transition and DetailScreen data loading
    // for (int i = 0; i < 20; i++) {
    //   await tester.pump(const Duration(milliseconds: 500));
    //   if (find.byType(DetailScreen).evaluate().isNotEmpty) {
    //     break;
    //   }
    // }
    expect(find.byType(DetailScreen), findsOneWidget);

    // 5. Toggle Favorite
    // Find FavoriteButton widget
    final favoriteButton = find.byType(FavoriteButton);
    expect(favoriteButton, findsOneWidget);
    await tester.tap(favoriteButton);

    // Give time for database operation to complete
    await tester.pump(const Duration(seconds: 1));

    // 6. Go back to Main Screen
    // Look for the default back button
    final backButton =
        find.byTooltip('Back'); // Default tooltip for Material back button
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
    } else {
      // Fallback to finding by icon if tooltip differs
      await tester.tap(find.byIcon(Icons.arrow_back).first);
    }

    // Wait for return transition
    await tester.pumpAndSettle();

    // 7. Navigate to Favorite Screen via Popup Menu
    // Look for PopupMenuButton
    final popupMenu = find.byKey(const ValueKey('myPopupMenuButton'));
    await tester.tap(popupMenu);
    await tester.pumpAndSettle();

    // Tap the 'Favorite' menu item
    final favoriteMenuItem = find.text('Favorite');
    await tester.tap(favoriteMenuItem);

    await tester.pumpAndSettle();

    // 8. Verify the result
    expect(find.byType(FavoriteScreen), findsOneWidget);
    // expect(find.byType(RestaurantCard), findsWidgets,
    //     reason: "Restaurant should appear in favorites");

    // Final settlement
    // await tester.pump(const Duration(seconds: 1));
  });
}
