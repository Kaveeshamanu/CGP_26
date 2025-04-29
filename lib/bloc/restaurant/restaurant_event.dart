part of 'restaurant_bloc.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurants extends RestaurantEvent {
  final String? destinationId;
  final int limit;
  final int offset;

  const LoadRestaurants({
    this.destinationId,
    this.limit = 10,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [destinationId, limit, offset];
}

class LoadRestaurantDetails extends RestaurantEvent {
  final String restaurantId;

  const LoadRestaurantDetails({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}

class FilterRestaurants extends RestaurantEvent {
  final String? destinationId;
  final List<String>? cuisineTypes;
  final RangeValues? priceRange;
  final double? rating;
  final List<String>? facilities;
  final List<String>? dietaryOptions;

  const FilterRestaurants({
    this.destinationId,
    this.cuisineTypes,
    this.priceRange,
    this.rating,
    this.facilities,
    this.dietaryOptions,
  });

  @override
  List<Object?> get props => [
    destinationId,
    cuisineTypes,
    priceRange,
    rating,
    facilities,
    dietaryOptions,
  ];
}

class BookRestaurantTable extends RestaurantEvent {
  final String restaurantId;
  final DateTime date;
  final TimeOfDay time;
  final int partySize;
  final String? specialRequests;
  final String userId;

  const BookRestaurantTable({
    required this.restaurantId,
    required this.date,
    required this.time,
    required this.partySize,
    this.specialRequests,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    restaurantId,
    date,
    time,
    partySize,
    specialRequests,
    userId,
  ];
}

class SearchRestaurants extends RestaurantEvent {
  final String query;
  final String? destinationId;
  final int limit;
  final int offset;

  const SearchRestaurants({
    required this.query,
    this.destinationId,
    this.limit = 10,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, destinationId, limit, offset];
}

class LoadFeaturedRestaurants extends RestaurantEvent {
  final String? destinationId;
  final int limit;

  const LoadFeaturedRestaurants({
    this.destinationId,
    this.limit = 5,
  });

  @override
  List<Object?> get props => [destinationId, limit];
}

class LoadNearbyRestaurants extends RestaurantEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;
  final int limit;

  const LoadNearbyRestaurants({
    required this.latitude,
    required this.longitude,
    this.radiusInKm = 5.0,
    this.limit = 10,
  });

  @override
  List<Object> get props => [latitude, longitude, radiusInKm, limit];
}

class ToggleRestaurantFavorite extends RestaurantEvent {
  final String restaurantId;
  final String userId;

  const ToggleRestaurantFavorite({
    required this.restaurantId,
    required this.userId,
  });

  @override
  List<Object> get props => [restaurantId, userId];
}

class SubmitRestaurantReview extends RestaurantEvent {
  final String restaurantId;
  final String userId;
  final double rating;
  final String comment;
  final List<String>? photos;

  const SubmitRestaurantReview({
    required this.restaurantId,
    required this.userId,
    required this.rating,
    required this.comment,
    this.photos,
  });

  @override
  List<Object?> get props => [restaurantId, userId, rating, comment, photos];
}