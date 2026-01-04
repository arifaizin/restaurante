import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/providers/search_provider.dart';
import 'package:restaurant_app/providers/review_submission_provider.dart';
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

  /// Build light theme with centralized typography
  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.white,
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.orange),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Nunito',
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.0,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 2.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.orange, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        hintStyle: TextStyle(
          fontFamily: 'Nunito',
          color: Colors.grey.shade600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  /// Build dark theme with centralized typography
  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'Nunito',
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0.0,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 2.0,
        color: Colors.grey.shade900,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.orange, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        hintStyle: TextStyle(
          fontFamily: 'Nunito',
          color: Colors.grey.shade400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  /// Build centralized text theme for both light and dark modes
  TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor =
        brightness == Brightness.light ? Colors.black : Colors.white;
    final Color secondaryTextColor = brightness == Brightness.light
        ? Colors.grey.shade600
        : Colors.grey.shade400;

    return TextTheme(
      // Headlines
      headlineLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),

      // Titles
      titleLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Body text
      bodyLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
      ),

      // Labels
      labelLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 10.0,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RestaurantProvider()),
        ChangeNotifierProvider(create: (context) => RestaurantDetailProvider()),
        ChangeNotifierProvider(create: (context) => SearchProvider()),
        ChangeNotifierProvider(create: (context) => ReviewSubmissionProvider()),
      ],
      child: MaterialApp(
        title: Constants.appName,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
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
