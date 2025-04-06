// lib/data/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taprobana_trails/data/models/user.dart';
import 'package:taprobana_trails/data/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService}) : _authService = authService;

  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _authService.signInWithEmail(email, password);
      final User? user = credential.user;

      if (user != null) {
        return _getUserModelFromUser(user);
      } else {
        throw Exception('Failed to sign in');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> registerWithEmail(String email, String password, String name) async {
    try {
      final UserCredential credential = await _authService.registerWithEmail(email, password);
      final User? user = credential.user;

      if (user != null) {
        await user.updateDisplayName(name);

        final UserModel userModel = UserModel(
          id: user.uid,
          email: user.email ?? email,
          name: name,
          photoUrl: user.photoURL,
        );

        await _authService.createUserProfile(userModel);
        return userModel;
      } else {
        throw Exception('Failed to register');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final UserCredential credential = await _authService.signInWithGoogle();
      final User? user = credential.user;

      if (user != null) {
        final UserModel userModel = _getUserModelFromUser(user);

        // Check if user exists in database, if not, create profile
        try {
          await _authService.getUserProfile(user.uid);
        } catch (e) {
          await _authService.createUserProfile(userModel);
        }

        return userModel;
      } else {
        throw Exception('Failed to sign in with Google');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  Future<UserModel> getCurrentUser() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        return await _authService.getUserProfile(user.uid);
      } catch (e) {
        return _getUserModelFromUser(user);
      }
    } else {
      throw Exception('No authenticated user');
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (name != null) {
          await user.updateDisplayName(name);
        }

        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }

        // Update Firestore document
        await _authService.firestore
            .collection('users')
            .doc(user.uid)
            .update({
          if (name != null) 'name': name,
          if (photoUrl != null) 'photoUrl': photoUrl,
        });
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();

  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;

  UserModel _getUserModelFromUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      photoUrl: user.photoURL,
    );
  }
}