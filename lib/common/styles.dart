import 'package:flutter/material.dart';

final Color darkPrimaryColor = Colors.black;
final Color darkSecondaryColor = Colors.grey.shade800;
final Color lightPrimaryColor = Colors.white;
final Color lightSecondaryColor = Colors.orange;

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: lightPrimaryColor,
  colorScheme:
      ColorScheme.fromSwatch().copyWith(secondary: lightSecondaryColor),
  scaffoldBackgroundColor: lightPrimaryColor,
  fontFamily: 'Nunito',
  textTheme: _buildTextTheme(Brightness.light),
  appBarTheme: AppBarTheme(
    backgroundColor: lightPrimaryColor,
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

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkPrimaryColor,
  scaffoldBackgroundColor: darkPrimaryColor,
  fontFamily: 'Nunito',
  textTheme: _buildTextTheme(Brightness.dark),
  appBarTheme: AppBarTheme(
    backgroundColor: darkPrimaryColor,
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
