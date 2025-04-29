part of 'auth_bloc.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// State that represents that the authentication state is not yet determined.
class AuthUninitialized extends AuthState {}

/// State that represents that the authentication state is loading.
class AuthLoading extends AuthState {}

/// State that represents that the user is authenticated.
class AuthAuthenticated extends AuthState {
  final AppUser user;
  
  const AuthAuthenticated({required this.user});
  
  @override
  List<Object> get props => [user];
}

/// State that represents that the user is not authenticated.
class AuthUnauthenticated extends AuthState {}

/// State that represents that an error occurred during authentication.
class AuthError extends AuthState {
  final String message;
  
  const AuthError({required this.message});
  
  @override
  List<Object> get props => [message];
}