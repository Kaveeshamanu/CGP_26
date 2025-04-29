part of 'home_controller.dart';

@immutable
abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {
  final List<Destination> trendingDestinations;
  final List<Destination> recentlyViewedDestinations;
  final List<Destination> nearbyDestinations;
  final List<Accommodation> recommendedAccommodations;
  final List<Restaurant> popularRestaurants;
  final List<Map<String, dynamic>> upcomingItineraries;
  final List<Map<String, dynamic>> deals;
  final String userName;
  final Position? currentLocation;
  final Map<String, dynamic>? weatherData;
  final bool isConnected;

  const HomeLoading({
    required this.trendingDestinations,
    required this.recentlyViewedDestinations,
    required this.nearbyDestinations,
    required this.recommendedAccommodations,
    required this.popularRestaurants,
    required this.upcomingItineraries,
    required this.deals,
    required this.userName,
    required this.currentLocation,
    required this.weatherData,
    required this.isConnected,
  });

  @override
  List<Object?> get props => [
    trendingDestinations,
    recentlyViewedDestinations,
    nearbyDestinations,
    recommendedAccommodations,
    popularRestaurants,
    upcomingItineraries,
    deals,
    userName,
    currentLocation,
    weatherData,
    isConnected,
  ];
}

class HomeLoaded extends HomeState {
  final List<Destination> trendingDestinations;
  final List<Destination> recentlyViewedDestinations;
  final List<Destination> nearbyDestinations;
  final List<Accommodation> recommendedAccommodations;
  final List<Restaurant> popularRestaurants;
  final List<Map<String, dynamic>> upcomingItineraries;
  final List<Map<String, dynamic>> deals;
  final String userName;
  final Position? currentLocation;
  final Map<String, dynamic>? weatherData;
  final bool isConnected;
  final DateTime lastUpdated;

  const HomeLoaded({
    required this.trendingDestinations,
    required this.recentlyViewedDestinations,
    required this.nearbyDestinations,
    required this.recommendedAccommodations,
    required this.popularRestaurants,
    required this.upcomingItineraries,
    required this.deals,
    required this.userName,
    required this.currentLocation,
    required this.weatherData,
    required this.isConnected,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    trendingDestinations,
    recentlyViewedDestinations,
    nearbyDestinations,
    recommendedAccommodations,
    popularRestaurants,
    upcomingItineraries,
    deals,
    userName,
    currentLocation,
    weatherData,
    isConnected,
    lastUpdated,
  ];

  HomeLoaded copyWith({
    List<Destination>? trendingDestinations,
    List<Destination>? recentlyViewedDestinations,
    List<Destination>? nearbyDestinations,
    List<Accommodation>? recommendedAccommodations,
    List<Restaurant>? popularRestaurants,
    List<Map<String, dynamic>>? upcomingItineraries,
    List<Map<String, dynamic>>? deals,
    String? userName,
    Position? currentLocation,
    Map<String, dynamic>? weatherData,
    bool? isConnected,
    DateTime? lastUpdated,
  }) {
    return HomeLoaded(
      trendingDestinations: trendingDestinations ?? this.trendingDestinations,
      recentlyViewedDestinations: recentlyViewedDestinations ?? this.recentlyViewedDestinations,
      nearbyDestinations: nearbyDestinations ?? this.nearbyDestinations,
      recommendedAccommodations: recommendedAccommodations ?? this.recommendedAccommodations,
      popularRestaurants: popularRestaurants ?? this.popularRestaurants,
      upcomingItineraries: upcomingItineraries ?? this.upcomingItineraries,
      deals: deals ?? this.deals,
      userName: userName ?? this.userName,
      currentLocation: currentLocation ?? this.currentLocation,
      weatherData: weatherData ?? this.weatherData,
      isConnected: isConnected ?? this.isConnected,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  final bool isConnectivityError;

  const HomeError({
    required this.message,
    required this.isConnectivityError,
  });

  @override
  List<Object?> get props => [message, isConnectivityError];
}