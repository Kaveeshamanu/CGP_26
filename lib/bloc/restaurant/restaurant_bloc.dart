import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/models/restaurant.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../core/utils/connectivity.dart';

part 'restaurant_event.dart';
part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantRepository _restaurantRepository;
  final ConnectivityService _connectivityService;
  final Logger _logger = Logger();

  RestaurantBloc({
    required RestaurantRepository restaurantRepository,
    required ConnectivityService connectivityService,
  })  : _restaurantRepository = restaurantRepository,
        _connectivityService = connectivityService,
        super(RestaurantInitial()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<LoadRestaurantDetails>(_onLoadRestaurantDetails);
    on<FilterRestaurants>(_onFilterRestaurants);
    on<BookRestaurantTable>(_onBookRestaurantTable);
    on<SearchRestaurants>(_onSearchRestaurants);
    on<LoadFeaturedRestaurants>(_onLoadFeaturedRestaurants);
    on<LoadNearbyRestaurants>(_onLoadNearbyRestaurants);
    on<ToggleRestaurantFavorite>(_onToggleRestaurantFavorite);
    on<SubmitRestaurantReview>(_onSubmitRestaurantReview);
  }

  Future<void> _onLoadRestaurants(
    LoadRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    try {
      emit(RestaurantsLoading());

      // Check connectivity - fixed to properly handle ConnectivityStatus
      final connectivityStatus = await _connectivityService.checkConnectivity();
      if (connectivityStatus != ConnectivityStatus.connected) {
        emit(RestaurantsError(
            'No internet connection. Please check your network settings.'));
        return;
      }

      // Fixed to properly await and handle the Stream<List<Restaurant>>
      final restaurants = await _restaurantRepository
          .getRestaurants(
            destinationId: event.destinationId,
            limit: event.limit,
            offset: event.offset,
          )
          .first; // Using first to get the first emission from the stream

      emit(RestaurantsLoaded(
        restaurants: restaurants,
        hasReachedMax: restaurants.length < event.limit,
      ));
    } catch (e, stackTrace) {
      _logger.e('Error loading restaurants', error: e, stackTrace: stackTrace);
      emit(RestaurantsError('Failed to load restaurants. Please try again.'));
    }
  }

  Future<void> _onLoadRestaurantDetails(
    LoadRestaurantDetails event,
    Emitter<RestaurantState> emit,
  ) async {
    try {
      emit(RestaurantDetailsLoading());

      // Check connectivity
      final connectivityStatus = await _connectivityService.checkConnectivity();
      if (connectivityStatus != ConnectivityStatus.connected) {
        emit(RestaurantDetailsError(
            'No internet connection. Please check your network settings.'));
        return;
      }

      final restaurant =
          await _restaurantRepository.getRestaurantById(event.restaurantId);

      if (restaurant != null) {
        emit(RestaurantDetailsLoaded(restaurant: restaurant));
      } else {
        emit(RestaurantDetailsError('Restaurant not found.'));
      }
    } catch (e, stackTrace) {
      _logger.e('Error loading restaurant details',
          error: e, stackTrace: stackTrace);
      emit(RestaurantDetailsError(
          'Failed to load restaurant details. Please try again.'));
    }
  }

  Future<void> _onFilterRestaurants(
    FilterRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    if (state is! RestaurantsLoaded) {
      // Cannot filter if restaurants are not loaded yet
      return;
    }

    try {
      emit(RestaurantsFiltering());

      final filteredRestaurants = await _restaurantRepository
          .filterRestaurants(
            destinationId: event.destinationId,
            cuisineTypes: event.cuisineTypes,
            priceRange: event.priceRange,
            rating: event.rating,
            facilities: event.facilities,
            dietaryOptions: event.dietaryOptions,
          )
          .first; // Using first to get the first emission from the stream

      emit(RestaurantsLoaded(
        restaurants: filteredRestaurants,
        hasReachedMax: true, // No pagination for filtered results
        appliedFilters: event,
      ));
    } catch (e, stackTrace) {
      _logger.e('Error filtering restaurants',
          error: e, stackTrace: stackTrace);
      // Revert to previous loaded state
      emit((state as RestaurantsLoaded).copyWith(
        isFiltering: false,
      ));
    }
  }

  Future<void> _onBookRestaurantTable(
    BookRestaurantTable event,
    Emitter<RestaurantState> emit,
  ) async {
    try {
      emit(RestaurantBookingInProgress());

      // Check connectivity
      final connectivityStatus = await _connectivityService.checkConnectivity();
      if (connectivityStatus != ConnectivityStatus.connected) {
        emit(RestaurantBookingError(
            'No internet connection. Please check your network settings.'));
        return;
      }

      final bookingResult = await _restaurantRepository.bookTable(
        restaurantId: event.restaurantId,
        date: event.date,
        time: event.time,
        partySize: event.partySize,
        specialRequests: event.specialRequests,
        userId: event.userId,
      );

      if (bookingResult.success) {
        emit(RestaurantBookingSuccess(
            bookingId: bookingResult.bookingId!,
            bookingDetails: bookingResult.bookingDetails!));
      } else {
        emit(RestaurantBookingError(
            bookingResult.errorMessage ?? 'Booking failed. Please try again.'));
      }
    } catch (e, stackTrace) {
      _logger.e('Error booking restaurant table',
          error: e, stackTrace: stackTrace);
      emit(RestaurantBookingError(
          'Failed to complete booking. Please try again.'));
    }
  }

  Future<void> _onSearchRestaurants(
    SearchRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    try {
      emit(RestaurantsSearching());

      // Check connectivity
      final connectivityStatus = await _connectivityService.checkConnectivity();
      if (connectivityStatus != ConnectivityStatus.connected) {
        emit(RestaurantsError(
            'No internet connection. Please check your network settings.'));
        return;
      }

      // Fixed: Removed .first call since Future doesn't have this method
      final searchResults = await _restaurantRepository.searchRestaurants(
        query: event.query,
        destinationId: event.destinationId,
        limit: event.limit,
        offset: event.offset,
      );

      emit(RestaurantsSearchResults(
        restaurants: searchResults,
        query: event.query,
        hasReachedMax: searchResults.length < event.limit,
      ));
    } catch (e, stackTrace) {
      _logger.e('Error searching restaurants',
          error: e, stackTrace: stackTrace);
      emit(RestaurantsError('Failed to search restaurants. Please try again.'));
    }
  }

  Future<void> _onLoadFeaturedRestaurants(
    LoadFeaturedRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    try {
      emit(FeaturedRestaurantsLoading());

      // Check connectivity
      final connectivityStatus = await _connectivityService.checkConnectivity();
      if (connectivityStatus != ConnectivityStatus.connected) {
        emit(RestaurantsError(
            'No internet connection. Please check your network settings.'));
        return;
      }

      // Removed .first since it's returning a Future<List<Restaurant>> not a Stream
      final featuredRestaurants =
          await _restaurantRepository.getFeaturedRestaurants(
        destinationId: event.destinationId,
        limit: event.limit,
      );

      emit(FeaturedRestaurantsLoaded(restaurants: featuredRestaurants));
    } catch (e, stackTrace) {
      _logger.e('Error loading featured restaurants',
          error: e, stackTrace: stackTrace);
      emit(RestaurantsError(
          'Failed to load featured restaurants. Please try again.'));
    }
  }

  Future<void> _onLoadNearbyRestaurants(
    LoadNearbyRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    try {
      emit(NearbyRestaurantsLoading());

      // Check connectivity - fixed the condition
      final connectivityStatus = await _connectivityService.checkConnectivity();
      if (connectivityStatus != ConnectivityStatus.connected) {
        emit(RestaurantsError(
            'No internet connection. Please check your network settings.'));
        return;
      }

      final nearbyRestaurants = await _restaurantRepository
          .getNearbyRestaurants(
            latitude: event.latitude,
            longitude: event.longitude,
            radiusInKm: event.radiusInKm,
            limit: event.limit,
          )
          .first; // Using first to get the first emission from the stream

      emit(NearbyRestaurantsLoaded(restaurants: nearbyRestaurants));
    } catch (e, stackTrace) {
      _logger.e('Error loading nearby restaurants',
          error: e, stackTrace: stackTrace);
      emit(RestaurantsError(
          'Failed to load nearby restaurants. Please try again.'));
    }
  }

  Future<void> _onToggleRestaurantFavorite(
    ToggleRestaurantFavorite event,
    Emitter<RestaurantState> emit,
  ) async {
    try {
      // Get current state to retain after operation
      final currentState = state;

      // Update favorite status immediately for UI response
      if (currentState is RestaurantsLoaded) {
        final updatedRestaurants = currentState.restaurants.map((restaurant) {
          if (restaurant.id == event.restaurantId) {
            return restaurant.copyWith(isFavorite: !restaurant.isFavorite!);
          }
          return restaurant;
        }).toList();

        emit(currentState.copyWith(restaurants: updatedRestaurants));
      } else if (currentState is RestaurantDetailsLoaded &&
          currentState.restaurant.id == event.restaurantId) {
        final updatedRestaurant = currentState.restaurant
            .copyWith(isFavorite: !currentState.restaurant.isFavorite!);
        emit(RestaurantDetailsLoaded(restaurant: updatedRestaurant));
      }

      // Persist the change
      await _restaurantRepository.toggleFavorite(
        restaurantId: event.restaurantId,
        userId: event.userId,
      );
    } catch (e, stackTrace) {
      _logger.e('Error toggling restaurant favorite',
          error: e, stackTrace: stackTrace);
      // No need to change UI state on error as we already updated UI optimistically
    }
  }

  Future<void> _onSubmitRestaurantReview(
    SubmitRestaurantReview event,
    Emitter<RestaurantState> emit,
  ) async {
    try {
      emit(SubmittingRestaurantReview());

      // Check connectivity
      final connectivityStatus = await _connectivityService.checkConnectivity();
      if (connectivityStatus != ConnectivityStatus.connected) {
        emit(SubmitReviewError(
            'No internet connection. Please check your network settings.'));
        return;
      }

      await _restaurantRepository.submitReview(
        restaurantId: event.restaurantId,
        userId: event.userId,
        rating: event.rating,
        comment: event.comment,
        photos: event.photos,
      );

      // If we're in restaurant details view, reload the details to show updated review
      if (state is RestaurantDetailsLoaded &&
          (state as RestaurantDetailsLoaded).restaurant.id ==
              event.restaurantId) {
        add(LoadRestaurantDetails(restaurantId: event.restaurantId));
      } else {
        emit(SubmitReviewSuccess());
      }
    } catch (e, stackTrace) {
      _logger.e('Error submitting restaurant review',
          error: e, stackTrace: stackTrace);
      emit(SubmitReviewError('Failed to submit review. Please try again.'));
    }
  }
}

// Adding this enum to ensure the code compiles
enum ConnectivityStatus { connected, disconnected, limited }
