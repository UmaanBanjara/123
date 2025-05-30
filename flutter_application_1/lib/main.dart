import 'package:feed/config/theme/myapptheme.dart';
import 'package:feed/presentation/loginscreen/loginscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Feed());
}

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,  // No theme toggling, always light
      home: const LoginScreen(),
    );
  }
}
