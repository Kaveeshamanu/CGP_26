import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:taprobana_trails/data/models/review.dart';

part 'restaurant.g.dart';

/// Restaurant model for storing restaurant and dining information.
@JsonSerializable()
class Restaurant extends Equatable {
  /// The unique identifier of the restaurant.
  final String id;

  /// The name of the restaurant.
  final String name;

  /// The description of the restaurant.
  final String description;

  /// The location of the restaurant.
  final String location;

  /// The destination ID where the restaurant is located.
  final String destinationId;

  /// The cuisine type of the restaurant.
  final String cuisine;

  /// The restaurant category (casual, fine dining, etc.).
  final String category;

  /// The price range of the restaurant.
  final String priceRange;

  /// The user rating of the restaurant (0-5).
  final double rating;

  /// The number of reviews for the restaurant.
  final int reviewCount;

  /// The main image URL of the restaurant.
  final String imageUrl;

  /// The gallery images of the restaurant.
  final List<String> galleryImages;

  /// The menu images or links of the restaurant.
  final List<String>? menuImages;

  /// The menu URL of the restaurant.
  final String? menuUrl;

  /// The address of the restaurant.
  final String address;

  /// The latitude of the restaurant.
  final double latitude;

  /// The longitude of the restaurant.
  final double longitude;

  /// The phone number of the restaurant.
  final String? phoneNumber;

  /// The email of the restaurant.
  final String? email;

  /// The website of the restaurant.
  final String? website;

  /// The opening hours of the restaurant.
  final Map<String, String> openingHours;

  /// Whether the restaurant is saved by the user.
  final bool isSaved;

  /// Whether the restaurant is featured.
  final bool isFeatured;

  /// Whether the restaurant has a special deal.
  final bool hasSpecialDeal;

  /// The special deal details if available.
  final Map<String, dynamic>? dealDetails;

  /// The list of reviews for the restaurant.
  final List<Review>? reviews;

  /// The facilities of the restaurant.
  final List<String> facilities;

  /// Whether the restaurant accepts reservations.
  final bool acceptsReservations;

  /// Whether the restaurant has outdoor seating.
  final bool hasOutdoorSeating;

  /// Whether the restaurant offers delivery.
  final bool offersDelivery;

  /// Whether the restaurant offers takeaway.
  final bool offersTakeaway;

  /// The popular dishes of the restaurant.
  final List<String>? popularDishes;

  /// The dietary options available at the restaurant.
  final List<String>? dietaryOptions;

  /// The distance from city center.
  final double? distanceFromCenter;

  /// The parking availability at the restaurant.
  final String? parking;

  /// Whether the restaurant is kid-friendly.
  final bool? isKidFriendly;

  /// Whether the restaurant serves alcohol.
  final bool? servesAlcohol;

  /// The payment methods accepted by the restaurant.
  final List<String>? paymentMethods;

  /// The dress code of the restaurant.
  final String? dressCode;

  /// Whether the restaurant requires reservations.
  final bool? requiresReservation;

  /// The average wait time without reservation.
  final String? averageWaitTime;

  /// The noise level of the restaurant.
  final String? noiseLevel;

  /// Whether the restaurant offers happy hour.
  final bool? hasHappyHour;

  /// The happy hour details if available.
  final Map<String, dynamic>? happyHourDetails;

  /// The chef's name of the restaurant.
  final String? chefName;

  /// The menu highlights of the restaurant.
  final List<Map<String, dynamic>>? menuHighlights;

