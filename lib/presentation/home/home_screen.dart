import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../data/models/destination.dart';
import '../../data/models/accommodation.dart';
import '../../data/models/restaurant.dart';
import '../../core/utils/connectivity.dart';
import '../../core/utils/location_service.dart';
import '../../core/utils/permissions.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/buttons.dart';
import '../common/widgets/loaders.dart';
import '../common/widgets/cards.dart';
import 'controllers/home_controller.dart';
import 'widgets/trending_destinations.dart';
import 'widgets/deals_carousel.dart';
import 'widgets/weather_widget.dart';
import 'widgets/quick_access_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Load home data when screen is opened
    context.read<HomeController>().add(LoadHomeData());
    
    // Setup connectivity listener
    _setupConnectivityListener();
  }
  
  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      context.read<HomeController>().add(CheckConnectivity());
    } as void Function(List<ConnectivityResult> event)?);
  }
  
  void _onRefresh() async {
    context.read<HomeController>().add(RefreshHomeData());
    _refreshController.refreshCompleted();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeController, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial) {
            return Center(child: LoadingSpinner());
          }
          
          if (state is HomeError) {
            return _buildErrorView(state);
          }
          
          // For both loading and loaded states, we show the content with shimmer for loading
          final isLoading = state is HomeLoading;
          final homeData = isLoading ? state : (state as HomeLoaded);
          
          return SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Custom app bar with greeting and profile
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  title: _buildGreetingSection(homeData),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.notifications_outlined),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.notificationCenter);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.person_outline),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                    ),
                  ],
                ),
                
                // Main content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Weather widget if available
                      if (homeData.weatherData != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: WeatherWidget(
                            weatherData: homeData.weatherData!,
                            isLoading: isLoading,
                          ),
                        ),
                      
                      // Quick access panel
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: QuickAccessPanel(),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Upcoming trips section if available
                      if (homeData.upcomingItineraries.isNotEmpty)
                        _buildUpcomingTripsSection(homeData, isLoading),
                      
                      SizedBox(height: 24),
                      
                      // Deals section
                      _buildDealsSection(homeData, isLoading),
                      
                      SizedBox(height: 24),
                      
                      // Trending destinations section
                      _buildTrendingDestinationsSection(homeData, isLoading),
                      
                      SizedBox(height: 24),
                      
                      // Nearby destinations section if available
                      if (homeData.nearbyDestinations.isNotEmpty || isLoading)
                        _buildNearbyDestinationsSection(homeData, isLoading),
                      
                      SizedBox(height: 24),
                      
                      // Recently viewed destinations section if available
                      if (homeData.recentlyViewedDestinations.isNotEmpty || isLoading)
                        _buildRecentlyViewedSection(homeData, isLoading),
                      
                      SizedBox(height: 24),
                      
                      // Recommended accommodations section
                      _buildRecommendedAccommodationsSection(homeData, isLoading),
                      
                      SizedBox(height: 24),
                      
                      // Popular restaurants section
                      _buildPopularRestaurantsSection(homeData, isLoading),
                      
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildErrorView(HomeError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isConnectivityError 
                ? Icons.wifi_off
                : Icons.error_outline,
              color: state.isConnectivityError 
                ? Colors.orange 
                : Colors.red,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              state.isConnectivityError 
                ? 'No Internet Connection'
                : 'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HomeController>().add(LoadHomeData());
              },
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGreetingSection(dynamic homeData) {
    final timeNow = DateTime.now().hour;
    String greeting = 'Good morning';
    
    if (timeNow >= 12 && timeNow < 17) {
      greeting = 'Good afternoon';
    } else if (timeNow >= 17) {
      greeting = 'Good evening';
    }
    
    final userName = homeData.userName.isNotEmpty 
      ? homeData.userName.split(' ').first 
      : 'Traveler';
    
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              userName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildUpcomingTripsSection(dynamic homeData, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Upcoming Trips',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.itineraryPlanner);
                },
                child: Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: isLoading
            ? _buildLoadingHorizontalList()
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: homeData.upcomingItineraries.length,
                itemBuilder: (context, index) {
                  final itinerary = homeData.upcomingItineraries[index];
                  return _buildUpcomingTripCard(itinerary);
                },
              ),
        ),
      ],
    );
  }
  
  Widget _buildUpcomingTripCard(Map<String, dynamic> itinerary) {
    final startDate = DateTime.parse(itinerary['startDate']);
    final endDate = DateTime.parse(itinerary['endDate']);
    final formattedStartDate = DateFormat.MMMd().format(startDate);
    final formattedEndDate = DateFormat.MMMd().format(endDate);
    final daysLeft = startDate.difference(DateTime.now()).inDays;
    
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.itineraryDetails,
            arguments: itinerary['id'],
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination image and days left badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: itinerary['coverImage'],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 100,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      color: Colors.grey[300],
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
                
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      daysLeft == 0 
                        ? 'Today!' 
                        : daysLeft == 1 
                          ? 'Tomorrow!' 
                          : '$daysLeft days left',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Trip details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itinerary['title'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    itinerary['destinationName'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '$formattedStartDate - $formattedEndDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDealsSection(dynamic homeData, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exclusive Deals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.deals);
                },
                child: Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        isLoading
          ? _buildLoadingCarousel()
          : DealsCarousel(
              deals: homeData.deals,
              onDealTap: (dealId) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.dealDetails,
                  arguments: dealId,
                );
              },
            ),
      ],
    );
  }
  
  Widget _buildTrendingDestinationsSection(dynamic homeData, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending in Sri Lanka',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.destinationDiscovery);
                },
                child: Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        isLoading
          ? _buildLoadingTrendingDestinations()
          : TrendingDestinations(
              destinations: homeData.trendingDestinations,
              onDestinationTap: (destinationId) {
                context.read<HomeController>().add(
                  ViewDestinationDetails(destinationId: destinationId),
                );
                Navigator.pushNamed(
                  context,
                  AppRoutes.destinationDetails,
                  arguments: destinationId,
                );
              },
              onToggleFavorite: (destinationId, isFavorite) {
                context.read<HomeController>().add(
                  ToggleFavoriteDestination(
                    destinationId: destinationId,
                    isFavorite: isFavorite,
                  ),
                );
              },
            ),
      ],
    );
  }
  
  Widget _buildNearbyDestinationsSection(dynamic homeData, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Near You',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.maps,
                  );
                },
                child: Text('View Map'),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: isLoading
            ? _buildLoadingHorizontalList()
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: homeData.nearbyDestinations.length,
                itemBuilder: (context, index) {
                  final destination = homeData.nearbyDestinations[index];
                  return _buildDestinationCard(
                    destination: destination,
                    onTap: () {
                      context.read<HomeController>().add(
                        ViewDestinationDetails(destinationId: destination.id),
                      );
                      Navigator.pushNamed(
                        context,
                        AppRoutes.destinationDetails,
                        arguments: destination.id,
                      );
                    },
                    onToggleFavorite: (isFavorite) {
                      context.read<HomeController>().add(
                        ToggleFavoriteDestination(
                          destinationId: destination.id,
                          isFavorite: isFavorite,
                        ),
                      );
                    },
                  );
                },
              ),
        ),
      ],
    );
  }
  
  Widget _buildRecentlyViewedSection(dynamic homeData, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Recently Viewed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: isLoading
            ? _buildLoadingHorizontalList()
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: homeData.recentlyViewedDestinations.length,
                itemBuilder: (context, index) {
                  final destination = homeData.recentlyViewedDestinations[index];
                  return _buildDestinationCard(
                    destination: destination,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.destinationDetails,
                        arguments: destination.id,
                      );
                    },
                    onToggleFavorite: (isFavorite) {
                      context.read<HomeController>().add(
                        ToggleFavoriteDestination(
                          destinationId: destination.id,
                          isFavorite: isFavorite,
                        ),
                      );
                    },
                    compact: true,
                  );
                },
              ),
        ),
      ],
    );
  }
  
  Widget _buildRecommendedAccommodationsSection(dynamic homeData, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Stays',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.accommodationList);
                },
                child: Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: isLoading
            ? _buildLoadingHorizontalList()
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: homeData.recommendedAccommodations.length,
                itemBuilder: (context, index) {
                  final accommodation = homeData.recommendedAccommodations[index];
                  return _buildAccommodationCard(accommodation);
                },
              ),
        ),
      ],
    );
  }
  
  Widget _buildPopularRestaurantsSection(dynamic homeData, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Dining',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.restaurantList);
                },
                child: Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: isLoading
            ? _buildLoadingHorizontalList()
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: homeData.popularRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = homeData.popularRestaurants[index];
                  return _buildRestaurantCard(restaurant);
                },
              ),
        ),
      ],
    );
  }
  
  Widget _buildDestinationCard({
    required Destination destination,
    required VoidCallback onTap,
    required Function(bool) onToggleFavorite,
    bool compact = false,
  }) {
    return Container(
      width: compact ? 160 : 200,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: destination.images.first,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 120,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
                
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        destination.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: destination.isFavorite ? Colors.red : Colors.grey,
                      ),
                      iconSize: 18,
                      constraints: BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => onToggleFavorite(!destination.isFavorite),
                    ),
                  ),
                ),
              ],
            ),
            
            // Destination details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.regionName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAccommodationCard(Accommodation accommodation) {
    return Container(
      width: 220,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.hotelDetails,
            arguments: accommodation.id,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: accommodation.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 120,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
                
                // Rating
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          accommodation.rating.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Price badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'From \${accommodation.price}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Hotel details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accommodation.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          accommodation.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Amenities
                  Row(
                    children: accommodation.amenities.take(3).map((amenity) {
                      return Container(
                        margin: EdgeInsets.only(right: 6),
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRestaurantCard(Restaurant restaurant) {
    final isOpen = _isRestaurantOpenNow(restaurant.openingHours as String);
    
    return Container(
      width: 220,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.restaurantDetails,
            arguments: restaurant.id,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: restaurant.images.first,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 120,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
                
                // Rating
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          restaurant.rating.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Open status
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                
                // Price level
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriceLevel(restaurant.priceLevel),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Restaurant details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      restaurant.cuisineTypes,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Loading placeholders
  Widget _buildLoadingHorizontalList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 200,
            height: 180,
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildLoadingCarousel() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 180,
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  
  Widget _buildLoadingTrendingDestinations() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 220,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 180,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper methods
  bool _isRestaurantOpenNow(String openingHours) {
    // This would typically involve parsing the opening hours
    // and checking against current time
    // For this example, we'll return a simple check
    return true;
  }
  
  String _getPriceLevel(int level) {
    switch (level) {
      case 1:
        return '$\;
      case 2:
        return '\$;
      case 3:
        return '\$\$;
      case 4:
        return '\$\$\$;
      default:
        return '\$;
    }
  }
  
  DealsCarousel({required deals, required Null Function(dynamic dealId) onDealTap}) {}
  
  TrendingDestinations({required destinations, required Null Function(dynamic destinationId) onDestinationTap, required Null Function(dynamic destinationId, dynamic isFavorite) onToggleFavorite}) {}
  
  QuickAccessPanel() {}
  
  LoadingSpinner() {}
  
  WeatherWidget({required weatherData, required bool isLoading}) {}
}

extension on HomeState {
  get recentlyViewedDestinations => null;
  
  get nearbyDestinations => null;
  
  get upcomingItineraries => null;
  
  get weatherData => null;
}