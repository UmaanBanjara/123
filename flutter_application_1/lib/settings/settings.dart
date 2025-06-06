import 'package:feed/core/utils/error_notice.dart';
import 'package:feed/presentation/loginscreen/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feed/data/bloc/theme_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart'; // Make sure this points to your ThemeCubit file

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    final storage = FlutterSecureStorage();
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
              title: Text(
                "Change Theme",
                style: const TextStyle(
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
              onTap: () async{
                  await storage.delete(key: 'jwt_token');
                errorNotice(context, "Please Re-Login");
                Navigator.pushAndRemoveUntil(context, PageTransition(

                  type : PageTransitionType.fade , 
                  duration: Duration(milliseconds: 300) ,
                  reverseDuration: Duration(milliseconds: 300) , 
                  child: LoginScreen()

                ) , (route) => false);
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
              onTap: () {
                // Add delete account logic here
              },
            ),
          ),
        ],
      ),
    );
  }
}
