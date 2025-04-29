import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../bloc/deals/deals_bloc.dart';
import '../../bloc/deals/deals_event.dart';
import '../../bloc/deals/deals_state.dart';
import '../../data/models/user.dart';
import '../../core/utils/connectivity.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import '../common/widgets/cards.dart';
import 'widgets/deal_card.dart';
import 'widgets/loyalty_program.dart';

class DealsScreen extends StatefulWidget {
  final String? categoryFilter;

  const DealsScreen({
    super.key,
    this.categoryFilter,
  });

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> with SingleTickerProviderStateMixin {
  late DealsBloc _dealsBloc;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String _currentQuery = '';
  int _selectedCategoryIndex = 0;

  final List<String> _dealCategories = [
    'All Deals',
    'Hotels',
    'Restaurants',
    'Activities',
    'Transport',
    'Packages',
  ];

  final List<IconData> _categoryIcons = [
    Icons.local_offer,
    Icons.hotel,
    Icons.restaurant,
    Icons.local_activity,
    Icons.directions_bus,
    Icons.card_travel,
  ];

  @override
  void initState() {
    super.initState();
    _dealsBloc = BlocProvider.of<DealsBloc>(context);
    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    // Set initial category if provided
    if (widget.categoryFilter != null) {
      final categoryIndex = _dealCategories.indexWhere(
        (category) => category.toLowerCase() == widget.categoryFilter?.toLowerCase(),
      );
      if (categoryIndex != -1) {
        _selectedCategoryIndex = categoryIndex;
      }
    }

    // Load initial data
    _loadDeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadDeals() {
    final category = _selectedCategoryIndex == 0 
        ? null 
        : _dealCategories[_selectedCategoryIndex];
    
    _dealsBloc.add(DealsRequested(
      category: category,
      searchQuery: _currentQuery.isEmpty ? null : _currentQuery,
    ));
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _currentQuery = '';
        _loadDeals();
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      _currentQuery = query;
    });
    _loadDeals();
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    _loadDeals();
  }

  void _refreshDeals() {
    _loadDeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCategorySelector(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDealsList(sortBy: 'featured'),
                _buildDealsList(sortBy: 'ending_soon'),
                _buildDealsList(sortBy: 'discount'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return _isSearchActive
        ? SearchAppBar(
            title: 'Deals & Offers',
            hintText: 'Search deals...',
            onSearch: _performSearch,
            onBackPressed: _toggleSearch,
          )
        : CustomAppBar(
            title: 'Deals & Offers',
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _toggleSearch,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshDeals,
              ),
            ],
          );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: _dealCategories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _selectCategory(index),
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.4),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Icon(
                      _categoryIcons[index],
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  _dealCategories[index],
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.0,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        indicatorColor: Theme.of(context).primaryColor,
        indicatorWeight: 3.0,
        tabs: const [
          Tab(text: 'Featured'),
          Tab(text: 'Ending Soon'),
          Tab(text: 'Best Discount'),
        ],
        onTap: (index) {
          // Reload data when tab changes
          _loadDeals();
        },
      ),
    );
  }

  Widget _buildDealsList({required String sortBy}) {
    return BlocBuilder<DealsBloc, DealsState>(
      builder: (context, state) {
        if (state is DealsInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DealsLoading && state.deals.isEmpty) {
          return ContentLoader(
            itemCount: 5,
            showImage: true,
            height: 180.0,
          );
        } else if (state is DealsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48.0,
                  color: Colors.red,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Error: ${state.message}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _refreshDeals,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Get deals from state and sort them
        final deals = state is DealsLoaded 
            ? _sortDeals(state.deals, sortBy)
            : state is DealsLoading
                ? _sortDeals(state.deals, sortBy)
                : [];

        if (deals.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            _refreshDeals();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: deals.length + 1 + (state is DealsLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0) {
                // Loyalty program card at the top
                return _buildLoyaltyProgramCard();
              }
              
              if (index == deals.length + 1) {
                // Loading indicator at the bottom if still loading
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Adjust index for the deals (because of loyalty card)
              final dealIndex = index - 1;
              final deal = deals[dealIndex];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DealCard(
                  dealData: deal,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/deal_details',
                      arguments: {'dealId': deal['id']},
                    ).then((_) => _loadDeals());
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoyaltyProgramCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withRed(
                Theme.of(context).primaryColor.red - 40,
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/loyalty_program');
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.loyalty,
                      color: Colors.white,
                      size: 40.0,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loyalty Program',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          const Text(
                            'Earn points and unlock exclusive rewards',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    IconData iconData;
    String message;

    if (_currentQuery.isNotEmpty) {
      iconData = Icons.search_off;
      message = 'No deals found matching "$_currentQuery"';
    } else if (_selectedCategoryIndex != 0) {
      iconData = _categoryIcons[_selectedCategoryIndex];
      message = 'No deals available in ${_dealCategories[_selectedCategoryIndex]}';
    } else {
      iconData = Icons.local_offer;
      message = 'No deals available at the moment';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 64.0,
            color: Colors.grey,
          ),
          const SizedBox(height: 16.0),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              if (_selectedCategoryIndex != 0 || _currentQuery.isNotEmpty) {
                setState(() {
                  _selectedCategoryIndex = 0;
                  _currentQuery = '';
                  if (_isSearchActive) {
                    _searchController.clear();
                    _toggleSearch();
                  }
                });
                _loadDeals();
              } else {
                _refreshDeals();
              }
            },
            child: Text(
              _selectedCategoryIndex != 0 || _currentQuery.isNotEmpty
                  ? 'Show All Deals'
                  : 'Refresh',
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _sortDeals(
    List<Map<String, dynamic>> deals, 
    String sortBy,
  ) {
    final sortedDeals = List<Map<String, dynamic>>.from(deals);
    
    switch (sortBy) {
      case 'featured':
        sortedDeals.sort((a, b) {
          final aFeatured = a['isFeatured'] as bool? ?? false;
          final bFeatured = b['isFeatured'] as bool? ?? false;
          if (aFeatured != bFeatured) {
            return aFeatured ? -1 : 1;
          }
          
          final aPopularity = a['popularity'] as int? ?? 0;
          final bPopularity = b['popularity'] as int? ?? 0;
          return bPopularity.compareTo(aPopularity);
        });
        break;
      case 'ending_soon':
        sortedDeals.sort((a, b) {
          final aEndDate = DateTime.parse(a['endDate'] as String);
          final bEndDate = DateTime.parse(b['endDate'] as String);
          return aEndDate.compareTo(bEndDate);
        });
        break;
      case 'discount':
        sortedDeals.sort((a, b) {
          final aDiscount = a['discountPercentage'] as int? ?? 0;
          final bDiscount = b['discountPercentage'] as int? ?? 0;
          return bDiscount.compareTo(aDiscount);
        });
        break;
    }
    
    return sortedDeals;
  }
}