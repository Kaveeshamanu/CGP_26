import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Service class responsible for handling Google authentication.
class GoogleAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  
  /// Creates a new instance of [GoogleAuthService].
  /// 
  /// If no [FirebaseAuth] or [GoogleSignIn] is provided, the default instances will be used.
  GoogleAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(
         scopes: [
           'email',
           'profile',
         ],
       );
  
  /// Signs in the user with Google.
  /// 
  /// Returns a [UserCredential] if successful, or throws an exception if not.
  Future<UserCredential> signIn() async {
    try {
      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If user canceled the sign-in flow, throw an exception
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign-in-canceled',
          message: 'Sign in was canceled by the user',
        );
      }
      
      // Obtain the auth details from the Google sign-in
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      return userCredential;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      rethrow;
    }
  }
  
  /// Signs out the current user from both Firebase and Google.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }
  
  /// Checks if a user is currently signed in.
  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }
  
  /// Gets the current Firebase user ID.
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }
  
  /// Gets the current Firebase user.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
  
  /// Gets the current user's display name.
  String? getCurrentUserDisplayName() {
    return _firebaseAuth.currentUser?.displayName;
  }
  
  /// Gets the current user's email.
  String? getCurrentUserEmail() {
    return _firebaseAuth.currentUser?.email;
  }
  
  /// Gets the current user's photo URL.
  String? getCurrentUserPhotoUrl() {
    return _firebaseAuth.currentUser?.photoURL;
  }
  
  /// Checks if the current user's email is verified.
  bool isEmailVerified() {
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }
}