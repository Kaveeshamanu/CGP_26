// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accommodation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Accommodation _$AccommodationFromJson(Map<String, dynamic> json) =>
    Accommodation(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      destinationId: json['destinationId'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      priceRange: json['priceRange'] as String,
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      starRating: (json['starRating'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      amenities:
          (json['amenities'] as List<dynamic>).map((e) => e as String).toList(),
      imageUrl: json['imageUrl'] as String,
      galleryImages: (json['galleryImages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      checkInTime: json['checkInTime'] as String,
      checkOutTime: json['checkOutTime'] as String,
      isSaved: json['isSaved'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      hasSpecialDeal: json['hasSpecialDeal'] as bool? ?? false,
      dealDetails: json['dealDetails'] as Map<String, dynamic>?,
      rooms: (json['rooms'] as List<dynamic>?)
          ?.map((e) => Room.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      facilities: (json['facilities'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      policies: (json['policies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      distanceFromCenter: (json['distanceFromCenter'] as num?)?.toDouble(),
      distanceFromAirport: (json['distanceFromAirport'] as num?)?.toDouble(),
      mealPlans: (json['mealPlans'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sustainabilityPractices:
          (json['sustainabilityPractices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      accessibilityFeatures: (json['accessibilityFeatures'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isFamilyFriendly: json['isFamilyFriendly'] as bool?,
      isPetFriendly: json['isPetFriendly'] as bool?,
      parking: json['parking'] as String?,
    );

Map<String, dynamic> _$AccommodationToJson(Accommodation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'location': instance.location,
      'destinationId': instance.destinationId,
      'type': instance.type,
      'category': instance.category,
      'priceRange': instance.priceRange,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'starRating': instance.starRating,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'amenities': instance.amenities,
      'imageUrl': instance.imageUrl,
      'galleryImages': instance.galleryImages,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'website': instance.website,
      'checkInTime': instance.checkInTime,
      'checkOutTime': instance.checkOutTime,
      'isSaved': instance.isSaved,
      'isFeatured': instance.isFeatured,
      'hasSpecialDeal': instance.hasSpecialDeal,
      'dealDetails': instance.dealDetails,
      'rooms': instance.rooms,
      'reviews': instance.reviews,
      'facilities': instance.facilities,
      'policies': instance.policies,
      'languages': instance.languages,
      'paymentMethods': instance.paymentMethods,
      'distanceFromCenter': instance.distanceFromCenter,
      'distanceFromAirport': instance.distanceFromAirport,
      'mealPlans': instance.mealPlans,
      'sustainabilityPractices': instance.sustainabilityPractices,
      'accessibilityFeatures': instance.accessibilityFeatures,
      'isFamilyFriendly': instance.isFamilyFriendly,
      'isPetFriendly': instance.isPetFriendly,
      'parking': instance.parking,
    };
