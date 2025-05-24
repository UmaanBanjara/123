import 'package:flutter/material.dart';

class AppImages{
  static String google(BuildContext context){
    final isdark = Theme.of(context).brightness == Brightness.dark;

    return isdark ? "assets/images/googlelight.png"  : "assets/images/googledark.png" ;
    
  } 

  

  
}