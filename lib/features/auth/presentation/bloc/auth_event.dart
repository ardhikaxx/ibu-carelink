import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const RegisterEvent({required this.name, required this.email, required this.password});

  @override
  List<Object?> get props => [name, email, password];
}

class GoogleLoginEvent extends AuthEvent {}

class SaveRoleEvent extends AuthEvent {
  final String uid;
  final String role;
  const SaveRoleEvent({required this.uid, required this.role});

  @override
  List<Object?> get props => [uid, role];
}

class LogoutEvent extends AuthEvent {}
