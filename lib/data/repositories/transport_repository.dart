import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/data/models/transport.dart';
import 'package:taprobana_trails/data/models/transport_schedule.dart';
import 'package:uuid/uuid.dart';

/// Repository for transport-related operations.
class TransportRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();
  final String _schedulesCollection = 'transport_schedules';
  final String _rentalsCollection = 'transport_rentals';
  final String _bookingsCollection = 'transport_bookings';
  
  /// Creates a new [TransportRepository] instance.
  TransportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Gets public transport options.
  Future<List<Map<String, dynamic>>> getPublicTransportOptions({
    required String from,
    required String to,
    DateTime? date,
  }) async {
    try {
      final options = <Map<String, dynamic>>[];
      final currentDate = date ?? DateTime.now();
      
      // Get bus schedules
      final busSchedule = await getTransportSchedule(
        transportType: 'bus',
        route: '$from-$to',
        date: currentDate,
      );
      
      if (busSchedule != null) {
        options.add({
          'type': 'bus',
          'origin': busSchedule.origin,
          'destination': busSchedule.destination,
          'date': busSchedule.date,
          'options': busSchedule.entries,
          'cheapest': busSchedule.cheapestEntry,
          'fastest': busSchedule.fastestEntry,
        });
      }
      
      // Get train schedules
      final trainSchedule = await getTransportSchedule(
        transportType: 'train',
        route: '$from-$to',
        date: currentDate,
      );
      
      if (trainSchedule != null) {
        options.add({
          'type': 'train',
          'origin': trainSchedule.origin,
          'destination': trainSchedule.destination,
          'date': trainSchedule.date,
          'options': trainSchedule.entries,
          'cheapest': trainSchedule.cheapestEntry,
          'fastest': trainSchedule.fastestEntry,
        });
      }
      
      // Get ferry schedules if appropriate
      if (_isCoastalLocation(from) || _isCoastalLocation(to)) {
        final ferrySchedule = await getTransportSchedule(
          transportType: 'ferry',
          route: '$from-$to',
          date: currentDate,
        );
        
        if (ferrySchedule != null) {
          options.add({
            'type': 'ferry',
            'origin': ferrySchedule.origin,
            'destination': ferrySchedule.destination,
            'date': ferrySchedule.date,
            'options': ferrySchedule.entries,
            'cheapest': ferrySchedule.cheapestEntry,
            'fastest': ferrySchedule.fastestEntry,
          });
        }
      }
      
      // Get flight schedules for longer distances
      if (_isLongDistance(from, to)) {
        final flightSchedule = await getTransportSchedule(
          transportType: 'flight',
          route: '$from-$to',
          date: currentDate,
        );
        
        if (flightSchedule != null) {
          options.add({
            'type': 'flight',
            'origin': flightSchedule.origin,
            'destination': flightSchedule.destination,
            'date': flightSchedule.date,
            'options': flightSchedule.entries,
            'cheapest': flightSchedule.cheapestEntry,
            'fastest': flightSchedule.fastestEntry,
          });
        }
      }
      
      return options;
    } catch (e) {
      debugPrint('Error getting public transport options: $e');
      return [];
    }
  }
  
  /// Gets transport schedule by type, route, and date.
  Future<TransportSchedule?> getTransportSchedule({
    required String transportType,
    required String route,
    required DateTime date,
  }) async {
    try {
      // Format date to YYYY-MM-DD for querying
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Query Firestore
      final snapshot = await _firestore
          .collection(_schedulesCollection)
          .where('type', isEqualTo: transportType)
          .where('route', isEqualTo: route)
          .where('dateString', isEqualTo: dateString)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        // If real data doesn't exist, generate mock schedule for demo
        return _generateMockSchedule(transportType, route, date);
      }
      
      final data = snapshot.docs.first.data();
      return TransportSchedule.fromJson(data);
    } catch (e) {
      debugPrint('Error getting transport schedule: $e');
      // Return mock data for demonstration
      return _generateMockSchedule(transportType, route, date);
    }
  }
  
  /// Gets available vehicle rentals.
  Future<List<Map<String, dynamic>>> getRentals({
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    String? vehicleType,
  }) async {
    try {
      var query = _firestore
          .collection(_rentalsCollection)
          .where('location', isEqualTo: location)
          .where('isAvailable', isEqualTo: true);
      
      if (vehicleType != null) {
        query = query.where('vehicleType', isEqualTo: vehicleType);
      }
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        // Return mock data for demonstration
        return _generateMockRentals(location, vehicleType);
      }
      
      final rentals = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'vehicleType': data['vehicleType'] ?? 'Unknown',
          'make': data['make'] ?? 'Unknown',
          'model': data['model'] ?? 'Unknown',
          'year': data['year'] ?? 2022,
          'pricePerDay': data['pricePerDay'] ?? 0.0,
          'location': data['location'] ?? 'Unknown',
          'imageUrl': data['imageUrl'] ?? '',
          'features': data['features'] ?? <String>[],
          'rating': data['rating'] ?? 4.0,
          'reviewCount': data['reviewCount'] ?? 0,
        };
      }).toList();
      
      return rentals;
    } catch (e) {
      debugPrint('Error getting rentals: $e');
      // Return mock data for demonstration
      return _generateMockRentals(location, vehicleType);
    }
  }
  
  /// Books a rental vehicle.
  Future<String> bookRental({
    required String rentalId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final bookingId = _uuid.v4();
      
      await _firestore.collection(_bookingsCollection).doc(bookingId).set({
        'id': bookingId,
        'rentalId': rentalId,
        'userId': userId,
        'startDate': startDate,
        'endDate': endDate,
        'status': 'confirmed',
        'totalCost': 0, // This would be calculated in a real app
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return bookingId;
    } catch (e) {
      debugPrint('Error booking rental: $e');
      rethrow;
    }
  }
  
  /// Checks if a location is coastal.
  bool _isCoastalLocation(String location) {
    // Simple check for coastal cities in Sri Lanka
    const coastalLocations = [
      'colombo', 'galle', 'matara', 'bentota', 'negombo', 'trincomalee',
      'batticaloa', 'arugam bay', 'jaffna', 'mannar', 'kalpitiya', 'tangalle'
    ];
    
    return coastalLocations.contains(location.toLowerCase());
  }
  
  /// Checks if distance between locations is long enough for flights.
  bool _isLongDistance(String from, String to) {
    // Define location pairs that are considered long distance
    const longDistancePairs = [
      ['colombo', 'jaffna'],
      ['colombo', 'batticaloa'],
      ['colombo', 'trincomalee'],
      ['kandy', 'jaffna'],
      ['galle', 'jaffna'],
    ];
    
    // Normalize inputs
    final normalizedFrom = from.toLowerCase();
    final normalizedTo = to.toLowerCase();
    
    // Check if this pair is in our long distance list (in either direction)
    return longDistancePairs.any((pair) =>
        (pair[0] == normalizedFrom && pair[1] == normalizedTo) ||
        (pair[0] == normalizedTo && pair[1] == normalizedFrom));
  }
  
  /// Generates mock transport schedule for demonstration.
  TransportSchedule _generateMockSchedule(
    String transportTypeStr,
    String route,
    DateTime date,
  ) {
    // Parse route into origin and destination
    final routeParts = route.split('-');
    if (routeParts.length != 2) {
      throw Exception('Invalid route format: $route');
    }
    
    final origin = routeParts[0];
    final destination = routeParts[1];
    
    // Determine transport type
    final transportType = _parseTransportType(transportTypeStr);
    
    // Create schedule entries based on transport type
    final entries = <ScheduleEntry>[];
    
    switch (transportType) {
      case TransportType.bus:
        // Buses typically run frequently throughout the day
        for (int hour = 6; hour <= 20; hour += 2) {
          entries.add(_createMockScheduleEntry(
            transportType,
            date,
            hour,
            hour + 3, // 3 hour trip
            origin,
            destination,
            15.0, // LKR 15
          ));
        }
        break;
      
      case TransportType.train:
        // Trains might have fewer departures
        for (int hour = 7; hour <= 19; hour += 4) {
          entries.add(_createMockScheduleEntry(
            transportType,
            date,
            hour,
            hour + 2, // 2 hour trip
            origin,
            destination,
            25.0, // LKR 25
          ));
        }
        break;
      
      case TransportType.ferry:
        // Ferries might have even fewer departures
        for (int hour = 8; hour <= 16; hour += 4) {
          entries.add(_createMockScheduleEntry(
            transportType,
            date,
            hour,
            hour + 1, // 1 hour trip
            origin,
            destination,
            30.0, // LKR 30
          ));
        }
        break;
      
      case TransportType.flight:
        // Flights might have only a few departures
        entries.add(_createMockScheduleEntry(
          transportType,
          date,
          8,
          9, // 1 hour flight
          origin,
          destination,
          150.0, // LKR 150
        ));
        
        entries.add(_createMockScheduleEntry(
          transportType,
          date,
          14,
          15, // 1 hour flight
          origin,
          destination,
          180.0, // LKR 180
        ));
        
        entries.add(_createMockScheduleEntry(
          transportType,
          date,
          19,
          20, // 1 hour flight
          origin,
          destination,
          120.0, // LKR 120
        ));
        break;
    }
    
    return TransportSchedule(
      id: _uuid.v4(),
      type: transportType,
      origin: origin,
      destination: destination,
      date: DateTime(date.year, date.month, date.day),
      entries: entries,
    );
  }
  
  /// Creates a mock schedule entry.
  ScheduleEntry _createMockScheduleEntry(
    TransportType transportType,
    DateTime date,
    int departureHour,
    int arrivalHour,
    String origin,
    String destination,
    double fare,
  ) {
    final departureTime = DateTime(
      date.year,
      date.month,
      date.day,
      departureHour,
      0,
    );
    
    final arrivalTime = DateTime(
      date.year,
      date.month,
      date.day,
      arrivalHour,
      0,
    );
    
    String carrier;
    String routeNumber;
    List<String> stops;
    
    switch (transportType) {
      case TransportType.bus:
        carrier = 'Sri Lanka Transport Board';
        routeNumber = 'Route ${100 + departureHour}';
        stops = ['$origin Central', 'Midway Town', '$destination Central'];
        break;
      
      case TransportType.train:
        carrier = 'Sri Lanka Railways';
        routeNumber = 'Express ${1000 + departureHour}';
        stops = ['$origin Station', 'Junction Point', '$destination Station'];
        break;
      
      case TransportType.ferry:
        carrier = 'Sri Lanka Ferry Service';
        routeNumber = 'Ferry $departureHour';
        stops = ['$origin Port', '$destination Port'];
        break;
      
      case TransportType.flight:
        carrier = 'SriLankan Airlines';
        routeNumber = 'UL${100 + departureHour}';
        stops = ['$origin Airport', '$destination Airport'];
        break;
    }
    
    return ScheduleEntry(
      id: _uuid.v4(),
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      carrier: carrier,
      routeNumber: routeNumber,
      fare: fare,
      stops: stops,
      availableSeats: 20 + (departureHour % 10),
      additionalInfo: {
        'platform': transportType == TransportType.train ? 'Platform ${1 + (departureHour % 3)}' : null,
        'gate': transportType == TransportType.flight ? 'Gate ${(departureHour % 10) + 1}' : null,
        'amenities': _generateAmenities(transportType),
      },
    );
  }
  
  /// Generates mock rentals for demonstration.
  List<Map<String, dynamic>> _generateMockRentals(String location, String? vehicleType) {
    final rentals = <Map<String, dynamic>>[];
    
    // If vehicleType is specified, only generate that type
    final vehicleTypes = vehicleType != null
        ? [vehicleType]
        : ['car', 'motorbike', 'scooter', 'bicycle'];
    
    for (final type in vehicleTypes) {
      switch (type) {
        case 'car':
          rentals.addAll([
            {
              'id': _uuid.v4(),
              'vehicleType': 'car',
              'make': 'Toyota',
              'model': 'Corolla',
              'year': 2022,
              'pricePerDay': 50.0,
              'location': location,
              'imageUrl': 'assets/images/car_corolla.png',
              'features': ['Air Conditioning', 'Automatic', '5 Seats'],
              'rating': 4.7,
              'reviewCount': 42,
            },
            {
              'id': _uuid.v4(),
              'vehicleType': 'car',
              'make': 'Honda',
              'model': 'Civic',
              'year': 2021,
              'pricePerDay': 45.0,
              'location': location,
              'imageUrl': 'assets/images/car_civic.png',
              'features': ['Air Conditioning', 'Manual', '5 Seats'],
              'rating': 4.5,
              'reviewCount': 38,
            },
          ]);
          break;
        
        case 'motorbike':
          rentals.addAll([
            {
              'id': _uuid.v4(),
              'vehicleType': 'motorbike',
              'make': 'Honda',
              'model': 'CBR',
              'year': 2023,
              'pricePerDay': 35.0,
              'location': location,
              'imageUrl': 'assets/images/motorbike_cbr.png',
              'features': ['300cc', 'Sports', 'Helmet Included'],
              'rating': 4.8,
              'reviewCount': 25,
            },
            {
              'id': _uuid.v4(),
              'vehicleType': 'motorbike',
              'make': 'Yamaha',
              'model': 'FZ',
              'year': 2022,
              'pricePerDay': 30.0,
              'location': location,
              'imageUrl': 'assets/images/motorbike_fz.png',
              'features': ['150cc', 'Street', 'Helmet Included'],
              'rating': 4.6,
              'reviewCount': 32,
            },
          ]);
          break;
        
        case 'scooter':
          rentals.addAll([
            {
              'id': _uuid.v4(),
              'vehicleType': 'scooter',
              'make': 'Honda',
              'model': 'Dio',
              'year': 2023,
              'pricePerDay': 20.0,
              'location': location,
              'imageUrl': 'assets/images/scooter_dio.png',
              'features': ['110cc', 'Automatic', 'Helmet Included'],
              'rating': 4.5,
              'reviewCount': 48,
            },
            {
              'id': _uuid.v4(),
              'vehicleType': 'scooter',
              'make': 'TVS',
              'model': 'Ntorq',
              'year': 2022,
              'pricePerDay': 18.0,
              'location': location,
              'imageUrl': 'assets/images/scooter_ntorq.png',
              'features': ['125cc', 'Automatic', 'Helmet Included'],
              'rating': 4.4,
              'reviewCount': 36,
            },
          ]);
          break;
        
        case 'bicycle':
          rentals.addAll([
            {
              'id': _uuid.v4(),
              'vehicleType': 'bicycle',
              'make': 'Giant',
              'model': 'City Cruiser',
              'year': 2023,
              'pricePerDay': 10.0,
              'location': location,
              'imageUrl': 'assets/images/bicycle_city.png',
              'features': ['7 Speed', 'Basket', 'Lock Included'],
              'rating': 4.6,
              'reviewCount': 52,
            },
            {
              'id': _uuid.v4(),
              'vehicleType': 'bicycle',
              'make': 'Trek',
              'model': 'Mountain Bike',
              'year': 2022,
              'pricePerDay': 15.0,
              'location': location,
              'imageUrl': 'assets/images/bicycle_mountain.png',
              'features': ['21 Speed', 'Off-road tires', 'Helmet Included'],
              'rating': 4.7,
              'reviewCount': 44,
            },
          ]);
          break;
      }
    }
    
    return rentals;
  }
  
  /// Generates amenities based on transport type.
  List<String> _generateAmenities(TransportType type) {
    switch (type) {
      case TransportType.bus:
        return ['Air Conditioning', 'WiFi', 'USB Charging'];
      case TransportType.train:
        return ['Air Conditioning', 'Restaurant Car', 'Power Outlets'];
      case TransportType.ferry:
        return ['Seating Area', 'Refreshments', 'Viewing Deck'];
      case TransportType.flight:
        return ['In-flight Meal', 'Entertainment System', 'Baggage Allowance'];
    }
  }
  
  /// Parses a string to TransportType enum.
  TransportType _parseTransportType(String type) {
    switch (type.toLowerCase()) {
      case 'bus':
        return TransportType.bus;
      case 'train':
        return TransportType.train;
      case 'ferry':
        return TransportType.ferry;
      case 'flight':
        return TransportType.flight;
      default:
        throw ArgumentError('Invalid transport type: $type');
    }
  }
}