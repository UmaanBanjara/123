import 'package:feed/core/utils/error_notice.dart';
import 'package:feed/profilecreation/profile_creation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:page_transition/page_transition.dart';



Future<void> signInWithGoogle(BuildContext context ,{ required bool  isDarkMode , required  VoidCallback onThemeToggle}) async {
  final storage = FlutterSecureStorage();
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // User cancelled the sign-in
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      // Prepare data to send to your backend
      String googleId = user.uid;
      String? email = user.email;
      String? firstName = user.displayName?.split(' ').first ?? '';
      String? lastName = (user.displayName != null && user.displayName!.split(' ').length > 1)
          ? user.displayName!.split(' ').last
          : '';

      // Call your backend google_signin API
      final response = await http.post(
        Uri.parse('http://192.168.1.5:3000/google_signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'google_id': googleId,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responsedata = jsonDecode(response.body);
        final token = responsedata['token'];

        // store token safely
        await storage.write(key: 'jwt_token', value: token);

        // successful login
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: ProfileCreation(
              isDarkMode: isDarkMode,
              onThemeToggle: onThemeToggle,
            ),
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        final responsebody = jsonDecode(response.body);
        final errormessage = responsebody['error'] ?? "Unknown error occurred";
        errorNotice(context, errormessage);
      }
    }
  } catch (e) {
    errorNotice(context, 'An error occurred during Google Sign-In.');
  }
}
