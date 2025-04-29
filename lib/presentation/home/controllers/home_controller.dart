// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../data/models/destination.dart';
import '../../../data/models/accommodation.dart';
import '../../../data/models/restaurant.dart';
import '../../../data/models/transport.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/destination_repository.dart';
import '../../../data/repositories/accommodation_repository.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../data/repositories/transport_repository.dart';
import '../../../core/utils/connectivity.dart';
import '../../../core/utils/location_service.dart';
import '../../../core/utils/permissions.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeController extends Bloc<HomeEvent, HomeState> {
  final UserRepository userRepository;
  final DestinationRepository destinationRepository;
  final AccommodationRepository accommodationRepository;
  final RestaurantRepository restaurantRepository;
  final TransportRepository transportRepository;
  final LocationService locationService;
  final ConnectivityUtils connectivityUtils;

  HomeController({
    required this.userRepository,
    required this.destinationRepository,
    required this.accommodationRepository,
    required this.restaurantRepository,
    required this.transportRepository,
    required this.locationService,
    required this.connectivityUtils,
  }) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<CheckConnectivity>(_onCheckConnectivity);
    on<SearchNearbyDestinations>(_onSearchNearbyDestinations);
    on<LoadWeatherData>(_onLoadWeatherData);
    on<LoadDeals>(_onLoadDeals);
    on<ToggleFavoriteDestination>(_onToggleFavoriteDestination);
    on<ViewDestinationDetails>(_onViewDestinationDetails);
    on<BookmarkDestination>(_onBookmarkDestination);
    on<LoadUpcomingItineraries>(_onLoadUpcomingItineraries);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading(
      trendingDestinations: const [],
      recentlyViewedDestinations: const [],
      nearbyDestinations: const [],
      recommendedAccommodations: const [],
      popularRestaurants: const [],
      upcomingItineraries: const [],
      deals: const [],
      userName: '',
      currentLocation: null,
      weatherData: null,
      isConnected: true,
    ));

    try {
      // Check internet connectivity
      final isConnected = await connectivityUtils.isConnected();
      
      if (!isConnected) {
        emit(HomeError(
          message: 'No internet connection. Please check your network settings.',
          isConnectivityError: true,
        ));
        return;
      }

      // Load user data
      final user = await userRepository.getCurrentUser();
      
      // Request location permission and get current location
      Position? currentPosition;
      try {
        final hasPermission = await locationService.requestLocationPermission();
        if (hasPermission) {
          currentPosition = await locationService.getCurrentLocation();
        }
      } catch (e) {
        // Location error, but we can still load other data
        print('Error getting location: $e');
      }

      // Load trending destinations
      final trendingDestinations = await destinationRepository.getTrendingDestinations();
      
      // Load recently viewed destinations
      final recentlyViewedDestinations = await destinationRepository.getRecentlyViewedDestinations();
      
      // Load nearby destinations if location is available
      List<Destination> nearbyDestinations = [];
      if (currentPosition != null) {
        nearbyDestinations = await destinationRepository.getNearbyDestinations(
          latitude: currentPosition.latitude,
          longitude: currentPosition.longitude,
          radiusKm: 50, // 50km radius
        );
      }
      
      // Load recommended accommodations
      final recommendedAccommodations = await accommodationRepository.getRecommendedAccommodations();
      
      // Load popular restaurants
      final popularRestaurants = await restaurantRepository.getPopularRestaurants();
      
      // Load upcoming itineraries
      final upcomingItineraries = await userRepository.getUpcomingItineraries();
      
      // Load deals
      final deals = await destinationRepository.getDeals(limit: 0);
      
      // Load weather data for current location
      Map<String, dynamic>? weatherData;
      if (currentPosition != null) {
        weatherData = await destinationRepository.getWeatherData(
          latitude: currentPosition.latitude,
          longitude: currentPosition.longitude,
        );
      }

      // Emit loaded state with all data
      emit(HomeLoaded(
        trendingDestinations: trendingDestinations,
        recentlyViewedDestinations: recentlyViewedDestinations,
        nearbyDestinations: nearbyDestinations,
        recommendedAccommodations: recommendedAccommodations,
        popularRestaurants: popularRestaurants,
        upcomingItineraries: upcomingItineraries,
        deals: deals,
        userName: user.name,
        currentLocation: currentPosition,
        weatherData: weatherData,
        isConnected: true,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(HomeError(
        message: 'Failed to load home data: ${e.toString()}',
        isConnectivityError: false,
      ));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      
      emit(HomeLoading(
        trendingDestinations: currentState.trendingDestinations,
        recentlyViewedDestinations: currentState.recentlyViewedDestinations,
        nearbyDestinations: currentState.nearbyDestinations,
        recommendedAccommodations: currentState.recommendedAccommodations,
        popularRestaurants: currentState.popularRestaurants,
        upcomingItineraries: currentState.upcomingItineraries,
        deals: currentState.deals,
        userName: currentState.userName,
        currentLocation: currentState.currentLocation,
        weatherData: currentState.weatherData,
        isConnected: currentState.isConnected,
      ));
    }
    
    // Re-use same logic as initial load
    add(LoadHomeData());
  }

  Future<void> _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    
    final currentState = state as HomeLoaded;
    
    try {
      final hasPermission = await locationService.requestLocationPermission();
      
      if (!hasPermission) {
        // Location permission denied, keep current state
        return;
      }
      
      final currentPosition = await locationService.getCurrentLocation();
      
      // Load nearby destinations for new location
      final nearbyDestinations = await destinationRepository.getNearbyDestinations(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        radiusKm: 50, // 50km radius
      );
      
      // Load weather data for new location
      final weatherData = await destinationRepository.getWeatherData(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
      );
      
      emit(currentState.copyWith(
        nearbyDestinations: nearbyDestinations,
        currentLocation: currentPosition,
        weatherData: weatherData,
      ));
    } catch (e) {
      // Error updating location, keep current state
      print('Error updating location: $e');
    }
  }

  Future<void> _onCheckConnectivity(
    CheckConnectivity event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    
    final currentState = state as HomeLoaded;
    final isConnected = await connectivityUtils.isConnected();
    
    emit(currentState.copyWith(isConnected: isConnected));
  }

  Future<void> _onSearchNearbyDestinations(
    SearchNearbyDestinations event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    
    final currentState = state as HomeLoaded;
    
    if (currentState.currentLocation == null) {
      // No location available, can't search nearby
      return;
    }
    
    try {
      final nearbyDestinations = await destinationRepository.searchNearbyDestinations(
        latitude: currentState.currentLocation!.latitude,
        longitude: currentState.currentLocation!.longitude,
        radius: event.radius,
        query: event.query,
        category: event.category,
      );
      
      emit(currentState.copyWith(nearbyDestinations: nearbyDestinations));
    } catch (e) {
      // Error searching nearby destinations, keep current state
      print('Error searching nearby destinations: $e');
    }
  }

  Future<void> _onLoadWeatherData(
    LoadWeatherData event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    
    final currentState = state as HomeLoaded;
    
    try {
      Map<String, dynamic>? weatherData;
      
      if (event.destinationId != null) {
        // Load weather for specific destination
        final destination = await destinationRepository.getDestinationById(event.destinationId!);
        
        weatherData = await destinationRepository.getWeatherData(
          latitude: destination.latitude,
          longitude: destination.longitude,
        );
      } else if (currentState.currentLocation != null) {
        // Load weather for current location
        weatherData = await destinationRepository.getWeatherData(
          latitude: currentState.currentLocation!.latitude,
          longitude: currentState.currentLocation!.longitude,
        );
      }
      
      if (weatherData != null) {
        emit(currentState.copyWith(weatherData: weatherData));
      }
    } catch (e) {
      // Error loading weather data, keep current state
      print('Error loading weather data: $e');
    }
  }

  Future<void> _onLoadDeals(
    LoadDeals event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    
    final currentState = state as HomeLoaded;
    
    try {
      final deals = await destinationRepository.getDeals(
        category: event.category,
        limit: event.limit,
      );
      
      emit(currentState.copyWith(deals: deals));
    } catch (e) {
      // Error loading deals, keep current state
      print('Error loading deals: $e');
    }
  }

  Future<void> _onToggleFavoriteDestination(
    ToggleFavoriteDestination event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    
    final currentState = state as HomeLoaded;
    
    try {
      await userRepository.toggleFavoriteDestination(event.destinationId);
      
      // Update trending destinations list with favorite status
      final updatedTrendingDestinations = currentState.trendingDestinations.map((destination) {
        if (destination.id == event.destinationId) {
          return destination.copyWith(isFavorite: event.isFavorite, isBookmarked: false);
        }
        return destination;
      }).toList();
      
      // Update nearby destinations list with favorite status
      final updatedNearbyDestinations = currentState.nearbyDestinations.map((destination) {
        if (destination.id == event.destinationId) {
          return destination.copyWith(isFavorite: event.isFavorite, isBookmarked: true);
        }
        return destination;
      }).toList();
      
      // Update recently viewed destinations list with favorite status
      final updatedRecentlyViewedDestinations = currentState.recentlyViewedDestinations.map((destination) {
        if (destination.id == event.destinationId) {
          return destination.copyWith(isFavorite: event.isFavorite, isBookmarked: true);
        }
        return destination;
      }).toList();
      
      emit(currentState.copyWith(
        trendingDestinations: updatedTrendingDestinations,
        nearbyDestinations: updatedNearbyDestinations,
        recentlyViewedDestinations: updatedRecentlyViewedDestinations,
      ));
    } catch (e) {
      // Error toggling favorite, keep current state
      print('Error toggling favorite destination: $e');
    }
  }

  Future<void> _onViewDestinationDetails(
    ViewDestinationDetails event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    
    final currentState = state as HomeLoaded;
    
    try {
      // Add destination to recently viewed
      await destinationRepository.addToRecentlyViewed(event.destinationId);
      
      // Fetch updated list of recently viewed destinations
      final recentlyViewedDestinations = await destinationRepository.getRecentlyViewedDestinations();
      
      emit(currentState.copyWith(
        recentlyViewedDestinations: recentlyViewedDestinations,
      ));
    } catch (e) {
      // Error updating recently viewed, keep current state
      print('Error updating recently viewed destinations: $e');
    }
  }

  Future<void> _onBookmarkDestination(
    BookmarkDestination event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    
    final currentState = state as HomeLoaded;
    
    try {
      // Toggle bookmark status
      await userRepository.toggleBookmarkDestination(
        event.destinationId,
        event.isBookmarked,
      );
      
      // Update trending destinations list with bookmark status
      final updatedTrendingDestinations = currentState.trendingDestinations.map((destination) {
        if (destination.id == event.destinationId) {
          return destination.copyWith(isBookmarked: event.isBookmarked, isFavorite: true);
        }
        return destination;
      }).toList();
      
      // Update nearby destinations list with bookmark status
      final updatedNearbyDestinations = currentState.nearbyDestinations.map((destination) {
        if (destination.id == event.destinationId) {
          return destination.copyWith(isBookmarked: event.isBookmarked, isFavorite: true);
        }
        return destination;
      }).toList();
      
      // Update recently viewed destinations list with bookmark status
      final updatedRecentlyViewedDestinations = currentState.recentlyViewedDestinations.map((destination) {
        if (destination.id == event.destinationId) {
          return destination.copyWith(isBookmarked: event.isBookmarked, isFavorite: true);
        }
        return destination;
      }).toList();
      
      emit(currentState.copyWith(
        trendingDestinations: updatedTrendingDestinations,
        nearbyDestinations: updatedNearbyDestinations,
        recentlyViewedDestinations: updatedRecentlyViewedDestinations,
      ));
    } catch (e) {
      // Error toggling bookmark, keep current state
      print('Error toggling bookmark destination: $e');
    }
  }

  Future<void> _onLoadUpcomingItineraries(
    LoadUpcomingItineraries event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    
    final currentState = state as HomeLoaded;
    
    try {
      final upcomingItineraries = await userRepository.getUpcomingItineraries();
      
      emit(currentState.copyWith(upcomingItineraries: upcomingItineraries));
    } catch (e) {
      // Error loading itineraries, keep current state
      print('Error loading upcoming itineraries: $e');
    }
  }
}