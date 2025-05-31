
/*
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state - before any action
class AuthInitial extends AuthState {}

// Loading state - while waiting for login/signup response
class AuthLoading extends AuthState {}

// Authenticated state - user is logged in
class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final bool profilecompleted;
  final bool isGoogleSignIn;  // <-- add this flag

  AuthAuthenticated({
    required this.userId,
    required this.email,
    required this.profilecompleted,
    this.isGoogleSignIn = false,  // <-- default to false
  });

  @override
  List<Object?> get props => [userId, email, profilecompleted, isGoogleSignIn];
}

// Unauthenticated state - user is logged out or login failed
class AuthUnauthenticated extends AuthState {}

// Error state - when login/signup fails
class AuthError extends AuthState {
  final String error;

  AuthError({required this.error});

  @override
  List<Object?> get props => [error];
}


*/