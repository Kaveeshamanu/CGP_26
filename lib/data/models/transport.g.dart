// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transport _$TransportFromJson(Map<String, dynamic> json) => Transport(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$TransportTypeEnumMap, json['type']),
      pricingModel: $enumDecode(_$PricingModelEnumMap, json['pricingModel']),
      basePrice: (json['basePrice'] as num).toDouble(),
      pricePerKm: (json['pricePerKm'] as num?)?.toDouble() ?? 0.0,
      pricePerMinute: (json['pricePerMinute'] as num?)?.toDouble() ?? 0.0,
      currencyCode: json['currencyCode'] as String,
      iconUrl: json['iconUrl'] as String,
      estimatedWaitTime: Transport._durationFromJson(
          (json['estimatedWaitTime'] as num).toInt()),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );

Map<String, dynamic> _$TransportToJson(Transport instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$TransportTypeEnumMap[instance.type]!,
      'pricingModel': _$PricingModelEnumMap[instance.pricingModel]!,
      'basePrice': instance.basePrice,
      'pricePerKm': instance.pricePerKm,
      'pricePerMinute': instance.pricePerMinute,
      'currencyCode': instance.currencyCode,
      'iconUrl': instance.iconUrl,
      'estimatedWaitTime':
          Transport._durationToJson(instance.estimatedWaitTime),
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'additionalInfo': instance.additionalInfo,
      'isAvailable': instance.isAvailable,
    };

const _$TransportTypeEnumMap = {
  TransportType.uber: 'uber',
  TransportType.pickMe: 'pickMe',
  TransportType.taxi: 'taxi',
  TransportType.bus: 'bus',
  TransportType.train: 'train',
  TransportType.tuk: 'tuk',
  TransportType.rental: 'rental',
  TransportType.walk: 'walk',
  TransportType.ferry: 'ferry',
  TransportType.flight: 'flight',
  TransportType.tuktuk: 'tuktuk',
  TransportType.car: 'car',
  TransportType.all: 'all',
};

const _$PricingModelEnumMap = {
  PricingModel.fixed: 'fixed',
  PricingModel.distance: 'distance',
  PricingModel.time: 'time',
  PricingModel.combined: 'combined',
};

TransportBooking _$TransportBookingFromJson(Map<String, dynamic> json) =>
    TransportBooking(
      id: json['id'] as String,
      transport: Transport.fromJson(json['transport'] as Map<String, dynamic>),
      userId: json['userId'] as String,
      startLocationId: json['startLocationId'] as String,
      endLocationId: json['endLocationId'] as String,
      bookingTime: DateTime.parse(json['bookingTime'] as String),
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      actualPickupTime: json['actualPickupTime'] == null
          ? null
          : DateTime.parse(json['actualPickupTime'] as String),
      completionTime: json['completionTime'] == null
          ? null
          : DateTime.parse(json['completionTime'] as String),
      distance: (json['distance'] as num).toDouble(),
      estimatedDuration: TransportBooking._durationFromJson(
          (json['estimatedDuration'] as num).toInt()),
      estimatedFare: (json['estimatedFare'] as num).toDouble(),
      actualFare: (json['actualFare'] as num?)?.toDouble(),
      driverName: json['driverName'] as String?,
      driverContact: json['driverContact'] as String?,
      vehicleDetails: json['vehicleDetails'] as String?,
      bookingStatus: json['bookingStatus'] as String,
      cancellationReason: json['cancellationReason'] as String?,
      userRating: (json['userRating'] as num?)?.toInt(),
      userReview: json['userReview'] as String?,
    );

Map<String, dynamic> _$TransportBookingToJson(TransportBooking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transport': instance.transport,
      'userId': instance.userId,
      'startLocationId': instance.startLocationId,
      'endLocationId': instance.endLocationId,
      'bookingTime': instance.bookingTime.toIso8601String(),
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'actualPickupTime': instance.actualPickupTime?.toIso8601String(),
      'completionTime': instance.completionTime?.toIso8601String(),
      'distance': instance.distance,
      'estimatedDuration':
          TransportBooking._durationToJson(instance.estimatedDuration),
      'estimatedFare': instance.estimatedFare,
      'actualFare': instance.actualFare,
      'driverName': instance.driverName,
      'driverContact': instance.driverContact,
      'vehicleDetails': instance.vehicleDetails,
      'bookingStatus': instance.bookingStatus,
      'cancellationReason': instance.cancellationReason,
      'userRating': instance.userRating,
      'userReview': instance.userReview,
    };
