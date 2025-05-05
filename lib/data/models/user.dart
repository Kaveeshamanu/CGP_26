import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

/// Represents authentication provider for user accounts
enum AuthProvider {
  email,
  google,
  apple,
  facebook,
  phone,
}

/// Represents account type
enum UserRole {
  traveler,
  localGuide,
  businessOwner,
  admin,
}

/// User model representing application users
@JsonSerializable()
class User extends Equatable {
  final String id;
  final String email;
  final String? phoneNumber;
  final String? displayName;
  final String? profilePhotoUrl;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final AuthProvider? authProvider;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? fcmToken;
  final List<String> favoriteDestinations;
  final List<String> favoriteAccommodations;
  final List<String> favoriteRestaurants;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? settingsData;
  final bool isActive;
  final bool isProfileComplete;
  final String? languageCode;
  final String? countryCode;
  final String? currencyCode;

  // Added fields from constructor parameters
  final String? name;
  final String? profileImageUrl;
  final DateTime? memberSince;
  final int? travelPoints;
  final int? completedTrips;
  final int? wishlistedDestinations;
  final int? reviewsCount;
  final List<UserBadge>? badges;

  const User({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.displayName,
    this.profilePhotoUrl,
    required this.isEmailVerified,
    this.isPhoneVerified = false,
    this.authProvider,
    this.role = UserRole.traveler,
    required this.createdAt,
    this.lastLoginAt,
    this.fcmToken,
    this.favoriteDestinations = const [],
    this.favoriteAccommodations = const [],
    this.favoriteRestaurants = const [],
    this.preferences,
    this.settingsData,
    this.isActive = true,
    this.isProfileComplete = false,
    this.languageCode = 'en',
    this.countryCode,
    this.currencyCode = 'USD',
    this.name,
    this.profileImageUrl,
    this.memberSince,
    this.travelPoints,
    this.completedTrips,
    this.wishlistedDestinations,
    this.reviewsCount,
    this.badges,
  });

  /// Creates a User object from a JSON map
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Converts the User object to a JSON map
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Creates a new instance with empty data (for anonymous users)
  factory User.anonymous() {
    final uuid = const Uuid().v4();
    return User(
      id: uuid,
      email: '$uuid@anonymous.user',
      displayName: 'Guest User',
      isEmailVerified: false,
      authProvider: AuthProvider.email,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      name: 'Guest User',
      profileImageUrl: '',
      memberSince: DateTime.now(),
      travelPoints: 0,
      completedTrips: 0,
      wishlistedDestinations: 0,
      reviewsCount: 0,
      badges: const [],
    );
  }

  /// Creates a copy of this User with the given fields replaced
  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? profilePhotoUrl,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    AuthProvider? authProvider,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? fcmToken,
    List<String>? favoriteDestinations,
    List<String>? favoriteAccommodations,
    List<String>? favoriteRestaurants,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? settingsData,
    bool? isActive,
    bool? isProfileComplete,
    String? languageCode,
    String? countryCode,
    String? currencyCode,
    String? name,
    String? profileImageUrl,
    DateTime? memberSince,
    int? travelPoints,
    int? completedTrips,
    int? wishlistedDestinations,
    int? reviewsCount,
    List<UserBadge>? badges,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      authProvider: authProvider ?? this.authProvider,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      fcmToken: fcmToken ?? this.fcmToken,
      favoriteDestinations: favoriteDestinations ?? this.favoriteDestinations,
      favoriteAccommodations:
          favoriteAccommodations ?? this.favoriteAccommodations,
      favoriteRestaurants: favoriteRestaurants ?? this.favoriteRestaurants,
      preferences: preferences ?? this.preferences,
      settingsData: settingsData ?? this.settingsData,
      isActive: isActive ?? this.isActive,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      memberSince: memberSince ?? this.memberSince,
      travelPoints: travelPoints ?? this.travelPoints,
      completedTrips: completedTrips ?? this.completedTrips,
      wishlistedDestinations:
          wishlistedDestinations ?? this.wishlistedDestinations,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      badges: badges ?? this.badges,
    );
  }

  /// Check if the user has favorited a destination
  bool hasFavoritedDestination(String destinationId) {
    return favoriteDestinations.contains(destinationId);
  }

  /// Check if the user has favorited an accommodation
  bool hasFavoritedAccommodation(String accommodationId) {
    return favoriteAccommodations.contains(accommodationId);
  }

  /// Check if the user has favorited a restaurant
  bool hasFavoritedRestaurant(String restaurantId) {
    return favoriteRestaurants.contains(restaurantId);
  }

  /// Get user's initials for avatar fallback
  String get initials {
    if (displayName!.isEmpty) return '';

    final nameParts = displayName!.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else if (nameParts.length == 1 && nameParts.first.isNotEmpty) {
      return nameParts.first[0].toUpperCase();
    }

    return '';
  }

  /// Check if the user is an admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if the user is a local guide
  bool get isLocalGuide => role == UserRole.localGuide;

  /// Check if the user is a business owner
  bool get isBusinessOwner => role == UserRole.businessOwner;

  /// Check if user is logged in anonymously
  bool get isAnonymous => email.endsWith('@anonymous.user');

  @override
  List<Object?> get props => [
        id,
        email,
        phoneNumber,
        displayName,
        profilePhotoUrl,
        isEmailVerified,
        isPhoneVerified,
        authProvider,
        role,
        createdAt,
        lastLoginAt,
        fcmToken,
        favoriteDestinations,
        favoriteAccommodations,
        favoriteRestaurants,
        preferences,
        settingsData,
        isActive,
        isProfileComplete,
        languageCode,
        countryCode,
        currencyCode,
        name,
        profileImageUrl,
        memberSince,
        travelPoints,
        completedTrips,
        wishlistedDestinations,
        reviewsCount,
        badges,
      ];

  @override
  String toString() =>
      'User(id: $id, name: $displayName, email: $email, role: $role)';
}

