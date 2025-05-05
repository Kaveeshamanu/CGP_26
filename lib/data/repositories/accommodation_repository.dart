import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:taprobana_trails/data/models/accommodation.dart';
import 'package:taprobana_trails/data/models/room.dart';

/// Repository for managing accommodation data
/// Repository for managing accommodation data
class AccommodationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  final String _collectionPath = 'accommodations';
  final String _bookingsCollectionPath = 'accommodation_bookings';
  final String _userCollection = 'users'; // Added missing collection path

  /// Constructor that initializes Firebase instances
  AccommodationRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Get accommodations, optionally filtered by destination ID
  Future<List<Accommodation>> getAccommodations(
      {required String destinationId}) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('destinationId', isEqualTo: destinationId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Accommodation.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }

  /// Get accommodation by ID
  Future<Accommodation?> getAccommodation(String id) async {
    final doc = await _firestore.collection(_collectionPath).doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return Accommodation.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  /// Get accommodations by destination ID
  Future<List<Accommodation>> getAccommodationsByDestination(
      String destinationId) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('destinationId', isEqualTo: destinationId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Accommodation.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }

  /// Search accommodations by query
  Future<List<Accommodation>> searchAccommodations({
    required String query,
    String? destinationId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guestCount,
    List<String>? amenities,
    double? minPrice,
    double? maxPrice,
    String? accommodationType,
    double? minRating,
  }) async {
    Query query_ = _firestore
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true);

    if (destinationId != null) {
      query_ = query_.where('destinationId', isEqualTo: destinationId);
    }

    if (accommodationType != null) {
      query_ = query_.where('type', isEqualTo: accommodationType);
    }

    if (minRating != null) {
      query_ = query_.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    // Note: For more complex queries, we'll need to fetch and filter in the app
    // since Firestore has limitations on combining different query conditions

    final snapshot = await query_.get();

    List<Accommodation> accommodations = snapshot.docs
        .map((doc) => Accommodation.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }))
        .toList();

    // Apply any additional filters that couldn't be done at the database level
    if (minPrice != null || maxPrice != null) {
      accommodations = accommodations.where((accommodation) {
        final price = accommodation.basePrice;
        if (minPrice != null && price < minPrice) return false;
        if (maxPrice != null && price > maxPrice) return false;
        return true;
      }).toList();
    }

    if (amenities != null && amenities.isNotEmpty) {
      accommodations = accommodations.where((accommodation) {
        return amenities
            .every((amenity) => accommodation.amenities.contains(amenity));
      }).toList();
    }

    if (guestCount != null) {
      accommodations = accommodations.where((accommodation) {
        return accommodation.maxGuests >= guestCount;
      }).toList();
    }

    if (query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      accommodations = accommodations.where((accommodation) {
        return accommodation.name.toLowerCase().contains(lowercaseQuery) ||
            (accommodation.description.toLowerCase().contains(lowercaseQuery));
      }).toList();
    }

    // If dates are provided, we need to check availability
    if (checkInDate != null && checkOutDate != null) {
      final availableIds = await _getAvailableAccommodationIds(
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      accommodations = accommodations.where((accommodation) {
        return availableIds.contains(accommodation.id);
      }).toList();
    }

    return accommodations;
  }

  /// Filter accommodations based on criteria
  Future<List<Accommodation>> filterAccommodations({
    required Map<String, dynamic> filters,
  }) async {
    // Extract filter parameters from the map
    final String? destinationId = filters['destinationId'];
    final DateTime? checkInDate = filters['checkInDate'];
    final DateTime? checkOutDate = filters['checkOutDate'];
    final int? guestCount = filters['guestCount'];
    final List<String>? amenities = filters['amenities']?.cast<String>();
    final double? minPrice = filters['minPrice'];
    final double? maxPrice = filters['maxPrice'];
    final String? accommodationType = filters['accommodationType'];
    final double? minRating = filters['minRating'];
    final String? query = filters['query'];

    // Use the search method with filters
    return searchAccommodations(
      query: query ?? '',
      destinationId: destinationId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      guestCount: guestCount,
      amenities: amenities,
      minPrice: minPrice,
      maxPrice: maxPrice,
      accommodationType: accommodationType,
      minRating: minRating,
    );
  }

  /// Get featured accommodations
  Future<List<Accommodation>> getFeaturedAccommodations(
      {int limit = 10}) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('isFeatured', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Accommodation.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }

  /// Get recommended accommodations
  Future<List<Accommodation>> getRecommendedAccommodations({
    String? destinationId,
    int limit = 10,
  }) async {
    Query query = _firestore
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true)
        .where('isRecommended', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(limit);

    if (destinationId != null) {
      query = query.where('destinationId', isEqualTo: destinationId);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => Accommodation.fromJson({
              'id': doc.id,
              ...(doc.data() as Map<String,
                  dynamic>), // Added casting to ensure type safety
            }))
        .toList();
  }

  /// Get top rated accommodations
  Future<List<Accommodation>> getTopRatedAccommodations(
      {int limit = 10}) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Accommodation.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }

  /// Get user's favorite accommodations
  Future<List<Accommodation>> getFavoriteAccommodations(
      List<String> favoriteIds) async {
    if (favoriteIds.isEmpty) {
      return [];
    }

    // Firestore has a limit on array queries, so we might need to split into batches
    const int batchSize = 10;
    List<Accommodation> result = [];

    for (int i = 0; i < favoriteIds.length; i += batchSize) {
      final end = (i + batchSize < favoriteIds.length)
          ? i + batchSize
          : favoriteIds.length;
      final batch = favoriteIds.sublist(i, end);

      final snapshot = await _firestore
          .collection(_collectionPath)
          .where(FieldPath.documentId, whereIn: batch)
          .where('isActive', isEqualTo: true)
          .get();

      final accommodations = snapshot.docs
          .map((doc) => Accommodation.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      result.addAll(accommodations);
    }

    return result;
  }

  /// Check accommodation availability for specific dates
  Future<bool> checkRoomAvailability({
    required String accommodationId,
    required String roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) async {
    // Make sure the dates are valid
    if (checkIn.isAfter(checkOut)) {
      throw ArgumentError('Check-in date must be before check-out date');
    }

    // Get all bookings that overlap with the requested period
    final snapshot = await _firestore
        .collection(_bookingsCollectionPath)
        .where('accommodationId', isEqualTo: accommodationId)
        .where('roomTypeId', isEqualTo: roomTypeId)
        .where('status', whereIn: ['confirmed', 'pending']).get();

    // Check for any booking conflicts
    for (final doc in snapshot.docs) {
      final bookingData = doc.data();
      final bookingCheckIn = (bookingData['checkInDate'] as Timestamp).toDate();
      final bookingCheckOut =
          (bookingData['checkOutDate'] as Timestamp).toDate();

      // Check if there's an overlap
      if (checkIn.isBefore(bookingCheckOut) &&
          checkOut.isAfter(bookingCheckIn)) {
        return false; // Not available
      }
    }

    return true; // Available
  }

  /// Get room types for an accommodation
  Future<List<Room>> getRoomTypes({
    required String accommodationId,
    DateTime? checkIn,
    DateTime? checkOut,
  }) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .doc(accommodationId)
        .collection('roomTypes')
        .where('isActive', isEqualTo: true)
        .get();

    final roomTypes = snapshot.docs
        .map((doc) => Room.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();

    // If check-in and check-out dates are provided, filter available rooms
    if (checkIn != null && checkOut != null) {
      List<Room> availableRooms = [];

      for (final room in roomTypes) {
        final isAvailable = await checkRoomAvailability(
          accommodationId: accommodationId,
          roomTypeId: room.id,
          checkIn: checkIn,
          checkOut: checkOut,
          guests: 1, // Default value, can be adjusted
        );

        if (isAvailable) {
          availableRooms.add(room);
        }
      }

      return availableRooms;
    }

    return roomTypes;
  }

  /// Book an accommodation
  Future<String> bookAccommodation({
    required String accommodationId,
    required String roomTypeId,
    required String userId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guestCount,
    required double totalPrice,
    String? specialRequests,
  }) async {
    // First, check availability
    final isAvailable = await checkRoomAvailability(
      accommodationId: accommodationId,
      roomTypeId: roomTypeId,
      checkIn: checkInDate,
      checkOut: checkOutDate,
      guests: guestCount,
    );

    if (!isAvailable) {
      throw Exception('Room is not available for the selected dates');
    }

    // Create booking document
    final bookingData = {
      'accommodationId': accommodationId,
      'roomTypeId': roomTypeId,
      'userId': userId,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'guestCount': guestCount,
      'totalPrice': totalPrice,
      'specialRequests': specialRequests,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef =
        await _firestore.collection(_bookingsCollectionPath).add(bookingData);
    return docRef.id;
  }

  /// Cancel a booking
  Future<void> cancelBooking({
    required String bookingId,
    String? cancellationReason,
  }) async {
    await _firestore.collection(_bookingsCollectionPath).doc(bookingId).update({
      'status': 'cancelled',
      'cancellationReason': cancellationReason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get bookings for a user
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    final snapshot = await _firestore
        .collection(_bookingsCollectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('checkInDate', descending: true)
        .get();

    List<Map<String, dynamic>> bookings = [];

    for (final doc in snapshot.docs) {
      final bookingData = doc.data();
      final accommodationId = bookingData['accommodationId'] as String;

      // Get accommodation details
      final accommodation = await getAccommodation(accommodationId);

      if (accommodation != null) {
        bookings.add({
          'id': doc.id,
          ...bookingData,
          'accommodation': accommodation.toJson(),
        });
      }
    }

    return bookings;
  }

  /// Get accommodation images URL
  Future<List<String>> getAccommodationImages(String accommodationId) async {
    try {
      final ref = _storage.ref().child('accommodations/$accommodationId');
      final result = await ref.listAll();

      List<String> urls = [];
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      debugPrint('Error getting accommodation images: $e');
      return [];
    }
  }

  /// Helper method to get IDs of available accommodations for a date range
  Future<List<String>> _getAvailableAccommodationIds({
    required DateTime checkInDate,
    required DateTime checkOutDate,
  }) async {
    // Get all bookings that overlap with the requested period
    final snapshot = await _firestore
        .collection(_bookingsCollectionPath)
        .where('status', whereIn: ['confirmed', 'pending']).get();

    // Create a set of booked accommodation IDs
    Set<String> bookedAccommodationIds = {};

    for (final doc in snapshot.docs) {
      final bookingData = doc.data();
      final bookingCheckIn = (bookingData['checkInDate'] as Timestamp).toDate();
      final bookingCheckOut =
          (bookingData['checkOutDate'] as Timestamp).toDate();

      // Check if there's an overlap
      if (checkInDate.isBefore(bookingCheckOut) &&
          checkOutDate.isAfter(bookingCheckIn)) {
        bookedAccommodationIds.add(bookingData['accommodationId'] as String);
      }
    }

    // Get all accommodation IDs
    final allAccommodationsSnapshot = await _firestore
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true)
        .get();

    // Filter out the booked ones
    return allAccommodationsSnapshot.docs
        .map((doc) => doc.id)
        .where((id) => !bookedAccommodationIds.contains(id))
        .toList();
  }

  /// Add a review for an accommodation
  Future<void> addReview({
    required String accommodationId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    List<String>? photoUrls,
  }) async {
    // Add review to a subcollection
    await _firestore
        .collection(_collectionPath)
        .doc(accommodationId)
        .collection('reviews')
        .add({
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'photoUrls': photoUrls ?? [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update the average rating in the accommodation document
    final reviewsQuery = await _firestore
        .collection(_collectionPath)
        .doc(accommodationId)
        .collection('reviews')
        .get();

    final totalReviews = reviewsQuery.docs.length;
    double sumRatings = 0;

    for (final reviewDoc in reviewsQuery.docs) {
      sumRatings += reviewDoc.data()['rating'] as double;
    }

    final averageRating = totalReviews > 0 ? sumRatings / totalReviews : 0.0;

    await _firestore.collection(_collectionPath).doc(accommodationId).update({
      'rating': averageRating,
      'reviewCount': totalReviews,
    });
  }

  /// Get reviews for an accommodation
  Future<List<Map<String, dynamic>>> getReviews(String accommodationId) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .doc(accommodationId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
              'createdAt': (doc.data()['createdAt'] as Timestamp?)
                  ?.toDate()
                  .toIso8601String(),
            })
        .toList();
  }

  /// Save accommodation to user's favorites
  Future<void> saveAccommodation(
      {required String userId, required String accommodationId}) async {
    await _firestore.collection(_userCollection).doc(userId).update({
      'favoriteAccommodations': FieldValue.arrayUnion([accommodationId]),
    });
  }

  /// Remove accommodation from user's favorites
  Future<void> unsaveAccommodation(
      {required String userId, required String accommodationId}) async {
    await _firestore.collection(_userCollection).doc(userId).update({
      'favoriteAccommodations': FieldValue.arrayRemove([accommodationId]),
    });
  }
}
