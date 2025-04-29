import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

import '../models/restaurant.dart';

/// Repository for managing restaurant data and operations
class RestaurantRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  final String _collectionPath = 'restaurants';
  final String _reservationsCollectionPath = 'restaurant_reservations';
  
  /// Constructor that initializes Firebase instances
  RestaurantRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _storage = storage ?? FirebaseStorage.instance;
  
  /// Stream of all restaurants
  Stream<List<Restaurant>> getRestaurants({String? destinationId, required int limit, required int offset}) {
    return _firestore
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Restaurant.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }
  
  /// Get restaurant by ID
  Future<Restaurant?> getRestaurantById(String id) async {
    final doc = await _firestore.collection(_collectionPath).doc(id).get();
    
    if (!doc.exists) {
      return null;
    }
    
    return Restaurant.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }
  
  /// Get restaurants by destination ID
  Future<List<Restaurant>> getRestaurantsByDestination(String destinationId) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('destinationId', isEqualTo: destinationId)
        .where('isActive', isEqualTo: true)
        .get();
    
    return snapshot.docs
        .map((doc) => Restaurant.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }
  
  /// Search restaurants by various criteria
  Future<List<Restaurant>> searchRestaurants({
    String? destinationId,
    List<String>? cuisineTypes,
    List<String>? dietaryOptions,
    double? minRating,
    double? maxPrice,
    bool? hasOutdoorSeating,
    String? query,
    double? latitude,
    double? longitude,
    double? radiusKm, required int limit, required int offset,
  }) async {
    Query query_ = _firestore
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true);
    
    if (destinationId != null) {
      query_ = query_.where('destinationId', isEqualTo: destinationId);
    }
    
    if (minRating != null) {
      query_ = query_.where('rating', isGreaterThanOrEqualTo: minRating);
    }
    
    // For single cuisine type query (if only one is specified)
    if (cuisineTypes != null && cuisineTypes.length == 1) {
      query_ = query_.where('cuisineTypes', arrayContains: cuisineTypes.first);
    }
    
    final snapshot = await query_.get();
    
    List<Restaurant> restaurants = snapshot.docs
        .map((doc) => Restaurant.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }))
        .toList();
    
    // Apply additional filters that couldn't be done at the database level
    
    // Filter by multiple cuisine types
    if (cuisineTypes != null && cuisineTypes.length > 1) {
      restaurants = restaurants.where((restaurant) {
        return cuisineTypes.any((cuisine) => 
            restaurant.cuisineTypes?.contains(cuisine) ?? false);
      }).toList();
    }
    
    // Filter by dietary options
    if (dietaryOptions != null && dietaryOptions.isNotEmpty) {
      restaurants = restaurants.where((restaurant) {
        return dietaryOptions.every((option) => 
            restaurant.dietaryOptions?.contains(option) ?? false);
      }).toList();
    }
    
    // Filter by price level
    if (maxPrice != null) {
      restaurants = restaurants.where((restaurant) {
        return restaurant.priceLevel <= maxPrice.toInt();
      }).toList();
    }
    
    // Filter by outdoor seating
    if (hasOutdoorSeating != null && hasOutdoorSeating) {
      restaurants = restaurants.where((restaurant) {
        return restaurant.hasOutdoorSeating;
      }).toList();
    }
    
    // Filter by text query
    if (query != null && query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      restaurants = restaurants.where((restaurant) {
        return restaurant.name.toLowerCase().contains(lowercaseQuery) ||
               (restaurant.description.toLowerCase().contains(lowercaseQuery)) ||
               (restaurant.cuisineTypes?.any((cuisine) => 
                  cuisine.toLowerCase().contains(lowercaseQuery)) ?? false);
      }).toList();
    }
    
    // Filter by location and radius
    if (latitude != null && longitude != null && radiusKm != null) {
      restaurants = restaurants.where((restaurant) {
        final distance = _calculateDistance(
          latitude, 
          longitude, 
          restaurant.latitude, 
          restaurant.longitude
        );
        
        return distance <= radiusKm;
      }).toList();
    }
    
    return restaurants;
  }
  
  /// Get featured restaurants
  Future<List<Restaurant>> getFeaturedRestaurants({int limit = 10, String? destinationId}) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('isFeatured', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => Restaurant.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }
  
  /// Get top rated restaurants
  Future<List<Restaurant>> getTopRatedRestaurants({int limit = 10}) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => Restaurant.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }
  
  /// Get restaurants by cuisine type
  Future<List<Restaurant>> getRestaurantsByCuisine(String cuisineType, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('cuisineTypes', arrayContains: cuisineType)
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => Restaurant.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }
  
  /// Get restaurants with specific dietary options
  Future<List<Restaurant>> getRestaurantsByDietaryOption(String dietaryOption, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('dietaryOptions', arrayContains: dietaryOption)
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => Restaurant.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }
  
  /// Get user's favorite restaurants
  Future<List<Restaurant>> getFavoriteRestaurants(List<String> favoriteIds) async {
    if (favoriteIds.isEmpty) {
      return [];
    }
    
    // Firestore has a limit on array queries, so we might need to split into batches
    const int batchSize = 10;
    List<Restaurant> result = [];
    
    for (int i = 0; i < favoriteIds.length; i += batchSize) {
      final end = (i + batchSize < favoriteIds.length) ? i + batchSize : favoriteIds.length;
      final batch = favoriteIds.sublist(i, end);
      
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where(FieldPath.documentId, whereIn: batch)
          .where('isActive', isEqualTo: true)
          .get();
      
      final restaurants = snapshot.docs.map((doc) => Restaurant.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
      
      result.addAll(restaurants);
    }
    
    return result;
  }
  
  /// Get restaurant menu
  Future<List<Map<String, dynamic>>> getRestaurantMenu(String restaurantId) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .doc(restaurantId)
        .collection('menu_categories')
        .orderBy('order')
        .get();
    
    List<Map<String, dynamic>> menuCategories = [];
    
    for (final categoryDoc in snapshot.docs) {
      final categoryData = categoryDoc.data();
      final categoryId = categoryDoc.id;
      
      // Get menu items for this category
      final itemsSnapshot = await _firestore
          .collection(_collectionPath)
          .doc(restaurantId)
          .collection('menu_categories')
          .doc(categoryId)
          .collection('items')
          .orderBy('order')
          .get();
      
      final items = itemsSnapshot.docs.map((itemDoc) => {
        'id': itemDoc.id,
        ...itemDoc.data(),
      }).toList();
      
      menuCategories.add({
        'id': categoryId,
        'name': categoryData['name'],
        'description': categoryData['description'],
        'order': categoryData['order'],
        'items': items,
      });
    }
    
    return menuCategories;
  }
  
  /// Check restaurant availability for reservation
  Future<Map<String, dynamic>> checkReservationAvailability({
    required String restaurantId,
    required DateTime date,
    required int partySize,
  }) async {
    try {
      // Get restaurant operation hours
      final restaurant = await getRestaurantById(restaurantId);
      
      if (restaurant == null) {
        return {
          'available': false,
          'message': 'Restaurant not found',
          'availableSlots': <Map<String, dynamic>>[],
        };
      }
      
      // Check if restaurant is open on the requested date
      final dayOfWeek = date.weekday; // 1 = Monday, 7 = Sunday
      final operatingHours = restaurant.operatingHours;
      
      if (operatingHours == null || operatingHours.isEmpty) {
        return {
          'available': false,
          'message': 'Operating hours information not available',
          'availableSlots': <Map<String, dynamic>>[],
        };
      }
      
      final dayHours = operatingHours.firstWhereOrNull((hours) => hours['day'] == dayOfWeek);
      
      if (dayHours == null || dayHours['closed'] == true) {
        return {
          'available': false,
          'message': 'Restaurant is closed on the requested date',
          'availableSlots': <Map<String, dynamic>>[],
        };
      }
      
      // Get opening and closing times
      final openTime = _parseTimeString(dayHours['open']);
      final closeTime = _parseTimeString(dayHours['close']);
      
      // Check if restaurant has enough capacity
      if (restaurant.maxCapacity != null && partySize > restaurant.maxCapacity!) {
        return {
          'available': false,
          'message': 'Party size exceeds restaurant capacity',
          'availableSlots': <Map<String, dynamic>>[],
        };
      }
      
      // Get all existing reservations for the date
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final reservationsSnapshot = await _firestore
          .collection(_reservationsCollectionPath)
          .where('restaurantId', isEqualTo: restaurantId)
          .where('reservationTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('reservationTime', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: ['confirmed', 'pending'])
          .get();
      
      final existingReservations = reservationsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'time': (data['reservationTime'] as Timestamp).toDate(),
          'partySize': data['partySize'] as int,
        };
      }).toList();
      
      // Generate available time slots
      final interval = const Duration(minutes: 30); // 30-minute intervals
      DateTime currentSlot = DateTime(
        date.year, 
        date.month, 
        date.day, 
        openTime['hour']!, 
        openTime['minute']!
      );
      
      final endTime = DateTime(
        date.year, 
        date.month, 
        date.day, 
        closeTime['hour']!, 
        closeTime['minute']!
      );
      
      List<Map<String, dynamic>> availableSlots = [];
      
      while (currentSlot.isBefore(endTime.subtract(const Duration(hours: 1)))) {
        // Check if this slot is available based on existing reservations
        final slotEnd = currentSlot.add(const Duration(hours: 2)); // Assuming 2-hour dining window
        
        // Count reservations that overlap with this slot
        int overlappingPartySize = 0;
        for (final reservation in existingReservations) {
          final reservationTime = reservation['time'] as DateTime;
          final reservationEnd = reservationTime.add(const Duration(hours: 2));
          
          if ((reservationTime.isBefore(slotEnd) && reservationEnd.isAfter(currentSlot))) {
            overlappingPartySize += reservation['partySize'] as int;
          }
        }
        
        // Check if there's enough capacity for this party
        final remainingCapacity = (restaurant.maxCapacity ?? 100) - overlappingPartySize;
        final isAvailable = remainingCapacity >= partySize;
        
        // Only add available slots
        if (isAvailable) {
          availableSlots.add({
            'time': currentSlot,
            'formattedTime': '${currentSlot.hour.toString().padLeft(2, '0')}:${currentSlot.minute.toString().padLeft(2, '0')}',
            'remainingCapacity': remainingCapacity,
          });
        }
        
        // Move to next slot
        currentSlot = currentSlot.add(interval);
      }
      
      return {
        'available': availableSlots.isNotEmpty,
        'message': availableSlots.isNotEmpty 
            ? 'Reservation slots available' 
            : 'No available slots for the requested date and party size',
        'availableSlots': availableSlots,
      };
    } catch (e) {
      debugPrint('Error checking reservation availability: $e');
      return {
        'available': false,
        'message': 'Error checking availability',
        'availableSlots': <Map<String, dynamic>>[],
      };
    }
  }
  
  /// Make a restaurant reservation
  Future<String> makeReservation({
    required String restaurantId,
    required String userId,
    required String userName,
    required String userPhone,
    required DateTime reservationTime,
    required int partySize,
    String? specialRequests,
  }) async {
    // First check if the requested time is available
    final availabilityCheck = await checkReservationAvailability(
      restaurantId: restaurantId,
      date: reservationTime,
      partySize: partySize,
    );
    
    if (!availabilityCheck['available']) {
      throw Exception(availabilityCheck['message']);
    }
    
    // Check if the exact time slot is available
    final availableSlots = availabilityCheck['availableSlots'] as List<Map<String, dynamic>>;
    final requestedTime = '${reservationTime.hour.toString().padLeft(2, '0')}:${reservationTime.minute.toString().padLeft(2, '0')}';
    
    final isTimeAvailable = availableSlots.any((slot) => slot['formattedTime'] == requestedTime);
    
    if (!isTimeAvailable) {
      throw Exception('The selected time slot is no longer available');
    }
    
    // Create the reservation
    final reservationData = {
      'restaurantId': restaurantId,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'reservationTime': Timestamp.fromDate(reservationTime),
      'partySize': partySize,
      'specialRequests': specialRequests,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    final docRef = await _firestore
        .collection(_reservationsCollectionPath)
        .add(reservationData);
    
    return docRef.id;
  }
  
  /// Cancel a reservation
  Future<void> cancelReservation({
    required String reservationId,
    String? cancellationReason,
  }) async {
    await _firestore
        .collection(_reservationsCollectionPath)
        .doc(reservationId)
        .update({
          'status': 'cancelled',
          'cancellationReason': cancellationReason,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
  
  /// Get reservations for a user
  Future<List<Map<String, dynamic>>> getUserReservations(String userId) async {
    final snapshot = await _firestore
        .collection(_reservationsCollectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('reservationTime', descending: true)
        .get();
    
    List<Map<String, dynamic>> reservations = [];
    
    for (final doc in snapshot.docs) {
      final reservationData = doc.data();
      final restaurantId = reservationData['restaurantId'] as String;
      
      // Get restaurant details
      final restaurant = await getRestaurantById(restaurantId);
      
      if (restaurant != null) {
        reservations.add({
          'id': doc.id,
          ...reservationData,
          'restaurant': restaurant.toJson(),
          'reservationTime': (reservationData['reservationTime'] as Timestamp).toDate().toIso8601String(),
          'createdAt': (reservationData['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
          'updatedAt': (reservationData['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
        });
      }
    }
    
    return reservations;
  }
  
  /// Get restaurant images URL
  Future<List<String>> getRestaurantImages(String restaurantId) async {
    try {
      final ref = _storage.ref().child('restaurants/$restaurantId');
      final result = await ref.listAll();
      
      List<String> urls = [];
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      debugPrint('Error getting restaurant images: $e');
      return [];
    }
  }
  
  /// Add a review for a restaurant
  Future<void> addReview({
    required String restaurantId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    List<String>? photoUrls,
    String? visitDate,
  }) async {
    // Add review to a subcollection
    await _firestore
        .collection(_collectionPath)
        .doc(restaurantId)
        .collection('reviews')
        .add({
          'userId': userId,
          'userName': userName,
          'rating': rating,
          'comment': comment,
          'photoUrls': photoUrls ?? [],
          'visitDate': visitDate,
          'createdAt': FieldValue.serverTimestamp(),
          'likes': 0,
        });
    
    // Update the average rating in the restaurant document
    final reviewsQuery = await _firestore
        .collection(_collectionPath)
        .doc(restaurantId)
        .collection('reviews')
        .get();
    
    final totalReviews = reviewsQuery.docs.length;
    double sumRatings = 0;
    
    for (final reviewDoc in reviewsQuery.docs) {
      sumRatings += reviewDoc.data()['rating'] as double;
    }
    
    final averageRating = totalReviews > 0 ? sumRatings / totalReviews : 0.0;
    
    await _firestore.collection(_collectionPath).doc(restaurantId).update({
      'rating': averageRating,
      'reviewCount': totalReviews,
    });
  }
  
  /// Get reviews for a restaurant
  Future<List<Map<String, dynamic>>> getReviews(String restaurantId) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .doc(restaurantId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
      'createdAt': (doc.data()['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    }).toList();
  }
  
  /// Like a review
  Future<void> likeReview(String restaurantId, String reviewId) async {
    final reviewRef = _firestore
        .collection(_collectionPath)
        .doc(restaurantId)
        .collection('reviews')
        .doc(reviewId);
    
    await _firestore.runTransaction((transaction) async {
      final reviewDoc = await transaction.get(reviewRef);
      if (!reviewDoc.exists) {
        throw Exception('Review does not exist');
      }
      
      final currentLikes = reviewDoc.data()?['likes'] as int? ?? 0;
      transaction.update(reviewRef, {'likes': currentLikes + 1});
    });
  }
  
  /// Helper method to calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    const c = 12742; // 2 * Earth's radius in km
    
    final a = 0.5 - 
      (0.5 * cos((lat2 - lat1) * p)) + 
      cos(lat1 * p) * cos(lat2 * p) * 
      (0.5 - 0.5 * cos((lon2 - lon1) * p));
    
    return c * asin(sqrt(a));
  }
  
  /// Helper method to parse time string (format: "HH:MM")
  Map<String, int> _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return {
      'hour': int.parse(parts[0]),
      'minute': int.parse(parts[1]),
    };
  }

  getPopularRestaurants() {}

  filterRestaurants({String? destinationId, List<String>? cuisineTypes, required priceRange, double? rating, List<String>? facilities, List<String>? dietaryOptions}) {}

  getNearbyRestaurants({required double latitude, required double longitude, required double radiusInKm, required int limit}) {}

  toggleFavorite({required String restaurantId, required String userId}) {}

  submitReview({required String restaurantId, required String userId, required double rating, required String comment, List<String>? photos}) {}

  bookTable({required String restaurantId, required DateTime date, required time, required int partySize, String? specialRequests, required String userId}) {}
}