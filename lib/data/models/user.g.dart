// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      authProvider: $enumDecode(_$AuthProviderEnumMap, json['authProvider']),
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.traveler,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      fcmToken: json['fcmToken'] as String?,
      favoriteDestinations: (json['favoriteDestinations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      favoriteAccommodations: (json['favoriteAccommodations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      favoriteRestaurants: (json['favoriteRestaurants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferences: json['preferences'] as Map<String, dynamic>?,
      settingsData: json['settingsData'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool? ?? true,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      languageCode: json['languageCode'] as String? ?? 'en',
      countryCode: json['countryCode'] as String?,
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
      memberSince: DateTime.parse(json['memberSince'] as String),
      travelPoints: (json['travelPoints'] as num).toInt(),
      completedTrips: (json['completedTrips'] as num).toInt(),
      wishlistedDestinations: (json['wishlistedDestinations'] as num).toInt(),
      reviewsCount: (json['reviewsCount'] as num).toInt(),
      badges: (json['badges'] as List<dynamic>)
          .map((e) => UserBadge.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'displayName': instance.displayName,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'isEmailVerified': instance.isEmailVerified,
      'isPhoneVerified': instance.isPhoneVerified,
      'authProvider': _$AuthProviderEnumMap[instance.authProvider]!,
      'role': _$UserRoleEnumMap[instance.role]!,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'fcmToken': instance.fcmToken,
      'favoriteDestinations': instance.favoriteDestinations,
      'favoriteAccommodations': instance.favoriteAccommodations,
      'favoriteRestaurants': instance.favoriteRestaurants,
      'preferences': instance.preferences,
      'settingsData': instance.settingsData,
      'isActive': instance.isActive,
      'isProfileComplete': instance.isProfileComplete,
      'languageCode': instance.languageCode,
      'countryCode': instance.countryCode,
      'currencyCode': instance.currencyCode,
      'name': instance.name,
      'profileImageUrl': instance.profileImageUrl,
      'memberSince': instance.memberSince?.toIso8601String(),
      'travelPoints': instance.travelPoints,
      'completedTrips': instance.completedTrips,
      'wishlistedDestinations': instance.wishlistedDestinations,
      'reviewsCount': instance.reviewsCount,
      'badges': instance.badges,
    };

const _$AuthProviderEnumMap = {
  AuthProvider.email: 'email',
  AuthProvider.google: 'google',
  AuthProvider.apple: 'apple',
  AuthProvider.facebook: 'facebook',
  AuthProvider.phone: 'phone',
};

const _$UserRoleEnumMap = {
  UserRole.traveler: 'traveler',
  UserRole.localGuide: 'localGuide',
  UserRole.businessOwner: 'businessOwner',
  UserRole.admin: 'admin',
};

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      userId: json['userId'] as String,
      bio: json['bio'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String?,
      nationality: json['nationality'] as String?,
      passportNumber: json['passportNumber'] as String?,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      emergencyContact: json['emergencyContact'] as Map<String, dynamic>?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      travelPreferences: json['travelPreferences'] as Map<String, dynamic>?,
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => UserAddress.fromJson(e as Map<String, dynamic>))
          .toList(),
      socialProfiles: json['socialProfiles'] as Map<String, dynamic>?,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      travelStats: (json['travelStats'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      completedTrips: (json['completedTrips'] as num?)?.toInt() ?? 0,
      badges: (json['badges'] as List<dynamic>?)
          ?.map((e) => UserBadge.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'bio': instance.bio,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'nationality': instance.nationality,
      'passportNumber': instance.passportNumber,
      'languages': instance.languages,
      'emergencyContact': instance.emergencyContact,
      'interests': instance.interests,
      'travelPreferences': instance.travelPreferences,
      'addresses': instance.addresses,
      'socialProfiles': instance.socialProfiles,
      'reviewCount': instance.reviewCount,
      'averageRating': instance.averageRating,
      'travelStats': instance.travelStats,
      'completedTrips': instance.completedTrips,
      'badges': instance.badges,
    };

UserAddress _$UserAddressFromJson(Map<String, dynamic> json) => UserAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      street: json['street'] as String,
      unit: json['unit'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$UserAddressToJson(UserAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'street': instance.street,
      'unit': instance.unit,
      'city': instance.city,
      'state': instance.state,
      'postalCode': instance.postalCode,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isDefault': instance.isDefault,
    };

UserBadge _$UserBadgeFromJson(Map<String, dynamic> json) => UserBadge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      awardedAt: DateTime.parse(json['awardedAt'] as String),
      category: json['category'] as String,
      level: (json['level'] as num?)?.toInt() ?? 1,
      criteria: json['criteria'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserBadgeToJson(UserBadge instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'awardedAt': instance.awardedAt.toIso8601String(),
      'category': instance.category,
      'level': instance.level,
      'criteria': instance.criteria,
    };
