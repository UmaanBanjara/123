import 'package:flutter/material.dart';

class Customtextfile extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String hinttext;
  final TextInputType? keyboardtype;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final TextStyle? textStyle ; 
  final int maxlines ; 
  final String? Function (String?)? validator ;  

  const Customtextfile({
    Key? key,
    required this.controller,
    required this.obscureText,
    required this.hinttext,
    this.keyboardtype,
    this.prefixIcon,
    this.suffixIcon,
    this.validator ,
    this.focusNode,
    this.textStyle ,
    this.maxlines = 1 , 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardtype,
      style: textStyle,
      maxLines: maxlines,
      decoration: InputDecoration(
        hintText: hinttext,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      focusNode: focusNode,
      validator : validator 
    );
  }
}
