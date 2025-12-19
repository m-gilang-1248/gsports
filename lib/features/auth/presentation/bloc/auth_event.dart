import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String role;

  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.displayName,
    this.role = 'user',
  });

  @override
  List<Object> get props => [email, password, displayName, role];
}

class AuthGoogleSignInRequested extends AuthEvent {
  final String? role;

  const AuthGoogleSignInRequested({this.role});

  @override
  List<Object> get props => [role ?? ''];
}

class LogoutRequested extends AuthEvent {}
