import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/core/auth/google_auth.dart';
import 'package:taprobana_trails/data/models/app_user.dart';
import 'package:taprobana_trails/data/models/user.dart';

/// Service class responsible for handling authentication.
class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleAuthService _googleAuthService;

  /// Creates a new instance of [AuthService].
  ///
  /// If no [FirebaseAuth] or [GoogleAuthService] is provided, default instances will be used.
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleAuthService? googleAuthService,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleAuthService = googleAuthService ?? GoogleAuthService();

  /// Stream of authentication state changes.
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  /// Stream of user changes.
  Stream<firebase_auth.User?> get userChanges => _firebaseAuth.userChanges();

  /// The current user.
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  /// Converts a Firebase [User] to an app [AppUser].
  AppUser? _firebaseUserToAppUser(firebase_auth.User? user) {
    if (user == null) return null;

    var appUser = AppUser(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName!,
      profilePhotoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      authProvider: AuthProvider.email,
    );
    return appUser;
  }

  /// Signs in a user with email and password.
  ///
  /// Returns an [AppUser] if successful, or throws an exception if not.
  Future<AppUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return _firebaseUserToAppUser(userCredential.user);
    } catch (e) {
      debugPrint('Sign in with email and password error: $e');
      rethrow;
    }
  }

  /// Signs in a user with Google.
  ///
  /// Returns an [AppUser] if successful, or throws an exception if not.
  Future<AppUser?> signInWithGoogle() async {
    try {
      final userCredential = await _googleAuthService.signIn();
      return _firebaseUserToAppUser(userCredential.user);
    } catch (e) {
      debugPrint('Sign in with Google error: $e');
      rethrow;
    }
  }

  /// Creates a new user with email and password.
  ///
  /// Returns an [AppUser] if successful, or throws an exception if not.
  Future<AppUser?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return _firebaseUserToAppUser(userCredential.user);
    } catch (e) {
      debugPrint('Create user with email and password error: $e');
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleAuthService.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Sends a password reset email to the provided email address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Send password reset email error: $e');
      rethrow;
    }
  }

  /// Updates the current user's profile information.
  Future<void> updateUserProfile(
      {String? displayName, String? photoUrl}) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
      await _firebaseAuth.currentUser?.updatePhotoURL(photoUrl);
    } catch (e) {
      debugPrint('Update user profile error: $e');
      rethrow;
    }
  }

  /// Updates the current user's email.
  Future<void> updateEmail(String email) async {
    try {
      await _firebaseAuth.currentUser?.updateEmail(email);
    } catch (e) {
      debugPrint('Update email error: $e');
      rethrow;
    }
  }

  /// Updates the current user's password.
  Future<void> updatePassword(String password) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(password);
    } catch (e) {
      debugPrint('Update password error: $e');
      rethrow;
    }
  }

  /// Sends an email verification to the current user.
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint('Send email verification error: $e');
      rethrow;
    }
  }

  /// Re-authenticates the current user with their credentials.
  ///
  /// This is useful for operations that require recent authentication, like updating passwords.
  Future<void> reauthenticateWithCredential(
      String email, String password) async {
    try {
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await _firebaseAuth.currentUser?.reauthenticateWithCredential(credential);
    } catch (e) {
      debugPrint('Reauthenticate with credential error: $e');
      rethrow;
    }
  }

  /// Deletes the current user.
  Future<void> deleteUser() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } catch (e) {
      debugPrint('Delete user error: $e');
      rethrow;
    }
  }

  /// Gets the current user as an [AppUser].
  AppUser? getCurrentAppUser() {
    return _firebaseUserToAppUser(_firebaseAuth.currentUser);
  }

  /// Returns a stream of [AppUser] objects based on Firebase auth state changes.
  Stream<AppUser?> get appUserChanges =>
      _firebaseAuth.userChanges().map(_firebaseUserToAppUser);
}
