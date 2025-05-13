import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _currentUser;
  bool _isLoading = false;

  AuthService(this._prefs) {
    // Listen for Firebase auth state changes
    _auth.authStateChanges().listen(_handleAuthStateChanged);
    _loadUserFromPrefs();
  }

  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  void _loadUserFromPrefs() {
    final userJson = _prefs.getString('user');
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(json.decode(userJson));
        notifyListeners();
      } catch (e) {
        print('Error loading user: $e');
      }
    }
  }

  void _handleAuthStateChanged(firebase.User? firebaseUser) {
    if (firebaseUser == null) {
      // User signed out
      _currentUser = null;
      _prefs.remove('user');
      notifyListeners();
    } else if (_currentUser?.id != firebaseUser.uid) {
      // Convert Firebase user to our User model
      _currentUser = User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL ??
            'https://ui-avatars.com/api/?name=${firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User'}',
      );

      // Save to prefs
      _prefs.setString('user', json.encode(_currentUser!.toJson()));
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Create user with email and password
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Update photo URL
      await credential.user?.updatePhotoURL(
        'https://ui-avatars.com/api/?name=$name',
      );

      // Reload user to get the updated info
      await credential.user?.reload();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Register error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in flow
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtain the auth details from the Google sign-in
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await _auth.signInWithCredential(credential);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Google login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut(); // Sign out from Google
    await _auth.signOut(); // Sign out from Firebase
    // Firebase auth state listener will handle the rest
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Password reset error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}