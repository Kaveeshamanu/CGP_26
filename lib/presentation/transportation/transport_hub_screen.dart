import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../config/theme.dart';
import '../../data/models/transport.dart';
import '../../data/models/destination.dart';
import '../../bloc/destination/destination_bloc.dart';
import '../../bloc/transport/transport_bloc.dart';
import '../../bloc/transport/transport_event.dart';
import '../../bloc/transport/transport_state.dart';
import '../../core/location/location_service.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import 'widgets/transport_type_selector.dart';
import 'transport_booking_screen.dart';

class TransportHubScreen extends StatefulWidget {
  final String? destinationId;
  final TransportType? initialTransportType;

  const TransportHubScreen({
    super.key,
    this.destinationId,
    this.initialTransportType,
  });

  @override
  State<TransportHubScreen> createState() => _TransportHubScreenState();
}

class _TransportHubScreenState extends State<TransportHubScreen> {
  final LocationService _locationService = LocationService();
  final CarouselController _carouselController = CarouselController();
  
  bool _isLoading = false;
  TransportType _selectedTransportType = TransportType.all;
  int _selectedTabIndex = 0;
  int _currentCarouselIndex = 0;
  Destination? _destination;
  LatLng? _currentLocation;
  
  // Map controller
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  
  // Filter criteria
  String _searchQuery = '';
  double _maxDistance = 10.0; // km
  bool _onlyAvailableNow = false;
  
  @override
  void initState() {
    super.initState();
    
    // Set initial transport type if provided
    if (widget.initialTransportType != null) {
      _selectedTransportType = widget.initialTransportType!;
      
      // Set the corresponding tab index
      switch (_selectedTransportType) {
        case TransportType.bus:
          _selectedTabIndex = 0;
          break;
        case TransportType.train:
          _selectedTabIndex = 1;
          break;
        case TransportType.taxi:
          _selectedTabIndex = 2;
          break;
        case TransportType.tuktuk:
          _selectedTabIndex = 3;
          break;
        case TransportType.all:
          _selectedTabIndex = 4;
          break;
        default:
          _selectedTabIndex = 0;
      }
    }
    
    _getUserLocation();
    
    // Load destination data if destinationId is provided
    if (widget.destinationId != null) {
      context.read<DestinationBloc>().add(
        LoadDestinationDetails(destinationId: widget.destinationId!),
      );
    }
    
    // Load transport options
    _loadTransportOptions();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  void _loadTransportOptions() {
    // Initial load of transport options based on current filter
    context.read<TransportBloc>().add(
      LoadTransportOptions(
        destinationId: widget.destinationId,
        transportType: _selectedTransportType,
        searchQuery: _searchQuery,
        userLocation: _currentLocation,
        maxDistance: _maxDistance,
        onlyAvailableNow: _onlyAvailableNow,
      ),
    );
  }

  void _onTransportTypeChanged(TransportType type) {
    setState(() {
      _selectedTransportType = type;
      
      // Update tab index based on transport type
      switch (type) {
        case TransportType.bus:
          _selectedTabIndex = 0;
          break;
        case TransportType.train:
          _selectedTabIndex = 1;
          break;
        case TransportType.taxi:
          _selectedTabIndex = 2;
          break;
        case TransportType.tuktuk:
          _selectedTabIndex = 3;
          break;
        case TransportType.all:
          _selectedTabIndex = 4;
          break;
        default:
          _selectedTabIndex = 0;
      }
    });
    
    // Load transport options for the selected type
    context.read<TransportBloc>().add(
      LoadTransportOptions(
        destinationId: widget.destinationId,
        transportType: _selectedTransportType,
        searchQuery: _searchQuery,
        userLocation: _currentLocation,
        maxDistance: _maxDistance,
        onlyAvailableNow: _onlyAvailableNow,
      ),
    );
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
      
      // Update transport type based on tab index
      switch (index) {
        case 0:
          _selectedTransportType = TransportType.bus;
          break;
        case 1:
          _selectedTransportType = TransportType.train;
          break;
        case 2:
          _selectedTransportType = TransportType.taxi;
          break;
        case 3:
          _selectedTransportType = TransportType.tuktuk;
          break;
        case 4:
          _selectedTransportType = TransportType.all;
          break;
        default:
          _selectedTransportType = TransportType.bus;
      }
    });
    
