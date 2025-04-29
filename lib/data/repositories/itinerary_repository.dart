import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/data/models/itinerary.dart';
import 'package:taprobana_trails/data/models/itinerary_item.dart';
import 'package:uuid/uuid.dart';

/// Repository for itinerary-related operations.
class ItineraryRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'itineraries';
  final Uuid _uuid = const Uuid();
  
  /// Creates a new [ItineraryRepository] instance.
  ItineraryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Gets all itineraries for a user.
  Future<List<Itinerary>> getItineraries({required String userId}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Itinerary.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting itineraries: $e');
      return [];
    }
  }
  
  /// Gets an itinerary by ID.
  Future<Itinerary?> getItinerary({required String itineraryId}) async {
    try {
      final doc = await _firestore.collection(_collection).doc(itineraryId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return Itinerary.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error getting itinerary: $e');
      return null;
    }
  }
  
  /// Creates a new itinerary.
  Future<String> createItinerary({
    required String userId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required String destination,
  }) async {
    try {
      final itineraryId = _uuid.v4();
      final now = DateTime.now();
      
      final itinerary = Itinerary(
        id: itineraryId,
        title: title,
        userId: userId,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        items: [],
        isShared: false,
        createdAt: now,
        updatedAt: now,
      );
      
      await _firestore
          .collection(_collection)
          .doc(itineraryId)
          .set(itinerary.toJson());
      
      return itineraryId;
    } catch (e) {
      debugPrint('Error creating itinerary: $e');
      rethrow;
    }
  }
  
  /// Updates an existing itinerary.
  Future<void> updateItinerary({
    required String itineraryId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
  }) async {
    try {
      final data = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (title != null) data['title'] = title;
      if (startDate != null) data['startDate'] = startDate;
      if (endDate != null) data['endDate'] = endDate;
      if (destination != null) data['destination'] = destination;
      
      await _firestore.collection(_collection).doc(itineraryId).update(data);
    } catch (e) {
      debugPrint('Error updating itinerary: $e');
      rethrow;
    }
  }
  
  /// Deletes an itinerary.
  Future<void> deleteItinerary({required String itineraryId}) async {
    try {
      await _firestore.collection(_collection).doc(itineraryId).delete();
    } catch (e) {
      debugPrint('Error deleting itinerary: $e');
      rethrow;
    }
  }
  
  /// Adds an item to an itinerary.
  Future<void> addItineraryItem({
    required String itineraryId,
    required ItineraryItem item,
  }) async {
    try {
      await _firestore.collection(_collection).doc(itineraryId).update({
        'items': FieldValue.arrayUnion([item.toJson()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding itinerary item: $e');
      rethrow;
    }
  }
  
  /// Updates an item in an itinerary.
  Future<void> updateItineraryItem({
    required String itineraryId,
    required String itemId,
    required ItineraryItem item,
  }) async {
    try {
      // Get current itinerary
      final itinerary = await getItinerary(itineraryId: itineraryId);
      
      if (itinerary == null) {
        throw Exception('Itinerary not found');
      }
      
      // Find and update the item
      final updatedItems = itinerary.items.map((existingItem) {
        if (existingItem.id == itemId) {
          return item;
        }
        return existingItem;
      }).toList();
      
      // Update the itinerary with the new items list
      await _firestore.collection(_collection).doc(itineraryId).update({
        'items': updatedItems.map((i) => i.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating itinerary item: $e');
      rethrow;
    }
  }
  
  /// Deletes an item from an itinerary.
  Future<void> deleteItineraryItem({
    required String itineraryId,
    required String itemId,
  }) async {
    try {
      // Get current itinerary
      final itinerary = await getItinerary(itineraryId: itineraryId);
      
      if (itinerary == null) {
        throw Exception('Itinerary not found');
      }
      
      // Filter out the item to delete
      final updatedItems = itinerary.items
          .where((item) => item.id != itemId)
          .toList();
      
      // Update the itinerary with the new items list
      await _firestore.collection(_collection).doc(itineraryId).update({
        'items': updatedItems.map((i) => i.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error deleting itinerary item: $e');
      rethrow;
    }
  }
  
  /// Reorders items in an itinerary.
  Future<void> reorderItineraryItems({
    required String itineraryId,
    required List<String> itemIds,
  }) async {
    try {
      // Get current itinerary
      final itinerary = await getItinerary(itineraryId: itineraryId);
      
      if (itinerary == null) {
        throw Exception('Itinerary not found');
      }
      
      // Create a map of items by ID for quick access
      final itemsMap = {for (var item in itinerary.items) item.id: item};
      
      // Create a new ordered list based on the provided order
      final orderedItems = itemIds
          .map((id) => itemsMap[id])
          .whereType<ItineraryItem>()
          .toList();
      
      // Update the itinerary with the new items list
      await _firestore.collection(_collection).doc(itineraryId).update({
        'items': orderedItems.map((i) => i.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error reordering itinerary items: $e');
      rethrow;
    }
  }
  
  /// Generates a share link for an itinerary.
  Future<String> generateShareLink({required String itineraryId}) async {
    try {
      // In a real app, this would use Firebase Dynamic Links or similar service
      // For now, we'll create a simple URL
      final shareUrl = 'https://taprobanatrails.com/share/itinerary/$itineraryId';
      
      // Update the itinerary with sharing info
      await _firestore.collection(_collection).doc(itineraryId).update({
        'isShared': true,
        'shareUrl': shareUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return shareUrl;
    } catch (e) {
      debugPrint('Error generating share link: $e');
      rethrow;
    }
  }
  
  /// Generates a suggested itinerary based on user preferences.
  Future<Itinerary> generateSuggestedItinerary({
    required String userId,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final itineraryId = _uuid.v4();
      final now = DateTime.now();
      
      // This is a simplified implementation - in a real app, this would use
      // an algorithm to generate a suggested itinerary based on the user's
      // preferences, the destination, and the dates
      
      // For now, we'll create a basic suggested itinerary with some mock items
      final items = _generateMockItineraryItems(startDate, endDate, destination);
      
      final suggestedItinerary = Itinerary(
        id: itineraryId,
        title: 'Suggested: $destination Trip',
        userId: userId,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        items: items,
        isShared: false,
        createdAt: now,
        updatedAt: now,
      );
      
      // Note that we don't save this to Firestore yet, as it's just a suggestion
      // The user would need to explicitly save it
      
      return suggestedItinerary;
    } catch (e) {
      debugPrint('Error generating suggested itinerary: $e');
      rethrow;
    }
  }
  
  /// Generates mock itinerary items for demonstration purposes.
  List<ItineraryItem> _generateMockItineraryItems(
    DateTime startDate,
    DateTime endDate,
    String destination,
  ) {
    final items = <ItineraryItem>[];
    final days = endDate.difference(startDate).inDays + 1;
    
    // Define some sample attractions for destinations
    final Map<String, List<Map<String, dynamic>>> attractions = {
      'Colombo': [
        {'name': 'Gangaramaya Temple', 'type': ItineraryItemType.sight},
        {'name': 'National Museum', 'type': ItineraryItemType.sight},
        {'name': 'Galle Face Green', 'type': ItineraryItemType.sight},
        {'name': 'Ministry of Crab', 'type': ItineraryItemType.restaurant},
        {'name': 'Pettah Market', 'type': ItineraryItemType.activity},
      ],
      'Kandy': [
        {'name': 'Temple of the Tooth', 'type': ItineraryItemType.sight},
        {'name': 'Kandy Lake', 'type': ItineraryItemType.sight},
        {'name': 'Royal Botanical Gardens', 'type': ItineraryItemType.sight},
        {'name': 'Cultural Dance Show', 'type': ItineraryItemType.activity},
        {'name': 'Empire Cafe', 'type': ItineraryItemType.restaurant},
      ],
      'Galle': [
        {'name': 'Galle Fort', 'type': ItineraryItemType.sight},
        {'name': 'Maritime Museum', 'type': ItineraryItemType.sight},
        {'name': 'Unawatuna Beach', 'type': ItineraryItemType.activity},
        {'name': 'The Fort Printers', 'type': ItineraryItemType.restaurant},
        {'name': 'Lighthouse', 'type': ItineraryItemType.sight},
      ],
      // Default attractions if destination not found
      'default': [
        {'name': 'Local Museum', 'type': ItineraryItemType.sight},
        {'name': 'Main Square', 'type': ItineraryItemType.sight},
        {'name': 'Beach', 'type': ItineraryItemType.activity},
        {'name': 'Popular Restaurant', 'type': ItineraryItemType.restaurant},
        {'name': 'Market', 'type': ItineraryItemType.activity},
      ],
    };
    
    final destinationAttractions = attractions[destination] ?? attractions['default']!;
    
    // Add hotel for the entire stay
    items.add(
      ItineraryItem(
        id: _uuid.v4(),
        title: 'Hotel Stay: $destination Grand Hotel',
        description: 'Your accommodation for the duration of your trip',
        type: ItineraryItemType.accommodation,
        date: startDate,
        startTime: DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          14, // 2 PM check-in
          0,
        ),
        endTime: DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          12, // 12 PM check-out
          0,
        ),
        location: '$destination City Center',
        cost: 120.0 * days, // $120 per night
        isBooked: false,
      ),
    );
    
    // Add items for each day
    for (int i = 0; i < days; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final isFirstDay = i == 0;
      final isLastDay = i == days - 1;
      
      // Morning activity
      if (!isFirstDay || currentDate.hour < 10) {
        final morningAttraction = destinationAttractions[i % destinationAttractions.length];
        items.add(
          ItineraryItem(
            id: _uuid.v4(),
            title: morningAttraction['name'] as String,
            type: morningAttraction['type'] as ItineraryItemType,
            date: currentDate,
            startTime: DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day,
              9, // 9 AM
              0,
            ),
            endTime: DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day,
              11, // 11 AM
              30,
            ),
            location: destination,
            cost: 15.0, // $15 per person
            isBooked: false,
          ),
        );
      }
      
      // Lunch
      items.add(
        ItineraryItem(
          id: _uuid.v4(),
          title: 'Lunch at Local Restaurant',
          type: ItineraryItemType.restaurant,
          date: currentDate,
          startTime: DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            12, // 12 PM
            30,
          ),
          endTime: DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            14, // 2 PM
            0,
          ),
          location: '$destination City Center',
          cost: 25.0, // $25 per person
          isBooked: false,
        ),
      );
      
      // Afternoon activity
      if (!isLastDay || currentDate.hour < 16) {
        final afternoonAttraction = destinationAttractions[(i + 2) % destinationAttractions.length];
        items.add(
          ItineraryItem(
            id: _uuid.v4(),
            title: afternoonAttraction['name'] as String,
            type: afternoonAttraction['type'] as ItineraryItemType,
            date: currentDate,
            startTime: DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day,
              14, // 2 PM
              30,
            ),
            endTime: DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day,
              17, // 5 PM
              0,
            ),
            location: destination,
            cost: 20.0, // $20 per person
            isBooked: false,
          ),
        );
      }
      
      // Dinner
      items.add(
        ItineraryItem(
          id: _uuid.v4(),
          title: 'Dinner at ${destinationAttractions[3]['name']}',
          type: ItineraryItemType.restaurant,
          date: currentDate,
          startTime: DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            19, // 7 PM
            0,
          ),
          endTime: DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            21, // 9 PM
            0,
          ),
          location: destination,
          cost: 35.0, // $35 per person
          isBooked: false,
        ),
      );
      
      // Add transportation between days if multi-destination trip
      if (i < days - 1 && days > 3) {
        final shouldAddTransport = i == days ~/ 2 - 1; // Add transport in the middle of the trip
        
        if (shouldAddTransport) {
          items.add(
            ItineraryItem(
              id: _uuid.v4(),
              title: 'Transport to Next Destination',
              type: ItineraryItemType.transport,
              date: currentDate.add(const Duration(days: 1)),
              startTime: DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day + 1,
                9, // 9 AM
                0,
              ),
              endTime: DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day + 1,
                11, // 11 AM
                0,
              ),
              location: 'From $destination to Next Destination',
              cost: 50.0, // $50 per person
              isBooked: false,
            ),
          );
        }
      }
    }
    
    // Sort items by date and time
    items.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      
      final aStartTime = a.startTime ?? DateTime(a.date.year, a.date.month, a.date.day);
      final bStartTime = b.startTime ?? DateTime(b.date.year, b.date.month, b.date.day);
      return aStartTime.compareTo(bStartTime);
    });
    
    return items;
  }
}