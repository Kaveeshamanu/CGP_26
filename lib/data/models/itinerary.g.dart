// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Itinerary _$ItineraryFromJson(Map<String, dynamic> json) => Itinerary(
      id: json['id'] as String,
      title: json['title'] as String,
      userId: json['userId'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => ItineraryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      isShared: json['isShared'] as bool? ?? false,
      shareUrl: json['shareUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ItineraryToJson(Itinerary instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'userId': instance.userId,
      'destination': instance.destination,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'items': instance.items,
      'isShared': instance.isShared,
      'shareUrl': instance.shareUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
