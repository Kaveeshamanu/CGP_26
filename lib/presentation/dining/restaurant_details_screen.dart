import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taprobana_trails/bloc/restaurant/restaurant_state.dart';
import 'package:taprobana_trails/presentation/dining/restaurant_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../bloc/restaurant/restaurant_bloc.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../data/models/restaurant.dart';
import '../../core/utils/connectivity.dart';
import '../../core/utils/date_utils.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/buttons.dart';
import '../common/widgets/loaders.dart';
import 'widgets/menu_viewer.dart';
import 'widgets/restaurant_card.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantId;
  
  const RestaurantDetailsScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> with TickerProviderStateMixin {
  final PanelController _panelController = PanelController();
  final CarouselController _carouselController = CarouselController();
  
  late TabController _tabController;
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _isBookmarked = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load restaurant details when screen is opened
    context.read<RestaurantBloc>().add(LoadRestaurantDetails(widget.restaurantId));
    
    // Check if restaurant is in favorites or bookmarks
    _checkFavoriteStatus();
    _checkBookmarkStatus();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _checkFavoriteStatus() async {
    // This would typically come from your user preferences or repository
    setState(() {
      _isFavorite = false; // Replace with actual implementation
    });
  }
  
  void _checkBookmarkStatus() async {
    // This would typically come from your user preferences or repository
    setState(() {
      _isBookmarked = false; // Replace with actual implementation
    });
  }
  
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    // Update the favorite status in repository/preferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite 
          ? 'Added to favorites' 
          : 'Removed from favorites'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    // Update the bookmark status in repository/preferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked 
          ? 'Saved to your places' 
          : 'Removed from your places'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _shareRestaurant(Restaurant restaurant) {
    Share.share(
      'Check out ${restaurant.name} on Taprobana Trails! ${restaurant.description} Download the app now.',
      subject: 'Great restaurant in Sri Lanka: ${restaurant.name}',
    );
  }
  
  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch phone call'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  void _openWebsite(String website) async {
    if (await canLaunch(website)) {
      await launch(website);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open website'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  void _openLocation(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open maps'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  void _navigateToReservation(Restaurant restaurant) {
    Navigator.pushNamed(
      context,
      AppRoutes.restaurantReservation,
      arguments: restaurant,
    );
  }
  
  void _submitReview() {
    // TODO: Implement review submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Review feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantDetailsLoading) {
          return Scaffold(
            body: LoadingSpinner(),
          );
        }
        
        if (state is RestaurantDetailsError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
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
                    'Failed to load restaurant details',
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
                    onPressed: () => context.read<RestaurantBloc>().add(
                      LoadRestaurantDetails(widget.restaurantId),
                    ),
                    child: Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (state is RestaurantDetailsLoaded) {
          final restaurant = state.restaurant;
          final isOpen = _isRestaurantOpenNow(restaurant.openingHours);
          
          return Scaffold(
            body: SlidingUpPanel(
              controller: _panelController,
              minHeight: screenHeight * 0.5,
              maxHeight: screenHeight * 0.85,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              parallaxEnabled: true,
              parallaxOffset: 0.5,
              body: _buildImageCarousel(restaurant),
              panelBuilder: (scrollController) => _buildDetailsPanel(
                context,
                restaurant,
                scrollController,
                isOpen,
              ),
            ),
          );
        }
        
        // Default loading state
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
  
  Widget _buildImageCarousel(Restaurant restaurant) {
    return Stack(
      children: [
        // Image carousel
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.6,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: restaurant.images.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
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
                );
              },
            );
          }).toList(),
        ),
        
        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black.withOpacity(0.4),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        
        // Action buttons
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _isBookmarked ? Colors.amber : Colors.white,
                  ),
                  onPressed: _toggleBookmark,
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: Icon(Icons.share, color: Colors.white),
                  onPressed: () => _shareRestaurant(restaurant),
                ),
              ),
            ],
          ),
        ),
        
        // Image indicators
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.5 + 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: restaurant.images.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(
                    _currentImageIndex == entry.key ? 0.9 : 0.4,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailsPanel(
    BuildContext context,
    Restaurant restaurant,
    ScrollController scrollController,
    bool isOpen,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel drag handle
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        // Restaurant name and rating
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant.location,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        restaurant.rating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${restaurant.reviewCount} reviews',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: 12),
        
        // Cuisine type, price level, and open status
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              _buildInfoChip(
                context,
                restaurant.cuisineTypes,
                Icons.restaurant,
              ),
              SizedBox(width: 8),
              _buildInfoChip(
                context,
                _getPriceText(restaurant.priceLevel),
                Icons.attach_money,
              ),
              SizedBox(width: 8),
              _buildOpenStatusChip(context, isOpen),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // Quick action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              _buildActionButton(
                context,
                'Call',
                Icons.call,
                () => _makePhoneCall(restaurant.phoneNumber),
              ),
              SizedBox(width: 12),
              _buildActionButton(
                context,
                'Website',
                Icons.language,
                () => _openWebsite(restaurant.website),
              ),
              SizedBox(width: 12),
              _buildActionButton(
                context,
                'Directions',
                Icons.directions,
                () => _openLocation(
                  restaurant.latitude,
                  restaurant.longitude,
                ),
              ),
              SizedBox(width: 12),
              _buildActionButton(
                context,
                'Save',
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                _toggleBookmark,
                isSelected: _isBookmarked,
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // Reserve button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ElevatedButton(
            onPressed: isOpen 
              ? () => _navigateToReservation(restaurant)
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isOpen ? 'Reserve a Table' : 'Currently Closed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 16),
        
        // Tab bar
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
            indicatorColor: theme.colorScheme.primary,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Menu'),
              Tab(text: 'Reviews'),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, restaurant, scrollController),
              _buildMenuTab(context, restaurant, scrollController),
              _buildReviewsTab(context, restaurant, scrollController),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoChip(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOpenStatusChip(BuildContext context, bool isOpen) {
    Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOpen ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            isOpen ? 'Open Now' : 'Closed',
            style: TextStyle(
              color: isOpen ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
    {bool isSelected = false}
  ) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isSelected
                  ? Colors.white
                  : theme.colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewTab(
    BuildContext context,
    Restaurant restaurant,
    ScrollController scrollController,
  ) {
    final theme = Theme.of(context);
    
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.all(24),
      children: [
        // About section
        Text(
          'About',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          restaurant.description,
          style: theme.textTheme.bodyMedium,
        ),
        SizedBox(height: 24),
        
        // Location and map preview
        Text(
          'Location',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 48,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 12),
                Text(
                  'Map preview would appear here',
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _openLocation(
                    restaurant.latitude,
                    restaurant.longitude,
                  ),
                  icon: Icon(Icons.directions),
                  label: Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),
        
        // Opening hours
        Text(
          'Opening Hours',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Column(
          children: [
            _buildOpeningHoursRow('Monday', restaurant.mondayHours),
            _buildOpeningHoursRow('Tuesday', restaurant.tuesdayHours),
            _buildOpeningHoursRow('Wednesday', restaurant.wednesdayHours),
            _buildOpeningHoursRow('Thursday', restaurant.thursdayHours),
            _buildOpeningHoursRow('Friday', restaurant.fridayHours),
            _buildOpeningHoursRow('Saturday', restaurant.saturdayHours),
            _buildOpeningHoursRow('Sunday', restaurant.sundayHours),
          ],
        ),
        SizedBox(height: 24),
        
        // Facilities
        Text(
          'Facilities',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: restaurant.facilities.map((facility) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline,
                ),
              ),
              child: Text(
                facility,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 24),
        
        // Contact information
        Text(
          'Contact Information',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        _buildContactInfoRow(
          'Phone',
          restaurant.phoneNumber,
          Icons.call,
          () => _makePhoneCall(restaurant.phoneNumber),
        ),
        SizedBox(height: 8),
        _buildContactInfoRow(
          'Website',
          restaurant.website,
          Icons.language,
          () => _openWebsite(restaurant.website),
        ),
        SizedBox(height: 8),
        _buildContactInfoRow(
          'Email',
          restaurant.email,
          Icons.email,
          () 
          {/* TODO: Implement email action */},
        ),
      ],
    );
  }
  
  Widget _buildOpeningHoursRow(String day, String hours) {
    final theme = Theme.of(context);
    final isToday = _isToday(day);
    final isOpen = _isDayOpen(hours);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isToday) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
              ] else
                SizedBox(width: 16),
              Text(
                day,
                style: isToday
                  ? TextStyle(fontWeight: FontWeight.bold)
                  : null,
              ),
            ],
          ),
          Text(
            hours == 'Closed' ? 'Closed' : hours,
            style: TextStyle(
              color: hours == 'Closed'
                ? Colors.red
                : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactInfoRow(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuTab(
    BuildContext context,
    Restaurant restaurant,
    ScrollController scrollController,
  ) {
    final theme = Theme.of(context);
    
    // This would typically be implemented with a MenuViewer widget
    // For this example, we'll create a simple placeholder
    return restaurant.menuItems.isEmpty
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'Menu not available',
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Text(
                'The restaurant hasn\'t provided a menu yet',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
      : ListView(
          controller: scrollController,
          padding: EdgeInsets.all(16),
          children: [
            // Menu categories
            ...restaurant.menuCategories.map((category) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    category,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Menu items for this category
                ...restaurant.menuItems
                  .where((item) => item.category == category)
                  .map((item) => _buildMenuItem(context, item)),
                SizedBox(height: 16),
              ],
            )),
          ],
        );
  }
  
  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image (if available)
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                      width: 80,
                      height: 80,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            
            SizedBox(width: item.imageUrl != null ? 16 : 0),
            
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  if (item.description != null) ...[
                    SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  SizedBox(height: 8),
                  
                  // Tags (spicy, vegetarian, etc.)
                  if (item.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: item.tags.map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTagColor(tag, theme).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: _getTagColor(tag, theme),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
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
  
  Color _getTagColor(String tag, ThemeData theme) {
    switch (tag.toLowerCase()) {
      case 'spicy':
        return Colors.red;
      case 'vegetarian':
        return Colors.green;
      case 'vegan':
        return Colors.green.shade700;
      case 'gluten-free':
        return Colors.amber.shade800;
      case 'chef\'s special':
      case 'special':
        return theme.colorScheme.primary;
      case 'popular':
        return Colors.purple;
      default:
        return theme.colorScheme.primary;
    }
  }
  
  Widget _buildReviewsTab(
    BuildContext context,
    Restaurant restaurant,
    ScrollController scrollController,
  ) {
    final theme = Theme.of(context);
    
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.all(16),
      children: [
        // Rating summary card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Average rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      restaurant.rating.toString(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingBar.builder(
                          initialRating: restaurant.rating,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20,
                          ignoreGestures: true,
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (_) {},
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${restaurant.reviewCount} reviews',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Rating distribution
                Column(
                  children: [
                    _buildRatingBar(context, 5, 0.65),
                    _buildRatingBar(context, 4, 0.25),
                    _buildRatingBar(context, 3, 0.07),
                    _buildRatingBar(context, 2, 0.02),
                    _buildRatingBar(context, 1, 0.01),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Write a review button
                OutlinedButton.icon(
                  onPressed: _submitReview,
                  icon: Icon(Icons.edit),
                  label: Text('Write a Review'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 16),
        
        // Reviews heading
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Show all reviews
                },
                child: Text('See All'),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 8),
        
        // Review list
        ...restaurant.reviews.take(5).map((review) => _buildReviewItem(context, review)),
      ],
    );
  }
  
  Widget _buildRatingBar(BuildContext context, int rating, double percentage) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              '$rating',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.star,
            color: Colors.amber,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[300],
                color: theme.colorScheme.primary,
                minHeight: 8,
              ),
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewItem(BuildContext context, Review review) {
    final theme = Theme.of(context);
    final timeAgo = timeago.format(review.date);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reviewer info and rating
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.authorImage != null
                    ? CachedNetworkImageProvider(review.authorImage!)
                    : null,
                  child: review.authorImage == null
                    ? Text(review.authorName[0])
                    : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.authorName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          RatingBar.builder(
                            initialRating: review.rating,
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 14,
                            ignoreGestures: true,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (_) {},
                          ),
                          SizedBox(width: 8),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Review content
            Text(
              review.content,
              style: theme.textTheme.bodyMedium,
            ),
            
            if (review.photos.isNotEmpty) ...[
              SizedBox(height: 12),
              
              // Review photos
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 80,
                      height: 80,
                      margin: EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: review.photos[index],
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
                    );
                  },
                ),
              ),
            ],
            
            // If there's owner response
            if (review.ownerResponse != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Response from owner',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      review.ownerResponse!,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Helper methods
  bool _isRestaurantOpenNow(String openingHours) {
    // This would typically involve parsing the opening hours
    // and checking against current time
    // For this example, we'll assume it's open
    return true;
  }
  
  bool _isToday(String day) {
    final today = DateFormat('EEEE').format(DateTime.now());
    return day.toLowerCase() == today.toLowerCase();
  }
  
  bool _isDayOpen(String hours) {
    return hours != 'Closed';
  }
  
  String _getPriceText(int priceLevel) {
    switch (priceLevel) {
      case 1:
        return 'Budget';
      case 2:
        return 'Moderate';
      case 3:
        return 'Expensive';
      case 4:
        return 'Luxury';
      default:
        return 'Moderate';
    }
  }
}

// Model classes for this screen

class MenuItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final String? imageUrl;
  final List<String> tags;
  
  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    required this.tags,
  });
}

class Review {
  final String id;
  final String authorName;
  final String? authorImage;
  final double rating;
  final String content;
  final DateTime date;
  final List<String> photos;
  final String? ownerResponse;
  
  Review({
    required this.id,
    required this.authorName,
    this.authorImage,
    required this.rating,
    required this.content,
    required this.date,
    required this.photos,
    this.ownerResponse,
  });
}