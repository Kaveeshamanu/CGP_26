part of 'destination_bloc.dart';

/// Base class for all destination states.
abstract class DestinationState extends Equatable {
  const DestinationState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state of the destination bloc.
class DestinationInitial extends DestinationState {}

/// State when destinations are being loaded.
class DestinationsLoading extends DestinationState {}

/// State when destinations have been successfully loaded.
class DestinationsLoaded extends DestinationState {
  final List<Destination> destinations;
  
  const DestinationsLoaded({required this.destinations});
  
  @override
  List<Object> get props => [destinations];
}

/// State when destination details are being loaded.
class DestinationDetailsLoading extends DestinationState {}

/// State when destination details have been successfully loaded.
class DestinationDetailsLoaded extends DestinationState {
  final Destination destination;
  
  const DestinationDetailsLoaded({required this.destination});
  
  @override
  List<Object> get props => [destination];
}

/// State when trending destinations are being loaded.
class TrendingDestinationsLoading extends DestinationState {}

/// State when trending destinations have been successfully loaded.
class TrendingDestinationsLoaded extends DestinationState {
  final List<Destination> destinations;
  
  const TrendingDestinationsLoaded({required this.destinations});
  
  @override
  List<Object> get props => [destinations];
}

/// State when there is an error loading destinations.
class DestinationsError extends DestinationState {
  final String message;
  
  const DestinationsError({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// State when there is an error performing an action on a destination.
class DestinationActionError extends DestinationState {
  final String message;
  
  const DestinationActionError({required this.message});
  
  @override
  List<Object> get props => [message];
}