    // Load transport options for the selected type
    context.read<TransportBloc>().add(
      LoadTransportOptions(
        destinationId: widget.destinationId,
        transportType: _selectedTransportType,
        searchQuery: _searchQuery,
        userLocation: _currentLocation,
        maxDistance: _maxDistance,
        onlyAvailableNow: _onlyAvailableNow,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMarkers();
  }

  void _updateMarkers() {
    // Clear existing markers
    _markers.clear();
    
    // Get transport options from the current state
    final state = context.read<TransportBloc>().state;
    if (state is TransportOptionsLoaded) {
      // Add markers for each transport option
      for (final option in state.transportOptions) {
        if (option.latitude != null && option.longitude != null) {
          final marker = Marker(
            markerId: MarkerId(option.id),
            position: LatLng(option.latitude!, option.longitude!),
            infoWindow: InfoWindow(
              title: option.name,
              snippet: _getTransportTypeString(option.type),
            ),
            icon: _getMarkerIcon(option.type),
            onTap: () {
              // Show transport option details
              _showTransportOptionDetails(option);
            },
          );
          
          _markers.add(marker);
        }
      }
      
      // Add current location marker if available
      if (_currentLocation != null) {
        final marker = Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(
            title: 'Your Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
        
        _markers.add(marker);
      }
      
      setState(() {});
    }
  }

  BitmapDescriptor _getMarkerIcon(TransportType type) {
    // This would ideally use custom icons
    // For now, we're using different colors for different transport types
    switch (type) {
      case TransportType.bus:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case TransportType.train:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      case TransportType.taxi:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case TransportType.tuktuk:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case TransportType.car:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
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
      case TransportType.all:
        return 'All';
      default:
        return 'Unknown';
    }
  }

  void _showTransportOptionDetails(TransportOption option) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildTransportOptionDetails(option),
    );
  }

