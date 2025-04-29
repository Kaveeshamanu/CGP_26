// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      id: json['id'] as String,
      entityId: json['entityId'] as String,
      entityType: $enumDecode(_$ReviewEntityTypeEnumMap, json['entityType']),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String?,
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] as String,
      content: json['content'] as String,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      aspectRatings: (json['aspectRatings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      tripType: json['tripType'] as String?,
      visitDate: json['visitDate'] == null
          ? null
          : DateTime.parse(json['visitDate'] as String),
      helpfulVotes: (json['helpfulVotes'] as num?)?.toInt() ?? 0,
      unhelpfulVotes: (json['unhelpfulVotes'] as num?)?.toInt() ?? 0,
      ownerReply: json['ownerReply'] as Map<String, dynamic>?,
      isVerified: json['isVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'id': instance.id,
      'entityId': instance.entityId,
      'entityType': _$ReviewEntityTypeEnumMap[instance.entityType]!,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPhotoUrl': instance.userPhotoUrl,
      'rating': instance.rating,
      'title': instance.title,
      'content': instance.content,
      'images': instance.images,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
      'aspectRatings': instance.aspectRatings,
      'tripType': instance.tripType,
      'visitDate': instance.visitDate?.toIso8601String(),
      'helpfulVotes': instance.helpfulVotes,
      'unhelpfulVotes': instance.unhelpfulVotes,
      'ownerReply': instance.ownerReply,
      'isVerified': instance.isVerified,
    };

const _$ReviewEntityTypeEnumMap = {
  ReviewEntityType.accommodation: 'accommodation',
  ReviewEntityType.restaurant: 'restaurant',
  ReviewEntityType.destination: 'destination',
  ReviewEntityType.activity: 'activity',
  ReviewEntityType.transportation: 'transportation',
};
