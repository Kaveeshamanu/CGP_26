part of 'accommodation_bloc.dart';

/// Base class for all accommodation states.
abstract class AccommodationState extends Equatable {
  const AccommodationState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state of the accommodation bloc.
class AccommodationInitial extends AccommodationState {}

/// State when accommodations are being loaded.
class AccommodationsLoading extends AccommodationState {}

/// State when accommodations have been successfully loaded.
class AccommodationsLoaded extends AccommodationState {
  final List<Accommodation> accommodations;
  
  const AccommodationsLoaded({required this.accommodations});
  
  @override
  List<Object> get props => [accommodations];
}

/// State when accommodation details are being loaded.
class AccommodationDetailsLoading extends AccommodationState {}

/// State when accommodation details have been successfully loaded.
class AccommodationDetailsLoaded extends AccommodationState {
  final Accommodation accommodation;
  
  const AccommodationDetailsLoaded({required this.accommodation});
  
  @override
  List<Object> get props => [accommodation];
}

/// State when room types are being loaded.
class RoomTypesLoading extends AccommodationState {}

/// State when room types have been successfully loaded.
class RoomTypesLoaded extends AccommodationState {
  final List<Room> rooms;
  
  const RoomTypesLoaded({required this.rooms});
  
  @override
  List<Object> get props => [rooms];
}

/// State when room availability is being checked.
class RoomAvailabilityLoading extends AccommodationState {}

/// State when room availability has been successfully checked.
class RoomAvailabilityLoaded extends AccommodationState {
  final bool isAvailable;
  
  const RoomAvailabilityLoaded({required this.isAvailable});
  
  @override
  List<Object> get props => [isAvailable];
}

/// State when there is an error loading accommodations.
class AccommodationsError extends AccommodationState {
  final String message;
  
  const AccommodationsError({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// State when there is an error performing an action on an accommodation.
class AccommodationActionError extends AccommodationState {
  final String message;
  
  const AccommodationActionError({required this.message});
  
  @override
  List<Object> get props => [message];
}