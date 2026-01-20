import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event triggered when user requests login
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

/// Event triggered when user requests logout
class AuthLogoutRequested extends AuthEvent {}

/// Event triggered to check if user is already logged in
class AuthCheckRequested extends AuthEvent {}
