import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0XFF464F51), // Blue Munsell
    scaffoldBackgroundColor: const Color(0xFFDEFFF2), // Platinum
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFFDEFFF2),
      foregroundColor: Color(0XFF464F51),
      titleTextStyle: TextStyle(
        fontFamily: "special",
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Color(0XFF464F51),
      ),
    ),
    iconTheme: const IconThemeData(
      color: Colors.black,
      size: 24,
    ),
    primaryIconTheme: const IconThemeData(
      color: Colors.black,
      size: 24,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          color: Colors.black,
          fontFamily: "Primary",
          fontSize: 35,
          fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(
          color: Colors.black,
          fontFamily: "Secondary",
          fontSize: 18,
          fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: Colors.black, fontFamily: "Texxt"),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0XFF464F51).withOpacity(0.1),
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
        borderSide: const BorderSide(color: Color(0XFF464F51), width: 2),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0XFF464F51),
      onPrimary: Colors.black,
      background: Color(0xFFDEFFF2),
      onBackground: Colors.black,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: const Color(0XFF464F51),
      unselectedLabelColor: Colors.black,
      labelStyle: const TextStyle(
        fontFamily: "Primary",
        fontSize: 18,
        fontWeight: FontWeight.normal,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: "Primary",
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: Color(0XFF464F51),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: const Color(0XFF464F51).withOpacity(0.8),
      unselectedItemColor: Colors.black,
      selectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontFamily: "Primary",
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontFamily: "Primary",
        fontWeight: FontWeight.bold,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFFDEFFF2),
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.black,
      thickness: 1,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.yellow,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.black,
      foregroundColor: Colors.yellow,
      titleTextStyle: TextStyle(
        fontFamily: "special",
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.yellow,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),
    primaryIconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          color: Colors.white,
          fontFamily: "Primary",
          fontSize: 35,
          fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(
          color: Colors.white,
          fontFamily: "Secondary",
          fontSize: 18,
          fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: Colors.white, fontFamily: "Texxt"),
    ),

    // **Improved input decoration theme:**
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade900, // Dark grey fill for better contrast
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      prefixIconColor: Colors.yellow.shade700, // softer yellow
      suffixIconColor: Colors.yellow.shade700,
      hintStyle: TextStyle(
        color: Colors.grey.shade400, // softer grey hint
        fontFamily: "Secondary",
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade800), // subtle border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade800), // subtle border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.yellow, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: Colors.yellow,
      onPrimary: Colors.black,
      background: Colors.black,
      onBackground: Colors.white,
    ),

    tabBarTheme: TabBarTheme(
      labelColor: Colors.yellow,
      unselectedLabelColor: Colors.white,
      labelStyle: const TextStyle(
        fontFamily: "Primary",
        fontSize: 18,
        fontWeight: FontWeight.normal,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: "Primary",
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: Colors.yellow.withOpacity(0.9),
        ),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: Colors.yellow.withOpacity(0.9),
      unselectedItemColor: Colors.white,
      selectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontFamily: "Primary",
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontFamily: "Primary",
        fontWeight: FontWeight.bold,
      ),
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.black,
      elevation: 0,
    ),

    dividerTheme: const DividerThemeData(
      color: Colors.white,
      thickness: 1,
    ),
  );
}
