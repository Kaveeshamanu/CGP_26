import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:taprobana_trails/bloc/restaurant/restaurant_state.dart';

import '../../bloc/restaurant/restaurant_bloc.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../data/models/restaurant.dart';
import '../../core/utils/connectivity.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/buttons.dart';
import '../common/widgets/loaders.dart';
import 'widgets/restaurant_card.dart';
import 'widgets/cuisine_filter.dart';

class RestaurantListScreen extends StatefulWidget {
  final String? destinationId;
  final String? title;

  const RestaurantListScreen({
    super.key,
    this.destinationId,
    this.title,
  });

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _selectedCuisine = 'All';
  String _searchQuery = '';
  String _sortBy = 'rating'; // Options: rating, price, distance
  
  // Filter states
  RangeValues _priceRange = RangeValues(1, 4); // Price levels 1-4
  bool _openNow = false;
  double _minRating = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    // Load restaurants when screen is opened
    _loadRestaurants();
    
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _loadRestaurants() {
    if (widget.destinationId != null) {
      context.read<RestaurantBloc>().add(
        LoadRestaurantsByDestination(
          destinationId: widget.destinationId!,
          cuisineType: _selectedCuisine != 'All' ? _selectedCuisine : null,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
          minPriceLevel: _priceRange.start.toInt(),
          maxPriceLevel: _priceRange.end.toInt(),
          openNow: _openNow ? true : null,
          minRating: _minRating > 0 ? _minRating : null,
          sortBy: _sortBy,
        ),
      );
    } else {
      context.read<RestaurantBloc>().add(
        LoadRestaurants(
          cuisineType: _selectedCuisine != 'All' ? _selectedCuisine : null,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
          minPriceLevel: _priceRange.start.toInt(),
          maxPriceLevel: _priceRange.end.toInt(),
          openNow: _openNow ? true : null,
          minRating: _minRating > 0 ? _minRating : null,
          sortBy: _sortBy,
        ),
      );
    }
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<RestaurantBloc>().state;
      if (state is RestaurantsLoaded && !state.isLoadingMore && state.hasMore) {
        _loadMoreRestaurants();
      }
    }
  }
  
  void _loadMoreRestaurants() {
    final state = context.read<RestaurantBloc>().state;
    if (state is RestaurantsLoaded) {
      final lastRestaurant = state.restaurants.last;
      
      if (widget.destinationId != null) {
        context.read<RestaurantBloc>().add(
          LoadMoreRestaurantsByDestination(
            destinationId: widget.destinationId!,
            lastRestaurantId: lastRestaurant.id,
            cuisineType: _selectedCuisine != 'All' ? _selectedCuisine : null,
            searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
            minPriceLevel: _priceRange.start.toInt(),
            maxPriceLevel: _priceRange.end.toInt(),
            openNow: _openNow ? true : null,
            minRating: _minRating > 0 ? _minRating : null,
            sortBy: _sortBy,
          ),
        );
      } else {
        context.read<RestaurantBloc>().add(
          LoadMoreRestaurants(
            lastRestaurantId: lastRestaurant.id,
            cuisineType: _selectedCuisine != 'All' ? _selectedCuisine : null,
            searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
            minPriceLevel: _priceRange.start.toInt(),
            maxPriceLevel: _priceRange.end.toInt(),
            openNow: _openNow ? true : null,
            minRating: _minRating > 0 ? _minRating : null,
            sortBy: _sortBy,
          ),
        );
      }
    }
  }
  
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadRestaurants();
  }
  
  void _onCuisineSelected(String cuisine) {
    setState(() {
      _selectedCuisine = cuisine;
    });
    _loadRestaurants();
  }
  
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }
  
  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => _buildSortBottomSheet(),
    );
  }
  
  void _navigateToRestaurantDetails(String restaurantId) {
    Navigator.pushNamed(
      context,
      AppRoutes.restaurantDetails,
      arguments: restaurantId,
    );
  }
  
  void _navigateToReservation(Restaurant restaurant) {
    Navigator.pushNamed(
      context,
      AppRoutes.restaurantReservation,
      arguments: restaurant,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title ?? 'Restaurants',
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortBottomSheet,
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search restaurants',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    )
                  : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Cuisine filter
          Container(
            height: 60,
            child: CuisineFilter(
              selectedCuisine: _selectedCuisine,
              onCuisineSelected: _onCuisineSelected,
            ),
          ),
          
          // Restaurant list
          Expanded(
            child: BlocBuilder<RestaurantBloc, RestaurantState>(
              builder: (context, state) {
                if (state is RestaurantsLoading && !state.isLoadingMore) {
                  return Center(child: LoadingSpinner());
                }
                
                if (state is RestaurantsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load restaurants',
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 8),
                        Text(
                          state.message,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadRestaurants,
                          child: Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is RestaurantsLoaded || 
                    (state is RestaurantsLoading && state.isLoadingMore)) {
                  final restaurants = state is RestaurantsLoaded
                    ? state.restaurants
                    : (state as RestaurantsLoading).lastLoadedRestaurants;
                  
                  final isLoadingMore = state is RestaurantsLoaded
                    ? state.isLoadingMore
                    : true;
                  
                  if (restaurants.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            color: Colors.grey[400],
                            size: 60,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No restaurants found',
                            style: theme.textTheme.titleMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadRestaurants();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16),
                      itemCount: restaurants.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == restaurants.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        final restaurant = restaurants[index];
                        
                        return RestaurantCard(
                          restaurant: restaurant,
                          onTap: () => _navigateToRestaurantDetails(restaurant.id),
                          onReserve: () => _navigateToReservation(restaurant),
                        );
                      },
                    ),
                  );
                }
                
                // Default loading state
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterBottomSheet() {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Restaurants',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          Divider(),
          
          // Filter options
          Expanded(
            child: ListView(
              children: [
                // Price range
                Text(
                  'Price Range',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Budget'),
                    Text('Luxury'),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 1,
                  max: 4,
                  divisions: 3,
                  labels: RangeLabels(
                    _getPriceLabel(_priceRange.start.toInt()),
                    _getPriceLabel(_priceRange.end.toInt()),
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                
                // Pricing explanation
                Wrap(
                  spacing: 16,
                  children: [
                    _buildPriceExplanation('\$', 'Budget'),
                    _buildPriceExplanation('\$\$', 'Moderate'),
                    _buildPriceExplanation('\$\$\$', 'Expensive'),
                    _buildPriceExplanation('\$\$\$\$', 'Luxury'),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Rating filter
                Text(
                  'Minimum Rating',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _minRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ],
                ),
                Slider(
                  value: _minRating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: _minRating.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _minRating = value;
                    });
                  },
                ),
                
                SizedBox(height: 24),
                
                // Open now filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Open Now',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _openNow,
                      onChanged: (value) {
                        setState(() {
                          _openNow = value;
                        });
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Reset and apply buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _priceRange = RangeValues(1, 4);
                            _minRating = 0;
                            _openNow = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Reset'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _loadRestaurants();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSortBottomSheet() {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort By',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Sort options
          _buildSortOption(
            'Top Rated',
            'rating',
            Icons.star,
          ),
          Divider(),
          _buildSortOption(
            'Price: Low to High',
            'price_asc',
            Icons.arrow_upward,
          ),
          Divider(),
          _buildSortOption(
            'Price: High to Low',
            'price_desc',
            Icons.arrow_downward,
          ),
          Divider(),
          _buildSortOption(
            'Nearest',
            'distance',
            Icons.near_me,
          ),
          Divider(),
          _buildSortOption(
            'Most Popular',
            'popularity',
            Icons.trending_up,
          ),
          
          SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildSortOption(String label, String sortValue, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _sortBy == sortValue;
    
    return InkWell(
      onTap: () {
        setState(() {
          _sortBy = sortValue;
        });
        Navigator.pop(context);
        _loadRestaurants();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
              size: 20,
            ),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
            Spacer(),
            if (isSelected)
              Icon(
                Icons.check,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPriceExplanation(String symbol, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  String _getPriceLabel(int level) {
    switch (level) {
      case 1:
        return '\$';
      case 2:
        return '\$\$';
      case 3:
        return '\$\$\$';
      case 4:
        return '\$\$\$\$';
      default:
        return '\$';
    }
  }
  
  LoadingSpinner() {}
  
  LoadMoreRestaurants({required String lastRestaurantId, String? cuisineType, String? searchQuery, required int minPriceLevel, required int maxPriceLevel, bool? openNow, double? minRating, required String sortBy}) {}
  
  LoadMoreRestaurantsByDestination({required String destinationId, required String lastRestaurantId, String? cuisineType, String? searchQuery, required int minPriceLevel, required int maxPriceLevel, bool? openNow, double? minRating, required String sortBy}) {}
  
  LoadRestaurants({String? cuisineType, String? searchQuery, required int minPriceLevel, required int maxPriceLevel, bool? openNow, double? minRating, required String sortBy}) {}
  
  LoadRestaurantsByDestination({required String destinationId, String? cuisineType, String? searchQuery, required int minPriceLevel, required int maxPriceLevel, bool? openNow, double? minRating, required String sortBy}) {}
}

class RestaurantBloc {
  get state => null;

  void add(loadMoreRestaurants) {}
}