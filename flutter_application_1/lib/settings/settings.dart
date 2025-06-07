import 'package:feed/core/utils/error_notice.dart';
import 'package:feed/presentation/loginscreen/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feed/data/bloc/theme_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 200),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Icon(isDark ? Icons.nights_stay : Icons.wb_sunny),
              title: const Text(
                "Change Theme",
                style: TextStyle(
                  fontFamily: "rEGULAR",
                  fontSize: 15,
                ),
              ),
              onTap: () {
                context.read<ThemeCubit>().toggleTheme();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const Icon(Icons.lock_rounded),
              title: const Text(
                "Logout",
                style: TextStyle(fontFamily: "rEGULAR", fontSize: 15),
              ),
              onTap: () async {
                await storage.delete(key: 'jwt_token');
                errorNotice(context, "Please Re-Login");
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 300),
                    child: const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const Icon(Icons.delete),
              title: const Text(
                "Delete Account",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: "rEGULAR",
                  fontSize: 15,
                ),
              ),
              onTap: () async {
                final token = await storage.read(key: 'jwt_token');

                if (token == null) {
                  errorNotice(context, 'No token found. Please log in again.');
                  return;
                }

                final response = await http.delete(
                  Uri.parse('http://192.168.1.5:3000/delete-account'), 
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                );

                if (response.statusCode == 200) {
                  await storage.delete(key: 'jwt_token');
                  errorNotice(context, 'Account deleted successfully.');

                  Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 300),
                      child: const LoginScreen(),
                    ),
                    (route) => false,
                  );
                } else {
                  errorNotice(context, 'Failed to delete account. Please try again.');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
