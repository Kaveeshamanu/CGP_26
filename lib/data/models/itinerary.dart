import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:taprobana_trails/data/models/itinerary_item.dart';

part 'itinerary.g.dart';

/// Itinerary model for storing trip plans.
@JsonSerializable()
class Itinerary extends Equatable {
  /// The unique identifier of the itinerary.
  final String id;
  
  /// The title of the itinerary.
  final String title;
  
  /// The user ID of the itinerary owner.
  final String userId;
  
  /// The destination of the itinerary.
  final String destination;
  
  /// The start date of the itinerary.
  final DateTime startDate;
  
  /// The end date of the itinerary.
  final DateTime endDate;
  
  /// The list of items in the itinerary.
  final List<ItineraryItem> items;
  
  /// Whether the itinerary is shared.
  final bool isShared;
  
  /// The share URL of the itinerary.
  final String? shareUrl;
  
  /// The created date of the itinerary.
  final DateTime createdAt;
  
  /// The updated date of the itinerary.
  final DateTime updatedAt;
  
  /// The total budget of the itinerary calculated from items.
  double get totalBudget => items.fold(0, (sum, item) => sum + (item.cost ?? 0));
  
  /// Creates a new Itinerary.
  const Itinerary({
    required this.id,
    required this.title,
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.items,
    this.isShared = false,
    this.shareUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Factory constructor that creates an [Itinerary] from JSON.
  factory Itinerary.fromJson(Map<String, dynamic> json) => _$ItineraryFromJson(json);
  
  /// Converts this [Itinerary] to JSON.
  Map<String, dynamic> toJson() => _$ItineraryToJson(this);
  
  /// Creates a copy of this [Itinerary] with the given fields replaced with new values.
  Itinerary copyWith({
    String? id,
    String? title,
    String? userId,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    List<ItineraryItem>? items,
    bool? isShared,
    String? shareUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Itinerary(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      items: items ?? this.items,
      isShared: isShared ?? this.isShared,
      shareUrl: shareUrl ?? this.shareUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Gets the items for a specific date.
  List<ItineraryItem> getItemsForDate(DateTime date) {
    final dateWithoutTime = DateTime(date.year, date.month, date.day);
    return items.where((item) {
      final itemDate = DateTime(
        item.date.year,
        item.date.month,
        item.date.day,
      );
      return itemDate == dateWithoutTime;
    }).toList();
  }
  
  /// Gets all dates within the itinerary.
  List<DateTime> getAllDates() {
    final dates = <DateTime>[];
    final difference = endDate.difference(startDate).inDays;
    
    for (int i = 0; i <= difference; i++) {
      final date = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      ).add(Duration(days: i));
      dates.add(date);
    }
    
    return dates;
  }
  
  @override
  List<Object?> get props => [
    id,
    title,
    userId,
    destination,
    startDate,
    endDate,
    items,
    isShared,
    shareUrl,
    createdAt,
    updatedAt,
  ];

  get activities => null;
}