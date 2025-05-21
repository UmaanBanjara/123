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
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black , fontFamily: "Primary" , fontSize: 35 , fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(color: Colors.black , fontFamily: "Secondary" , fontSize: 18 , fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: Colors.black , fontFamily: "Texxt" ,  )
      

    ),

    inputDecorationTheme: InputDecorationTheme(
      fillColor : Color(0xFF0093AF).withOpacity(0.1),
      filled: true , 
      contentPadding: EdgeInsets.symmetric(vertical : 8 , horizontal: 12),
      prefixIconColor: Colors.black,
      suffixIconColor: Colors.black,
      hintStyle: TextStyle(
        color : Colors.black , 
        fontFamily: "Seconary" , 
        fontSize: 16 , 
        fontWeight: FontWeight.normal

      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none
      ) ,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none ,
      ) , 
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12) ,
        borderSide: BorderSide(color : Color(0xFF0093AF) , width : 2 )
      )
    ),


    colorScheme: const ColorScheme.light(
      primary: const Color(0xFF0093AF),
      onPrimary: Colors.black,
      background: const Color(0xFFE5E4E2),
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
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white , fontFamily: "Primary" , fontSize: 35 , fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(color: Colors.white , fontFamily: "Secondary" , fontSize: 18, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: Colors.white , fontFamily: "Texxt",   )
    ),
    inputDecorationTheme:InputDecorationTheme(
      fillColor : Colors.yellow.withOpacity(0.1),
      filled: true , 
      contentPadding: EdgeInsets.symmetric(vertical: 8 , horizontal: 12),
      prefixIconColor: Colors.white,
      suffixIconColor: Colors.white,
      hintStyle: TextStyle(
        
        color : Colors.black , 
        fontFamily: "Secondary" , 
        fontSize: 16 , 
        fontWeight: FontWeight.normal

      ) , 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12) , 
        borderSide: BorderSide.none ,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none ,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.yellow , width: 2)
      )
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.yellow,
      onPrimary: Colors.black,
      background: Colors.black,
      onBackground: Colors.white,
    ),
  );
}
