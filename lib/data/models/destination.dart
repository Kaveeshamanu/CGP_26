import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'destination.g.dart';

/// Destination model for storing places to visit.
@JsonSerializable()
class Destination extends Equatable {
  /// The unique identifier of the destination.
  final String id;

  /// The name of the destination.
  final String name;

  /// The description of the destination.
  final String description;

  /// The location of the destination.
  final String location;

  /// The category of the destination.
  final String category;

  /// The tags associated with the destination.
  final List<String> tags;

  /// The rating of the destination (out of 5).
  final double rating;

  /// The number of reviews for the destination.
  final int reviewCount;

  /// The main image URL of the destination.
  final String imageUrl;

  /// The gallery images of the destination.
  final List<String> galleryImages;

  /// The latitude of the destination.
  final double latitude;

  /// The longitude of the destination.
  final double longitude;

  /// Whether the destination is saved by the user.
  final bool isSaved;

  /// Whether the destination is trending.
  final bool isTrending;

  /// The estimated budget for the destination (per day per person).
  final double? estimatedBudget;

  /// The best time to visit the destination.
  final String? bestTimeToVisit;

  /// The duration of stay recommendation (in days).
  final String? recommendedDuration;

  /// The list of nearby attractions.
  final List<String>? nearbyAttractions;

  /// The transport options to reach the destination.
  final Map<String, dynamic>? transportOptions;

  /// The accommodation options at the destination.
  final Map<String, dynamic>? accommodationOptions;

  /// Additional information about the destination.
  final Map<String, dynamic>? additionalInfo;

  /// Cultural information
  final String languageInfo;
  final String religionInfo;
  final List<String> culturalImages;
  final String artsCraftsInfo;
  final List<Map<String, String>> traditionalArts;
  final String cuisineInfo;
  final List<Map<String, String>> popularDishes;
  final List<Map<String, String>> festivals;
  final String culturalOverview;
  final List<String> customs;

  // Optional fields for UI states
  final bool isBookmarked;
  final bool isFavorite;

  /// Creates a new Destination.
  const Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.category,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.galleryImages,
    required this.latitude,
    required this.longitude,
    this.isSaved = false,
    this.isTrending = false,
    this.estimatedBudget,
    this.bestTimeToVisit,
    this.recommendedDuration,
    this.nearbyAttractions,
    this.transportOptions,
    this.accommodationOptions,
    this.additionalInfo,
    required this.languageInfo,
    required this.religionInfo,
    required this.culturalImages,
    required this.artsCraftsInfo,
    required this.traditionalArts,
    required this.cuisineInfo,
    required this.popularDishes,
    required this.festivals,
    required this.culturalOverview,
    required this.customs,
    this.isBookmarked = false,
    this.isFavorite = false,
  });

  /// Factory constructor that creates a [Destination] from JSON.
  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);

  /// Converts this [Destination] to JSON.
  Map<String, dynamic> toJson() => _$DestinationToJson(this);

  /// Creates a copy of this [Destination] with the given fields replaced with new values.
  Destination copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    String? category,
    List<String>? tags,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    List<String>? galleryImages,
    double? latitude,
    double? longitude,
    bool? isSaved,
    bool? isTrending,
    double? estimatedBudget,
    String? bestTimeToVisit,
    String? recommendedDuration,
    List<String>? nearbyAttractions,
    Map<String, dynamic>? transportOptions,
    Map<String, dynamic>? accommodationOptions,
    Map<String, dynamic>? additionalInfo,
    String? languageInfo,
    String? religionInfo,
    List<String>? culturalImages,
    String? artsCraftsInfo,
    List<Map<String, String>>? traditionalArts,
    String? cuisineInfo,
    List<Map<String, String>>? popularDishes,
    List<Map<String, String>>? festivals,
    String? culturalOverview,
    List<String>? customs,
    bool? isBookmarked,
    bool? isFavorite,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSaved: isSaved ?? this.isSaved,
      isTrending: isTrending ?? this.isTrending,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      bestTimeToVisit: bestTimeToVisit ?? this.bestTimeToVisit,
      recommendedDuration: recommendedDuration ?? this.recommendedDuration,
      nearbyAttractions: nearbyAttractions ?? this.nearbyAttractions,
      transportOptions: transportOptions ?? this.transportOptions,
      accommodationOptions: accommodationOptions ?? this.accommodationOptions,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      languageInfo: languageInfo ?? this.languageInfo,
      religionInfo: religionInfo ?? this.religionInfo,
      culturalImages: culturalImages ?? this.culturalImages,
      artsCraftsInfo: artsCraftsInfo ?? this.artsCraftsInfo,
      traditionalArts: traditionalArts ?? this.traditionalArts,
      cuisineInfo: cuisineInfo ?? this.cuisineInfo,
      popularDishes: popularDishes ?? this.popularDishes,
      festivals: festivals ?? this.festivals,
      culturalOverview: culturalOverview ?? this.culturalOverview,
      customs: customs ?? this.customs,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Gets the category icon.
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'beach':
        return 'beach_access';
      case 'heritage':
        return 'account_balance';
      case 'wildlife':
        return 'pets';
      case 'mountain':
        return 'landscape';
      case 'city':
        return 'location_city';
      case 'temple':
        return 'temple_buddhist';
      case 'waterfall':
        return 'water';
      case 'adventure':
        return 'hiking';
      default:
        return 'place';
    }
  }

  /// Gets the formatted rating with the number of reviews.
  String get formattedRating {
    return '$rating (${reviewCount.toString()})';
  }

  /// Gets the estimated budget range as a string.
  String get budgetRange {
    if (estimatedBudget == null) return 'Varies';

    final lowerBound = (estimatedBudget! * 0.8).round();
    final upperBound = (estimatedBudget! * 1.2).round();

    return '\$$lowerBound - \$$upperBound';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        location,
        category,
        tags,
        rating,
        reviewCount,
        imageUrl,
        galleryImages,
        latitude,
        longitude,
        isSaved,
        isTrending,
        estimatedBudget,
        bestTimeToVisit,
        recommendedDuration,
        nearbyAttractions,
        transportOptions,
        accommodationOptions,
        additionalInfo,
        languageInfo,
        religionInfo,
        culturalImages,
        artsCraftsInfo,
        traditionalArts,
        cuisineInfo,
        popularDishes,
        festivals,
        culturalOverview,
        customs,
        isBookmarked,
        isFavorite,
      ];

  // Helper getters for the UI
  String get regionName => location.split(',').lastOrNull?.trim() ?? location;

  List<dynamic> get images => [imageUrl, ...galleryImages];

  String get gettingThere =>
      transportOptions?['description'] as String? ??
      'Information not available';

  String get bestTimeDetails => bestTimeToVisit ?? 'Year-round';

  String get localCulture => culturalOverview;

  String get safetyInfo =>
      additionalInfo?['safety'] as String? ??
      'General safety precautions apply';

  List<Map<String, String>> get attractions =>
      nearbyAttractions?.map((name) => {'name': name}).toList() ?? [];

  List<dynamic> get hotels => [];

  List<dynamic> get restaurants => [];

  Map<String, dynamic> get currentWeather =>
      {'temperature': '25°C', 'condition': 'Sunny'};

  String get language => languageInfo;

  String get currency => additionalInfo?['currency'] as String? ?? 'USD';

  String get timezone => additionalInfo?['timezone'] as String? ?? 'GMT+0';

  List<dynamic> get transportHubs => [];

  List<dynamic> get accommodations => [];
}
