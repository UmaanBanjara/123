import 'package:feed/config/theme/myapptheme.dart';
import 'package:feed/presentation/loginscreen/loginscreen.dart';
import 'package:feed/presentation/signupscreen/signupscreen.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(Feed());
}

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false ,
      home : LoginScreen() ,
      theme: AppTheme.lightTheme,
    );
  }
}