import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/bloc/auth/auth_bloc.dart' as app_user
    show AppUser;
import 'package:taprobana_trails/core/auth/auth_service.dart';
import 'package:taprobana_trails/core/auth/google_auth.dart';
import 'package:taprobana_trails/core/storage/secure_storage.dart';
import 'package:taprobana_trails/data/models/user.dart';
import 'package:taprobana_trails/data/models/app_user.dart';
import 'package:taprobana_trails/data/repositories/user_repository.dart';
import 'package:taprobana_trails/config/constants.dart';

/// Exception thrown when there's an authentication error.
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

/// Repository for authentication-related operations.
class AuthRepository {
  final AuthService _authService;
  final GoogleAuthService _googleAuthService;
  final UserRepository _userRepository;
  final SecureStorage _secureStorage;
  final StreamController<AppUser?> _userController =
      StreamController<AppUser?>.broadcast();

  /// Stream of user changes.
  Stream<AppUser?> get user => _userController.stream;

  /// Creates a new [AuthRepository] instance.
  AuthRepository({
    AuthService? authService,
    GoogleAuthService? googleAuthService,
    UserRepository? userRepository,
    SecureStorage? secureStorage,
  })  : _authService = authService ?? AuthService(),
        _googleAuthService = googleAuthService ?? GoogleAuthService(),
        _userRepository = userRepository ?? UserRepository(),
        _secureStorage = secureStorage ?? SecureStorage() {
    // Listen to Firebase auth changes
    _subscribeToUserChanges();
  }

  /// Subscribes to user changes from Firebase.
  void _subscribeToUserChanges() {
    _authService.userChanges.listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        await _clearAuthData();
        _userController.add(null);
        return;
      }

