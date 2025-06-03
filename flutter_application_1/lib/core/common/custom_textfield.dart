import 'package:flutter/material.dart';

class Customtextfile extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final int? minlines ; 
  final String? hinttext;
  final TextInputType? keyboardtype;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Widget? suffixIcon;
  final String? suffixText;  
  final FocusNode? focusNode;
  final TextStyle? textStyle;
  final TextStyle? hintStyle ;
  final int? maxlines;
  final String? Function(String?)? validator;
  final double? cursorHeight;

  const Customtextfile({
    Key? key,
    required this.controller,
    required this.obscureText,
    this.hinttext,
    this.cursorHeight,
    this.hintStyle,
    this.keyboardtype,
    this.prefixIcon,
    this.minlines,
    this.prefix,
    this.suffixIcon,
    this.suffixText,  
    this.validator,
    this.focusNode,
    this.textStyle,
    this.maxlines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardtype,
      style: textStyle,
      maxLines: maxlines,
      minLines: minlines,
      cursorHeight: cursorHeight,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(12),
        prefix: prefix,
        hintText: hinttext,
        hintStyle : hintStyle ,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffixText: suffixText,  
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8)
        )
      ),
      focusNode: focusNode,
      validator: validator,
      
    );
  }
}
