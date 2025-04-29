part of 'restaurant_bloc.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();
  
  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {}

// Restaurant List States
class RestaurantsLoading extends RestaurantState {}

class RestaurantsFiltering extends RestaurantState {}

class RestaurantsSearching extends RestaurantState {}

class RestaurantsLoaded extends RestaurantState {
  final List<Restaurant> restaurants;
  final bool hasReachedMax;
  final FilterRestaurants? appliedFilters;
  final bool isFiltering;

  const RestaurantsLoaded({
    required this.restaurants,
    required this.hasReachedMax,
    this.appliedFilters,
    this.isFiltering = false,
  });

  RestaurantsLoaded copyWith({
    List<Restaurant>? restaurants,
    bool? hasReachedMax,
    FilterRestaurants? appliedFilters,
    bool? isFiltering,
  }) {
    return RestaurantsLoaded(
      restaurants: restaurants ?? this.restaurants,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      appliedFilters: appliedFilters ?? this.appliedFilters,
      isFiltering: isFiltering ?? this.isFiltering,
    );
  }

  @override
  List<Object?> get props => [
    restaurants,
    hasReachedMax,
    appliedFilters,
    isFiltering,
  ];
}

class RestaurantsSearchResults extends RestaurantState {
  final List<Restaurant> restaurants;
  final String query;
  final bool hasReachedMax;

  const RestaurantsSearchResults({
    required this.restaurants,
    required this.query,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [restaurants, query, hasReachedMax];
}

class RestaurantsError extends RestaurantState {
  final String message;

  const RestaurantsError(this.message);

  @override
  List<Object> get props => [message];
}

// Restaurant Details States
class RestaurantDetailsLoading extends RestaurantState {}

class RestaurantDetailsLoaded extends RestaurantState {
  final Restaurant restaurant;

  const RestaurantDetailsLoaded({required this.restaurant});

  @override
  List<Object> get props => [restaurant];
}

class RestaurantDetailsError extends RestaurantState {
  final String message;

  const RestaurantDetailsError(this.message);

  @override
  List<Object> get props => [message];
}

// Featured Restaurants States
class FeaturedRestaurantsLoading extends RestaurantState {}

class FeaturedRestaurantsLoaded extends RestaurantState {
  final List<Restaurant> restaurants;

  const FeaturedRestaurantsLoaded({required this.restaurants});

  @override
  List<Object> get props => [restaurants];
}

// Nearby Restaurants States
class NearbyRestaurantsLoading extends RestaurantState {}

class NearbyRestaurantsLoaded extends RestaurantState {
  final List<Restaurant> restaurants;

  const NearbyRestaurantsLoaded({required this.restaurants});

  @override
  List<Object> get props => [restaurants];
}

// Restaurant Booking States
class RestaurantBookingInProgress extends RestaurantState {}

class RestaurantBookingSuccess extends RestaurantState {
  final String bookingId;
  final Map<String, dynamic> bookingDetails;

  const RestaurantBookingSuccess({
    required this.bookingId,
    required this.bookingDetails,
  });

  @override
  List<Object> get props => [bookingId, bookingDetails];
}

class RestaurantBookingError extends RestaurantState {
  final String message;

  const RestaurantBookingError(this.message);

  @override
  List<Object> get props => [message];
}

// Restaurant Review States
class SubmittingRestaurantReview extends RestaurantState {}

class SubmitReviewSuccess extends RestaurantState {}

class SubmitReviewError extends RestaurantState {
  final String message;

  const SubmitReviewError(this.message);

  @override
  List<Object> get props => [message];
}