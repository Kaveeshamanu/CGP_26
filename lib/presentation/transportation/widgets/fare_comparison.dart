import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/transport.dart';

class FareComparison extends StatefulWidget {
  final List<TransportFare> fares;
  final String origin;
  final String destination;
  final TransportFare? selectedFare;
  final Function(TransportFare)? onFareSelected;
  final bool showDetailedComparison;

  const FareComparison({
    super.key,
    required this.fares,
    required this.origin,
    required this.destination,
    this.selectedFare,
    this.onFareSelected,
    this.showDetailedComparison = true,
  });

  @override
  State<FareComparison> createState() => _FareComparisonState();
}

class _FareComparisonState extends State<FareComparison> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TransportFare? _selectedFare;
  
  // Sorting options
  SortOption _sortOption = SortOption.price;
  bool _sortAscending = true;
  
  // Filter options
  Set<TransportType> _selectedTypes = {};
  RangeValues _priceRange = const RangeValues(0, 10000); // Default range in LKR
  int _maxTravelTime = 720; // Default max travel time in minutes (12 hours)
  
  // Grouped fares by transport type
  Map<TransportType, List<TransportFare>> _groupedFares = {};
  
  @override
  void initState() {
    super.initState();
    
    // Initialize selected fare if provided
    _selectedFare = widget.selectedFare;
    
    // Initialize tab controller for transport types
    _groupAndFilterFares();
    _tabController = TabController(
      length: _groupedFares.keys.length,
      vsync: this,
    );
    
    // Initialize filters with all transport types
    _selectedTypes = Set<TransportType>.from(widget.fares.map((fare) => fare.transportType));
  }

  @override
  void didUpdateWidget(FareComparison oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (!const ListEquality().equals(oldWidget.fares, widget.fares) ||
        oldWidget.selectedFare != widget.selectedFare) {
      _selectedFare = widget.selectedFare;
      _groupAndFilterFares();
      
      // Rebuild tab controller if transport types changed
      if (_tabController.length != _groupedFares.keys.length) {
        _tabController.dispose();
        _tabController = TabController(
          length: _groupedFares.keys.length,
          vsync: this,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _groupAndFilterFares() {
    // Filter fares based on selection criteria
    final filteredFares = widget.fares.where((fare) {
      // Filter by selected transport types
      if (_selectedTypes.isNotEmpty && !_selectedTypes.contains(fare.transportType)) {
        return false;
      }
      
      // Filter by price range
      if (fare.price < _priceRange.start || fare.price > _priceRange.end) {
        return false;
      }
      
      // Filter by travel time
      if (fare.durationMinutes > _maxTravelTime) {
        return false;
      }
      
      return true;
    }).toList();
    
    // Sort fares based on selected criteria
    _sortFares(filteredFares);
    
    // Group fares by transport type
    _groupedFares = groupBy(filteredFares, (TransportFare fare) => fare.transportType);
  }

  void _sortFares(List<TransportFare> fares) {
    switch (_sortOption) {
      case SortOption.price:
        fares.sort((a, b) => _sortAscending
            ? a.price.compareTo(b.price)
            : b.price.compareTo(a.price));
        break;
      case SortOption.duration:
        fares.sort((a, b) => _sortAscending
            ? a.durationMinutes.compareTo(b.durationMinutes)
            : b.durationMinutes.compareTo(a.durationMinutes));
        break;
      case SortOption.departureTime:
        fares.sort((a, b) => _sortAscending
            ? a.departureTime.compareTo(b.departureTime)
            : b.departureTime.compareTo(a.departureTime));
        break;
      case SortOption.arrivalTime:
        fares.sort((a, b) {
          if (a.arrivalTime == null || b.arrivalTime == null) {
            return 0;
          }
          return _sortAscending
              ? a.arrivalTime!.compareTo(b.arrivalTime!)
              : b.arrivalTime!.compareTo(a.arrivalTime!);
        });
        break;
      case SortOption.rating:
        fares.sort((a, b) {
          if (a.rating == null || b.rating == null) {
            return 0;
          }
          return _sortAscending
              ? a.rating!.compareTo(b.rating!)
              : b.rating!.compareTo(a.rating!);
        });
        break;
    }
  }

  void _onSortOptionChanged(SortOption? option) {
    if (option != null) {
      setState(() {
        _sortOption = option;
        _groupAndFilterFares();
      });
    }
  }

  void _toggleSortDirection() {
    setState(() {
      _sortAscending = !_sortAscending;
      _groupAndFilterFares();
    });
  }

  void _updatePriceRange(RangeValues values) {
    setState(() {
      _priceRange = values;
      _groupAndFilterFares();
    });
  }

  void _updateMaxTravelTime(double value) {
    setState(() {
      _maxTravelTime = value.toInt();
      _groupAndFilterFares();
    });
  }

  void _toggleTransportType(TransportType type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
      _groupAndFilterFares();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fares.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Origin and destination header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.origin} to ${widget.destination}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Sort controls
              Row(
                children: [
                  const Text(
                    'Sort by:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<SortOption>(
                    value: _sortOption,
                    onChanged: _onSortOptionChanged,
                    items: SortOption.values.map((option) {
                      return DropdownMenuItem<SortOption>(
                        value: option,
                        child: Text(_getSortOptionLabel(option)),
                      );
                    }).toList(),
                    underline: Container(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 18,
                    ),
                    onPressed: _toggleSortDirection,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  
                  const Spacer(),
                  
                  // Filter button
                  TextButton.icon(
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Filter'),
                    onPressed: _showFilterDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Transport type tabs
        if (_groupedFares.isNotEmpty)
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppTheme.primaryColor,
              tabs: _groupedFares.keys.map((type) {
                return Tab(
                  text: _getTransportTypeString(type),
                  icon: Icon(_getTransportTypeIcon(type), size: 18),
                );
              }).toList(),
            ),
          ),
        
        // Transport fares content
        if (_groupedFares.isNotEmpty)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _groupedFares.keys.map((type) {
                final fares = _groupedFares[type]!;
                return _buildFareList(fares);
              }).toList(),
            ),
          )
        else
          Expanded(
            child: _buildEmptyFilteredState(),
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
            Icons.no_transfer,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No fare information available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different route or transportation type',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilteredState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results match your filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareList(List<TransportFare> fares) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fares.length,
      itemBuilder: (context, index) {
        final fare = fares[index];
        final isSelected = _selectedFare != null && _selectedFare!.id == fare.id;
        
        return _buildFareCard(fare, isSelected);
      },
    );
  }

  Widget _buildFareCard(TransportFare fare, bool isSelected) {
    // Format the price
    final currencyFormatter = NumberFormat.currency(
      symbol: 'Rs. ',
      decimalDigits: 0,
    );
    final formattedPrice = currencyFormatter.format(fare.price);
    
    // Format departure time
    final departureTime = _formatTime(fare.departureTime);
    final arrivalTime = fare.arrivalTime != null ? _formatTime(fare.arrivalTime!) : 'N/A';
    
    // Format duration
    final hours = fare.durationMinutes ~/ 60;
    final minutes = fare.durationMinutes % 60;
    final duration = hours > 0 
        ? '${hours}h ${minutes > 0 ? '${minutes}m' : ''}'
        : '${minutes}m';
    
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (widget.onFareSelected != null) {
            widget.onFareSelected!(fare);
          }
          
          setState(() {
            _selectedFare = fare;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider name and rating
              Row(
                children: [
                  Icon(
                    _getTransportTypeIcon(fare.transportType),
                    color: _getTransportTypeColor(fare.transportType),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fare.providerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (fare.rating != null) ...[
                    Icon(
                      Icons.star,
                      color: Colors.amber[700],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      fare.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Time and duration info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Departure time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Departure',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        departureTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Duration
                  Column(
                    children: [
                      const Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Arrival time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Arrival',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        arrivalTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Features
              if (fare.features != null && fare.features!.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: fare.features!.map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              // Price and book button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      if (widget.onFareSelected != null) {
                        widget.onFareSelected!(fare);
                      }
                      
                      setState(() {
                        _selectedFare = fare;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Select'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Find min and max prices from all fares
            final minPrice = widget.fares.map((fare) => fare.price).reduce(
                  (value, element) => value < element ? value : element);
            final maxPrice = widget.fares.map((fare) => fare.price).reduce(
                  (value, element) => value > element ? value : element);
            
            // Find max travel time from all fares
            final maxTravelTimeFromFares = widget.fares.map((fare) => fare.durationMinutes).reduce(
                  (value, element) => value > element ? value : element);
            
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Transport types
                  const Text(
                    'Transport Types',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getAvailableTransportTypes().map((type) {
                      final isSelected = _selectedTypes.contains(type);
                      return FilterChip(
                        label: Text(_getTransportTypeString(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTypes.add(type);
                            } else {
                              _selectedTypes.remove(type);
                            }
                          });
                        },
                        selectedColor: _getTransportTypeColor(type).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? _getTransportTypeColor(type)
                              : Colors.black87,
                        ),
                        avatar: isSelected
                            ? Icon(_getTransportTypeIcon(type), size: 16, color: _getTransportTypeColor(type))
                            : null,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Price range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Rs. ${_priceRange.start.toInt()} - Rs. ${_priceRange.end.toInt()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _priceRange,
                    min: minPrice,
                    max: maxPrice,
                    divisions: 20,
                    labels: RangeLabels(
                      'Rs. ${_priceRange.start.toInt()}',
                      'Rs. ${_priceRange.end.toInt()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Max travel time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Max Travel Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDuration(_maxTravelTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _maxTravelTime.toDouble(),
                    min: 0,
                    max: maxTravelTimeFromFares.toDouble(),
                    divisions: 20,
                    label: _formatDuration(_maxTravelTime),
                    onChanged: (value) {
                      setState(() {
                        _maxTravelTime = value.toInt();
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resetFilters();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Reset All'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            
                            this.setState(() {
                              // Apply the filters set in the dialog
                              _selectedTypes = Set<TransportType>.from(_selectedTypes);
                              _priceRange = _priceRange;
                              _maxTravelTime = _maxTravelTime;
                              _groupAndFilterFares();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      // Reset all filters to defaults
      _selectedTypes = Set<TransportType>.from(widget.fares.map((fare) => fare.transportType));
      
      // Reset price range to min/max from fares
      final minPrice = widget.fares.map((fare) => fare.price).reduce(
            (value, element) => value < element ? value : element);
      final maxPrice = widget.fares.map((fare) => fare.price).reduce(
            (value, element) => value > element ? value : element);
      _priceRange = RangeValues(minPrice, maxPrice);
      
      // Reset max travel time
      final maxTime = widget.fares.map((fare) => fare.durationMinutes).reduce(
            (value, element) => value > element ? value : element);
      _maxTravelTime = maxTime;
      
      _groupAndFilterFares();
    });
  }

  Set<TransportType> _getAvailableTransportTypes() {
    return Set<TransportType>.from(widget.fares.map((fare) => fare.transportType));
  }

  String _getSortOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.price:
        return 'Price';
      case SortOption.duration:
        return 'Duration';
      case SortOption.departureTime:
        return 'Departure Time';
      case SortOption.arrivalTime:
        return 'Arrival Time';
      case SortOption.rating:
        return 'Rating';
      }
  }

  String _getTransportTypeString(TransportType type) {
    switch (type) {
      case TransportType.bus:
        return 'Bus';
      case TransportType.train:
        return 'Train';
      case TransportType.taxi:
        return 'Taxi';
      case TransportType.tuktuk:
        return 'Tuk-Tuk';
      case TransportType.car:
        return 'Car';
      default:
        return 'Unknown';
    }
  }

  IconData _getTransportTypeIcon(TransportType type) {
    switch (type) {
      case TransportType.bus:
        return Icons.directions_bus;
      case TransportType.train:
        return Icons.train;
      case TransportType.taxi:
        return Icons.local_taxi;
      case TransportType.tuktuk:
        return Icons.moped;
      case TransportType.car:
        return Icons.directions_car;
      default:
        return Icons.help;
    }
  }

  Color _getTransportTypeColor(TransportType type) {
    switch (type) {
      case TransportType.bus:
        return Colors.green;
      case TransportType.train:
        return Colors.purple;
      case TransportType.taxi:
        return Colors.amber;
      case TransportType.tuktuk:
        return Colors.orange;
      case TransportType.car:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String time) {
    // Format from 24-hour to 12-hour time
    // Expected input: "14:30"
    final parts = time.split(':');
    if (parts.length != 2) return time;
    
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    return '$hour:$minute $period';
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0) {
      return '$hours${mins > 0 ? 'h ${mins}m' : 'h'}';
    } else {
      return '${mins}m';
    }
  }
}

class TransportFare {
  final String id;
  final String providerName;
  final TransportType transportType;
  final double price;
  final String departureTime; // Format: "HH:MM"
  final String? arrivalTime; // Format: "HH:MM"
  final int durationMinutes;
  final double? distance; // in kilometers
  final double? rating;
  final List<String>? features;
  final String? vehicleType;
  final String? serviceClass;
  final String? notes;

  TransportFare({
    required this.id,
    required this.providerName,
    required this.transportType,
    required this.price,
    required this.departureTime,
    this.arrivalTime,
    required this.durationMinutes,
    this.distance,
    this.rating,
    this.features,
    this.vehicleType,
    this.serviceClass,
    this.notes,
  });
}

enum SortOption {
  price,
  duration,
  departureTime,
  arrivalTime,
  rating,
}