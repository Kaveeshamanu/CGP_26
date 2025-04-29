import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import 'transport.dart';

part 'ride.g.dart';

/// Represents a ride (taxi, tuktuk, etc.) booking or request
@JsonSerializable()
class Ride extends Equatable {
  final String id;
  final String userId;
  final RideStatus status;
  final TransportType transportType;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final double? driverRating;
  final String? vehicleId;
  final String? vehicleModel;
  final String? vehiclePlateNumber;
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final DateTime pickupTime;
  final DateTime? scheduledPickupTime;
  final DateTime? actualPickupTime;
  final DateTime? dropoffTime;
  final double estimatedDistance; // in kilometers
  final int estimatedDuration; // in minutes
  final double estimatedFare;
  final double? actualFare;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? paymentId;
  final List<RideStop>? intermediateStops;
  final String? cancelReason;
  final String? notes;
  final RideOptions? rideOptions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ride({
    required this.id,
    required this.userId,
    required this.status,
    required this.transportType,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.driverRating,
    this.vehicleId,
    this.vehicleModel,
    this.vehiclePlateNumber,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.pickupTime,
    this.scheduledPickupTime,
    this.actualPickupTime,
    this.dropoffTime,
    required this.estimatedDistance,
    required this.estimatedDuration,
    required this.estimatedFare,
    this.actualFare,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentId,
    this.intermediateStops,
    this.cancelReason,
    this.notes,
    this.rideOptions,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        status,
        transportType,
        driverId,
        driverName,
        driverPhone,
        driverRating,
        vehicleId,
        vehicleModel,
        vehiclePlateNumber,
        pickupAddress,
        dropoffAddress,
        pickupLatitude,
        pickupLongitude,
        dropoffLatitude,
        dropoffLongitude,
        pickupTime,
        scheduledPickupTime,
        actualPickupTime,
        dropoffTime,
        estimatedDistance,
        estimatedDuration,
        estimatedFare,
        actualFare,
        paymentMethod,
        paymentStatus,
        paymentId,
        intermediateStops,
        cancelReason,
        notes,
        rideOptions,
        createdAt,
        updatedAt,
      ];

  /// Creates a copy of this Ride with the given fields replaced with new values.
  Ride copyWith({
    String? id,
    String? userId,
    RideStatus? status,
    TransportType? transportType,
    String? driverId,
    String? driverName,
    String? driverPhone,
    double? driverRating,
    String? vehicleId,
    String? vehicleModel,
    String? vehiclePlateNumber,
    String? pickupAddress,
    String? dropoffAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    DateTime? pickupTime,
    DateTime? scheduledPickupTime,
    DateTime? actualPickupTime,
    DateTime? dropoffTime,
    double? estimatedDistance,
    int? estimatedDuration,
    double? estimatedFare,
    double? actualFare,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? paymentId,
    List<RideStop>? intermediateStops,
    String? cancelReason,
    String? notes,
    RideOptions? rideOptions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ride(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      transportType: transportType ?? this.transportType,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverRating: driverRating ?? this.driverRating,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      pickupTime: pickupTime ?? this.pickupTime,
      scheduledPickupTime: scheduledPickupTime ?? this.scheduledPickupTime,
      actualPickupTime: actualPickupTime ?? this.actualPickupTime,
      dropoffTime: dropoffTime ?? this.dropoffTime,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      actualFare: actualFare ?? this.actualFare,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      intermediateStops: intermediateStops ?? this.intermediateStops,
      cancelReason: cancelReason ?? this.cancelReason,
      notes: notes ?? this.notes,
      rideOptions: rideOptions ?? this.rideOptions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates a Ride from a JSON object.
  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);

  /// Converts this Ride to a JSON object.
  Map<String, dynamic> toJson() => _$RideToJson(this);

  /// Checks if the ride is a scheduled ride.
  bool isScheduled() {
    return scheduledPickupTime != null && 
           scheduledPickupTime!.isAfter(DateTime.now());
  }

  /// Calculates the total distance including intermediate stops.
  double calculateTotalDistance() {
    double totalDistance = estimatedDistance;
    
    if (intermediateStops != null && intermediateStops!.isNotEmpty) {
      // Add extra distance for intermediate stops
      // This is a simplification, in a real app you would use detailed routing
      totalDistance += 0.5 * intermediateStops!.length;
    }
    
    return totalDistance;
  }

  /// Calculates the final fare based on actual distance, time and any extras.
  double calculateFinalFare() {
    if (actualFare != null) {
      return actualFare!;
    }
    
    double fare = estimatedFare;
    
    // Add extra for intermediate stops
    if (intermediateStops != null && intermediateStops!.isNotEmpty) {
      fare += 50.0 * intermediateStops!.length; // 50 LKR per stop
    }
    
    // Add extras from ride options
    if (rideOptions != null) {
      if (rideOptions!.extraLuggage) {
        fare += 100.0; // 100 LKR for extra luggage
      }
      
      if (rideOptions!.premiumVehicle) {
        fare *= 1.2; // 20% extra for premium vehicle
      }
      
      if (rideOptions!.petFriendly) {
        fare += 150.0; // 150 LKR for pet friendly ride
      }
    }
    
    return fare;
  }

  /// Returns the appropriate status message for the current ride status.
  String getStatusMessage() {
    switch (status) {
      case RideStatus.pending:
        return 'Searching for driver...';
      case RideStatus.accepted:
        return 'Driver is on the way';
      case RideStatus.arriving:
        return 'Driver is arriving soon';
      case RideStatus.arrived:
        return 'Driver has arrived at pickup location';
      case RideStatus.inProgress:
        return 'Ride in progress';
      case RideStatus.completed:
        return 'Ride completed';
      case RideStatus.cancelled:
        return 'Ride cancelled${cancelReason != null ? ': $cancelReason' : ''}';
      case RideStatus.noDriverFound:
        return 'No driver found';
      default:
        return 'Unknown status';
    }
  }

  /// Returns the estimated time of arrival (ETA) in minutes.
  int getEtaMinutes() {
    if (status == RideStatus.inProgress && dropoffTime != null) {
      final now = DateTime.now();
      final eta = dropoffTime!.difference(now).inMinutes;
      return eta > 0 ? eta : 1; // At least 1 minute
    }
    return estimatedDuration;
  }

  /// Returns a color representing the current status of the ride.
  Color getStatusColor() {
    switch (status) {
      case RideStatus.pending:
        return Colors.orange;
      case RideStatus.accepted:
        return Colors.blue;
      case RideStatus.arriving:
        return Colors.blue;
      case RideStatus.arrived:
        return Colors.green;
      case RideStatus.inProgress:
        return Colors.green;
      case RideStatus.completed:
        return Colors.green;
      case RideStatus.cancelled:
        return Colors.red;
      case RideStatus.noDriverFound:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Returns a string representing the payment method.
  String getPaymentMethodString() {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.paypal:
        return 'PayPal';
      default:
        return 'Unknown';
    }
  }

  /// Returns a string representation of the vehicle type.
  String getVehicleTypeString() {
    switch (transportType) {
      case TransportType.taxi:
        return 'Taxi';
      case TransportType.tuktuk:
        return 'Tuk-Tuk';
      case TransportType.car:
        return 'Car';
      default:
        return 'Vehicle';
    }
  }
}

/// Represents a stop along the ride's route
@JsonSerializable()
class RideStop extends Equatable {
  final String address;
  final double latitude;
  final double longitude;
  final int stopOrder;
  final bool reached;
  final DateTime? reachedAt;
  final String? notes;

  const RideStop({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.stopOrder,
    this.reached = false,
    this.reachedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
        address,
        latitude,
        longitude,
        stopOrder,
        reached,
        reachedAt,
        notes,
      ];

  /// Creates a copy of this RideStop with the given fields replaced with new values.
  RideStop copyWith({
    String? address,
    double? latitude,
    double? longitude,
    int? stopOrder,
    bool? reached,
    DateTime? reachedAt,
    String? notes,
  }) {
    return RideStop(
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      stopOrder: stopOrder ?? this.stopOrder,
      reached: reached ?? this.reached,
      reachedAt: reachedAt ?? this.reachedAt,
      notes: notes ?? this.notes,
    );
  }

  /// Creates a RideStop from a JSON object.
  factory RideStop.fromJson(Map<String, dynamic> json) => _$RideStopFromJson(json);

  /// Converts this RideStop to a JSON object.
  Map<String, dynamic> toJson() => _$RideStopToJson(this);
}

/// Represents additional options for a ride
@JsonSerializable()
class RideOptions extends Equatable {
  final bool extraLuggage;
  final bool premiumVehicle;
  final bool petFriendly;
  final bool childSeat;
  final bool wheelchairAccessible;
  final bool englishSpeaking;
  final String? specialInstructions;

  const RideOptions({
    this.extraLuggage = false,
    this.premiumVehicle = false,
    this.petFriendly = false,
    this.childSeat = false,
    this.wheelchairAccessible = false,
    this.englishSpeaking = false,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
        extraLuggage,
        premiumVehicle,
        petFriendly,
        childSeat,
        wheelchairAccessible,
        englishSpeaking,
        specialInstructions,
      ];

  /// Creates a copy of this RideOptions with the given fields replaced with new values.
  RideOptions copyWith({
    bool? extraLuggage,
    bool? premiumVehicle,
    bool? petFriendly,
    bool? childSeat,
    bool? wheelchairAccessible,
    bool? englishSpeaking,
    String? specialInstructions,
  }) {
    return RideOptions(
      extraLuggage: extraLuggage ?? this.extraLuggage,
      premiumVehicle: premiumVehicle ?? this.premiumVehicle,
      petFriendly: petFriendly ?? this.petFriendly,
      childSeat: childSeat ?? this.childSeat,
      wheelchairAccessible: wheelchairAccessible ?? this.wheelchairAccessible,
      englishSpeaking: englishSpeaking ?? this.englishSpeaking,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  /// Creates a RideOptions from a JSON object.
  factory RideOptions.fromJson(Map<String, dynamic> json) => _$RideOptionsFromJson(json);

  /// Converts this RideOptions to a JSON object.
  Map<String, dynamic> toJson() => _$RideOptionsToJson(this);

  /// Returns a list of all options that are enabled
  List<String> getEnabledOptions() {
    List<String> options = [];
    
    if (extraLuggage) options.add('Extra Luggage');
    if (premiumVehicle) options.add('Premium Vehicle');
    if (petFriendly) options.add('Pet Friendly');
    if (childSeat) options.add('Child Seat');
    if (wheelchairAccessible) options.add('Wheelchair Accessible');
    if (englishSpeaking) options.add('English Speaking Driver');
    
    return options;
  }

  /// Returns a string describing all enabled options
  String getOptionsDescription() {
    final options = getEnabledOptions();
    
    if (options.isEmpty) {
      return 'No special options';
    }
    
    return options.join(', ');
  }
}

/// Enum representing the status of a ride
enum RideStatus {
  pending,      // Waiting for driver acceptance
  accepted,     // Driver has accepted
  arriving,     // Driver is on the way to pickup
  arrived,      // Driver has arrived at pickup location
  inProgress,   // Ride is in progress
  completed,    // Ride has been completed
  cancelled,    // Ride was cancelled
  noDriverFound // No driver was found for the ride
}

/// Enum representing payment methods
enum PaymentMethod {
  cash,
  creditCard,
  applePay,
  googlePay,
  paypal
}

/// Enum representing payment status
enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded
}