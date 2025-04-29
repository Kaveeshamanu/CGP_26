import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:taprobana_trails/data/models/review.dart';
import 'package:taprobana_trails/data/models/room.dart';

part 'accommodation.g.dart';

/// Accommodation model for storing hotel, resort, hostel, etc. data.
@JsonSerializable()
class Accommodation extends Equatable {
  /// The unique identifier of the accommodation.
  final String id;
  
  /// The name of the accommodation.
  final String name;
  
  /// The description of the accommodation.
  final String description;
  
  /// The location of the accommodation.
  final String location;
  
  /// The destination ID where the accommodation is located.
  final String destinationId;
  
  /// The accommodation type (hotel, resort, hostel, etc.).
  final String type;
  
  /// The accommodation category (standard, deluxe, luxury, etc.).
  final String category;
  
  /// The price range of the accommodation (e.g., LKR 5000-10000).
  final String priceRange;
  
  /// The minimum price per night.
  final double minPrice;
  
  /// The maximum price per night.
  final double maxPrice;
  
  /// The star rating of the accommodation (1-5).
  final double starRating;
  
  /// The user rating of the accommodation (0-5).
  final double rating;
  
  /// The number of reviews for the accommodation.
  final int reviewCount;
  
  /// The list of amenities provided by the accommodation.
  final List<String> amenities;
  
  /// The main image URL of the accommodation.
  final String imageUrl;
  
  /// The gallery images of the accommodation.
  final List<String> galleryImages;
  
  /// The latitude of the accommodation.
  final double latitude;
  
  /// The longitude of the accommodation.
  final double longitude;
  
  /// The address of the accommodation.
  final String address;
  
  /// The phone number of the accommodation.
  final String? phoneNumber;
  
  /// The email of the accommodation.
  final String? email;
  
  /// The website of the accommodation.
  final String? website;
  
  /// The check-in time of the accommodation.
  final String checkInTime;
  
  /// The check-out time of the accommodation.
  final String checkOutTime;
  
  /// Whether the accommodation is saved by the user.
  final bool isSaved;
  
  /// Whether the accommodation is featured.
  final bool isFeatured;
  
  /// Whether the accommodation has a special deal.
  final bool hasSpecialDeal;
  
  /// The special deal details if available.
  final Map<String, dynamic>? dealDetails;
  
  /// The list of room types available at the accommodation.
  final List<Room>? rooms;
  
  /// The list of reviews for the accommodation.
  final List<Review>? reviews;
  
  /// The facilities of the accommodation.
  final Map<String, List<String>>? facilities;
  
  /// The policies of the accommodation.
  final Map<String, String>? policies;
  
  /// The languages spoken at the accommodation.
  final List<String>? languages;
  
  /// The payment methods accepted by the accommodation.
  final List<String>? paymentMethods;
  
  /// The distance from city center.
  final double? distanceFromCenter;
  
  /// The distance from nearest airport.
  final double? distanceFromAirport;
  
  /// The available meal plans.
  final List<String>? mealPlans;
  
  /// The sustainability practices of the accommodation.
  final List<String>? sustainabilityPractices;
  
  /// The accessibility features of the accommodation.
  final List<String>? accessibilityFeatures;
  
  /// Whether the accommodation is family-friendly.
  final bool? isFamilyFriendly;
  
  /// Whether the accommodation is pet-friendly.
  final bool? isPetFriendly;
  
  /// The parking availability at the accommodation.
  final String? parking;
  
  /// Creates a new Accommodation.
  const Accommodation({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.destinationId,
    required this.type,
    required this.category,
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.starRating,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
    required this.imageUrl,
    required this.galleryImages,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.phoneNumber,
    this.email,
    this.website,
    required this.checkInTime,
    required this.checkOutTime,
    this.isSaved = false,
    this.isFeatured = false,
    this.hasSpecialDeal = false,
    this.dealDetails,
    this.rooms,
    this.reviews,
    this.facilities,
    this.policies,
    this.languages,
    this.paymentMethods,
    this.distanceFromCenter,
    this.distanceFromAirport,
    this.mealPlans,
    this.sustainabilityPractices,
    this.accessibilityFeatures,
    this.isFamilyFriendly,
    this.isPetFriendly,
    this.parking,
  });
  
  /// Factory constructor that creates an [Accommodation] from JSON.
  factory Accommodation.fromJson(Map<String, dynamic> json) => _$AccommodationFromJson(json);
  
  /// Converts this [Accommodation] to JSON.
  Map<String, dynamic> toJson() => _$AccommodationToJson(this);
  
