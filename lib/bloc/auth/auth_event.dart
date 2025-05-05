part of 'auth_bloc.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event when application starts
class AppStarted extends AuthEvent {}

/// Event when user logs in
class LoggedIn extends AuthEvent {
  final AppUser user;

  const LoggedIn({required this.user});

  @override
  List<Object> get props => [user];
}

/// Event when user logs out
class LoggedOut extends AuthEvent {}

/// Event when the authenticated user changes
// From auth_event.dart
class UserChanged extends AuthEvent {
  // The explicit type declaration in this class is critical
  final AppUser? user;

  const UserChanged({this.user});

  @override
  List<Object?> get props => [user];
}
