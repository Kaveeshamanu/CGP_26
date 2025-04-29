// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      id: json['id'] as String,
      accommodationId: json['accommodationId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      maxAdults: (json['maxAdults'] as num).toInt(),
      maxChildren: (json['maxChildren'] as num).toInt(),
      maxOccupancy: (json['maxOccupancy'] as num).toInt(),
      bedConfiguration: json['bedConfiguration'] as String,
      roomSize: (json['roomSize'] as num?)?.toDouble(),
      amenities:
          (json['amenities'] as List<dynamic>).map((e) => e as String).toList(),
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      mainImage: json['mainImage'] as String,
      isRefundable: json['isRefundable'] as bool,
      cancellationPolicy: json['cancellationPolicy'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      viewType: json['viewType'] as String?,
      breakfastIncluded: json['breakfastIncluded'] as bool,
      freeWifi: json['freeWifi'] as bool,
      freeCancellation: json['freeCancellation'] as bool,
      cancellationDeadline: (json['cancellationDeadline'] as num?)?.toInt(),
      mealPlan: json['mealPlan'] as String?,
      policies: (json['policies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      ratePlanCode: json['ratePlanCode'] as String?,
      roomTypeCode: json['roomTypeCode'] as String?,
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'id': instance.id,
      'accommodationId': instance.accommodationId,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'discountedPrice': instance.discountedPrice,
      'maxAdults': instance.maxAdults,
      'maxChildren': instance.maxChildren,
      'maxOccupancy': instance.maxOccupancy,
      'bedConfiguration': instance.bedConfiguration,
      'roomSize': instance.roomSize,
      'amenities': instance.amenities,
      'images': instance.images,
      'mainImage': instance.mainImage,
      'isRefundable': instance.isRefundable,
      'cancellationPolicy': instance.cancellationPolicy,
      'quantity': instance.quantity,
      'viewType': instance.viewType,
      'breakfastIncluded': instance.breakfastIncluded,
      'freeWifi': instance.freeWifi,
      'freeCancellation': instance.freeCancellation,
      'cancellationDeadline': instance.cancellationDeadline,
      'mealPlan': instance.mealPlan,
      'policies': instance.policies,
      'ratePlanCode': instance.ratePlanCode,
      'roomTypeCode': instance.roomTypeCode,
    };
