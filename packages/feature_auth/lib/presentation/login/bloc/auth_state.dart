import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state when app starts
class AuthInitial extends AuthState {}

/// State when authentication is in progress
class AuthLoading extends AuthState {}

/// State when user is successfully authenticated
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {}

/// State when authentication fails
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