      try {
        // Get user from repository
        final user = await _userRepository.getUser(firebaseUser.uid);

        if (user != null) {
          await _secureStorage.write(key: StorageKeys.userId, value: user.id);
          _userController.add(user as AppUser?);
        } else {
          // Create new AppUser
          final newUser = User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? '',
            profilePhotoUrl: firebaseUser.photoURL,
            isEmailVerified: firebaseUser.emailVerified,
            createdAt: DateTime.now(),
          );

          await _userRepository.saveUser(newUser);
          await _secureStorage.write(
              key: StorageKeys.userId, value: newUser.id);
          _userController.add(newUser as AppUser?);
        }
      } catch (e) {
        debugPrint('Error getting user data: $e');

        // Create a basic AppUser
        final basicUser = AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? '',
          isEmailVerified: firebaseUser.emailVerified,
          profilePhotoUrl: firebaseUser.photoURL!,
        );

        await _secureStorage.write(
            key: StorageKeys.userId, value: basicUser.id);
        _userController.add(basicUser);
      }
    });
  }

  /// Signs in with email and password.
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user =
          await _authService.signInWithEmailAndPassword(email, password);

      if (user == null) {
        throw AuthException(
          message: 'Failed to sign in',
          code: 'sign_in_failed',
        );
      }

      // Update last login timestamp
      await _userRepository.updateLastLoginTimestamp(user.id);

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      throw AuthException(
        message: 'An error occurred during sign in: ${e.toString()}',
        code: 'unknown_error',
      );
    }
  }

  /// Signs in with Google.
  Future<AppUser> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();

      if (user == null) {
        throw AuthException(
          message: 'Failed to sign in with Google',
          code: 'google_sign_in_failed',
        );
      }

      // Update last login timestamp
      await _userRepository.updateLastLoginTimestamp(user.id);

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      throw AuthException(
        message: 'An error occurred during Google sign in: ${e.toString()}',
        code: 'unknown_error',
      );
    }
  }

  /// Creates a new user with email and password.
  Future<AppUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user =
          await _authService.createUserWithEmailAndPassword(email, password);

      if (user == null) {
        throw AuthException(
          message: 'Failed to create user',
          code: 'create_user_failed',
        );
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await _authService.updateUserProfile(displayName: displayName);
      }

      // Send email verification
      await _authService.sendEmailVerification();

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      throw AuthException(
        message: 'An error occurred during registration: ${e.toString()}',
        code: 'unknown_error',
      );
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await _clearAuthData();
    } catch (e) {
      debugPrint('Error signing out: $e');
      throw AuthException(
        message: 'Failed to sign out: ${e.toString()}',
        code: 'sign_out_failed',
      );
    }
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Failed to send password reset email: ${e.toString()}',
        code: 'password_reset_failed',
      );
    }
  }

  /// Updates the user profile.
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? preferredLanguage,
    String? homeCurrency,
    List<String>? travelPreferences,
    List<String>? dietaryPreferences,
  }) async {
    try {
      // Get current user
      final currentUser = _authService.getCurrentAppUser();

      if (currentUser == null) {
        throw AuthException(
          message: 'User not authenticated',
          code: 'user_not_authenticated',
        );
      }

      // Update Firebase Auth profile
      if (displayName != null || photoUrl != null) {
        await _authService.updateUserProfile(
          displayName: displayName,
          photoUrl: photoUrl,
        );
      }

      // Update Firestore user profile
      await _userRepository.updateProfile(
        currentUser.id,
        displayName: displayName,
        photoUrl: photoUrl,
        preferredLanguage: preferredLanguage,
        homeCurrency: homeCurrency,
        travelPreferences: travelPreferences,
        dietaryPreferences: dietaryPreferences,
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      throw AuthException(
        message: 'Failed to update profile: ${e.toString()}',
        code: 'update_profile_failed',
      );
    }
  }

  /// Updates the user's email.
  Future<void> updateEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Reauthenticate the user first
      final currentUser = _authService.getCurrentAppUser();

      if (currentUser == null || currentUser.email == null) {
        throw AuthException(
          message: 'User not authenticated or no email associated',
          code: 'user_not_authenticated',
        );
      }

      await _authService.reauthenticateWithCredential(
        currentUser.email!,
        password,
      );

      // Update email
      await _authService.updateEmail(email);

      // Send verification email
      await _authService.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      throw AuthException(
        message: 'Failed to update email: ${e.toString()}',
        code: 'update_email_failed',
      );
    }
  }

  /// Updates the user's password.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Reauthenticate the user first
      final currentUser = _authService.getCurrentAppUser();

      if (currentUser == null || currentUser.email == null) {
        throw AuthException(
          message: 'User not authenticated or no email associated',
          code: 'user_not_authenticated',
        );
      }

      await _authService.reauthenticateWithCredential(
        currentUser.email!,
        currentPassword,
      );

      // Update password
      await _authService.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      throw AuthException(
        message: 'Failed to update password: ${e.toString()}',
        code: 'update_password_failed',
      );
    }
  }

  /// Updates the notification settings.
  Future<void> updateNotificationSettings({
    required String userId,
    required bool isPushNotificationsEnabled,
    required bool isEmailNotificationsEnabled,
  }) async {
    try {
      await _userRepository.updateNotificationSettings(
        userId,
        isPushNotificationsEnabled: isPushNotificationsEnabled,
        isEmailNotificationsEnabled: isEmailNotificationsEnabled,
      );
    } catch (e) {
      throw AuthException(
        message: 'Failed to update notification settings: ${e.toString()}',
        code: 'update_settings_failed',
      );
    }
  }

  /// Updates the onboarding status.
  Future<void> updateOnboardingStatus({
    required String userId,
    required bool hasCompletedOnboarding,
  }) async {
    try {
      await _userRepository.updateOnboardingStatus(
        userId,
        hasCompletedOnboarding,
      );
    } catch (e) {
      throw AuthException(
        message: 'Failed to update onboarding status: ${e.toString()}',
        code: 'update_onboarding_failed',
      );
    }
  }

  /// Deletes the current user account.
  Future<void> deleteAccount({
    required String password,
  }) async {
    try {
      // Reauthenticate the user first
      final currentUser = _authService.getCurrentAppUser();

      if (currentUser == null || currentUser.email == null) {
        throw AuthException(
          message: 'User not authenticated or no email associated',
          code: 'user_not_authenticated',
        );
      }

      await _authService.reauthenticateWithCredential(
        currentUser.email!,
        password,
      );

      // Delete user data from Firestore
      await _userRepository.deleteUser(currentUser.id);

      // Delete user from Firebase Auth
      await _authService.deleteUser();

      // Clear local auth data
      await _clearAuthData();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      throw AuthException(
        message: 'Failed to delete account: ${e.toString()}',
        code: 'delete_account_failed',
      );
    }
  }

  /// Gets the current user.
  AppUser? getCurrentUser() {
    return _authService.getCurrentAppUser();
  }

  /// Checks if a user is currently signed in.
  bool isSignedIn() {
    return _authService.currentUser != null;
  }

  /// Gets the current user ID.
  Future<String?> getUserId() async {
    // Try to get from secure storage first for quicker access
    final storedId = await _secureStorage.read(key: StorageKeys.userId);

    if (storedId != null && storedId.isNotEmpty) {
      return storedId;
    }

    // Fall back to Auth service
    return _authService.currentUser?.uid;
  }

  /// Sends an email verification.
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      throw AuthException(
        message: 'Failed to send email verification: ${e.toString()}',
        code: 'verification_failed',
      );
    }
  }

  /// Refreshes the current user data.
  Future<User?> refreshUser() async {
    try {
      final currentUser = _authService.getCurrentAppUser();

      if (currentUser == null) {
        return null;
      }

      final user = await _userRepository.getUser(currentUser.id);

      if (user != null) {
        _userController.add(user as AppUser?);
      }

      return user;
    } catch (e) {
      debugPrint('Error refreshing user: $e');
      return null;
    }
  }

  /// Checks if an email is already in use.
  Future<bool> isEmailInUse(String email) async {
    try {
      final methods = await firebase_auth.FirebaseAuth.instance
          .fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if email is in use: $e');
      return false;
    }
  }

  /// Handles Firebase Auth exceptions and converts them to AuthExceptions.
  AuthException _handleFirebaseAuthException(
      firebase_auth.FirebaseAuthException e) {
    String message;
    String code;

    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email.';
        code = 'user_not_found';
        break;
      case 'wrong-password':
        message = 'Incorrect password.';
        code = 'wrong_password';
        break;
      case 'invalid-email':
        message = 'The email address is not valid.';
        code = 'invalid_email';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        code = 'user_disabled';
        break;
      case 'email-already-in-use':
        message = 'This email is already in use by another account.';
        code = 'email_already_in_use';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed.';
        code = 'operation_not_allowed';
        break;
      case 'weak-password':
        message = 'The password is too weak. Please use a stronger password.';
        code = 'weak_password';
        break;
      case 'requires-recent-login':
        message =
            'This operation requires recent authentication. Please log in again.';
        code = 'requires_recent_login';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        code = 'too_many_requests';
        break;
      case 'network-request-failed':
        message = 'A network error occurred. Please check your connection.';
        code = 'network_error';
        break;
      default:
        message = e.message ?? 'An authentication error occurred.';
        code = e.code;
    }

    return AuthException(
      message: message,
      code: code,
    );
  }

  /// Clears all authentication data.
  Future<void> _clearAuthData() async {
    await _secureStorage.delete(key: StorageKeys.userId);
    await _secureStorage.delete(key: StorageKeys.authToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
  }

  /// Disposes the repository.
  void dispose() {
    _userController.close();
  }
}

extension on AppUser {
  get email => null;

  String get id => "";
}
