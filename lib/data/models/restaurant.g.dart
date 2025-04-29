// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Restaurant _$RestaurantFromJson(Map<String, dynamic> json) => Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      destinationId: json['destinationId'] as String,
      cuisine: json['cuisine'] as String,
      category: json['category'] as String,
      priceRange: json['priceRange'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      galleryImages: (json['galleryImages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      menuImages: (json['menuImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      menuUrl: json['menuUrl'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      openingHours: Map<String, String>.from(json['openingHours'] as Map),
      isSaved: json['isSaved'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      hasSpecialDeal: json['hasSpecialDeal'] as bool? ?? false,
      dealDetails: json['dealDetails'] as Map<String, dynamic>?,
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      facilities: (json['facilities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      acceptsReservations: json['acceptsReservations'] as bool,
      hasOutdoorSeating: json['hasOutdoorSeating'] as bool,
      offersDelivery: json['offersDelivery'] as bool,
      offersTakeaway: json['offersTakeaway'] as bool,
      popularDishes: (json['popularDishes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dietaryOptions: (json['dietaryOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      distanceFromCenter: (json['distanceFromCenter'] as num?)?.toDouble(),
      parking: json['parking'] as String?,
      isKidFriendly: json['isKidFriendly'] as bool?,
      servesAlcohol: json['servesAlcohol'] as bool?,
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dressCode: json['dressCode'] as String?,
      requiresReservation: json['requiresReservation'] as bool?,
      averageWaitTime: json['averageWaitTime'] as String?,
      noiseLevel: json['noiseLevel'] as String?,
      hasHappyHour: json['hasHappyHour'] as bool?,
      happyHourDetails: json['happyHourDetails'] as Map<String, dynamic>?,
      chefName: json['chefName'] as String?,
      menuHighlights: (json['menuHighlights'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$RestaurantToJson(Restaurant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'location': instance.location,
      'destinationId': instance.destinationId,
      'cuisine': instance.cuisine,
      'category': instance.category,
      'priceRange': instance.priceRange,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'imageUrl': instance.imageUrl,
      'galleryImages': instance.galleryImages,
      'menuImages': instance.menuImages,
      'menuUrl': instance.menuUrl,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'website': instance.website,
      'openingHours': instance.openingHours,
      'isSaved': instance.isSaved,
      'isFeatured': instance.isFeatured,
      'hasSpecialDeal': instance.hasSpecialDeal,
      'dealDetails': instance.dealDetails,
      'reviews': instance.reviews,
      'facilities': instance.facilities,
      'acceptsReservations': instance.acceptsReservations,
      'hasOutdoorSeating': instance.hasOutdoorSeating,
      'offersDelivery': instance.offersDelivery,
      'offersTakeaway': instance.offersTakeaway,
      'popularDishes': instance.popularDishes,
      'dietaryOptions': instance.dietaryOptions,
      'distanceFromCenter': instance.distanceFromCenter,
      'parking': instance.parking,
      'isKidFriendly': instance.isKidFriendly,
      'servesAlcohol': instance.servesAlcohol,
      'paymentMethods': instance.paymentMethods,
      'dressCode': instance.dressCode,
      'requiresReservation': instance.requiresReservation,
      'averageWaitTime': instance.averageWaitTime,
      'noiseLevel': instance.noiseLevel,
      'hasHappyHour': instance.hasHappyHour,
      'happyHourDetails': instance.happyHourDetails,
      'chefName': instance.chefName,
      'menuHighlights': instance.menuHighlights,
    };
