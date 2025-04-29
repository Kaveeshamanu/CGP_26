import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/bloc/auth/auth_bloc.dart';
import 'package:taprobana_trails/data/models/user.dart';

/// Repository for user-related operations.
class UserRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'users';
  
  /// Creates a new [UserRepository] instance.
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Gets a user by ID.
  Future<AppUser?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return AppUser.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }
  
  /// Creates or updates a user.
  Future<void> saveUser(AppUser user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(
        user.toJson(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error saving user: $e');
      rethrow;
    }
  }
  
  /// Deletes a user.
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }
  
  /// Updates a user's profile.
  Future<void> updateProfile(
    String userId, {
    String? displayName,
    String? photoUrl,
    String? preferredLanguage,
    String? homeCurrency,
    List<String>? travelPreferences,
    List<String>? dietaryPreferences,
  }) async {
    try {
      final data = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (displayName != null) data['displayName'] = displayName;
      if (photoUrl != null) data['photoUrl'] = photoUrl;
      if (preferredLanguage != null) data['preferredLanguage'] = preferredLanguage;
      if (homeCurrency != null) data['homeCurrency'] = homeCurrency;
      if (travelPreferences != null) data['travelPreferences'] = travelPreferences;
      if (dietaryPreferences != null) data['dietaryPreferences'] = dietaryPreferences;
      
      await _firestore.collection(_collection).doc(userId).update(data);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }
  
  /// Updates a user's notification settings.
  Future<void> updateNotificationSettings(
    String userId, {
    bool? isPushNotificationsEnabled,
    bool? isEmailNotificationsEnabled,
  }) async {
    try {
      final data = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (isPushNotificationsEnabled != null) {
        data['isPushNotificationsEnabled'] = isPushNotificationsEnabled;
      }
      
      if (isEmailNotificationsEnabled != null) {
        data['isEmailNotificationsEnabled'] = isEmailNotificationsEnabled;
      }
      
      await _firestore.collection(_collection).doc(userId).update(data);
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      rethrow;
    }
  }
  
  /// Updates a user's onboarding status.
  Future<void> updateOnboardingStatus(String userId, bool hasCompletedOnboarding) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating onboarding status: $e');
      rethrow;
    }
  }
  
  /// Adds a destination to a user's saved destinations.
  Future<void> addSavedDestination(String userId, String destinationId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'savedDestinations': FieldValue.arrayUnion([destinationId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding saved destination: $e');
      rethrow;
    }
  }
  
  /// Removes a destination from a user's saved destinations.
  Future<void> removeSavedDestination(String userId, String destinationId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'savedDestinations': FieldValue.arrayRemove([destinationId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error removing saved destination: $e');
      rethrow;
    }
  }
  
  /// Adds an accommodation to a user's saved accommodations.
  Future<void> addSavedAccommodation(String userId, String accommodationId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'savedAccommodations': FieldValue.arrayUnion([accommodationId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding saved accommodation: $e');
      rethrow;
    }
  }
  
  /// Removes an accommodation from a user's saved accommodations.
  Future<void> removeSavedAccommodation(String userId, String accommodationId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'savedAccommodations': FieldValue.arrayRemove([accommodationId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error removing saved accommodation: $e');
      rethrow;
    }
  }
  
  /// Adds a restaurant to a user's saved restaurants.
  Future<void> addSavedRestaurant(String userId, String restaurantId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'savedRestaurants': FieldValue.arrayUnion([restaurantId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding saved restaurant: $e');
      rethrow;
    }
  }
  
  /// Removes a restaurant from a user's saved restaurants.
  Future<void> removeSavedRestaurant(String userId, String restaurantId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'savedRestaurants': FieldValue.arrayRemove([restaurantId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error removing saved restaurant: $e');
      rethrow;
    }
  }
  
  /// Updates a user's last login timestamp.
  Future<void> updateLastLoginTimestamp(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating last login timestamp: $e');
      rethrow;
    }
  }

  getUpcomingItineraries() {}

  toggleBookmarkDestination(String destinationId, bool isBookmarked) {}

  toggleFavoriteDestination(String destinationId) {}

  getCurrentUser() {}
}

extension on AppUser {
  String? get id => '';
}