import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/restaurant.dart';
import '../../../config/theme.dart';

class MenuViewer extends StatefulWidget {
  final List<MenuItem> menuItems;
  final List<String> categories;
  final VoidCallback? onClose;
  final bool showPrices;
  final bool allowFiltering;
  
  const MenuViewer({
    super.key,
    required this.menuItems,
    required this.categories,
    this.onClose,
    this.showPrices = true,
    this.allowFiltering = true,
  });

  @override
  State<MenuViewer> createState() => _MenuViewerState();
}

class _MenuViewerState extends State<MenuViewer> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;
  String _searchQuery = '';
  
  List<MenuItem> get _filteredItems {
    return widget.menuItems.where((item) {
      // Filter by category if selected
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      
      // Filter by search query if provided
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return item.name.toLowerCase().contains(query) ||
               (item.description?.toLowerCase().contains(query) ?? false) ||
               item.tags.any((tag) => tag.toLowerCase().contains(query));
      }
      
      return true;
    }).toList();
  }
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.categories.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    
    // Initialize with first category
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabSelection() {
    if (_tabController.indexIsChanging || _tabController.index != _tabController.previousIndex) {
      setState(() {
        _selectedCategory = widget.categories[_tabController.index];
      });
    }
  }
  
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }
  
  void _clearSearch() {
    setState(() {
      _searchQuery = '';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Header with search
        if (widget.allowFiltering) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search menu items',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: _clearSearch,
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
        
        // Category tabs
        if (widget.allowFiltering && _searchQuery.isEmpty) ...[
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
            indicatorColor: theme.colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            padding: EdgeInsets.symmetric(horizontal: 16),
            tabs: widget.categories.map((category) => Tab(text: category)).toList(),
          ),
        ],
        
        // Menu items
        Expanded(
          child: _filteredItems.isEmpty
            ? _buildEmptyState()
            : _searchQuery.isNotEmpty
              ? _buildSearchResults()
              : TabBarView(
                  controller: _tabController,
                  children: widget.categories.map((category) {
                    return _buildCategoryMenuItems(category);
                  }).toList(),
                ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
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
            _searchQuery.isNotEmpty
              ? 'No items match your search'
              : 'No menu items available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
              ? 'Try a different search term'
              : 'The restaurant hasn\'t provided a menu yet',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearSearch,
              child: Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return _buildMenuItem(_filteredItems[index]);
      },
    );
  }
  
  Widget _buildCategoryMenuItems(String category) {
    final categoryItems = widget.menuItems
      .where((item) => item.category == category)
      .toList();
    
    return categoryItems.isEmpty
      ? Center(
          child: Text('No items in this category'),
        )
      : ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: categoryItems.length,
          itemBuilder: (context, index) {
            return _buildMenuItem(categoryItems[index]);
          },
        );
  }
  
  Widget _buildMenuItem(MenuItem item) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image (if available)
            if (item.imageUrl != null) ...[
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
              SizedBox(width: 16),
            ],
            
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name and price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.showPrices) ...[
                        SizedBox(width: 8),
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Description (if available)
                  if (item.description != null) ...[
                    SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                  
                  // Tags
                  if (item.tags.isNotEmpty) ...[
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.tags.map((tag) => _buildTagChip(tag)).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTagChip(String tag) {
    final theme = Theme.of(context);
    final tagColor = _getTagColor(tag, theme);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tagColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTagIcon(tag),
            size: 12,
            color: tagColor,
          ),
          SizedBox(width: 4),
          Text(
            tag,
            style: TextStyle(
              color: tagColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getTagColor(String tag, ThemeData theme) {
    switch (tag.toLowerCase()) {
      case 'vegetarian':
        return Colors.green;
      case 'vegan':
        return Colors.green.shade700;
      case 'gluten-free':
      case 'gluten free':
        return Colors.amber.shade700;
      case 'spicy':
      case 'hot':
        return Colors.red;
      case 'chef\'s special':
      case 'special':
      case 'chef special':
        return theme.colorScheme.primary;
      case 'popular':
      case 'bestseller':
        return Colors.purple;
      case 'new':
        return Colors.blue;
      case 'dairy-free':
      case 'dairy free':
        return Colors.lightBlue;
      case 'organic':
        return Colors.teal;
      case 'local':
        return Colors.deepOrange;
      default:
        return theme.colorScheme.primary;
    }
  }
  
  IconData _getTagIcon(String tag) {
    switch (tag.toLowerCase()) {
      case 'vegetarian':
        return Icons.spa;
      case 'vegan':
        return Icons.eco;
      case 'gluten-free':
      case 'gluten free':
        return Icons.no_food;
      case 'spicy':
      case 'hot':
        return Icons.whatshot;
      case 'chef\'s special':
      case 'special':
      case 'chef special':
        return Icons.star;
      case 'popular':
      case 'bestseller':
        return Icons.thumb_up;
      case 'new':
        return Icons.fiber_new;
      case 'dairy-free':
      case 'dairy free':
        return Icons.no_drinks;
      case 'organic':
        return Icons.grass;
      case 'local':
        return Icons.location_on;
      default:
        return Icons.label;
    }
  }
}

// This is a model class for the menu items
// In a real app, this might be imported from a models file
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