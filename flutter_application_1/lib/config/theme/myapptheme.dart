import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0093AF), // Blue Munsell
    scaffoldBackgroundColor: const Color(0xFFE5E4E2), // Platinum
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0093AF),
      foregroundColor: Colors.black,
    ),
    iconTheme: const IconThemeData(
      color: Colors.black,  // Default icon color in light theme
      size: 24,
    ),
    primaryIconTheme: const IconThemeData(
      color: Colors.black,  // Icons in app bars and primary widgets
      size: 24,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontFamily: "Primary", fontSize: 35, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(color: Colors.black, fontFamily: "Secondary", fontSize: 18, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: Colors.black, fontFamily: "Texxt"),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFF0093AF).withOpacity(0.1),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      prefixIconColor: Colors.black,
      suffixIconColor: Colors.black,
      hintStyle: const TextStyle(
        color: Colors.black,
        fontFamily: "Secondary",
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0093AF), width: 2),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0093AF),
      onPrimary: Colors.black,
      background: Color(0xFFE5E4E2),
      onBackground: Colors.black,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.yellow,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,  // Default icon color in dark theme
      size: 24,
    ),
    primaryIconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontFamily: "Primary", fontSize: 35, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(color: Colors.white, fontFamily: "Secondary", fontSize: 18, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: Colors.white, fontFamily: "Texxt"),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.yellow.withOpacity(0.1),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      prefixIconColor: Colors.white,
      suffixIconColor: Colors.white,
      hintStyle: const TextStyle(
        color: Colors.black,
        fontFamily: "Secondary",
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.yellow, width: 2),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.yellow,
      onPrimary: Colors.black,
      background: Colors.black,
      onBackground: Colors.white,
    ),
  );
}
