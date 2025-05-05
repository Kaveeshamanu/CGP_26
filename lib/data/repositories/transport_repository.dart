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
        final upcomingDepartures = busSchedule.getUpcomingDepartures(limit: 5);

        if (upcomingDepartures.isNotEmpty) {
          options.add({
            'type': 'bus',
            'origin': busSchedule.origin,
            'destination': busSchedule.destination,
            'date': currentDate,
            'options': upcomingDepartures,
            'operator': busSchedule.operator,
            'estimatedDuration': busSchedule.getEstimatedTravelTimeMinutes(),
            'route': busSchedule.route,
          });
        }
      }

      // Get train schedules
      final trainSchedule = await getTransportSchedule(
        transportType: 'train',
        route: '$from-$to',
        date: currentDate,
      );

      if (trainSchedule != null) {
        final upcomingDepartures =
            trainSchedule.getUpcomingDepartures(limit: 5);

        if (upcomingDepartures.isNotEmpty) {
          options.add({
            'type': 'train',
            'origin': trainSchedule.origin,
            'destination': trainSchedule.destination,
            'date': currentDate,
            'options': upcomingDepartures,
            'operator': trainSchedule.operator,
            'estimatedDuration': trainSchedule.getEstimatedTravelTimeMinutes(),
            'route': trainSchedule.route,
          });
        }
      }

      // Get ferry schedules if appropriate
      if (_isCoastalLocation(from) || _isCoastalLocation(to)) {
        final ferrySchedule = await getTransportSchedule(
          transportType: 'ferry',
          route: '$from-$to',
          date: currentDate,
        );

        if (ferrySchedule != null) {
          final upcomingDepartures =
              ferrySchedule.getUpcomingDepartures(limit: 5);

          if (upcomingDepartures.isNotEmpty) {
            options.add({
              'type': 'ferry',
              'origin': ferrySchedule.origin,
              'destination': ferrySchedule.destination,
              'date': currentDate,
              'options': upcomingDepartures,
              'operator': ferrySchedule.operator,
              'estimatedDuration':
                  ferrySchedule.getEstimatedTravelTimeMinutes(),
              'route': ferrySchedule.route,
            });
          }
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
          final upcomingDepartures =
              flightSchedule.getUpcomingDepartures(limit: 5);

          if (upcomingDepartures.isNotEmpty) {
            options.add({
              'type': 'flight',
              'origin': flightSchedule.origin,
              'destination': flightSchedule.destination,
              'date': currentDate,
              'options': upcomingDepartures,
              'operator': flightSchedule.operator,
              'estimatedDuration':
                  flightSchedule.getEstimatedTravelTimeMinutes(),
              'route': flightSchedule.route,
            });
          }
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
      // Query by route (origin-destination) and transport type
      final snapshot = await _firestore
          .collection(_schedulesCollection)
          .where('transportType', isEqualTo: transportType.toUpperCase())
          .where('route', isEqualTo: route)
          .where('isActive', isEqualTo: true)
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
          'features': List<String>.from(data['features'] ?? []),
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
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
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
      'colombo',
      'galle',
      'matara',
      'bentota',
      'negombo',
      'trincomalee',
      'batticaloa',
      'arugam bay',
      'jaffna',
      'mannar',
      'kalpitiya',
      'tangalle'
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

    // Create schedule days and times based on transport type
    final scheduleDays = <ScheduleDay>[];

    // Add schedules for each day of the week (1-7)
    for (int weekday = 1; weekday <= 7; weekday++) {
      final times = <ScheduleTime>[];

      // Generate different schedule patterns based on transport type
      switch (transportType) {
        case TransportType.bus:
          // Buses run more frequently
          for (int hour = 6; hour <= 20; hour += 2) {
            times.add(ScheduleTime(
              departureTime: '${hour.toString().padLeft(2, '0')}:00',
              arrivalTime:
                  '${(hour + 3).toString().padLeft(2, '0')}:00', // 3-hour trip
              platformInfo: 'Platform ${1 + (hour % 3)}',
              isExpress: hour % 4 == 0, // Some are express
              availableSeats: {'economy': 25, 'business': 5},
              intermediateStops: ['Midway Town', 'Junction Point'],
            ));
          }
          break;

        case TransportType.train:
          // Trains run less frequently
          for (int hour = 7; hour <= 19; hour += 4) {
            times.add(ScheduleTime(
              departureTime: '${hour.toString().padLeft(2, '0')}:30',
              arrivalTime:
                  '${(hour + 2).toString().padLeft(2, '0')}:30', // 2-hour trip
              platformInfo: 'Platform ${1 + (hour % 5)}',
              isExpress:
                  hour == 7 || hour == 15, // Morning and afternoon express
              availableSeats: {'economy': 60, 'business': 20, 'first': 10},
              intermediateStops: [
                'Central Station',
                'Mountain Pass',
                'River Crossing'
              ],
            ));
          }
          break;

        case TransportType.ferry:
          // Ferries run even less frequently
          for (int hour = 8; hour <= 16; hour += 4) {
            times.add(ScheduleTime(
              departureTime: '${hour.toString().padLeft(2, '0')}:00',
              arrivalTime:
                  '${(hour + 1).toString().padLeft(2, '0')}:30', // 1.5-hour trip
              platformInfo: 'Dock ${1 + (hour % 2)}',
              isExpress: false,
              availableSeats: {'standard': 80, 'premium': 20},
              specialNotes: 'Weather dependent service',
            ));
          }
          break;

        case TransportType.flight:
          // Only a few flights per day
          final flightHours = [8, 12, 17];
          for (final hour in flightHours) {
            times.add(ScheduleTime(
              departureTime: '${hour.toString().padLeft(2, '0')}:00',
              arrivalTime:
                  '${(hour + 1).toString().padLeft(2, '0')}:15', // 1.25-hour flight
              platformInfo: 'Gate ${1 + (hour % 10)}',
              isExpress: true,
              availableSeats: {'economy': 120, 'business': 20, 'first': 10},
              specialNotes: hour == 8
                  ? 'Morning breakfast served'
                  : 'Complimentary snack',
            ));
          }
          break;

        case TransportType.uber:
          // Uber schedules are on-demand, but add a few typical options
          final uberHours = [7, 12, 17, 21];
          for (final hour in uberHours) {
            times.add(ScheduleTime(
              departureTime: '${hour.toString().padLeft(2, '0')}:00',
              arrivalTime:
                  '${(hour + 1).toString().padLeft(2, '0')}:00', // Typical 1-hour estimated trip
              isExpress: true,
              availableSeats: {'economy': 4, 'premium': 2},
              specialNotes: 'On-demand service',
            ));
          }
          break;

        case TransportType.tuktuk:
          // Tuk-tuk service
          for (int hour = 7; hour <= 21; hour += 3) {
            times.add(ScheduleTime(
              departureTime: '${hour.toString().padLeft(2, '0')}:00',
              arrivalTime:
                  '${(hour + 1).toString().padLeft(2, '0')}:00', // 1-hour trip
              isExpress: false,
              availableSeats: {'standard': 3},
              specialNotes: 'Local driver with knowledge of the area',
            ));
          }
          break;

        case TransportType.car:
          // Car rentals or taxis
          for (int hour = 6; hour <= 22; hour += 4) {
            times.add(ScheduleTime(
              departureTime: '${hour.toString().padLeft(2, '0')}:00',
              arrivalTime:
                  '${(hour + 1).toString().padLeft(2, '0')}:30', // 1.5-hour trip
              isExpress: true,
              availableSeats: {'standard': 4, 'luxury': 3},
              specialNotes: 'Professional driver, AC vehicle',
            ));
          }
          break;
        case TransportType.pickMe:
          // TODO: Handle this case.
          throw UnimplementedError();
        case TransportType.taxi:
          // TODO: Handle this case.
          throw UnimplementedError();
        case TransportType.tuk:
          // TODO: Handle this case.
          throw UnimplementedError();
        case TransportType.rental:
          // TODO: Handle this case.
          throw UnimplementedError();
        case TransportType.walk:
          // TODO: Handle this case.
          throw UnimplementedError();
        case TransportType.all:
          // TODO: Handle this case.
          throw UnimplementedError();
        case TransportType.motorcycle:
          // TODO: Handle this case.
          throw UnimplementedError();
        case TransportType.luxury:
          // TODO: Handle this case.
          throw UnimplementedError();
      }

      // Add this day to the schedule
      scheduleDays.add(ScheduleDay(
        weekday: weekday,
        scheduleTimes: times,
      ));
    }

    // Determine available classes and prices based on transport type
    Map<String, double> classPrices = {};
    List<String> availableClasses = [];
    Map<String, String> classFacilities = {};

    switch (transportType) {
      case TransportType.bus:
        availableClasses = ['economy', 'business'];
        classPrices = {'economy': 15.0, 'business': 30.0};
        classFacilities = {
          'economy': 'Standard seating',
          'business': 'Extra legroom, Wi-Fi, Power outlets',
        };
        break;

      case TransportType.train:
        availableClasses = ['economy', 'business', 'first'];
        classPrices = {'economy': 25.0, 'business': 50.0, 'first': 75.0};
        classFacilities = {
          'economy': 'Standard seating',
          'business': 'Extra legroom, Wi-Fi, Power outlets',
          'first':
              'Premium seating, Meals included, Wi-Fi, Power outlets, Priority boarding',
        };
        break;

      case TransportType.ferry:
        availableClasses = ['standard', 'premium'];
        classPrices = {'standard': 20.0, 'premium': 35.0};
        classFacilities = {
          'standard': 'Indoor seating',
          'premium': 'Outdoor deck access, Refreshments included',
        };
        break;

      case TransportType.flight:
        availableClasses = ['economy', 'business', 'first'];
        classPrices = {'economy': 120.0, 'business': 250.0, 'first': 400.0};
        classFacilities = {
          'economy': 'Standard seating, In-flight entertainment',
          'business':
              'Extra legroom, Priority boarding, Meals, In-flight entertainment',
          'first':
              'Premium seating, Priority boarding, Premium meals, Premium entertainment',
        };
        break;

      case TransportType.uber:
        availableClasses = ['economy', 'premium'];
        classPrices = {'economy': 40.0, 'premium': 60.0};
        classFacilities = {
          'economy': 'Standard vehicle',
          'premium': 'Premium vehicle, Refreshments, Wi-Fi',
        };
        break;

      case TransportType.tuktuk:
        availableClasses = ['standard'];
        classPrices = {'standard': 15.0};
        classFacilities = {
          'standard': 'Traditional tuk-tuk experience',
        };
        break;

      case TransportType.car:
        availableClasses = ['standard', 'luxury'];
        classPrices = {'standard': 50.0, 'luxury': 100.0};
        classFacilities = {
          'standard': 'Sedan with AC',
          'luxury': 'Premium car with amenities',
        };
        break;
      case TransportType.pickMe:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.taxi:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.tuk:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.rental:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.walk:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.all:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.motorcycle:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.luxury:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    // Generate unique ID
    final id = _uuid.v4();

    // Get operator name based on transport type
    String operatorName = _getOperatorForTransportType(transportType);

    // Create the TransportSchedule object
    return TransportSchedule(
      id: id,
      transportId: '${transportType.toString().split('.').last}-$id',
      transportType: transportType,
      origin: origin,
      destination: destination,
      route: route,
      scheduleDays: scheduleDays,
      availableClasses: availableClasses,
      classPrices: classPrices,
      classFacilities: classFacilities,
      operator: operatorName,
      operatorContact: '+94 11 ${100000 + (id.hashCode % 899999)}',
      isActive: true,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get a mock operator name based on transport type
  String _getOperatorForTransportType(TransportType type) {
    switch (type) {
      case TransportType.bus:
        return 'Sri Lanka Transport Board';
      case TransportType.train:
        return 'Sri Lanka Railways';
      case TransportType.ferry:
        return 'Sri Lanka Ferry Service';
      case TransportType.flight:
        return 'SriLankan Airlines';
      case TransportType.uber:
        return 'Uber Sri Lanka';
      case TransportType.tuktuk:
        return 'Local Tuk-tuk Association';
      case TransportType.car:
        return 'Lanka Car Service';
      case TransportType.pickMe:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.taxi:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.tuk:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.rental:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.walk:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.all:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.motorcycle:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.luxury:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// Generates mock rentals for demonstration.
  List<Map<String, dynamic>> _generateMockRentals(
      String location, String? vehicleType) {
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
      case TransportType.uber:
        return ['AC', 'Bottled Water', 'Phone Charging'];
      case TransportType.tuktuk:
        return ['Open Air Experience', 'Local Guide', 'Flexible Stops'];
      case TransportType.car:
        return ['AC', 'Professional Driver', 'Bottled Water', 'WiFi'];
      case TransportType.pickMe:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.taxi:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.tuk:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.rental:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.walk:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.all:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.motorcycle:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransportType.luxury:
        // TODO: Handle this case.
        throw UnimplementedError();
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
      case 'uber':
        return TransportType.uber;
      case 'tuktuk':
        return TransportType.tuktuk;
      case 'car':
        return TransportType.car;
      default:
        throw ArgumentError('Invalid transport type: $type');
    }
  }
}
