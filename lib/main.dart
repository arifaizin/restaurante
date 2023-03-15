import 'package:flutter/material.dart';
import 'package:restaurant_app/screens/detail_screen.dart';
import 'package:restaurant_app/screens/splash_screen.dart';
import 'package:restaurant_app/util/constants.dart';

import 'model/restaurant.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MaterialApp(
      title: '$Constants.appName',
      theme: theme.copyWith(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Colors.white,
        colorScheme: theme.colorScheme.copyWith(secondary: Colors.amber),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.amber,
        )
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => SplashScreen(),
        MainScreen.routeName: (context) => MainScreen(),
        DetailScreen.routeName: (context) => DetailScreen(
            restaurant: ModalRoute.of(context)?.settings.arguments as Restaurant),
      },
    );
  }
}
