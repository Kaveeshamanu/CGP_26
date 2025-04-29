part of 'accommodation_bloc.dart';

/// Base class for all accommodation events.
abstract class AccommodationEvent extends Equatable {
  const AccommodationEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event that is fired when accommodations need to be loaded.
class LoadAccommodations extends AccommodationEvent {
  final String? destinationId;
  
  const LoadAccommodations({this.destinationId});
  
  @override
  List<Object?> get props => [destinationId];
}

/// Event that is fired when accommodation details need to be loaded.
class LoadAccommodationDetails extends AccommodationEvent {
  final String accommodationId;
  
  const LoadAccommodationDetails({required this.accommodationId});
  
  @override
  List<Object> get props => [accommodationId];
}

/// Event that is fired when accommodations need to be filtered.
class FilterAccommodations extends AccommodationEvent {
  final Map<String, dynamic> filters;
  
  const FilterAccommodations({required this.filters});
  
  @override
  List<Object> get props => [filters];
}

/// Event that is fired when an accommodation is saved.
class SaveAccommodation extends AccommodationEvent {
  final String userId;
  final String accommodationId;
  
  const SaveAccommodation({required this.userId, required this.accommodationId});
  
  @override
  List<Object> get props => [userId, accommodationId];
}

/// Event that is fired when an accommodation is unsaved.
class UnsaveAccommodation extends AccommodationEvent {
  final String userId;
  final String accommodationId;
  
  const UnsaveAccommodation({required this.userId, required this.accommodationId});
  
  @override
  List<Object> get props => [userId, accommodationId];
}

/// Event that is fired when accommodations need to be searched.
class SearchAccommodations extends AccommodationEvent {
  final String query;
  
  const SearchAccommodations({required this.query});
  
  @override
  List<Object> get props => [query];
}

/// Event that is fired when room types need to be loaded.
class LoadRoomTypes extends AccommodationEvent {
  final String accommodationId;
  final DateTime? checkIn;
  final DateTime? checkOut;
  
  const LoadRoomTypes({
    required this.accommodationId,
    this.checkIn,
    this.checkOut,
  });
  
  @override
  List<Object?> get props => [accommodationId, checkIn, checkOut];
}

/// Event that is fired when room availability needs to be checked.
class CheckRoomAvailability extends AccommodationEvent {
  final String accommodationId;
  final String roomTypeId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  
  const CheckRoomAvailability({
    required this.accommodationId,
    required this.roomTypeId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
  });
  
  @override
  List<Object> get props => [
    accommodationId,
    roomTypeId,
    checkIn,
    checkOut,
    guests,
  ];
}