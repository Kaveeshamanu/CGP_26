import 'package:equatable/equatable.dart';
import 'package:taprobana_trails/data/models/itinerary.dart';

/// Base class for all itinerary states.
abstract class ItineraryState extends Equatable {
  const ItineraryState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state of the itinerary bloc.
class ItineraryInitial extends ItineraryState {}

/// State when itineraries are being loaded.
class ItinerariesLoading extends ItineraryState {}

/// State when itineraries have been successfully loaded.
class ItinerariesLoaded extends ItineraryState {
  final List<Itinerary> itineraries;
  
  const ItinerariesLoaded({required this.itineraries});
  
  @override
  List<Object> get props => [itineraries];
}

/// State when itinerary details are being loaded.
class ItineraryDetailsLoading extends ItineraryState {}

/// State when itinerary details have been successfully loaded.
class ItineraryDetailsLoaded extends ItineraryState {
  final Itinerary itinerary;
  
  const ItineraryDetailsLoaded({required this.itinerary});
  
  @override
  List<Object> get props => [itinerary];
}

/// State when an itinerary action is being processed.
class ItineraryActionLoading extends ItineraryState {}

/// State when an itinerary action has been successfully processed.
class ItineraryActionSuccess extends ItineraryState {}

/// State when an itinerary is being shared.
class ItineraryShareLoading extends ItineraryState {}

/// State when an itinerary has been successfully shared.
class ItineraryShareSuccess extends ItineraryState {
  final String shareUrl;
  
  const ItineraryShareSuccess({required this.shareUrl});
  
  @override
  List<Object> get props => [shareUrl];
}

/// State when a suggested itinerary is being generated.
class SuggestedItineraryLoading extends ItineraryState {}

/// State when a suggested itinerary has been successfully generated.
class SuggestedItineraryLoaded extends ItineraryState {
  final Itinerary itinerary;
  
  const SuggestedItineraryLoaded({required this.itinerary});
  
  @override
  List<Object> get props => [itinerary];
}

/// State when there is an error in itinerary operations.
class ItineraryError extends ItineraryState {
  final String message;
  
  const ItineraryError({required this.message});
  
  @override
  List<Object> get props => [message];
}