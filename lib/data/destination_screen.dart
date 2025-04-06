import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taprobana_trails/data/models/accommodation.dart';
import 'package:taprobana_trails/data/models/destination.dart';
import 'package:taprobana_trails/data/models/restaurant.dart';
import 'package:taprobana_trails/data/models/transportation.dart';
import 'package:taprobana_trails/data/services/firebase_service.dart';

class BookingRepository {
  final FirebaseService _firebaseService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BookingRepository({required FirebaseService firebaseService})
      : _firebaseService = firebaseService,
        _firestore = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _bookingsCollection =>
      _firestore.collection('bookings');

  CollectionReference get _userBookingsCollection =>
      _firestore.collection('users').doc(currentUserId).collection('bookings');

  CollectionReference get _accommodationsCollection =>
      _firestore.collection('accommodations');

  CollectionReference get _restaurantsCollection =>
      _firestore.collection('restaurants');

  CollectionReference get _transportationCollection =>
      _firestore.collection('transportation');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Book accommodation
  Future<String> bookAccommodation({
    required String accommodationId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guests,
    required String roomType,
    required double totalPrice,
    String? specialRequests,
  }) async {
    try {
      // Check if user is authenticated
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check accommodation availability
      final isAvailable = await checkAccommodationAvailability(
        accommodationId: accommodationId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        roomType: roomType,
      );

      if (!isAvailable) {
        throw Exception('Accommodation is not available for the selected dates');
      }

      // Create booking document
      final bookingData = {
        'userId': currentUserId,
        'accommodationId': accommodationId,
        'type': 'accommodation',
        'status': 'confirmed',
        'bookingDate': DateTime.now().millisecondsSinceEpoch,
        'checkInDate': checkInDate.millisecondsSinceEpoch,
        'checkOutDate': checkOutDate.millisecondsSinceEpoch,
        'guests': guests,
        'roomType': roomType,
        'totalPrice': totalPrice,
        'specialRequests': specialRequests,
        'isCancelled': false,
        'paymentStatus': 'pending', // or 'paid' if payment is handled
      };

      // Save to main bookings collection
      final bookingRef = await _bookingsCollection.add(bookingData);

      // Save to user's bookings collection
      await _userBookingsCollection.doc(bookingRef.id).set(bookingData);

      // Update accommodation availability (if needed)
      // This would depend on your database structure for managing availability

      return bookingRef.id;
    } catch (e) {
      throw Exception('Failed to book accommodation: $e');
    }
  }

  // Book restaurant reservation
  Future<String> bookRestaurant({
    required String restaurantId,
    required DateTime reservationDate,
    required String reservationTime,
    required int guests,
    String? specialRequests,
  }) async {
    try {
      // Check if user is authenticated
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check restaurant availability
      final isAvailable = await checkRestaurantAvailability(
        restaurantId: restaurantId,
        reservationDate: reservationDate,
        reservationTime: reservationTime,
        guests: guests,
      );

      if (!isAvailable) {
        throw Exception('Restaurant is not available for the selected time');
      }

      // Create booking document
      final bookingData = {
        'userId': currentUserId,
        'restaurantId': restaurantId,
        'type': 'restaurant',
        'status': 'confirmed',
        'bookingDate': DateTime.now().millisecondsSinceEpoch,
        'reservationDate': reservationDate.millisecondsSinceEpoch,
        'reservationTime': reservationTime,
        'guests': guests,
        'specialRequests': specialRequests,
        'isCancelled': false,
      };

      // Save to main bookings collection
      final bookingRef = await _bookingsCollection.add(bookingData);

      // Save to user's bookings collection
      await _userBookingsCollection.doc(bookingRef.id).set(bookingData);

      return bookingRef.id;
    } catch (e) {
      throw Exception('Failed to book restaurant: $e');
    }
  }

  // Book transportation
  Future<String> bookTransportation({
    required String transportationId,
    required DateTime departureDate,
    required String departureTime,
    required String departureLocation,
    required String arrivalLocation,
    required int passengers,
    required double totalPrice,
    String? specialRequests,
  }) async {
    try {
      // Check if user is authenticated
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check transportation availability
      final isAvailable = await checkTransportationAvailability(
        transportationId: transportationId,
        departureDate: departureDate,
        departureTime: departureTime,
        passengers: passengers,
      );

      if (!isAvailable) {
        throw Exception('Transportation is not available for the selected time');
      }

      // Create booking document
      final bookingData = {
        'userId': currentUserId,
        'transportationId': transportationId,
        'type': 'transportation',
        'status': 'confirmed',
        'bookingDate': DateTime.now().millisecondsSinceEpoch,
        'departureDate': departureDate.millisecondsSinceEpoch,
        'departureTime': departureTime,
        'departureLocation': departureLocation,
        'arrivalLocation': arrivalLocation,
        'passengers': passengers,
        'totalPrice': totalPrice,
        'specialRequests': specialRequests,
        'isCancelled': false,
        'paymentStatus': 'pending', // or 'paid' if payment is handled
      };

      // Save to main bookings collection
      final bookingRef = await _bookingsCollection.add(bookingData);

      // Save to user's bookings collection
      await _userBookingsCollection.doc(bookingRef.id).set(bookingData);

      return bookingRef.id;
    } catch (e) {
      throw Exception('Failed to book transportation: $e');
    }
  }