  /// Creates a new Restaurant.
  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.destinationId,
    required this.cuisine,
    required this.category,
    required this.priceRange,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.galleryImages,
    this.menuImages,
    this.menuUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.email,
    this.website,
    required this.openingHours,
    this.isSaved = false,
    this.isFeatured = false,
    this.hasSpecialDeal = false,
    this.dealDetails,
    this.reviews,
    required this.facilities,
    required this.acceptsReservations,
    required this.hasOutdoorSeating,
    required this.offersDelivery,
    required this.offersTakeaway,
    this.popularDishes,
    this.dietaryOptions,
    this.distanceFromCenter,
    this.parking,
    this.isKidFriendly,
    this.servesAlcohol,
    this.paymentMethods,
    this.dressCode,
    this.requiresReservation,
    this.averageWaitTime,
    this.noiseLevel,
    this.hasHappyHour,
    this.happyHourDetails,
    this.chefName,
    this.menuHighlights,
  });

  /// Factory constructor that creates a [Restaurant] from JSON.
  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);

  /// Converts this [Restaurant] to JSON.
  Map<String, dynamic> toJson() => _$RestaurantToJson(this);

  /// Creates a copy of this [Restaurant] with the given fields replaced with new values.
  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    String? destinationId,
    String? cuisine,
    String? category,
    String? priceRange,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    List<String>? galleryImages,
    List<String>? menuImages,
    String? menuUrl,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? email,
    String? website,
    Map<String, String>? openingHours,
    bool? isSaved,
    bool? isFeatured,
    bool? hasSpecialDeal,
    Map<String, dynamic>? dealDetails,
    List<Review>? reviews,
    List<String>? facilities,
    bool? acceptsReservations,
    bool? hasOutdoorSeating,
    bool? offersDelivery,
    bool? offersTakeaway,
    List<String>? popularDishes,
    List<String>? dietaryOptions,
    double? distanceFromCenter,
    String? parking,
    bool? isKidFriendly,
    bool? servesAlcohol,
    List<String>? paymentMethods,
    String? dressCode,
    bool? requiresReservation,
    String? averageWaitTime,
    String? noiseLevel,
    bool? hasHappyHour,
    Map<String, dynamic>? happyHourDetails,
    String? chefName,
    List<Map<String, dynamic>>? menuHighlights,
    required bool isFavorite,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      destinationId: destinationId ?? this.destinationId,
      cuisine: cuisine ?? this.cuisine,
      category: category ?? this.category,
      priceRange: priceRange ?? this.priceRange,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      menuImages: menuImages ?? this.menuImages,
      menuUrl: menuUrl ?? this.menuUrl,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      isSaved: isSaved ?? this.isSaved,
      isFeatured: isFeatured ?? this.isFeatured,
      hasSpecialDeal: hasSpecialDeal ?? this.hasSpecialDeal,
      dealDetails: dealDetails ?? this.dealDetails,
      reviews: reviews ?? this.reviews,
      facilities: facilities ?? this.facilities,
      acceptsReservations: acceptsReservations ?? this.acceptsReservations,
      hasOutdoorSeating: hasOutdoorSeating ?? this.hasOutdoorSeating,
      offersDelivery: offersDelivery ?? this.offersDelivery,
      offersTakeaway: offersTakeaway ?? this.offersTakeaway,
      popularDishes: popularDishes ?? this.popularDishes,
      dietaryOptions: dietaryOptions ?? this.dietaryOptions,
      distanceFromCenter: distanceFromCenter ?? this.distanceFromCenter,
      parking: parking ?? this.parking,
      isKidFriendly: isKidFriendly ?? this.isKidFriendly,
      servesAlcohol: servesAlcohol ?? this.servesAlcohol,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      dressCode: dressCode ?? this.dressCode,
      requiresReservation: requiresReservation ?? this.requiresReservation,
      averageWaitTime: averageWaitTime ?? this.averageWaitTime,
      noiseLevel: noiseLevel ?? this.noiseLevel,
      hasHappyHour: hasHappyHour ?? this.hasHappyHour,
      happyHourDetails: happyHourDetails ?? this.happyHourDetails,
      chefName: chefName ?? this.chefName,
      menuHighlights: menuHighlights ?? this.menuHighlights,
    );
  }

  /// Gets the formatted rating with the number of reviews.
  String get formattedRating {
    return '$rating (${reviewCount.toString()})';
  }

  /// Gets the rating as stars.
  String get ratingAsStars {
    final fullStars = rating.floor();
    final halfStar = rating - fullStars >= 0.5;
    final emptyStars = 5 - fullStars - (halfStar ? 1 : 0);

    return '${'★' * fullStars}${halfStar ? '½' : ''}${'☆' * emptyStars}';
  }

  /// Gets the cuisine icon.
  String get cuisineIcon {
    switch (cuisine.toLowerCase()) {
      case 'sri lankan':
        return 'rice_bowl';
      case 'indian':
        return 'restaurant';
      case 'chinese':
        return 'ramen_dining';
      case 'italian':
        return 'local_pizza';
      case 'seafood':
        return 'set_meal';
      case 'vegetarian':
      case 'vegan':
        return 'grass';
      case 'western':
        return 'lunch_dining';
      case 'asian':
        return 'soup_kitchen';
      case 'fast food':
        return 'fastfood';
      case 'cafe':
        return 'coffee';
      case 'bbq':
        return 'outdoor_grill';
      case 'dessert':
        return 'icecream';
      default:
        return 'restaurant_menu';
    }
  }

  /// Gets the price level as a string of dollar signs.
  String get priceLevelString {
    final priceLevel = getPriceLevel();
    return '₨' * priceLevel;
  }

  /// Gets the price level.
  int getPriceLevel() {
    switch (priceRange.toLowerCase()) {
      case 'budget':
        return 1;
      case 'mid-range':
        return 2;
      case 'upscale':
        return 3;
      case 'fine dining':
        return 4;
      default:
        // Try to parse from 'LKR 1000-2000' format
        try {
          final parts = priceRange.split('-');
          if (parts.length == 2) {
            final maxPrice =
                double.parse(parts[1].replaceAll(RegExp(r'[^0-9.]'), ''));

            if (maxPrice < 1000) return 1;
            if (maxPrice < 3000) return 2;
            if (maxPrice < 5000) return 3;
            return 4;
          }
        } catch (_) {
          // Ignore parsing errors
        }

        return 2; // Default to mid-range
    }
  }

  /// Gets whether the restaurant is open now.
  bool get isOpenNow {
    final now = DateTime.now();
    final todayWeekday = _getWeekdayName(now.weekday);

    if (!openingHours.containsKey(todayWeekday)) {
      return false;
    }

    final todayHours = openingHours[todayWeekday]!;

    // Check if closed today
    if (todayHours.toLowerCase() == 'closed') {
      return false;
    }

    // Parse opening hours (e.g., "10:00 AM - 10:00 PM")
    try {
      final parts = todayHours.split('-');
      if (parts.length != 2) {
        return false;
      }

      final openingTime = _parseTime(parts[0].trim());
      final closingTime = _parseTime(parts[1].trim());

      if (openingTime == null || closingTime == null) {
        return false;
      }

      final currentTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );

      return currentTime.isAfter(openingTime) &&
          currentTime.isBefore(closingTime);
    } catch (_) {
      return false;
    }
  }

  /// Gets the opening status as a string.
  String get openingStatus {
    if (isOpenNow) {
      return 'Open Now';
    }

    final now = DateTime.now();
    final todayWeekday = _getWeekdayName(now.weekday);

    if (!openingHours.containsKey(todayWeekday)) {
      return 'Hours Not Available';
    }

    final todayHours = openingHours[todayWeekday]!;

    // Check if closed today
    if (todayHours.toLowerCase() == 'closed') {
      return 'Closed Today';
    }

    // Parse opening hours (e.g., "10:00 AM - 10:00 PM")
    try {
      final parts = todayHours.split('-');
      if (parts.length != 2) {
        return 'Hours Not Available';
      }

      final openingTime = _parseTime(parts[0].trim());
      final closingTime = _parseTime(parts[1].trim());

      if (openingTime == null || closingTime == null) {
        return 'Hours Not Available';
      }

      final currentTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );

      if (currentTime.isBefore(openingTime)) {
        final openingHour = openingTime.hour;
        final openingMinute = openingTime.minute;
        final openingPeriod = openingHour >= 12 ? 'PM' : 'AM';
        final displayHour = openingHour > 12
            ? openingHour - 12
            : (openingHour == 0 ? 12 : openingHour);

        return 'Opens at $displayHour:${openingMinute.toString().padLeft(2, '0')} $openingPeriod';
      } else {
        return 'Closed Now';
      }
    } catch (_) {
      return 'Hours Not Available';
    }
  }

  /// Helper method to get the weekday name.
  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  /// Helper method to parse time strings.
  DateTime? _parseTime(String timeString) {
    try {
      final now = DateTime.now();

      // Standard format like "10:00 AM"
      final regExp = RegExp(r'(\d+):(\d+)\s*(AM|PM)?', caseSensitive: false);
      final match = regExp.firstMatch(timeString);

      if (match != null) {
        var hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        final period = match.group(3)?.toUpperCase();

        if (period == 'PM' && hour < 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }

        return DateTime(now.year, now.month, now.day, hour, minute);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Gets the distance from city center as a string.
  String? get formattedDistanceFromCenter {
    if (distanceFromCenter == null) return null;

    if (distanceFromCenter! < 1.0) {
      return '${(distanceFromCenter! * 1000).toInt()} m from center';
    } else {
      return '${distanceFromCenter!.toStringAsFixed(1)} km from center';
    }
  }

  /// Gets the primary facilities (up to 5).
  List<String> get primaryFacilities {
    return facilities.length > 5 ? facilities.sublist(0, 5) : facilities;
  }

  /// Gets the today's opening hours.
  String get todayOpeningHours {
    final now = DateTime.now();
    final todayWeekday = _getWeekdayName(now.weekday);

    if (!openingHours.containsKey(todayWeekday)) {
      return 'Hours not available';
    }

    return '$todayWeekday: ${openingHours[todayWeekday]}';
  }

  /// Gets whether the restaurant has menu information.
  bool get hasMenuInfo {
    return (menuImages != null && menuImages!.isNotEmpty) || menuUrl != null;
  }

  /// Gets whether the restaurant has popular dishes information.
  bool get hasPopularDishes {
    return popularDishes != null && popularDishes!.isNotEmpty;
  }

  /// Gets whether the restaurant has dietary options information.
  bool get hasDietaryOptions {
    return dietaryOptions != null && dietaryOptions!.isNotEmpty;
  }

  /// Gets a brief description (first 100 characters).
  String get briefDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 97)}...';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        location,
        destinationId,
        cuisine,
        category,
        priceRange,
        rating,
        reviewCount,
        imageUrl,
        galleryImages,
        menuImages,
        menuUrl,
        address,
        latitude,
        longitude,
        phoneNumber,
        email,
        website,
        openingHours,
        isSaved,
        isFeatured,
        hasSpecialDeal,
        dealDetails,
        reviews,
        facilities,
        acceptsReservations,
        hasOutdoorSeating,
        offersDelivery,
        offersTakeaway,
        popularDishes,
        dietaryOptions,
        distanceFromCenter,
        parking,
        isKidFriendly,
        servesAlcohol,
        paymentMethods,
        dressCode,
        requiresReservation,
        averageWaitTime,
        noiseLevel,
        hasHappyHour,
        happyHourDetails,
        chefName,
        menuHighlights,
      ];

  get cuisineTypes => null;

  get priceLevel => null;

  get maxCapacity => null;

  get operatingHours => null;

  get images => null;

  bool? get isFavorite => null;
}
