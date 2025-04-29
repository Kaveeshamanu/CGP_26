// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransportSchedule _$TransportScheduleFromJson(Map<String, dynamic> json) =>
    TransportSchedule(
      id: json['id'] as String,
      transportId: json['transportId'] as String,
      transportType: $enumDecode(_$TransportTypeEnumMap, json['transportType']),
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      route: json['route'] as String?,
      scheduleDays: (json['scheduleDays'] as List<dynamic>)
          .map((e) => ScheduleDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableClasses: (json['availableClasses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      classPrices: (json['classPrices'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      classFacilities: (json['classFacilities'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      operator: json['operator'] as String?,
      operatorContact: json['operatorContact'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$TransportScheduleToJson(TransportSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transportId': instance.transportId,
      'transportType': _$TransportTypeEnumMap[instance.transportType]!,
      'origin': instance.origin,
      'destination': instance.destination,
      'route': instance.route,
      'scheduleDays': instance.scheduleDays,
      'availableClasses': instance.availableClasses,
      'classPrices': instance.classPrices,
      'classFacilities': instance.classFacilities,
      'operator': instance.operator,
      'operatorContact': instance.operatorContact,
      'notes': instance.notes,
      'isActive': instance.isActive,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
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

ScheduleDay _$ScheduleDayFromJson(Map<String, dynamic> json) => ScheduleDay(
      weekday: (json['weekday'] as num).toInt(),
      scheduleTimes: (json['scheduleTimes'] as List<dynamic>)
          .map((e) => ScheduleTime.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScheduleDayToJson(ScheduleDay instance) =>
    <String, dynamic>{
      'weekday': instance.weekday,
      'scheduleTimes': instance.scheduleTimes,
    };

ScheduleTime _$ScheduleTimeFromJson(Map<String, dynamic> json) => ScheduleTime(
      departureTime: json['departureTime'] as String,
      arrivalTime: json['arrivalTime'] as String?,
      availableClasses: (json['availableClasses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      availableSeats: (json['availableSeats'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      platformInfo: json['platformInfo'] as String?,
      isExpress: json['isExpress'] as bool? ?? false,
      intermediateStops: (json['intermediateStops'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      specialNotes: json['specialNotes'] as String?,
    );

Map<String, dynamic> _$ScheduleTimeToJson(ScheduleTime instance) =>
    <String, dynamic>{
      'departureTime': instance.departureTime,
      'arrivalTime': instance.arrivalTime,
      'availableClasses': instance.availableClasses,
      'availableSeats': instance.availableSeats,
      'platformInfo': instance.platformInfo,
      'isExpress': instance.isExpress,
      'intermediateStops': instance.intermediateStops,
      'specialNotes': instance.specialNotes,
    };
