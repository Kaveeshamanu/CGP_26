part of 'auth_bloc.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before auth status is determined
class AuthUninitialized extends AuthState {}

/// Loading state during authentication operations
class AuthLoading extends AuthState {}

/// Authenticated state when user is logged in
class AuthAuthenticated extends AuthState {
  final AppUser user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

/// Unauthenticated state when no user is logged in
class AuthUnauthenticated extends AuthState {}

/// Error state when an auth operation fails
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