  // Check accommodation availability
  Future<bool> checkAccommodationAvailability({
    required String accommodationId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required String roomType,
  }) async {
    try {
      // In a real implementation, you would check against your availability database
      // This is a simplified approach

      // Get existing bookings for this accommodation
      final bookings = await _bookingsCollection
          .where('accommodationId', isEqualTo: accommodationId)
          .where('isCancelled', isEqualTo: false)
          .where('roomType', isEqualTo: roomType)
          .get();

      // Check if any booking overlaps with the requested dates
      for (final doc in bookings.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final existingCheckIn = DateTime.fromMillisecondsSinceEpoch(data['checkInDate'] as int);
        final existingCheckOut = DateTime.fromMillisecondsSinceEpoch(data['checkOutDate'] as int);

        // Check for overlap
        if (!(checkOutDate.isBefore(existingCheckIn) || checkInDate.isAfter(existingCheckOut))) {
          return false; // There is an overlap
        }
      }

      return true; // No overlaps found, accommodation is available
    } catch (e) {
      throw Exception('Failed to check accommodation availability: $e');
    }
  }

  // Check restaurant availability
  Future<bool> checkRestaurantAvailability({
    required String restaurantId,
    required DateTime reservationDate,
    required String reservationTime,
    required int guests,
  }) async {
    try {
      // In a real implementation, you would check against your availability database
      // This is a simplified approach

      // Get restaurant details to check capacity
      final restaurantDoc = await _restaurantsCollection.doc(restaurantId).get();
      if (!restaurantDoc.exists) {
        throw Exception('Restaurant not found');
      }

      final restaurantData = restaurantDoc.data() as Map<String, dynamic>;
      final capacity = restaurantData['capacity'] as int? ?? 50; // Default capacity

      // Get existing bookings for this time slot
      final bookings = await _bookingsCollection
          .where('restaurantId', isEqualTo: restaurantId)
          .where('isCancelled', isEqualTo: false)
          .where('reservationDate', isEqualTo: reservationDate.millisecondsSinceEpoch)
          .where('reservationTime', isEqualTo: reservationTime)
          .get();

      // Calculate total guests already booked
      int bookedGuests = 0;
      for (final doc in bookings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        bookedGuests += (data['guests'] as int? ?? 0);
      }

      // Check if there's enough capacity
      return (bookedGuests + guests) <= capacity;
    } catch (e) {
      throw Exception('Failed to check restaurant availability: $e');
    }
  }

  // Check transportation availability
  Future<bool> checkTransportationAvailability({
    required String transportationId,
    required DateTime departureDate,
    required String departureTime,
    required int passengers,
  }) async {
    try {
      // In a real implementation, you would check against your availability database
      // This is a simplified approach

      // Get transportation details to check capacity
      final transportationDoc = await _transportationCollection.doc(transportationId).get();
      if (!transportationDoc.exists) {
        throw Exception('Transportation not found');
      }

      final transportationData = transportationDoc.data() as Map<String, dynamic>;
      final capacity = transportationData['passengerCapacity'] as int? ?? 4; // Default capacity

      // Get existing bookings for this time slot
      final bookings = await _bookingsCollection
          .where('transportationId', isEqualTo: transportationId)
          .where('isCancelled', isEqualTo: false)
          .where('departureDate', isEqualTo: departureDate.millisecondsSinceEpoch)
          .where('departureTime', isEqualTo: departureTime)
          .get();

      // Calculate total passengers already booked
      int bookedPassengers = 0;
      for (final doc in bookings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        bookedPassengers += (data['passengers'] as int? ?? 0);
      }

      // Check if there's enough capacity
      return (bookedPassengers + passengers) <= capacity;
    } catch (e) {
      throw Exception('Failed to check transportation availability: $e');
    }
  }

