import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/data/models/destination.dart';

/// Repository for destination-related operations.
class DestinationRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'destinations';
  final String _userCollection = 'users';

  /// Creates a new [DestinationRepository] instance.
  DestinationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Gets all destinations, optionally filtered by category.
  Future<List<Destination>> getDestinations({String? category}) async {
    try {
      Query query = _firestore.collection(_collection);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
              (doc) => Destination.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting destinations: $e');
      return [];
    }
  }

  /// Gets a destination by ID.
  Future<Destination?> getDestination(String destinationId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(destinationId).get();

      if (!doc.exists) {
        return null;
      }

      return Destination.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error getting destination: $e');
      return null;
    }
  }

  /// Gets a destination by ID (alternative method name).
  Future<Destination?> getDestinationById(String destinationId) async {
    return getDestination(destinationId);
  }

  /// Gets trending destinations.
  Future<List<Destination>> getTrendingDestinations() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isTrending', isEqualTo: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => Destination.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting trending destinations: $e');
      return [];
    }
  }

  /// Gets deals, optionally filtered by category and limited to a certain number.
  Future<List<Destination>> getDeals(
      {String? category, required int limit}) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('hasDeals', isEqualTo: true)
          .limit(limit);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
              (doc) => Destination.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting deals: $e');
      return [];
    }
  }

  /// Filters destinations based on provided filters.
  Future<List<Destination>> filterDestinations({
    required Map<String, dynamic> filters,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      // Apply filters
      if (filters.containsKey('category') && filters['category'] != null) {
        query = query.where('category', isEqualTo: filters['category']);
      }

      if (filters.containsKey('tags') && filters['tags'] != null) {
        final tags = filters['tags'] as List<String>;
        if (tags.isNotEmpty) {
          query = query.where('tags', arrayContainsAny: tags);
        }
      }

      if (filters.containsKey('rating') && filters['rating'] != null) {
        final minRating = filters['rating'] as double;
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      // Maximum budget filter
      if (filters.containsKey('maxBudget') && filters['maxBudget'] != null) {
        final maxBudget = filters['maxBudget'] as double;
        query = query.where('estimatedBudget', isLessThanOrEqualTo: maxBudget);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
              (doc) => Destination.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error filtering destinations: $e');
      return [];
    }
  }

  /// Searches destinations by name or description.
  Future<List<Destination>> searchDestinations({required String query}) async {
    try {
      // Firestore doesn't support full-text search, so we'll use a simple approach
      // In a real app, you might use Algolia or similar
      final snapshot = await _firestore.collection(_collection).get();

      final searchQuery = query.toLowerCase();

      return snapshot.docs
          .map((doc) => Destination.fromJson(doc.data()))
          .where((destination) {
        return destination.name.toLowerCase().contains(searchQuery) ||
            destination.description.toLowerCase().contains(searchQuery) ||
            destination.location.toLowerCase().contains(searchQuery) ||
            destination.tags
                .any((tag) => tag.toLowerCase().contains(searchQuery));
      }).toList();
    } catch (e) {
      debugPrint('Error searching destinations: $e');
      return [];
    }
  }

  /// Saves a destination for a user.
  Future<void> saveDestination({
    required String userId,
    required String destinationId,
  }) async {
    try {
      await _firestore.collection(_userCollection).doc(userId).update({
        'savedDestinations': FieldValue.arrayUnion([destinationId]),
      });
    } catch (e) {
      debugPrint('Error saving destination: $e');
      rethrow;
    }
  }

  /// Unsaves a destination for a user.
  Future<void> unsaveDestination({
    required String userId,
    required String destinationId,
  }) async {
    try {
      await _firestore.collection(_userCollection).doc(userId).update({
        'savedDestinations': FieldValue.arrayRemove([destinationId]),
      });
    } catch (e) {
      debugPrint('Error unsaving destination: $e');
      rethrow;
    }
  }

  /// Gets destinations saved by a user.
  Future<List<Destination>> getSavedDestinations(
      {required String userId}) async {
    try {
      // Get user's saved destination IDs
      final userDoc =
          await _firestore.collection(_userCollection).doc(userId).get();

      if (!userDoc.exists ||
          !userDoc.data()!.containsKey('savedDestinations')) {
        return [];
      }

      final savedIds = List<String>.from(userDoc.data()!['savedDestinations']);

      if (savedIds.isEmpty) {
        return [];
      }

      // Fetch destinations in batches (Firestore has a limit on 'in' queries)
      final allDestinations = <Destination>[];
      for (int i = 0; i < savedIds.length; i += 10) {
        final end = (i + 10 < savedIds.length) ? i + 10 : savedIds.length;
        final batch = savedIds.sublist(i, end);

        final snapshot = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        final destinations = snapshot.docs
            .map((doc) =>
                Destination.fromJson(doc.data()).copyWith(isSaved: true))
            .toList();

        allDestinations.addAll(destinations);
      }

      return allDestinations;
    } catch (e) {
      debugPrint('Error getting saved destinations: $e');
      return [];
    }
  }

  /// Gets recently viewed destinations for a user.
  Future<List<Destination>> getRecentlyViewedDestinations(
      {required String userId}) async {
    try {
      // Get user's recently viewed destination IDs
      final userDoc =
          await _firestore.collection(_userCollection).doc(userId).get();

      if (!userDoc.exists || !userDoc.data()!.containsKey('recentlyViewed')) {
        return [];
      }

      final recentIds = List<String>.from(userDoc.data()!['recentlyViewed']);

      if (recentIds.isEmpty) {
        return [];
      }

      // Fetch destinations in batches
      final allDestinations = <Destination>[];
      for (int i = 0; i < recentIds.length; i += 10) {
        final end = (i + 10 < recentIds.length) ? i + 10 : recentIds.length;
        final batch = recentIds.sublist(i, end);

        final snapshot = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        final destinations = snapshot.docs
            .map((doc) => Destination.fromJson(doc.data()))
            .toList();

        allDestinations.addAll(destinations);
      }

      // Sort by the original order of recentIds (most recent first)
      allDestinations.sort((a, b) {
        final indexA = recentIds.indexOf(a.id);
        final indexB = recentIds.indexOf(b.id);
        return indexA.compareTo(indexB);
      });

      return allDestinations;
    } catch (e) {
      debugPrint('Error getting recently viewed destinations: $e');
      return [];
    }
  }

  /// Adds a destination to a user's recently viewed list.
  Future<void> addToRecentlyViewed(
      {required String userId, required String destinationId}) async {
    try {
      // First remove the destination ID if it already exists (to move it to the front)
      await _firestore.collection(_userCollection).doc(userId).update({
        'recentlyViewed': FieldValue.arrayRemove([destinationId]),
      });

      // Then add it to the front of the array
      await _firestore.collection(_userCollection).doc(userId).update({
        'recentlyViewed': FieldValue.arrayUnion([destinationId]),
      });

      // Optional: Limit the size of the array (e.g., keep only the 20 most recent)
      final userDoc =
          await _firestore.collection(_userCollection).doc(userId).get();

      if (userDoc.exists && userDoc.data()!.containsKey('recentlyViewed')) {
        final recentIds = List<String>.from(userDoc.data()!['recentlyViewed']);

        if (recentIds.length > 20) {
          final toKeep = recentIds.sublist(0, 20);
          await _firestore.collection(_userCollection).doc(userId).update({
            'recentlyViewed': toKeep,
          });
        }
      }
    } catch (e) {
      debugPrint('Error adding to recently viewed: $e');
      rethrow;
    }
  }

  /// Gets nearby destinations based on location.
  Future<List<Destination>> getNearbyDestinations({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      // This is a simplified approach - in a real app, you'd use geospatial queries
      // Firestore supports geohash-based queries, but for simplicity, we'll
      // fetch all destinations and filter client-side

      final snapshot = await _firestore.collection(_collection).get();

      final destinations =
          snapshot.docs.map((doc) => Destination.fromJson(doc.data())).toList();

      // Filter destinations within the radius
      return destinations.where((destination) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          destination.latitude,
          destination.longitude,
        );

        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      debugPrint('Error getting nearby destinations: $e');
      return [];
    }
  }

  /// Searches for nearby destinations based on location, with optional query and category filters.
  Future<List<Destination>> searchNearbyDestinations({
    required double latitude,
    required double longitude,
    required double radius,
    String? query,
    String? category,
  }) async {
    try {
      // Get all destinations
      final destinations = await getNearbyDestinations(
          latitude: latitude, longitude: longitude, radiusKm: radius);

      // Apply additional filters
      return destinations.where((destination) {
        // Apply category filter if provided
        if (category != null && category.isNotEmpty) {
          if (destination.category != category) {
            return false;
          }
        }

        // Apply search query if provided
        if (query != null && query.isNotEmpty) {
          final searchLower = query.toLowerCase();
          return destination.name.toLowerCase().contains(searchLower) ||
              destination.description.toLowerCase().contains(searchLower) ||
              destination.tags
                  .any((tag) => tag.toLowerCase().contains(searchLower));
        }

        return true;
      }).toList();
    } catch (e) {
      debugPrint('Error searching nearby destinations: $e');
      return [];
    }
  }

  /// Gets weather data for a location.
  Future<Map<String, dynamic>> getWeatherData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // This would typically call a weather API
      // For this example, we'll just return mock data
      return {
        'temperature': 28,
        'condition': 'Sunny',
        'humidity': 65,
        'windSpeed': 12,
        'forecast': [
          {'day': 'Today', 'temperature': 28, 'condition': 'Sunny'},
          {'day': 'Tomorrow', 'temperature': 27, 'condition': 'Partly Cloudy'},
          {'day': 'Day after', 'temperature': 29, 'condition': 'Sunny'},
        ]
      };
    } catch (e) {
      debugPrint('Error getting weather data: $e');
      return {'error': 'Failed to fetch weather data'};
    }
  }

  /// Calculates distance between two points using Haversine formula.
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // in kilometers

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2));

    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  /// Converts degrees to radians.
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
