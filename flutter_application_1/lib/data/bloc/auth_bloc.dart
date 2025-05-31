 /* import 'dart:convert';
  import 'package:feed/data/bloc/auth_event.dart';
  import 'package:feed/data/bloc/auth_state.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import 'package:http/http.dart' as http;
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:google_sign_in/google_sign_in.dart';

  class AuthBloc extends Bloc<AuthEvent, AuthState> {
    final _storage = const FlutterSecureStorage(); // Secure token storage

    AuthBloc() : super(AuthInitial()) {
      // LOGIN HANDLER
      on<LoginRequested>((event, emit) async {
        emit(AuthLoading());

        try {
          final response = await http.post(
            Uri.parse('http://192.168.1.5:3000/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': event.email,
              'password': event.password,
            }),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final token = data['token'];
            final user = data['user'];

            await _storage.write(key: 'jwt_token', value: token);

            emit(AuthAuthenticated(
              userId: user['id'].toString(),
              email: user['email'],
              profilecompleted: user['profile_completed'] ?? false,
              isGoogleSignIn: false,  // <-- explicitly false here
            ));
          } else {
            final errorData = jsonDecode(response.body);
            emit(AuthError(error: errorData['error'] ?? 'Login failed'));
            emit(AuthUnauthenticated());
          }
        } catch (e) {
          emit(AuthError(error: 'Network error: ${e.toString()}'));
          emit(AuthUnauthenticated());
        }
      });

      // LOGOUT HANDLER
      on<LogoutRequested>((event, emit) async {
        await _storage.delete(key: 'jwt_token');
        emit(AuthUnauthenticated());
      });

      // APP START / AUTO LOGIN HANDLER
      on<AppStarted>((event, emit) async {
        emit(AuthLoading());
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          try {
            final response = await http.get(
              Uri.parse('http://192.168.1.5:3000/getuserdetail'),
              headers: {
                'Authorization': 'Bearer $token',
              },
            );

            if (response.statusCode == 200) {
              final user = jsonDecode(response.body)['user'];
              emit(AuthAuthenticated(
                userId: user['id'].toString(),
                email: user['email'],
                profilecompleted: user['profile_completed'] ?? false,
                isGoogleSignIn: false, // <-- false here as well
              ));
            } else {
              await _storage.delete(key: 'jwt_token');
              emit(AuthUnauthenticated());
            }
          } catch (e) {
            emit(AuthUnauthenticated());
          }
        } else {
          emit(AuthUnauthenticated());
        }
      });

      // GOOGLE SIGN-IN HANDLER
      on<GoogleSigninRequested>((event, emit) async {
        emit(AuthLoading());

        try {
          final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
          if (googleUser == null) {
            emit(AuthUnauthenticated());
            return;
          }

          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          final user = userCredential.user;

          if (user == null || user.email == null) {
            emit(AuthError(error: "Google sign-in failed."));
            emit(AuthUnauthenticated());
            return;
          }

          final nameParts = user.displayName?.split(' ') ?? [];
          final firstName = nameParts.isNotEmpty ? nameParts.first : '';
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          final response = await http.post(
            Uri.parse('http://192.168.1.5:3000/google_signin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'google_id': user.uid,
              'email': user.email,
              'first_name': firstName,
              'last_name': lastName,
            }),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = jsonDecode(response.body);
            final token = data['token'];
            final userData = data['user'];

            await _storage.write(key: 'jwt_token', value: token);

            emit(AuthAuthenticated(
              userId: userData['id'].toString(),
              email: userData['email'],
              profilecompleted: userData['profile_completed'] ?? false,
              isGoogleSignIn: true,  // <-- true for google signin
            ));
          } else {
            final data = jsonDecode(response.body);
            emit(AuthError(error: data['error'] ?? 'Google sign-in failed'));
            emit(AuthUnauthenticated());
          }
        } catch (e) {
          emit(AuthError(error: 'Google Sign-In error: ${e.toString()}'));
          emit(AuthUnauthenticated());
        }
      });

      // SIGNUP HANDLER
      on<SignupSubmitted>((event, emit) async {
        emit(AuthLoading());

        try {
          final response = await http.post(
            Uri.parse('http://192.168.1.5:3000/signup'), // your signup endpoint
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'first_name': event.firstName,
              'last_name': event.lastName,
              'email': event.email,
              'password': event.password,
            }),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = jsonDecode(response.body);
            final token = data['token'];
            final user = data['user'];

            await _storage.write(key: 'jwt_token', value: token);

            emit(AuthAuthenticated(
              userId: user['id'].toString(),
              email: user['email'],
              profilecompleted: user['profile_completed'] ?? false,
              isGoogleSignIn: false,  // <-- false for signup too
            ));
          } else {
            final data = jsonDecode(response.body);
            emit(AuthError(error: data['error'] ?? 'Signup failed'));
            emit(AuthUnauthenticated());
          }
        } catch (e) {
          emit(AuthError(error: 'Network error: ${e.toString()}'));
          emit(AuthUnauthenticated());
        }
      });
    }
  } */
