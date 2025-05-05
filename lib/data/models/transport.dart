import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transport.g.dart';

/// Represents different types of transportation available to travelers
enum TransportType {
  uber,
  pickMe,
  taxi,
  bus,
  train,
  tuk,
  rental,
  walk,
  ferry,
  flight,
  tuktuk,
  car,
  all,
  motorcycle,
  luxury,
}

/// Represents different pricing models for transportation
enum PricingModel {
  fixed,
  distance,
  time,
  combined,
}

/// Model representing a transport option
@JsonSerializable()
class Transport extends Equatable {
  final String id;
  final String name;
  final TransportType type;
  final PricingModel pricingModel;
  final double basePrice;
  final double pricePerKm;
  final double pricePerMinute;
  final String currencyCode;
  final String iconUrl;

  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration estimatedWaitTime;

  final double rating;
  final int reviewCount;
  final Map<String, dynamic>? additionalInfo;
  final bool isAvailable;

  const Transport({
    required this.id,
    required this.name,
    required this.type,
    required this.pricingModel,
    required this.basePrice,
    this.pricePerKm = 0.0,
    this.pricePerMinute = 0.0,
    required this.currencyCode,
    required this.iconUrl,
    required this.estimatedWaitTime,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.additionalInfo,
    this.isAvailable = true,
  });

  /// Creates a Transport object from a map (typically from JSON)
  factory Transport.fromJson(Map<String, dynamic> json) =>
      _$TransportFromJson(json);

  /// Converts the Transport object to a map (typically for JSON)
  Map<String, dynamic> toJson() => _$TransportToJson(this);

  /// Creates a copy of this Transport with the given fields replaced
  Transport copyWith({
    String? id,
    String? name,
    TransportType? type,
    PricingModel? pricingModel,
    double? basePrice,
    double? pricePerKm,
    double? pricePerMinute,
    String? currencyCode,
    String? iconUrl,
    Duration? estimatedWaitTime,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? additionalInfo,
    bool? isAvailable,
  }) {
    return Transport(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      pricingModel: pricingModel ?? this.pricingModel,
      basePrice: basePrice ?? this.basePrice,
      pricePerKm: pricePerKm ?? this.pricePerKm,
      pricePerMinute: pricePerMinute ?? this.pricePerMinute,
      currencyCode: currencyCode ?? this.currencyCode,
      iconUrl: iconUrl ?? this.iconUrl,
      estimatedWaitTime: estimatedWaitTime ?? this.estimatedWaitTime,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  /// Calculate estimated fare for a given distance and time
  double calculateEstimatedFare(
      {required double distanceKm, required Duration travelTime}) {
    switch (pricingModel) {
      case PricingModel.fixed:
        return basePrice;
      case PricingModel.distance:
        return basePrice + (pricePerKm * distanceKm);
      case PricingModel.time:
        return basePrice + (pricePerMinute * travelTime.inMinutes);
      case PricingModel.combined:
        return basePrice +
            (pricePerKm * distanceKm) +
            (pricePerMinute * travelTime.inMinutes);
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        pricingModel,
        basePrice,
        pricePerKm,
        pricePerMinute,
        currencyCode,
        iconUrl,
        estimatedWaitTime,
        rating,
        reviewCount,
        additionalInfo,
        isAvailable,
      ];

  @override
  String toString() {
    return 'Transport(id: $id, name: $name, type: $type, pricingModel: $pricingModel)';
  }

  // Helper methods for JSON serialization of Duration
  static Duration _durationFromJson(int seconds) => Duration(seconds: seconds);
  static int _durationToJson(Duration duration) => duration.inSeconds;
}

/// Model representing a booked transport trip
@JsonSerializable()
class TransportBooking extends Equatable {
  final String id;
  final Transport transport;
  final String userId;
  final String startLocationId;
  final String endLocationId;

  final DateTime bookingTime;
  final DateTime scheduledTime;
  final DateTime? actualPickupTime;
  final DateTime? completionTime;

  final double distance;

  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration estimatedDuration;

  final double estimatedFare;
  final double? actualFare;

  final String? driverName;
  final String? driverContact;
  final String? vehicleDetails;
  final String
      bookingStatus; // pending, confirmed, in_progress, completed, cancelled
  final String? cancellationReason;
  final int? userRating;
  final String? userReview;

  const TransportBooking({
    required this.id,
    required this.transport,
    required this.userId,
    required this.startLocationId,
    required this.endLocationId,
    required this.bookingTime,
    required this.scheduledTime,
    this.actualPickupTime,
    this.completionTime,
    required this.distance,
    required this.estimatedDuration,
    required this.estimatedFare,
    this.actualFare,
    this.driverName,
    this.driverContact,
    this.vehicleDetails,
    required this.bookingStatus,
    this.cancellationReason,
    this.userRating,
    this.userReview,
  });

  /// Creates a TransportBooking object from a map (typically from JSON)
  factory TransportBooking.fromJson(Map<String, dynamic> json) =>
      _$TransportBookingFromJson(json);

  /// Converts the TransportBooking object to a map (typically for JSON)
  Map<String, dynamic> toJson() => _$TransportBookingToJson(this);

  /// Creates a copy of this TransportBooking with the given fields replaced
  TransportBooking copyWith({
    String? id,
    Transport? transport,
    String? userId,
    String? startLocationId,
    String? endLocationId,
    DateTime? bookingTime,
    DateTime? scheduledTime,
    DateTime? actualPickupTime,
    DateTime? completionTime,
    double? distance,
    Duration? estimatedDuration,
    double? estimatedFare,
    double? actualFare,
    String? driverName,
    String? driverContact,
    String? vehicleDetails,
    String? bookingStatus,
    String? cancellationReason,
    int? userRating,
    String? userReview,
  }) {
    return TransportBooking(
      id: id ?? this.id,
      transport: transport ?? this.transport,
      userId: userId ?? this.userId,
      startLocationId: startLocationId ?? this.startLocationId,
      endLocationId: endLocationId ?? this.endLocationId,
      bookingTime: bookingTime ?? this.bookingTime,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualPickupTime: actualPickupTime ?? this.actualPickupTime,
      completionTime: completionTime ?? this.completionTime,
      distance: distance ?? this.distance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      actualFare: actualFare ?? this.actualFare,
      driverName: driverName ?? this.driverName,
      driverContact: driverContact ?? this.driverContact,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      userRating: userRating ?? this.userRating,
      userReview: userReview ?? this.userReview,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transport,
        userId,
        startLocationId,
        endLocationId,
        bookingTime,
        scheduledTime,
        actualPickupTime,
        completionTime,
        distance,
        estimatedDuration,
        estimatedFare,
        actualFare,
        driverName,
        driverContact,
        vehicleDetails,
        bookingStatus,
        cancellationReason,
        userRating,
        userReview,
      ];

  @override
  String toString() {
    return 'TransportBooking(id: $id, transport: ${transport.name}, status: $bookingStatus)';
  }

  // Helper methods for JSON serialization of Duration
  static Duration _durationFromJson(int seconds) => Duration(seconds: seconds);
  static int _durationToJson(Duration duration) => duration.inSeconds;
}
