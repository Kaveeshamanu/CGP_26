import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../bloc/destination/destination_bloc.dart';
import '../../../data/models/destination.dart';
import '../../common/widgets/buttons.dart';

class FilterModal extends StatefulWidget {
  final RangeValues priceRange;
  final double minRating;
  final List<String> selectedRegions;
  final List<String> selectedTags;
  final Function({
    required RangeValues priceRange,
    required double minRating,
    required List<String> selectedRegions,
    required List<String> selectedTags,
  }) onApplyFilter;
  final VoidCallback onResetFilter;

  const FilterModal({
    super.key,
    required this.priceRange,
    required this.minRating,
    required this.selectedRegions,
    required this.selectedTags,
    required this.onApplyFilter,
    required this.onResetFilter,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late RangeValues _priceRange;
  late double _minRating;
  late List<String> _selectedRegions;
  late List<String> _selectedTags;
  
  // Available filter options (would come from your data in a real app)
  final List<String> _allRegions = [
    'Central Province',
    'Eastern Province',
    'North Central Province',
    'Northern Province',
    'North Western Province',
    'Sabaragamuwa Province',
    'Southern Province',
    'Uva Province',
    'Western Province',
  ];
  
  final List<String> _allTags = [
    'Beach',
    'Mountain',
    'Cultural',
    'Wildlife',
    'Adventure',
    'Historical',
    'Temple',
    'Waterfall',
    'Hiking',
    'Surfing',
    'Safari',
    'UNESCO',
    'Scenic',
    'Diving',
    'Food',
    'Shopping',
    'Luxury',
    'Budget',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current filter values
    _priceRange = widget.priceRange;
    _minRating = widget.minRating;
    _selectedRegions = List.from(widget.selectedRegions);
    _selectedTags = List.from(widget.selectedTags);
  }

  void _resetFilters() {
    setState(() {
      _priceRange = RangeValues(0, 1000);
      _minRating = 0.0;
      _selectedRegions = [];
      _selectedTags = [];
    });
  }
  
  void _applyFilters() {
    widget.onApplyFilter(
      priceRange: _priceRange,
      minRating: _minRating,
      selectedRegions: _selectedRegions,
      selectedTags: _selectedTags,
    );
    Navigator.pop(context);
  }
  
  void _toggleRegion(String region) {
    setState(() {
      if (_selectedRegions.contains(region)) {
        _selectedRegions.remove(region);
      } else {
        _selectedRegions.add(region);
      }
    });
  }
  
  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Destinations',
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
          ),
          
          // Filter options
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                // Price range
                _buildSectionTitle('Price Range (USD)'),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${_priceRange.start.round()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${_priceRange.end.round()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  labels: RangeLabels(
                    '\$${_priceRange.start.round()}',
                    '\$${_priceRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                
                SizedBox(height: 20),
                
                // Minimum rating
                _buildSectionTitle('Minimum Rating'),
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
                
                SizedBox(height: 20),
                
                // Regions
                _buildSectionTitle('Regions'),
                SizedBox(height: 8),
                _buildRegionsGrid(),
                
                SizedBox(height: 20),
                
                // Tags
                _buildSectionTitle('Tags'),
                SizedBox(height: 8),
                _buildTagsGrid(),
              ],
            ),
          ),
          
          // Action buttons
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _resetFilters();
                      widget.onResetFilter();
                      Navigator.pop(context);
                    },
                    child: Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: Text('Apply Filters'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildRegionsGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allRegions.map((region) {
        final isSelected = _selectedRegions.contains(region);
        
        return FilterChip(
          label: Text(region),
          selected: isSelected,
          onSelected: (_) => _toggleRegion(region),
          backgroundColor: Colors.grey[200],
          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          checkmarkColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildTagsGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allTags.map((tag) {
        final isSelected = _selectedTags.contains(tag);
        
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (_) => _toggleTag(tag),
          backgroundColor: Colors.grey[200],
          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          checkmarkColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}