/// User Profile model with additional profile information
@JsonSerializable()
class UserProfile extends Equatable {
  final String userId;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? nationality;
  final String? passportNumber;
  final List<String>? languages;
  final Map<String, dynamic>? emergencyContact;
  final List<String>? interests;
  final Map<String, dynamic>? travelPreferences;
  final List<UserAddress>? addresses;
  final Map<String, dynamic>? socialProfiles;
  final int reviewCount;
  final double averageRating;
  final Map<String, int>? travelStats;
  final int completedTrips;
  final List<UserBadge>? badges;

  const UserProfile({
    required this.userId,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.passportNumber,
    this.languages,
    this.emergencyContact,
    this.interests,
    this.travelPreferences,
    this.addresses,
    this.socialProfiles,
    this.reviewCount = 0,
    this.averageRating = 0.0,
    this.travelStats,
    this.completedTrips = 0,
    this.badges,
  });

  /// Creates a UserProfile object from a JSON map
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  /// Converts the UserProfile object to a JSON map
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  /// Creates a copy of this UserProfile with the given fields replaced
  UserProfile copyWith({
    String? userId,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    String? nationality,
    String? passportNumber,
    List<String>? languages,
    Map<String, dynamic>? emergencyContact,
    List<String>? interests,
    Map<String, dynamic>? travelPreferences,
    List<UserAddress>? addresses,
    Map<String, dynamic>? socialProfiles,
    int? reviewCount,
    double? averageRating,
    Map<String, int>? travelStats,
    int? completedTrips,
    List<UserBadge>? badges,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      passportNumber: passportNumber ?? this.passportNumber,
      languages: languages ?? this.languages,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      interests: interests ?? this.interests,
      travelPreferences: travelPreferences ?? this.travelPreferences,
      addresses: addresses ?? this.addresses,
      socialProfiles: socialProfiles ?? this.socialProfiles,
      reviewCount: reviewCount ?? this.reviewCount,
      averageRating: averageRating ?? this.averageRating,
      travelStats: travelStats ?? this.travelStats,
      completedTrips: completedTrips ?? this.completedTrips,
      badges: badges ?? this.badges,
    );
  }

  /// Check if profile has basic info completed
  bool get hasBasicInfoCompleted {
    return bio != null &&
        dateOfBirth != null &&
        gender != null &&
        nationality != null &&
        (languages?.isNotEmpty ?? false);
  }

  /// Get age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;

    final today = DateTime.now();
    final birthDate = dateOfBirth!;
    int age = today.year - birthDate.year;

    final currentMonth = today.month;
    final birthMonth = birthDate.month;

    if (birthMonth > currentMonth) {
      age--;
    } else if (currentMonth == birthMonth) {
      final currentDay = today.day;
      final birthDay = birthDate.day;
      if (birthDay > currentDay) {
        age--;
      }
    }

    return age;
  }

  @override
  List<Object?> get props => [
        userId,
        bio,
        dateOfBirth,
        gender,
        nationality,
        passportNumber,
        languages,
        emergencyContact,
        interests,
        travelPreferences,
        addresses,
        socialProfiles,
        reviewCount,
        averageRating,
        travelStats,
        completedTrips,
        badges,
      ];
}

/// User Address model
@JsonSerializable()
class UserAddress extends Equatable {
  final String id;
  final String label; // e.g., "Home", "Work", etc.
  final String street;
  final String? unit;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const UserAddress({
    required this.id,
    required this.label,
    required this.street,
    this.unit,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  /// Creates a UserAddress object from a JSON map
  factory UserAddress.fromJson(Map<String, dynamic> json) =>
      _$UserAddressFromJson(json);

  /// Converts the UserAddress object to a JSON map
  Map<String, dynamic> toJson() => _$UserAddressToJson(this);

  /// Creates a copy of this UserAddress with the given fields replaced
  UserAddress copyWith({
    String? id,
    String? label,
    String? street,
    String? unit,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      unit: unit ?? this.unit,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Get formatted address
  String get formattedAddress {
    final unitStr = unit != null ? ' $unit,' : '';
    return '$street,$unitStr\n$city, $state $postalCode\n$country';
  }

  @override
  List<Object?> get props => [
        id,
        label,
        street,
        unit,
        city,
        state,
        postalCode,
        country,
        latitude,
        longitude,
        isDefault,
      ];
}

/// User Badge model
@JsonSerializable()
class UserBadge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final DateTime awardedAt;
  final String category; // e.g., "Explorer", "Adventurer", etc.
  final int level;
  final Map<String, dynamic>? criteria;

  const UserBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.awardedAt,
    required this.category,
    this.level = 1,
    this.criteria,
  });

  /// Creates a UserBadge object from a JSON map
  factory UserBadge.fromJson(Map<String, dynamic> json) =>
      _$UserBadgeFromJson(json);

  /// Converts the UserBadge object to a JSON map
  Map<String, dynamic> toJson() => _$UserBadgeToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        awardedAt,
        category,
        level,
        criteria,
      ];
}
