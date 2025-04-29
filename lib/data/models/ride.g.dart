// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ride _$RideFromJson(Map<String, dynamic> json) => Ride(
      id: json['id'] as String,
      userId: json['userId'] as String,
      status: $enumDecode(_$RideStatusEnumMap, json['status']),
      transportType: $enumDecode(_$TransportTypeEnumMap, json['transportType']),
      driverId: json['driverId'] as String?,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      driverRating: (json['driverRating'] as num?)?.toDouble(),
      vehicleId: json['vehicleId'] as String?,
      vehicleModel: json['vehicleModel'] as String?,
      vehiclePlateNumber: json['vehiclePlateNumber'] as String?,
      pickupAddress: json['pickupAddress'] as String,
      dropoffAddress: json['dropoffAddress'] as String,
      pickupLatitude: (json['pickupLatitude'] as num).toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num).toDouble(),
      dropoffLatitude: (json['dropoffLatitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoffLongitude'] as num).toDouble(),
      pickupTime: DateTime.parse(json['pickupTime'] as String),
      scheduledPickupTime: json['scheduledPickupTime'] == null
          ? null
          : DateTime.parse(json['scheduledPickupTime'] as String),
      actualPickupTime: json['actualPickupTime'] == null
          ? null
          : DateTime.parse(json['actualPickupTime'] as String),
      dropoffTime: json['dropoffTime'] == null
          ? null
          : DateTime.parse(json['dropoffTime'] as String),
      estimatedDistance: (json['estimatedDistance'] as num).toDouble(),
      estimatedDuration: (json['estimatedDuration'] as num).toInt(),
      estimatedFare: (json['estimatedFare'] as num).toDouble(),
      actualFare: (json['actualFare'] as num?)?.toDouble(),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      paymentStatus: $enumDecode(_$PaymentStatusEnumMap, json['paymentStatus']),
      paymentId: json['paymentId'] as String?,
      intermediateStops: (json['intermediateStops'] as List<dynamic>?)
          ?.map((e) => RideStop.fromJson(e as Map<String, dynamic>))
          .toList(),
      cancelReason: json['cancelReason'] as String?,
      notes: json['notes'] as String?,
      rideOptions: json['rideOptions'] == null
          ? null
          : RideOptions.fromJson(json['rideOptions'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RideToJson(Ride instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'status': _$RideStatusEnumMap[instance.status]!,
      'transportType': _$TransportTypeEnumMap[instance.transportType]!,
      'driverId': instance.driverId,
      'driverName': instance.driverName,
      'driverPhone': instance.driverPhone,
      'driverRating': instance.driverRating,
      'vehicleId': instance.vehicleId,
      'vehicleModel': instance.vehicleModel,
      'vehiclePlateNumber': instance.vehiclePlateNumber,
      'pickupAddress': instance.pickupAddress,
      'dropoffAddress': instance.dropoffAddress,
      'pickupLatitude': instance.pickupLatitude,
      'pickupLongitude': instance.pickupLongitude,
      'dropoffLatitude': instance.dropoffLatitude,
      'dropoffLongitude': instance.dropoffLongitude,
      'pickupTime': instance.pickupTime.toIso8601String(),
      'scheduledPickupTime': instance.scheduledPickupTime?.toIso8601String(),
      'actualPickupTime': instance.actualPickupTime?.toIso8601String(),
      'dropoffTime': instance.dropoffTime?.toIso8601String(),
      'estimatedDistance': instance.estimatedDistance,
      'estimatedDuration': instance.estimatedDuration,
      'estimatedFare': instance.estimatedFare,
      'actualFare': instance.actualFare,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'paymentId': instance.paymentId,
      'intermediateStops': instance.intermediateStops,
      'cancelReason': instance.cancelReason,
      'notes': instance.notes,
      'rideOptions': instance.rideOptions,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RideStatusEnumMap = {
  RideStatus.pending: 'pending',
  RideStatus.accepted: 'accepted',
  RideStatus.arriving: 'arriving',
  RideStatus.arrived: 'arrived',
  RideStatus.inProgress: 'inProgress',
  RideStatus.completed: 'completed',
  RideStatus.cancelled: 'cancelled',
  RideStatus.noDriverFound: 'noDriverFound',
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

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.creditCard: 'creditCard',
  PaymentMethod.applePay: 'applePay',
  PaymentMethod.googlePay: 'googlePay',
  PaymentMethod.paypal: 'paypal',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};

RideStop _$RideStopFromJson(Map<String, dynamic> json) => RideStop(
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      stopOrder: (json['stopOrder'] as num).toInt(),
      reached: json['reached'] as bool? ?? false,
      reachedAt: json['reachedAt'] == null
          ? null
          : DateTime.parse(json['reachedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$RideStopToJson(RideStop instance) => <String, dynamic>{
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'stopOrder': instance.stopOrder,
      'reached': instance.reached,
      'reachedAt': instance.reachedAt?.toIso8601String(),
      'notes': instance.notes,
    };

RideOptions _$RideOptionsFromJson(Map<String, dynamic> json) => RideOptions(
      extraLuggage: json['extraLuggage'] as bool? ?? false,
      premiumVehicle: json['premiumVehicle'] as bool? ?? false,
      petFriendly: json['petFriendly'] as bool? ?? false,
      childSeat: json['childSeat'] as bool? ?? false,
      wheelchairAccessible: json['wheelchairAccessible'] as bool? ?? false,
      englishSpeaking: json['englishSpeaking'] as bool? ?? false,
      specialInstructions: json['specialInstructions'] as String?,
    );

Map<String, dynamic> _$RideOptionsToJson(RideOptions instance) =>
    <String, dynamic>{
      'extraLuggage': instance.extraLuggage,
      'premiumVehicle': instance.premiumVehicle,
      'petFriendly': instance.petFriendly,
      'childSeat': instance.childSeat,
      'wheelchairAccessible': instance.wheelchairAccessible,
      'englishSpeaking': instance.englishSpeaking,
      'specialInstructions': instance.specialInstructions,
    };
