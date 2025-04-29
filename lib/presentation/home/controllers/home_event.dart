part of 'home_controller.dart';

@immutable
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

class UpdateUserLocation extends HomeEvent {}

class CheckConnectivity extends HomeEvent {}

class SearchNearbyDestinations extends HomeEvent {
  final String? query;
  final String? category;
  final double radius;

  const SearchNearbyDestinations({
    this.query,
    this.category,
    this.radius = 50.0,
  });

  @override
  List<Object?> get props => [query, category, radius];
}

class LoadWeatherData extends HomeEvent {
  final String? destinationId;

  const LoadWeatherData({this.destinationId});

  @override
  List<Object?> get props => [destinationId];
}

class LoadDeals extends HomeEvent {
  final String? category;
  final int limit;

  const LoadDeals({
    this.category,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [category, limit];
}

class ToggleFavoriteDestination extends HomeEvent {
  final String destinationId;
  final bool isFavorite;

  const ToggleFavoriteDestination({
    required this.destinationId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [destinationId, isFavorite];
}

class ViewDestinationDetails extends HomeEvent {
  final String destinationId;

  const ViewDestinationDetails({
    required this.destinationId,
  });

  @override
  List<Object?> get props => [destinationId];
}

class BookmarkDestination extends HomeEvent {
  final String destinationId;
  final bool isBookmarked;

  const BookmarkDestination({
    required this.destinationId,
    required this.isBookmarked,
  });

  @override
  List<Object?> get props => [destinationId, isBookmarked];
}

class LoadUpcomingItineraries extends HomeEvent {}