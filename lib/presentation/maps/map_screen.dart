import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../core/location/location_service.dart';
import '../../core/utils/permissions.dart';
import '../../data/models/destination.dart';
import '../../data/models/transport.dart';
import '../../bloc/destination/destination_bloc.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import '../common/widgets/buttons.dart';
import 'widgets/map_filters.dart';
import 'widgets/map_marker.dart';
import 'widgets/route_planner.dart';

class MapScreen extends StatefulWidget {
  final String? destinationId;
  final LatLng? initialPosition;
  final List<LatLng>? predefinedMarkers;
  final bool showRoutes;

  const MapScreen({
    super.key,
    this.destinationId,
    this.initialPosition,
    this.predefinedMarkers,
    this.showRoutes = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final PanelController _panelController = PanelController();
  final LocationService _locationService = LocationService();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Circle> _circles = {};
  
  MapType _currentMapType = MapType.normal;
  LatLng _currentPosition = const LatLng(7.8731, 80.7718); // Sri Lanka center
  bool _isLoading = true;
  bool _locationPermissionGranted = false;
  bool _showUserLocation = true;
  bool _isTrafficEnabled = false;
  
  // Filter states
  bool _showAttractions = true;
  bool _showHotels = true;
  bool _showRestaurants = true;
  bool _showTransport = true;
  
  // Route states
  LatLng? _origin;
  LatLng? _destination;
  TravelMode _travelMode = TravelMode.driving;
  final Map<PolylineId, Polyline> _routePolylines = {};
  TransportType _selectedTransportType = TransportType.car;
  
  // Place details for bottom sheet
  Map<String, dynamic>? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  Future<void> _setupMap() async {
    setState(() {
      _isLoading = true;
    });

    // Check location permissions
    await _checkLocationPermission();
    
    // Set initial position if provided
    if (widget.initialPosition != null) {
      _currentPosition = widget.initialPosition!;
    } else if (_locationPermissionGranted) {
      // Otherwise try to get user's current position
      try {
        final position = await _locationService.getCurrentPosition();
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      } catch (e) {
        // Fallback to default position if location can't be determined
        print('Could not determine location: $e');
      }
    }
    
    // Add predefined markers if provided
    if (widget.predefinedMarkers != null) {
      _addPredefinedMarkers();
    }
    
    // Load destination data if destinationId is provided
    if (widget.destinationId != null) {
      context.read<DestinationBloc>().add(
        LoadDestinationDetails(destinationId: widget.destinationId!),
      );
    }
    
    // Set initial route if showRoutes is true
    if (widget.showRoutes && widget.predefinedMarkers != null && widget.predefinedMarkers!.length >= 2) {
      _origin = widget.predefinedMarkers!.first;
      _destination = widget.predefinedMarkers!.last;
      _getPolylinePoints();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkLocationPermission() async {
    final permissionHandler = PermissionsHandler();
    final hasPermission = await permissionHandler.requestLocationPermission();
    
    setState(() {
      _locationPermissionGranted = hasPermission;
    });
  }

  void _addPredefinedMarkers() {
    if (widget.predefinedMarkers == null) return;
    
    int i = 0;
    for (final position in widget.predefinedMarkers!) {
      final markerId = MarkerId('predefined_$i');
      final marker = Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(
          title: 'Location ${i + 1}',
          snippet: '${position.latitude}, ${position.longitude}',
        ),
      );
      
      _markers.add(marker);
      i++;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _setMapStyle(controller);
  }

  Future<void> _setMapStyle(GoogleMapController controller) async {
    // In a real app, you would load a JSON string from assets
    // controller.setMapStyle(mapStyle);
  }

  void _changeMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  Future<void> _goToCurrentLocation() async {
    if (!_locationPermissionGranted) {
      await _checkLocationPermission();
      if (!_locationPermissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to show your current location'),
          ),
        );
        return;
      }
    }
    
    try {
      final position = await _locationService.getCurrentPosition();
      final updatedPosition = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentPosition = updatedPosition;
      });
      
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(
        _currentPosition,
        14.0,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not determine location: $e'),
        ),
      );
    }
  }

  void _toggleTraffic() {
    setState(() {
      _isTrafficEnabled = !_isTrafficEnabled;
    });
  }

  void _toggleUserLocation() {
    setState(() {
      _showUserLocation = !_showUserLocation;
    });
  }

  void _updateFilters({
    bool? showAttractions,
    bool? showHotels,
    bool? showRestaurants,
    bool? showTransport,
  }) {
    setState(() {
      if (showAttractions != null) _showAttractions = showAttractions;
      if (showHotels != null) _showHotels = showHotels;
      if (showRestaurants != null) _showRestaurants = showRestaurants;
      if (showTransport != null) _showTransport = showTransport;
    });
    
    // Refresh markers based on filters
    _refreshMarkers();
  }

  void _refreshMarkers() {
    // This would be implemented to filter markers based on category
    // For the example, we're just using predefined markers
  }

  void _addMarker(LatLng position) {
    final markerId = MarkerId(position.toString());
    final marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(
        title: 'Custom Marker',
        snippet: '${position.latitude}, ${position.longitude}',
      ),
      onTap: () {
        // Show place details in bottom sheet
        _showPlaceDetails({
          'name': 'Custom Location',
          'type': 'custom',
          'position': position,
          'description': 'A location you added to the map',
        });
      },
    );
    
    setState(() {
      _markers.add(marker);
    });
  }

  void _showPlaceDetails(Map<String, dynamic> place) {
    setState(() {
      _selectedPlace = place;
    });
    
    _panelController.open();
  }

  void _hidePlaceDetails() {
    _panelController.close();
    
    // Wait for the panel to close before clearing the selected place
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _selectedPlace = null;
      });
    });
  }

  void _setRoutePoints({LatLng? origin, LatLng? destination}) {
    setState(() {
      if (origin != null) _origin = origin;
      if (destination != null) _destination = destination;
    });
    
    if (_origin != null && _destination != null) {
      _getPolylinePoints();
    }
  }

  void _setTravelMode(TravelMode mode) {
    setState(() {
      _travelMode = mode;
    });
    
    if (_origin != null && _destination != null) {
      _getPolylinePoints();
    }
  }

  void _setTransportType(TransportType type) {
    setState(() {
      _selectedTransportType = type;
    });
    
    if (_origin != null && _destination != null) {
      _getPolylinePoints();
    }
  }

  Future<void> _getPolylinePoints() async {
    if (_origin == null || _destination == null) return;
    
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'YOUR_GOOGLE_API_KEY', // Replace with your API key
      PointLatLng(_origin!.latitude, _origin!.longitude),
      PointLatLng(_destination!.latitude, _destination!.longitude),
      travelMode: _convertToTravelMode(_travelMode),
    );
    
    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = [];
      
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      
      PolylineId id = const PolylineId('poly');
      
      final polyline = Polyline(
        polylineId: id,
        color: _getPolylineColor(),
        points: polylineCoordinates,
        width: 5,
      );
      
      setState(() {
        _routePolylines[id] = polyline;
        _polylines.clear();
        _polylines.add(polyline);
      });
      
      // Fit the map to show the entire route
      _fitMapToRoute(polylineCoordinates);
    }
  }

  TravelMode _convertToTravelMode(TravelMode mode) {
    switch (mode) {
      case TravelMode.driving:
        return TravelMode.driving;
      case TravelMode.walking:
        return TravelMode.walking;
      case TravelMode.bicycling:
        return TravelMode.bicycling;
      case TravelMode.transit:
        return TravelMode.transit;
      default:
        return TravelMode.driving;
    }
  }

  Color _getPolylineColor() {
    switch (_travelMode) {
      case TravelMode.driving:
        return Colors.blue;
      case TravelMode.walking:
        return Colors.green;
      case TravelMode.bicycling:
        return Colors.orange;
      case TravelMode.transit:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  Future<void> _fitMapToRoute(List<LatLng> points) async {
    if (points.isEmpty) return;
    
    final GoogleMapController controller = await _controller.future;
    
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    
    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    
    // Add padding to the bounds
    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat - 0.01, minLng - 0.01),
      northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
    );
    
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _clearRoute() {
    setState(() {
      _origin = null;
      _destination = null;
      _polylines.clear();
      _routePolylines.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Explore Map',
        showBackButton: true,
      ),
      body: BlocConsumer<DestinationBloc, DestinationState>(
        listener: (context, state) {
          if (state is DestinationDetailsLoaded && 
              state.destination.id == widget.destinationId) {
            // Update map with destination points of interest
            _loadDestinationMarkers(state.destination);
          }
        },
        builder: (context, state) {
          return _buildMapWithPanel();
        },
      ),
    );
  }

  Widget _buildMapWithPanel() {
    return Stack(
      children: [
        SlidingUpPanel(
          controller: _panelController,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.5,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          panelBuilder: (ScrollController sc) => _selectedPlace != null
              ? _buildPlaceDetails(sc)
              : Container(),
          body: _buildMap(),
          onPanelClosed: _hidePlaceDetails,
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressLoader(),
          ),
      ],
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: 10,
          ),
          mapType: _currentMapType,
          markers: _markers,
          polylines: _polylines,
          circles: _circles,
          myLocationEnabled: _showUserLocation && _locationPermissionGranted,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          trafficEnabled: _isTrafficEnabled,
          tiltGesturesEnabled: true,
          compassEnabled: true,
          onTap: widget.showRoutes ? null : _addMarker,
        ),
        
        // Map control buttons
        _buildMapControls(),
        
        // Show route planner if routes are enabled
        if (widget.showRoutes)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: RoutePlanner(
              origin: _origin,
              destination: _destination,
              travelMode: _travelMode,
              transportType: _selectedTransportType,
              onSetPoints: _setRoutePoints,
              onChangeTravelMode: _setTravelMode,
              onChangeTransportType: _setTransportType,
              onClearRoute: _clearRoute,
            ),
          ),
      ],
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          _buildControlButton(
            icon: Icons.layers,
            onPressed: _changeMapType,
            tooltip: 'Change map type',
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.my_location,
            onPressed: _goToCurrentLocation,
            tooltip: 'Go to current location',
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: _showUserLocation
                ? Icons.location_on
                : Icons.location_off,
            onPressed: _toggleUserLocation,
            tooltip: _showUserLocation
                ? 'Hide my location'
                : 'Show my location',
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.traffic,
            onPressed: _toggleTraffic,
            isActive: _isTrafficEnabled,
            tooltip: 'Toggle traffic data',
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.filter_alt,
            onPressed: () => _showFiltersDialog(),
            tooltip: 'Filter map markers',
          ),
          if (widget.showRoutes) ...[
            const SizedBox(height: 8),
            _buildControlButton(
              icon: Icons.directions,
              onPressed: () {
                // Expand route planner
              },
              isActive: _origin != null && _destination != null,
              tooltip: 'Route options',
            ),
          ],
          const SizedBox(height: 8),
          _buildControlButton(
            icon: FontAwesomeIcons.vr,
            onPressed: () {
              // Navigate to AR mode screen
              Navigator.pushNamed(
                context,
                '/ar_mode',
                arguments: {
                  'latitude': _currentPosition.latitude,
                  'longitude': _currentPosition.longitude,
                },
              );
            },
            tooltip: 'AR View',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey[700],
        ),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildPlaceDetails(ScrollController scrollController) {
    if (_selectedPlace == null) return Container();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
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
          Text(
            _selectedPlace!['name'] ?? 'Unknown Place',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getCategoryName(_selectedPlace!['type'] ?? 'unknown'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedPlace!['description'] != null) ...[
            Text(_selectedPlace!['description']),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                  onPressed: () {
                    // Set as destination for route planning
                    if (_selectedPlace!['position'] != null) {
                      _setRoutePoints(
                        destination: _selectedPlace!['position'],
                      );
                      _hidePlaceDetails();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add to Itinerary'),
                  onPressed: () {
                    // Add location to user's itinerary
                    _hidePlaceDetails();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to your itinerary'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return MapFilters(
          showAttractions: _showAttractions,
          showHotels: _showHotels,
          showRestaurants: _showRestaurants,
          showTransport: _showTransport,
          onFiltersChanged: _updateFilters,
        );
      },
    );
  }

  String _getCategoryName(String type) {
    switch (type.toLowerCase()) {
      case 'attraction':
        return 'Attraction';
      case 'hotel':
      case 'accommodation':
        return 'Accommodation';
      case 'restaurant':
      case 'dining':
        return 'Restaurant';
      case 'transport':
        return 'Transport';
      case 'custom':
        return 'Custom Location';
      default:
        return 'Point of Interest';
    }
  }

  void _loadDestinationMarkers(Destination destination) {
    // Clear existing markers
    _markers.clear();
    
    // Add destination markers - this would be implemented based on your data model
    // For this example, we're just using a placeholder
    
    // Add accommodation markers
    if (destination.accommodations != null) {
      for (final accommodation in destination.accommodations!) {
        // Add marker for accommodation
      }
    }
    
    // Add attraction markers
    if (destination.attractions != null) {
      for (final attraction in destination.attractions!) {
        // Add marker for attraction
      }
    }
    
    // Add restaurant markers
    if (destination.restaurants != null) {
      for (final restaurant in destination.restaurants!) {
        // Add marker for restaurant
      }
    }
    
    // Add transport markers
    if (destination.transportHubs != null) {
      for (final hub in destination.transportHubs!) {
        // Add marker for transport hub
      }
    }
    
    setState(() {});
  }
}

enum TravelMode {
  driving,
  walking,
  bicycling,
  transit,
}