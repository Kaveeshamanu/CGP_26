import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../config/theme.dart';

class MapFilters extends StatefulWidget {
  final bool showAttractions;
  final bool showHotels;
  final bool showRestaurants;
  final bool showTransport;
  final Function({
    bool? showAttractions,
    bool? showHotels,
    bool? showRestaurants,
    bool? showTransport,
  }) onFiltersChanged;

  const MapFilters({
    super.key,
    required this.showAttractions,
    required this.showHotels,
    required this.showRestaurants,
    required this.showTransport,
    required this.onFiltersChanged,
  });

  @override
  State<MapFilters> createState() => _MapFiltersState();
}

class _MapFiltersState extends State<MapFilters> {
  late bool _showAttractions;
  late bool _showHotels;
  late bool _showRestaurants;
  late bool _showTransport;

  @override
  void initState() {
    super.initState();
    _showAttractions = widget.showAttractions;
    _showHotels = widget.showHotels;
    _showRestaurants = widget.showRestaurants;
    _showTransport = widget.showTransport;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Map Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Show or hide different types of locations on the map',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Filter options
          _buildFilterOption(
            icon: Icons.attractions,
            title: 'Attractions',
            subtitle: 'Tourist spots, landmarks, and activities',
            isActive: _showAttractions,
            onChanged: (value) {
              setState(() {
                _showAttractions = value;
              });
              widget.onFiltersChanged(showAttractions: value);
            },
            color: Colors.blue,
          ),
          const Divider(),
          
          _buildFilterOption(
            icon: Icons.hotel,
            title: 'Accommodations',
            subtitle: 'Hotels, homestays, and guesthouses',
            isActive: _showHotels,
            onChanged: (value) {
              setState(() {
                _showHotels = value;
              });
              widget.onFiltersChanged(showHotels: value);
            },
            color: Colors.purple,
          ),
          const Divider(),
          
          _buildFilterOption(
            icon: Icons.restaurant,
            title: 'Restaurants',
            subtitle: 'Dining options and food services',
            isActive: _showRestaurants,
            onChanged: (value) {
              setState(() {
                _showRestaurants = value;
              });
              widget.onFiltersChanged(showRestaurants: value);
            },
            color: Colors.orange,
          ),
          const Divider(),
          
          _buildFilterOption(
            icon: Icons.directions_bus,
            title: 'Transport',
            subtitle: 'Bus stops, train stations, and transport hubs',
            isActive: _showTransport,
            onChanged: (value) {
              setState(() {
                _showTransport = value;
              });
              widget.onFiltersChanged(showTransport: value);
            },
            color: Colors.green,
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAttractions = true;
                    _showHotels = true;
                    _showRestaurants = true;
                    _showTransport = true;
                  });
                  widget.onFiltersChanged(
                    showAttractions: true,
                    showHotels: true,
                    showRestaurants: true,
                    showTransport: true,
                  );
                },
                child: const Text('Show All'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAttractions = false;
                    _showHotels = false;
                    _showRestaurants = false;
                    _showTransport = false;
                  });
                  widget.onFiltersChanged(
                    showAttractions: false,
                    showHotels: false,
                    showRestaurants: false,
                    showTransport: false,
                  );
                },
                child: const Text('Hide All'),
              ),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive ? color : Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isActive,
          onChanged: onChanged,
          activeColor: color,
        ),
      ],
    );
  }
}