import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/providers/search_provider.dart';
import 'package:restaurant_app/screens/detail_screen.dart';
import 'package:restaurant_app/screens/search_screen.dart';
import 'package:restaurant_app/screens/splash_screen.dart';
import 'package:restaurant_app/util/constants.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RestaurantProvider()),
        ChangeNotifierProvider(create: (context) => RestaurantDetailProvider()),
        ChangeNotifierProvider(create: (context) => SearchProvider()),
      ],
      child: MaterialApp(
        title: Constants.appName,
        theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.light,
          primaryColor: Colors.white,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.cyan[600]),
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (context) => SplashScreen(),
          MainScreen.routeName: (context) => MainScreen(),
          SearchScreen.routeName: (context) => SearchScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case DetailScreen.routeName:
              final restaurantId = settings.arguments as String?;
              if (restaurantId != null) {
                return MaterialPageRoute(
                  builder: (context) =>
                      DetailScreen(restaurantId: restaurantId),
                );
              }
              // If restaurantId is null, navigate back to main screen
              return MaterialPageRoute(
                builder: (context) => MainScreen(),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
