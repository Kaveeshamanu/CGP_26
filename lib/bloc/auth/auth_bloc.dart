import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/core/auth/auth_service.dart';
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
          emit(AuthAuthenticated(user: completeUser ?? user));
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
      // When a user logs in, we need to get their complete profile from the repository
      final user = await _userRepository.getUser(event.user.id);
      emit(AuthAuthenticated(user: user ?? event.user));
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
  
  Future<void> _onUserChanged(UserChanged event, Emitter<AuthState> emit) async {
    if (event.user == null) {
      emit(AuthUnauthenticated());
    } else {
      try {
        // When the user changes, we need to get their complete profile from the repository
        final completeUser = await _userRepository.getUser(event.user!.id);
        emit(AuthAuthenticated(user: completeUser ?? event.user!));
      } catch (e) {
        debugPrint('Error in UserChanged: $e');
        // Even if we fail to get the complete user, we still want to consider the user authenticated
        emit(AuthAuthenticated(user: event.user!));
      }
    }
  }
  
  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}

extension on AppUser {
  String get id => "";
}
