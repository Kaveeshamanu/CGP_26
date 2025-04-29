import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'itinerary_item.g.dart';

/// Type of itinerary item.
enum ItineraryItemType {
  accommodation,
  restaurant,
  transport,
  activity,
  sight,
  custom,
}

/// Itinerary item model for storing individual activities, accommodations, etc. in an itinerary.
@JsonSerializable()
class ItineraryItem extends Equatable {
  /// The unique identifier of the item.
  final String id;
  
  /// The title of the item.
  final String title;
  
  /// The description of the item.
  final String? description;
  
  /// The type of the item.
  final ItineraryItemType type;
  
  /// The date of the item.
  final DateTime date;
  
  /// The start time of the item.
  final DateTime? startTime;
  
  /// The end time of the item.
  final DateTime? endTime;
  
  /// The location of the item.
  final String? location;
  
  /// The latitude of the item.
  final double? latitude;
  
  /// The longitude of the item.
  final double? longitude;
  
  /// The cost of the item.
  final double? cost;
  
  /// Whether the item is booked.
  final bool isBooked;
  
  /// The booking reference of the item.
  final String? bookingReference;
  
  /// The booking URL of the item.
  final String? bookingUrl;
  
  /// The notes for the item.
  final String? notes;
  
  /// The reference ID for linked entities (e.g., hotel ID, restaurant ID).
  final String? referenceId;
  
  /// The image URL of the item.
  final String? imageUrl;
  
  /// Creates a new ItineraryItem.
  const ItineraryItem({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.date,
    this.startTime,
    this.endTime,
    this.location,
    this.latitude,
    this.longitude,
    this.cost,
    this.isBooked = false,
    this.bookingReference,
    this.bookingUrl,
    this.notes,
    this.referenceId,
    this.imageUrl,
  });
  
  /// Factory constructor that creates an [ItineraryItem] from JSON.
  factory ItineraryItem.fromJson(Map<String, dynamic> json) => _$ItineraryItemFromJson(json);
  
  /// Converts this [ItineraryItem] to JSON.
  Map<String, dynamic> toJson() => _$ItineraryItemToJson(this);
  
  /// Creates a copy of this [ItineraryItem] with the given fields replaced with new values.
  ItineraryItem copyWith({
    String? id,
    String? title,
    String? description,
    ItineraryItemType? type,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    double? latitude,
    double? longitude,
    double? cost,
    bool? isBooked,
    String? bookingReference,
    String? bookingUrl,
    String? notes,
    String? referenceId,
    String? imageUrl,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cost: cost ?? this.cost,
      isBooked: isBooked ?? this.isBooked,
      bookingReference: bookingReference ?? this.bookingReference,
      bookingUrl: bookingUrl ?? this.bookingUrl,
      notes: notes ?? this.notes,
      referenceId: referenceId ?? this.referenceId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
  
  /// Gets the icon for the item type.
  String get typeIcon {
    switch (type) {
      case ItineraryItemType.accommodation:
        return 'hotel';
      case ItineraryItemType.restaurant:
        return 'restaurant';
      case ItineraryItemType.transport:
        return 'directions_car';
      case ItineraryItemType.activity:
        return 'local_activity';
      case ItineraryItemType.sight:
        return 'photo_camera';
      case ItineraryItemType.custom:
        return 'star';
    }
  }
  
  /// Gets the color for the item type.
  int get typeColor {
    switch (type) {
      case ItineraryItemType.accommodation:
        return 0xFF4CAF50; // Green
      case ItineraryItemType.restaurant:
        return 0xFFF44336; // Red
      case ItineraryItemType.transport:
        return 0xFF2196F3; // Blue
      case ItineraryItemType.activity:
        return 0xFFFF9800; // Orange
      case ItineraryItemType.sight:
        return 0xFF9C27B0; // Purple
      case ItineraryItemType.custom:
        return 0xFF607D8B; // Blue Grey
    }
  }
  
  /// Gets the duration of the item in minutes.
  int? get durationMinutes {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!).inMinutes;
  }
  
  /// Gets the formatted time range of the item.
  String? get timeRange {
    if (startTime == null) return null;
    
    final startFormat = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
    
    if (endTime == null) return startFormat;
    
    final endFormat = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
    
    return '$startFormat - $endFormat';
  }
  
  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    date,
    startTime,
    endTime,
    location,
    latitude,
    longitude,
    cost,
    isBooked,
    bookingReference,
    bookingUrl,
    notes,
    referenceId,
    imageUrl,
  ];
}