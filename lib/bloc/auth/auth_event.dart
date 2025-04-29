part of 'auth_bloc.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event that is fired when the app is started.
class AppStarted extends AuthEvent {}

/// Event that is fired when the user logs in.
class LoggedIn extends AuthEvent {
  final AppUser user;
  
  const LoggedIn({required this.user});
  
  @override
  List<Object> get props => [user];
}

/// Event that is fired when the user logs out.
class LoggedOut extends AuthEvent {}

/// Event that is fired when the user changes.
class UserChanged extends AuthEvent {
  final AppUser? user;
  
  const UserChanged({this.user});
  
  @override
  List<Object?> get props => [user];
}

mixin AppUser {
}

/// Event that is fired when the user updates their profile.
class UpdatedProfile extends AuthEvent {
  final AppUser user;
  
  const UpdatedProfile({required this.user});
  
  @override
  List<Object> get props => [user];
}