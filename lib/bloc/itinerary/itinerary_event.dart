import 'package:equatable/equatable.dart';
import 'package:taprobana_trails/data/models/itinerary_item.dart';

/// Base class for all itinerary events.
abstract class ItineraryEvent extends Equatable {
  const ItineraryEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event that is fired when itineraries need to be loaded.
class LoadItineraries extends ItineraryEvent {
  final String userId;
  
  const LoadItineraries({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

/// Event that is fired when itinerary details need to be loaded.
class LoadItineraryDetails extends ItineraryEvent {
  final String itineraryId;
  
  const LoadItineraryDetails({required this.itineraryId});
  
  @override
  List<Object> get props => [itineraryId];
}

/// Event that is fired when a new itinerary is created.
class CreateItinerary extends ItineraryEvent {
  final String userId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String destination;
  
  const CreateItinerary({
    required this.userId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.destination,
  });
  
  @override
  List<Object> get props => [userId, title, startDate, endDate, destination];
}

/// Event that is fired when an itinerary is updated.
class UpdateItinerary extends ItineraryEvent {
  final String itineraryId;
  final String? title;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? destination;
  
  const UpdateItinerary({
    required this.itineraryId,
    this.title,
    this.startDate,
    this.endDate,
    this.destination,
  });
  
  @override
  List<Object?> get props => [itineraryId, title, startDate, endDate, destination];
}

/// Event that is fired when an itinerary is deleted.
class DeleteItinerary extends ItineraryEvent {
  final String itineraryId;
  final String userId;
  
  const DeleteItinerary({required this.itineraryId, required this.userId});
  
  @override
  List<Object> get props => [itineraryId, userId];
}

/// Event that is fired when an item is added to an itinerary.
class AddItineraryItem extends ItineraryEvent {
  final String itineraryId;
  final ItineraryItem item;
  
  const AddItineraryItem({required this.itineraryId, required this.item});
  
  @override
  List<Object> get props => [itineraryId, item];
}

/// Event that is fired when an itinerary item is updated.
class UpdateItineraryItem extends ItineraryEvent {
  final String itineraryId;
  final String itemId;
  final ItineraryItem item;
  
  const UpdateItineraryItem({
    required this.itineraryId,
    required this.itemId,
    required this.item,
  });
  
  @override
  List<Object> get props => [itineraryId, itemId, item];
}

/// Event that is fired when an itinerary item is deleted.
class DeleteItineraryItem extends ItineraryEvent {
  final String itineraryId;
  final String itemId;
  
  const DeleteItineraryItem({required this.itineraryId, required this.itemId});
  
  @override
  List<Object> get props => [itineraryId, itemId];
}

/// Event that is fired when itinerary items are reordered.
class ReorderItineraryItems extends ItineraryEvent {
  final String itineraryId;
  final List<String> itemIds;
  
  const ReorderItineraryItems({required this.itineraryId, required this.itemIds});
  
  @override
  List<Object> get props => [itineraryId, itemIds];
}

/// Event that is fired when an itinerary is shared.
class ShareItinerary extends ItineraryEvent {
  final String itineraryId;
  
  const ShareItinerary({required this.itineraryId});
  
  @override
  List<Object> get props => [itineraryId];
}

/// Event that is fired when a suggested itinerary needs to be generated.
class GenerateSuggestedItinerary extends ItineraryEvent {
  final String userId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic>? preferences;
  
  const GenerateSuggestedItinerary({
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.preferences,
  });
  
  @override
  List<Object?> get props => [userId, destination, startDate, endDate, preferences];
}