  // Get all user bookings
  Future<List<Map<String, dynamic>>> getUserBookings() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _userBookingsCollection
          .orderBy('bookingDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  // Get upcoming bookings
  Future<List<Map<String, dynamic>>> getUpcomingBookings() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      // Get accommodation bookings
      final accommodationSnapshot = await _userBookingsCollection
          .where('type', isEqualTo: 'accommodation')
          .where('checkInDate', isGreaterThanOrEqualTo: now)
          .where('isCancelled', isEqualTo: false)
          .orderBy('checkInDate')
          .get();

      // Get restaurant bookings
      final restaurantSnapshot = await _userBookingsCollection
          .where('type', isEqualTo: 'restaurant')
          .where('reservationDate', isGreaterThanOrEqualTo: now)
          .where('isCancelled', isEqualTo: false)
          .orderBy('reservationDate')
          .get();

      // Get transportation bookings
      final transportationSnapshot = await _userBookingsCollection
          .where('type', isEqualTo: 'transportation')
          .where('departureDate', isGreaterThanOrEqualTo: now)
          .where('isCancelled', isEqualTo: false)
          .orderBy('departureDate')
          .get();

      // Combine all bookings
      final allBookings = [
        ...accommodationSnapshot.docs,
        ...restaurantSnapshot.docs,
        ...transportationSnapshot.docs,
      ];

      // Sort by date
      allBookings.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;

        final dateA = _getBookingDate(dataA);
        final dateB = _getBookingDate(dataB);

        return dateA.compareTo(dateB);
      });

      return allBookings.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming bookings: $e');
    }
  }

  // Helper method to get the relevant date from a booking
  int _getBookingDate(Map<String, dynamic> booking) {
    switch (booking['type']) {
      case 'accommodation':
        return booking['checkInDate'] as int;
      case 'restaurant':
        return booking['reservationDate'] as int;
      case 'transportation':
        return booking['departureDate'] as int;
      default:
        return booking['bookingDate'] as int;
    }
  }

  // Get booking details
  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _userBookingsCollection.doc(bookingId).get();
      if (!doc.exists) {
        throw Exception('Booking not found');
      }

      final data = doc.data() as Map<String, dynamic>;

      // Get related entity details
      Map<String, dynamic> entityDetails = {};

      switch (data['type']) {
        case 'accommodation':
          final accommodationDoc = await _accommodationsCollection.doc(data['accommodationId']).get();
          if (accommodationDoc.exists) {
            entityDetails = accommodationDoc.data() as Map<String, dynamic>;
          }
          break;
        case 'restaurant':
          final restaurantDoc = await _restaurantsCollection.doc(data['restaurantId']).get();
          if (restaurantDoc.exists) {
            entityDetails = restaurantDoc.data() as Map<String, dynamic>;
          }
          break;
        case 'transportation':
          final transportationDoc = await _transportationCollection.doc(data['transportationId']).get();
          if (transportationDoc.exists) {
            entityDetails = transportationDoc.data() as Map<String, dynamic>;
          }
          break;
      }

      return {
        'id': bookingId,
        ...data,
        'entityDetails': entityDetails,
      };
    } catch (e) {
      throw Exception('Failed to get booking details: $e');
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Update booking status in user's collection
      await _userBookingsCollection.doc(bookingId).update({
        'isCancelled': true,
        'status': 'cancelled',
        'cancelledAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Update in main bookings collection
      await _bookingsCollection.doc(bookingId).update({
        'isCancelled': true,
        'status': 'cancelled',
        'cancelledAt': DateTime.now().millisecondsSinceEpoch,
      });

      // You could also handle refunds, notifications, etc. here
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Get booking history
  Future<List<Map<String, dynamic>>> getBookingHistory() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      // Get past accommodation bookings
      final accommodationSnapshot = await _userBookingsCollection
          .where('type', isEqualTo: 'accommodation')
          .where('checkOutDate', isLessThan: now)
          .orderBy('checkOutDate', descending: true)
          .get();

      // Get past restaurant bookings
      final restaurantSnapshot = await _userBookingsCollection
          .where('type', isEqualTo: 'restaurant')
          .where('reservationDate', isLessThan: now)
          .orderBy('reservationDate', descending: true)
          .get();

      // Get past transportation bookings
      final transportationSnapshot = await _userBookingsCollection
          .where('type', isEqualTo: 'transportation')
          .where('departureDate', isLessThan: now)
          .orderBy('departureDate', descending: true)
          .get();

      // Combine all bookings
      final allBookings = [
        ...accommodationSnapshot.docs,
        ...restaurantSnapshot.docs,
        ...transportationSnapshot.docs,
      ];

      // Sort by date (descending)
      allBookings.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;

        final dateA = _getBookingEndDate(dataA);
        final dateB = _getBookingEndDate(dataB);

        return dateB.compareTo(dateA); // Descending order
      });

      return allBookings.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get booking history: $e');
    }
  }

  // Helper method to get the relevant end date from a booking
  int _getBookingEndDate(Map<String, dynamic> booking) {
    switch (booking['type']) {
      case 'accommodation':
        return booking['checkOutDate'] as int;
      case 'restaurant':
        return booking['reservationDate'] as int;
      case 'transportation':
        return booking['departureDate'] as int;
      default:
        return booking['bookingDate'] as int;
    }
  }

  // Create itinerary
  Future<String> createItinerary({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, dynamic>> itineraryItems,
    String? notes,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final itineraryData = {
        'userId': currentUserId,
        'name': name,
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'items': itineraryItems,
        'notes': notes,
      };

      // Save to user's itineraries collection
      final docRef = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('itineraries')
          .add(itineraryData);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create itinerary: $e');
    }
  }

  // Get user's itineraries
  Future<List<Map<String, dynamic>>> getUserItineraries() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('itineraries')
          .orderBy('startDate', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user itineraries: $e');
    }
  }
}