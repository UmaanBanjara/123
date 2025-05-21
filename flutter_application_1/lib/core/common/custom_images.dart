import 'package:flutter/material.dart';

class AppImages{
  static String google(BuildContext context){
    final isdark = Theme.of(context).brightness == Brightness.dark;

    return isdark ? "assets/images/googlelight.png"  : "assets/images/googledark.png" ;
    
  } 

  static String github(BuildContext context){
    final islight = Theme.of(context).brightness == Brightness.light ; 

    return islight ? "assets/images/github-mark.png" : "assets/images/github-mark-white.png" ;
  }

  
}