import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../bloc/destination/destination_bloc.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../data/models/destination.dart';
import '../../core/utils/connectivity.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/buttons.dart';
import '../common/widgets/loaders.dart';
import 'widgets/destination_card.dart';
import 'widgets/category_selector.dart';
import 'widgets/filter_modal.dart';

class DestinationDiscoveryScreen extends StatefulWidget {
  const DestinationDiscoveryScreen({super.key});

  @override
  State<DestinationDiscoveryScreen> createState() =>
      _DestinationDiscoveryScreenState();
}

class _DestinationDiscoveryScreenState
    extends State<DestinationDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _currentFeaturedIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isFilterApplied = false;

  // Filter parameters
  RangeValues _priceRange = RangeValues(0, 1000);
  double _minRating = 0.0;
  List<String> _selectedRegions = [];
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();

    // Load destinations when screen is opened
    context.read<DestinationBloc>().add(LoadDestinations());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });

    // Create a filters map
    final Map<String, dynamic> filters = {};

    // Add category filter
    if (category != 'All') {
      filters['category'] = category;
    }

    // Add search query if exists
    if (_searchQuery.isNotEmpty) {
      filters['searchQuery'] = _searchQuery;
    }

    // Add filter parameters if applied
    if (_isFilterApplied) {
      filters['minPrice'] = _priceRange.start;
      filters['maxPrice'] = _priceRange.end;

      if (_minRating > 0) {
        filters['minRating'] = _minRating;
      }

      if (_selectedRegions.isNotEmpty) {
        filters['regions'] = _selectedRegions;
      }

      if (_selectedTags.isNotEmpty) {
        filters['tags'] = _selectedTags;
      }
    }

    // Update destinations based on selected category
    context.read<DestinationBloc>().add(FilterDestinations(filters: filters));
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });

    // Create a filters map
    final Map<String, dynamic> filters = {};

    // Add category filter
    if (_selectedCategory != 'All') {
      filters['category'] = _selectedCategory;
    }

    // Add search query if exists
    if (query.isNotEmpty) {
      filters['searchQuery'] = query;
    }

    // Add filter parameters if applied
    if (_isFilterApplied) {
      filters['minPrice'] = _priceRange.start;
      filters['maxPrice'] = _priceRange.end;

      if (_minRating > 0) {
        filters['minRating'] = _minRating;
      }

      if (_selectedRegions.isNotEmpty) {
        filters['regions'] = _selectedRegions;
      }

      if (_selectedTags.isNotEmpty) {
        filters['tags'] = _selectedTags;
      }
    }

    // Update destinations based on search query
    context.read<DestinationBloc>().add(FilterDestinations(filters: filters));
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterModal(
        priceRange: _priceRange,
        minRating: _minRating,
        selectedRegions: _selectedRegions,
        selectedTags: _selectedTags,
        onApplyFilter: _applyFilter,
        onResetFilter: _resetFilter,
      ),
    );
  }

  void _applyFilter({
    required RangeValues priceRange,
    required double minRating,
    required List<String> selectedRegions,
    required List<String> selectedTags,
  }) {
    setState(() {
      _priceRange = priceRange;
      _minRating = minRating;
      _selectedRegions = selectedRegions;
      _selectedTags = selectedTags;
      _isFilterApplied = true;
    });

    // Create a filters map
    final Map<String, dynamic> filters = {};

    // Add category filter
    if (_selectedCategory != 'All') {
      filters['category'] = _selectedCategory;
    }

    // Add search query if exists
    if (_searchQuery.isNotEmpty) {
      filters['searchQuery'] = _searchQuery;
    }

    // Add filter parameters
    filters['minPrice'] = priceRange.start;
    filters['maxPrice'] = priceRange.end;

    if (minRating > 0) {
      filters['minRating'] = minRating;
    }

    if (selectedRegions.isNotEmpty) {
      filters['regions'] = selectedRegions;
    }

    if (selectedTags.isNotEmpty) {
      filters['tags'] = selectedTags;
    }

    // Update destinations based on filter
    context.read<DestinationBloc>().add(FilterDestinations(filters: filters));
  }

  void _resetFilter() {
    setState(() {
      _priceRange = RangeValues(0, 1000);
      _minRating = 0.0;
      _selectedRegions = [];
      _selectedTags = [];
      _isFilterApplied = false;
    });

    // Create a filters map
    final Map<String, dynamic> filters = {};

    // Only add category and search query filters if applicable
    if (_selectedCategory != 'All') {
      filters['category'] = _selectedCategory;
    }

    if (_searchQuery.isNotEmpty) {
      filters['searchQuery'] = _searchQuery;
    }

    // Reset destinations filter
    context.read<DestinationBloc>().add(FilterDestinations(filters: filters));
  }

  void _navigateToDestinationDetails(String destinationId) {
    Navigator.pushNamed(
      context,
      AppRoutes.destinationDetails,
      arguments: destinationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Discover',
        actions: [
          IconButton(
            icon: Icon(
                _isFilterApplied ? Icons.filter_list_alt : Icons.filter_list),
            onPressed: _showFilterModal,
            color: _isFilterApplied ? theme.colorScheme.primary : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search destinations',
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
              ],
            ),
          ),

          // Categories section
          Container(
            height: 60,
            child: CategorySelector(
              categories: [
                'All',
                'Beach',
                'Mountain',
                'Cultural',
                'Wildlife',
                'Adventure'
              ],
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
          ),

          // Filter chips section (only shown when filters are applied)
          if (_isFilterApplied)
            Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (_selectedRegions.isNotEmpty)
                    _buildFilterChip(
                      'Regions: ${_selectedRegions.length}',
                      () {
                        setState(() {
                          _selectedRegions = [];
                        });
                        _applyFilter(
                          priceRange: _priceRange,
                          minRating: _minRating,
                          selectedRegions: [],
                          selectedTags: _selectedTags,
                        );
                      },
                    ),
                  if (_selectedTags.isNotEmpty)
                    _buildFilterChip(
                      'Tags: ${_selectedTags.length}',
                      () {
                        setState(() {
                          _selectedTags = [];
                        });
                        _applyFilter(
                          priceRange: _priceRange,
                          minRating: _minRating,
                          selectedRegions: _selectedRegions,
                          selectedTags: [],
                        );
                      },
                    ),
                  if (_minRating > 0)
                    _buildFilterChip(
                      'Rating: ${_minRating.toStringAsFixed(1)}+',
                      () {
                        setState(() {
                          _minRating = 0;
                        });
                        _applyFilter(
                          priceRange: _priceRange,
                          minRating: 0,
                          selectedRegions: _selectedRegions,
                          selectedTags: _selectedTags,
                        );
                      },
                    ),
                  _buildFilterChip(
                    'Reset All',
                    _resetFilter,
                    isReset: true,
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: BlocBuilder<DestinationBloc, DestinationState>(
              builder: (context, state) {
                if (state is DestinationsLoading && !state.isFiltering) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is DestinationsError) {
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
                          'Failed to load destinations',
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
                          onPressed: () => context
                              .read<DestinationBloc>()
                              .add(LoadDestinations()),
                          child: Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DestinationsLoaded ||
                    (state is DestinationsLoading && state.isFiltering)) {
                  final destinations = state is DestinationsLoaded
                      ? state.destinations
                      : (state as DestinationsLoading).lastLoadedDestinations;

                  if (destinations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            color: Colors.grey[400],
                            size: 60,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No destinations found',
                            style: theme.textTheme.titleMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _resetFilter,
                            child: Text('Reset Filters'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Separate featured destinations (for this example, considering top 5 rated as featured)
                  final featuredDestinations = List.of(destinations)
                    ..sort((a, b) => b.rating.compareTo(a.rating));

                  if (featuredDestinations.length > 5) {
                    featuredDestinations.removeRange(
                        5, featuredDestinations.length);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<DestinationBloc>().add(LoadDestinations());
                    },
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Featured destinations carousel
                        if (featuredDestinations.isNotEmpty &&
                            _searchQuery.isEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(
                                  'Featured Destinations',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              CarouselSlider(
                                carouselController: _carouselController,
                                options: CarouselOptions(
                                  height: 220,
                                  viewportFraction: 0.9,
                                  enableInfiniteScroll:
                                      featuredDestinations.length > 1,
                                  enlargeCenterPage: true,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentFeaturedIndex = index;
                                    });
                                  },
                                ),
                                items: featuredDestinations.map((destination) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return _buildFeaturedDestinationCard(
                                        context,
                                        destination,
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: featuredDestinations
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return Container(
                                    width: 8.0,
                                    height: 8.0,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          theme.colorScheme.primary.withOpacity(
                                        _currentFeaturedIndex == entry.key
                                            ? 0.9
                                            : 0.4,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 16),
                              Divider(),
                            ],
                          ),

                        // All destinations section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Search Results'
                                    : 'All Destinations',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (state is DestinationsLoading &&
                                  state.isFiltering)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Grid of destinations
                        GridView.builder(
                          padding: EdgeInsets.all(16),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: destinations.length,
                          itemBuilder: (context, index) {
                            return DestinationCard(
                              destination: destinations[index],
                              onTap: () => _navigateToDestinationDetails(
                                destinations[index].id,
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildFeaturedDestinationCard(
      BuildContext context, Destination destination) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _navigateToDestinationDetails(destination.id),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: destination.images.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: [0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Destination name
                      Text(
                        destination.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      // Location and rating
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              destination.regionName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                destination.rating.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: destination.tags.take(3).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Featured badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Featured',
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
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap,
      {bool isReset = false}) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (_) => onTap(),
        backgroundColor: isReset
            ? theme.colorScheme.error.withOpacity(0.1)
            : theme.colorScheme.primary.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isReset ? theme.colorScheme.error : theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        deleteIcon: Icon(
          isReset ? Icons.refresh : Icons.close,
          size: 18,
          color: isReset ? theme.colorScheme.error : theme.colorScheme.primary,
        ),
        onDeleted: onTap,
      ),
    );
  }
}

extension on DestinationsLoading {
  bool get isFiltering => true;

  get lastLoadedDestinations => null;
}
