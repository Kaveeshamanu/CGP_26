import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

/// Room model for storing accommodation room type information.
@JsonSerializable()
class Room extends Equatable {
  /// The unique identifier of the room.
  final String id;
  
  /// The accommodation ID this room belongs to.
  final String accommodationId;
  
  /// The name of the room type.
  final String name;
  
  /// The description of the room.
  final String description;
  
  /// The price per night for the room.
  final double price;
  
  /// The discounted price (if available).
  final double? discountedPrice;
  
  /// The maximum number of adults allowed.
  final int maxAdults;
  
  /// The maximum number of children allowed.
  final int maxChildren;
  
  /// The total maximum occupancy.
  final int maxOccupancy;
  
  /// The bed configuration (e.g., "1 King Bed", "2 Twin Beds").
  final String bedConfiguration;
  
  /// The size of the room in square meters.
  final double? roomSize;
  
  /// The list of amenities in the room.
  final List<String> amenities;
  
  /// The list of room images.
  final List<String> images;
  
  /// The main image of the room.
  final String mainImage;
  
  /// Whether the room is refundable.
  final bool isRefundable;
  
  /// The cancellation policy of the room.
  final String? cancellationPolicy;
  
  /// The number of rooms available.
  final int quantity;
  
  /// The view type from the room (e.g., "Ocean View", "Garden View").
  final String? viewType;
  
  /// Whether breakfast is included.
  final bool breakfastIncluded;
  
  /// Whether the room has free WiFi.
  final bool freeWifi;
  
  /// Whether the room has free cancellation.
  final bool freeCancellation;
  
  /// The cancellation deadline in hours before check-in.
  final int? cancellationDeadline;
  
  /// The meal plan included (e.g., "Bed & Breakfast", "Half Board").
  final String? mealPlan;
  
  /// Additional room policies.
  final Map<String, String>? policies;
  
  /// The rate plan code (for booking systems).
  final String? ratePlanCode;
  
  /// The room type code (for booking systems).
  final String? roomTypeCode;
  
  /// Creates a new Room.
  const Room({
    required this.id,
    required this.accommodationId,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.maxAdults,
    required this.maxChildren,
    required this.maxOccupancy,
    required this.bedConfiguration,
    this.roomSize,
    required this.amenities,
    required this.images,
    required this.mainImage,
    required this.isRefundable,
    this.cancellationPolicy,
    required this.quantity,
    this.viewType,
    required this.breakfastIncluded,
    required this.freeWifi,
    required this.freeCancellation,
    this.cancellationDeadline,
    this.mealPlan,
    this.policies,
    this.ratePlanCode,
    this.roomTypeCode,
  });
  
  /// Factory constructor that creates a [Room] from JSON.
  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  
  /// Converts this [Room] to JSON.
  Map<String, dynamic> toJson() => _$RoomToJson(this);
  
  /// Creates a copy of this [Room] with the given fields replaced with new values.
  Room copyWith({
    String? id,
    String? accommodationId,
    String? name,
    String? description,
    double? price,
    double? discountedPrice,
    int? maxAdults,
    int? maxChildren,
    int? maxOccupancy,
    String? bedConfiguration,
    double? roomSize,
    List<String>? amenities,
    List<String>? images,
    String? mainImage,
    bool? isRefundable,
    String? cancellationPolicy,
    int? quantity,
    String? viewType,
    bool? breakfastIncluded,
    bool? freeWifi,
    bool? freeCancellation,
    int? cancellationDeadline,
    String? mealPlan,
    Map<String, String>? policies,
    String? ratePlanCode,
    String? roomTypeCode,
  }) {
    return Room(
      id: id ?? this.id,
      accommodationId: accommodationId ?? this.accommodationId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      maxAdults: maxAdults ?? this.maxAdults,
      maxChildren: maxChildren ?? this.maxChildren,
      maxOccupancy: maxOccupancy ?? this.maxOccupancy,
      bedConfiguration: bedConfiguration ?? this.bedConfiguration,
      roomSize: roomSize ?? this.roomSize,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      mainImage: mainImage ?? this.mainImage,
      isRefundable: isRefundable ?? this.isRefundable,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      quantity: quantity ?? this.quantity,
      viewType: viewType ?? this.viewType,
      breakfastIncluded: breakfastIncluded ?? this.breakfastIncluded,
      freeWifi: freeWifi ?? this.freeWifi,
      freeCancellation: freeCancellation ?? this.freeCancellation,
      cancellationDeadline: cancellationDeadline ?? this.cancellationDeadline,
      mealPlan: mealPlan ?? this.mealPlan,
      policies: policies ?? this.policies,
      ratePlanCode: ratePlanCode ?? this.ratePlanCode,
      roomTypeCode: roomTypeCode ?? this.roomTypeCode,
    );
  }
  
  /// Gets the discount percentage if a discounted price is available.
  int? get discountPercentage {
    if (discountedPrice == null || discountedPrice! >= price) {
      return null;
    }
    
    return (((price - discountedPrice!) / price) * 100).round();
  }
  
  /// Gets the display price, which is the discounted price if available, otherwise the regular price.
  double get displayPrice {
    return discountedPrice ?? price;
  }
  
  /// Gets the formatted price as a string.
  String get formattedPrice {
    return 'LKR ${price.toInt()}';
  }
  
  /// Gets the formatted display price as a string.
  String get formattedDisplayPrice {
    return 'LKR ${displayPrice.toInt()}';
  }
  
  /// Gets the occupancy information as a string.
  String get occupancyInfo {
    return '$maxAdults Adult${maxAdults > 1 ? 's' : ''}${maxChildren > 0 ? ', $maxChildren Child${maxChildren > 1 ? 'ren' : ''}' : ''}';
  }
  
  /// Gets the availability status as a string.
  String get availabilityStatus {
    if (quantity <= 0) {
      return 'Sold Out';
    } else if (quantity < 3) {
      return 'Only $quantity left';
    } else {
      return 'Available';
    }
  }
  
  /// Gets whether the room has a discount.
  bool get hasDiscount {
    return discountedPrice != null && discountedPrice! < price;
  }
  
  /// Gets the room size as a formatted string.
  String? get formattedRoomSize {
    if (roomSize == null) return null;
    return '$roomSize m²';
  }
  
  /// Gets a brief list of amenities (up to 3).
  List<String> get briefAmenities {
    return amenities.length > 3 ? amenities.sublist(0, 3) : amenities;
  }
  
  /// Gets a brief description (first 100 characters).
  String get briefDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 97)}...';
  }
  
  @override
  List<Object?> get props => [
    id,
    accommodationId,
    name,
    description,
    price,
    discountedPrice,
    maxAdults,
    maxChildren,
    maxOccupancy,
    bedConfiguration,
    roomSize,
    amenities,
    images,
    mainImage,
    isRefundable,
    cancellationPolicy,
    quantity,
    viewType,
    breakfastIncluded,
    freeWifi,
    freeCancellation,
    cancellationDeadline,
    mealPlan,
    policies,
    ratePlanCode,
    roomTypeCode,
  ];
}