  /// Creates a copy of this [Accommodation] with the given fields replaced with new values.
  Accommodation copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    String? destinationId,
    String? type,
    String? category,
    String? priceRange,
    double? minPrice,
    double? maxPrice,
    double? starRating,
    double? rating,
    int? reviewCount,
    List<String>? amenities,
    String? imageUrl,
    List<String>? galleryImages,
    double? latitude,
    double? longitude,
    String? address,
    String? phoneNumber,
    String? email,
    String? website,
    String? checkInTime,
    String? checkOutTime,
    bool? isSaved,
    bool? isFeatured,
    bool? hasSpecialDeal,
    Map<String, dynamic>? dealDetails,
    List<Room>? rooms,
    List<Review>? reviews,
    Map<String, List<String>>? facilities,
    Map<String, String>? policies,
    List<String>? languages,
    List<String>? paymentMethods,
    double? distanceFromCenter,
    double? distanceFromAirport,
    List<String>? mealPlans,
    List<String>? sustainabilityPractices,
    List<String>? accessibilityFeatures,
    bool? isFamilyFriendly,
    bool? isPetFriendly,
    String? parking,
  }) {
    return Accommodation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      destinationId: destinationId ?? this.destinationId,
      type: type ?? this.type,
      category: category ?? this.category,
      priceRange: priceRange ?? this.priceRange,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      starRating: starRating ?? this.starRating,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      amenities: amenities ?? this.amenities,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isSaved: isSaved ?? this.isSaved,
      isFeatured: isFeatured ?? this.isFeatured,
      hasSpecialDeal: hasSpecialDeal ?? this.hasSpecialDeal,
      dealDetails: dealDetails ?? this.dealDetails,
      rooms: rooms ?? this.rooms,
      reviews: reviews ?? this.reviews,
      facilities: facilities ?? this.facilities,
      policies: policies ?? this.policies,
      languages: languages ?? this.languages,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      distanceFromCenter: distanceFromCenter ?? this.distanceFromCenter,
      distanceFromAirport: distanceFromAirport ?? this.distanceFromAirport,
      mealPlans: mealPlans ?? this.mealPlans,
      sustainabilityPractices: sustainabilityPractices ?? this.sustainabilityPractices,
      accessibilityFeatures: accessibilityFeatures ?? this.accessibilityFeatures,
      isFamilyFriendly: isFamilyFriendly ?? this.isFamilyFriendly,
      isPetFriendly: isPetFriendly ?? this.isPetFriendly,
      parking: parking ?? this.parking,
    );
  }
  
  /// Gets the formatted star rating with stars.
  String get formattedStarRating {
    final fullStars = starRating.floor();
    return '${'★' * fullStars}${starRating - fullStars >= 0.5 ? '½' : ''}';
  }
  
  /// Gets the formatted user rating with the number of reviews.
  String get formattedRating {
    return '$rating (${reviewCount.toString()})';
  }
  
  /// Gets the primary amenities (up to 5).
  List<String> get primaryAmenities {
    return amenities.length > 5 ? amenities.sublist(0, 5) : amenities;
  }
  
  /// Gets the accommodation icon based on type.
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'hotel':
        return 'hotel';
      case 'resort':
        return 'beach_access';
      case 'hostel':
        return 'bunk_bed';
      case 'guesthouse':
        return 'house';
      case 'villa':
        return 'villa';
      case 'apartment':
        return 'apartment';
      case 'homestay':
        return 'home';
      case 'bungalow':
        return 'cabin';
      default:
        return 'location_city';
    }
  }
  
  /// Gets the accommodation's price level.
  int get priceLevel {
    if (minPrice < 5000) {
      return 1; // Budget
    } else if (minPrice < 10000) {
      return 2; // Economy
    } else if (minPrice < 15000) {
      return 3; // Mid-range
    } else if (minPrice < 25000) {
      return 4; // Luxury
    } else {
      return 5; // Ultra luxury
    }
  }
  
  /// Gets the price level as a string of dollar signs.
  String get priceLevelString {
    return '₨' * priceLevel;
  }
  
  /// Gets whether the accommodation has room availability.
  bool get hasRoomAvailability {
    return rooms != null && rooms!.isNotEmpty;
  }
  
  /// Gets the minimum and maximum price per night in a human-readable format.
  String get formattedPriceRange {
    return 'LKR ${minPrice.toInt()} - ${maxPrice.toInt()} per night';
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
  
  /// Gets the cheapest available room.
  Room? get cheapestRoom {
    if (rooms == null || rooms!.isEmpty) return null;
    
    return rooms!.reduce((a, b) => a.price < b.price ? a : b);
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    location,
    destinationId,
    type,
    category,
    priceRange,
    minPrice,
    maxPrice,
    starRating,
    rating,
    reviewCount,
    amenities,
    imageUrl,
    galleryImages,
    latitude,
    longitude,
    address,
    phoneNumber,
    email,
    website,
    checkInTime,
    checkOutTime,
    isSaved,
    isFeatured,
    hasSpecialDeal,
    dealDetails,
    rooms,
    reviews,
    facilities,
    policies,
    languages,
    paymentMethods,
    distanceFromCenter,
    distanceFromAirport,
    mealPlans,
    sustainabilityPractices,
    accessibilityFeatures,
    isFamilyFriendly,
    isPetFriendly,
    parking,
  ];

  get basePrice => null;

  get maxGuests => null;

  get standardOccupancy => null;

  get extraGuestCharge => null;

  get monthlyDiscount => null;

  get weeklyDiscount => null;

  get cleaningFee => null;

  get serviceFeePercent => null;

  get currencySymbol => null;

  get imageUrls => null;

  get features => null;

  bool get isTopRated => null;

  get hostDescription => null;

  get hostResponseRate => null;

  get hostSince => null;

  get hostName => null;

  get hostPhotoUrl => null;

  get houseRules => null;

  get cancellationPolicy => null;

  get locationDescription => null;

  get transportationOptions => null;
}