  Widget _buildTransportOptionDetails(TransportOption option) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                
                // Transport option name and type
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getTransportTypeColor(option.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getTransportTypeIcon(option.type),
                        color: _getTransportTypeColor(option.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getTransportTypeString(option.type),
                            style: TextStyle(
                              color: _getTransportTypeColor(option.type),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Contact information
                if (option.contactPhone != null || option.contactEmail != null)
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                
                if (option.contactPhone != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        option.contactPhone!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
                
                if (option.contactEmail != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        option.contactEmail!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Location information
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option.address ?? 'Address not available',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                
                // Operating hours
                if (option.operatingHours != null && option.operatingHours!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Operating Hours',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...option.operatingHours!.map((hours) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          hours,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  )),
                ],
                
                // Price information
                if (option.priceInfo != null) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Price Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option.priceInfo!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                
                // Rating and reviews summary
                if (option.rating != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Rating',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${option.rating!.toStringAsFixed(1)}/5.0',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      if (option.reviewCount != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${option.reviewCount} reviews)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                
                // Description
                if (option.description != null) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option.description!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                
                // Book button
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransportBookingScreen(
                            transportOption: option,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _getBookingButtonText(option.type),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
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
        return Icons.commute;
    }
  }

  String _getBookingButtonText(TransportType type) {
    switch (type) {
      case TransportType.bus:
        return 'Check Schedule';
      case TransportType.train:
        return 'Book Tickets';
      case TransportType.taxi:
        return 'Book Taxi';
      case TransportType.tuktuk:
        return 'Book Tuk-Tuk';
      case TransportType.car:
        return 'Rent Car';
      default:
        return 'Book Now';
    }
  }

  void _showFiltersModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
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
                
                // Search query
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    hintText: 'Search by name or route',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _searchQuery,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Distance filter
                const Text(
                  'Maximum Distance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _maxDistance,
                        min: 1.0,
                        max: 50.0,
                        divisions: 49,
                        label: '${_maxDistance.toInt()} km',
                        onChanged: (value) {
                          setState(() {
                            _maxDistance = value;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      '${_maxDistance.toInt()} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Availability toggle
                SwitchListTile(
                  title: const Text(
                    'Show only available now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: _onlyAvailableNow,
                  onChanged: (value) {
                    setState(() {
                      _onlyAvailableNow = value;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                
                const SizedBox(height: 20),
                
                // Apply and reset buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Reset filters
                          setState(() {
                            _searchQuery = '';
                            _maxDistance = 10.0;
                            _onlyAvailableNow = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Apply filters
                          Navigator.pop(context);
                          
                          // Update local state
                          this.setState(() {
                            _searchQuery = _searchQuery;
                            _maxDistance = _maxDistance;
                            _onlyAvailableNow = _onlyAvailableNow;
                          });
                          
                          // Reload with new filters
                          context.read<TransportBloc>().add(
                            LoadTransportOptions(
                              destinationId: widget.destinationId,
                              transportType: _selectedTransportType,
                              searchQuery: _searchQuery,
                              userLocation: _currentLocation,
                              maxDistance: _maxDistance,
                              onlyAvailableNow: _onlyAvailableNow,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Transportation Hub',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersModal,
          ),
        ],
      ),
      body: BlocConsumer<TransportBloc, TransportState>(
        listener: (context, state) {
          if (state is TransportLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            
            if (state is TransportOptionsLoaded) {
              // Update markers on map
              _updateMarkers();
            }
          }
        },
        builder: (context, state) {
          return BlocBuilder<DestinationBloc, DestinationState>(
            builder: (context, destState) {
              if (destState is DestinationDetailsLoaded && 
                  destState.destination.id == widget.destinationId) {
                _destination = destState.destination;
              }
              
              return Column(
                children: [
                  // Transport type selector
                  TransportTypeSelector(
                    selectedType: _selectedTransportType,
                    onTypeSelected: _onTransportTypeChanged,
                  ),
                  
                  // Main content with tabs
                  Expanded(
                    child: DefaultTabController(
                      length: 5,
                      initialIndex: _selectedTabIndex,
                      child: Column(
                        children: [
                          // Tab bar
                          TabBar(
                            labelColor: AppTheme.primaryColor,
                            unselectedLabelColor: Colors.grey[600],
                            indicatorColor: AppTheme.primaryColor,
                            tabs: const [
                              Tab(text: 'Buses'),
                              Tab(text: 'Trains'),
                              Tab(text: 'Taxis'),
                              Tab(text: 'Tuk-Tuks'),
                              Tab(text: 'All'),
                            ],
                            onTap: _onTabChanged,
                          ),
                          
                          // Tab content
                          Expanded(
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(), // Disable swiping
                              children: [
                                // Each tab shows the same content but with different filters
                                _buildTransportContent(state),
                                _buildTransportContent(state),
                                _buildTransportContent(state),
                                _buildTransportContent(state),
                                _buildTransportContent(state),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTransportContent(TransportState state) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressLoader(),
      );
    }
    
    if (state is TransportOptionsLoaded) {
      final transportOptions = state.transportOptions;
      
      if (transportOptions.isEmpty) {
        return _buildEmptyState();
      }
      
      return Column(
        children: [
          // Map view
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? 
                           const LatLng(7.8731, 80.7718), // Default to Sri Lanka center
                    zoom: 12,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                ),
                
                // Map type selector
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.layers),
                      onPressed: () {
                        // Toggle map type
                        // This would be implemented in a real app
                      },
                    ),
                  ),
                ),
                
                // Current location button
                Positioned(
                  top: 68,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () {
                        // Center map on current location
                        if (_currentLocation != null && _mapController != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              _currentLocation!,
                              15,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Transport options carousel
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${transportOptions.length} ${_getTransportTypeString(_selectedTransportType)} Options',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_currentCarouselIndex + 1} of ${transportOptions.length}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Carousel of transport options
                  Expanded(
                    child: CarouselSlider.builder(
                      carouselController: _carouselController,
                      itemCount: transportOptions.length,
                      options: CarouselOptions(
                        height: double.infinity,
                        viewportFraction: 0.9,
                        enableInfiniteScroll: false,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentCarouselIndex = index;
                          });
                          
                          // Center map on the selected transport option
                          final option = transportOptions[index];
                          if (option.latitude != null && option.longitude != null && _mapController != null) {
                            _mapController!.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(option.latitude!, option.longitude!),
                                15,
                              ),
                            );
                          }
                        },
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final option = transportOptions[index];
                        return _buildTransportOptionCard(option);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    
    if (state is TransportError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.message}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransportOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTransportTypeIcon(_selectedTransportType),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_getTransportTypeString(_selectedTransportType)} Options Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filters or search criteria',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showFiltersModal,
              icon: const Icon(Icons.filter_list),
              label: const Text('Adjust Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportOptionCard(TransportOption option) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showTransportOptionDetails(option),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and type
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTransportTypeColor(option.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTransportTypeIcon(option.type),
                      color: _getTransportTypeColor(option.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getTransportTypeString(option.type),
                    style: TextStyle(
                      color: _getTransportTypeColor(option.type),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (option.rating != null) ...[
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      option.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Option name
              Text(
                option.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Address
              if (option.address != null)
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        option.address!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 8),
              
              // Operating hours or schedule
              if (option.operatingHours != null && option.operatingHours!.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        option.operatingHours!.first,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              
              const Spacer(),
              
              // Price and book button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (option.priceRange != null)
                    Text(
                      option.priceRange!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Spacer(),
                    
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransportBookingScreen(
                            transportOption: option, transportType: null,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(_getBookingButtonText(option.type)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

CircularProgressLoader() {
}

extension on TransportState {
   get transportOptions => null;
}

class TransportOptionsLoaded {
}