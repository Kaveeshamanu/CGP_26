// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Destination _$DestinationFromJson(Map<String, dynamic> json) => Destination(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      galleryImages: (json['galleryImages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isSaved: json['isSaved'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      estimatedBudget: (json['estimatedBudget'] as num?)?.toDouble(),
      bestTimeToVisit: json['bestTimeToVisit'] as String?,
      recommendedDuration: json['recommendedDuration'] as String?,
      nearbyAttractions: (json['nearbyAttractions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      transportOptions: json['transportOptions'] as Map<String, dynamic>?,
      accommodationOptions:
          json['accommodationOptions'] as Map<String, dynamic>?,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      languageInfo: json['languageInfo'] as String,
      religionInfo: json['religionInfo'] as String,
      culturalImages: (json['culturalImages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      artsCraftsInfo: json['artsCraftsInfo'] as String,
      traditionalArts: (json['traditionalArts'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      cuisineInfo: json['cuisineInfo'] as String,
      popularDishes: (json['popularDishes'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      festivals: (json['festivals'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      culturalOverview: json['culturalOverview'] as String,
      customs:
          (json['customs'] as List<dynamic>).map((e) => e as String).toList(),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$DestinationToJson(Destination instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'location': instance.location,
      'category': instance.category,
      'tags': instance.tags,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'imageUrl': instance.imageUrl,
      'galleryImages': instance.galleryImages,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isSaved': instance.isSaved,
      'isTrending': instance.isTrending,
      'estimatedBudget': instance.estimatedBudget,
      'bestTimeToVisit': instance.bestTimeToVisit,
      'recommendedDuration': instance.recommendedDuration,
      'nearbyAttractions': instance.nearbyAttractions,
      'transportOptions': instance.transportOptions,
      'accommodationOptions': instance.accommodationOptions,
      'additionalInfo': instance.additionalInfo,
      'languageInfo': instance.languageInfo,
      'religionInfo': instance.religionInfo,
      'culturalImages': instance.culturalImages,
      'artsCraftsInfo': instance.artsCraftsInfo,
      'traditionalArts': instance.traditionalArts,
      'cuisineInfo': instance.cuisineInfo,
      'popularDishes': instance.popularDishes,
      'festivals': instance.festivals,
      'culturalOverview': instance.culturalOverview,
      'customs': instance.customs,
      'isBookmarked': instance.isBookmarked,
      'isFavorite': instance.isFavorite,
    };
