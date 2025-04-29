// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItineraryItem _$ItineraryItemFromJson(Map<String, dynamic> json) =>
    ItineraryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: $enumDecode(_$ItineraryItemTypeEnumMap, json['type']),
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      cost: (json['cost'] as num?)?.toDouble(),
      isBooked: json['isBooked'] as bool? ?? false,
      bookingReference: json['bookingReference'] as String?,
      bookingUrl: json['bookingUrl'] as String?,
      notes: json['notes'] as String?,
      referenceId: json['referenceId'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ItineraryItemToJson(ItineraryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$ItineraryItemTypeEnumMap[instance.type]!,
      'date': instance.date.toIso8601String(),
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'cost': instance.cost,
      'isBooked': instance.isBooked,
      'bookingReference': instance.bookingReference,
      'bookingUrl': instance.bookingUrl,
      'notes': instance.notes,
      'referenceId': instance.referenceId,
      'imageUrl': instance.imageUrl,
    };

const _$ItineraryItemTypeEnumMap = {
  ItineraryItemType.accommodation: 'accommodation',
  ItineraryItemType.restaurant: 'restaurant',
  ItineraryItemType.transport: 'transport',
  ItineraryItemType.activity: 'activity',
  ItineraryItemType.sight: 'sight',
  ItineraryItemType.custom: 'custom',
};
