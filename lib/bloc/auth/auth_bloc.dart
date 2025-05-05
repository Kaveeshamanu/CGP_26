import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/core/auth/auth_service.dart';
import 'package:taprobana_trails/data/models/app_user.dart';
import 'package:taprobana_trails/data/models/user.dart';
import 'package:taprobana_trails/data/repositories/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC for handling authentication events and states.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final UserRepository _userRepository;
  late final StreamSubscription<AppUser?> _userSubscription;

  AuthBloc({
    required AuthService authService,
    required UserRepository userRepository,
  })  : _authService = authService,
        _userRepository = userRepository,
        super(AuthUninitialized()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
    on<UserChanged>(_onUserChanged);

    _userSubscription = _authService.appUserChanges.listen((user) {
      add(UserChanged(user: user));
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final isSignedIn = _authService.currentUser != null;

      if (isSignedIn) {
        final user = _authService.getCurrentAppUser();

        if (user != null) {
          final completeUser = await _userRepository.getUser(user.id);
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('Error in AppStarted: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Using direct assignment since LoggedIn.user is already typed as AppUser
      final completeUser = await _userRepository.getUser(event.user.id);
      emit(AuthAuthenticated(user: event.user));
    } catch (e) {
      debugPrint('Error in LoggedIn: $e');
      emit(AuthError(message: 'Failed to load user profile'));
      emit(AuthAuthenticated(user: event.user));
    }
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      debugPrint('Error in LoggedOut: $e');
      emit(AuthError(message: 'Failed to sign out'));
    }
  }

  Future<void> _onUserChanged(
      UserChanged event, Emitter<AuthState> emit) async {
    if (event.user == null) {
      emit(AuthUnauthenticated());
    } else {
      // Fix for the type error: Instead of accessing event.user directly,
      // we need to make Dart understand it's an AppUser
      final AppUser appUser = event.user!;

      try {
        final completeUser = await _userRepository.getUser(appUser.id);
        emit(AuthAuthenticated(user: appUser));
      } catch (e) {
        debugPrint('Error in UserChanged: $e');
        emit(AuthAuthenticated(user: appUser));
      }
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
