  import 'package:flutter/material.dart';

  class AppTheme {
    static final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF0093AF), // Blue Munsell
      scaffoldBackgroundColor: const Color(0xFFE5E4E2), // Platinum
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation : 0, 
        backgroundColor: Color(0xFFE5E4E2),
        foregroundColor: Color(0xFF0093AF),
        titleTextStyle: TextStyle(
          
          fontFamily: "special", 
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0093AF), 
        ),
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
      tabBarTheme: TabBarTheme(
        
        labelColor: Color(0xFF0093AF),
        unselectedLabelColor: Colors.black,
        labelStyle: TextStyle(
          fontFamily: "Primary" , 
          fontSize: 18,
          fontWeight: FontWeight.normal,
        
        ),
        unselectedLabelStyle: TextStyle(

          fontFamily: "Primary" , 
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),

        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 2 , 
            color: Color(0xFF0093AF)
          )
        )
      ),
       bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF0093AF).withOpacity(0.8),
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(
          fontSize: 14,
          fontFamily: "Primary",
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontFamily: "Primary",
          fontWeight: FontWeight.bold
        )
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor:  Color(0xFFE5E4E2),
        elevation: 0,
        
      )
      
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
          color: Colors.white,
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

      tabBarTheme: TabBarTheme(
        labelColor: Colors.yellow,
        unselectedLabelColor: Colors.white,
        labelStyle: TextStyle(
          fontFamily: "Primary", 
          fontSize: 18,
          fontWeight: FontWeight.normal,
        
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: "Primary" , 
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),

        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 2 ,
            color: Colors.yellow.withOpacity(0.2)
          )
        )
      ) ,

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.yellow.withOpacity(0.2),
        unselectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(
          fontSize: 14,
          fontFamily: "Primary",
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontFamily: "Primary",
          fontWeight: FontWeight.bold
        )
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor:  Colors.black,
        elevation: 0,
        
      )
      
    );
  }
