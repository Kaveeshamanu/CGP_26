part of 'destination_bloc.dart';

/// Base class for all destination events.
abstract class DestinationEvent extends Equatable {
  const DestinationEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event that is fired when destinations need to be loaded.
class LoadDestinations extends DestinationEvent {
  final String? category;
  
  const LoadDestinations({this.category});
  
  @override
  List<Object?> get props => [category];
}

/// Event that is fired when destination details need to be loaded.
class LoadDestinationDetails extends DestinationEvent {
  final String destinationId;
  
  const LoadDestinationDetails({required this.destinationId});
  
  @override
  List<Object> get props => [destinationId];
}

/// Event that is fired when trending destinations need to be loaded.
class LoadTrendingDestinations extends DestinationEvent {}

/// Event that is fired when destinations need to be filtered.
class FilterDestinations extends DestinationEvent {
  final Map<String, dynamic> filters;
  
  const FilterDestinations({required this.filters});
  
  @override
  List<Object> get props => [filters];
}

/// Event that is fired when a destination is saved.
class SaveDestination extends DestinationEvent {
  final String userId;
  final String destinationId;
  
  const SaveDestination({required this.userId, required this.destinationId});
  
  @override
  List<Object> get props => [userId, destinationId];
}

/// Event that is fired when a destination is unsaved.
class UnsaveDestination extends DestinationEvent {
  final String userId;
  final String destinationId;
  
  const UnsaveDestination({required this.userId, required this.destinationId});
  
  @override
  List<Object> get props => [userId, destinationId];
}

/// Event that is fired when destinations need to be searched.
class SearchDestinations extends DestinationEvent {
  final String query;
  
  const SearchDestinations({required this.query});
  
  @override
  List<Object> get props => [query];
}