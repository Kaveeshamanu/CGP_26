// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math.dart' as vector;

// AR plugins with conditional imports
import 'dart:io' show Platform;
// Android AR support
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart'
    if (dart.library.io) 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
// iOS AR support
import 'package:arkit_plugin/arkit_plugin.dart' 
    if (dart.library.io) 'package:arkit_plugin/arkit_plugin.dart';

import '../../config/theme.dart';
import '../../core/utils/permissions.dart';
import '../../core/location/location_service.dart';
import '../../data/models/destination.dart';
import '../../bloc/destination/destination_bloc.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import '../common/widgets/buttons.dart';

class ARModeScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? destinationId;

  const ARModeScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.destinationId,
  });

  @override
  State<ARModeScreen> createState() => _ARModeScreenState();
}

class _ARModeScreenState extends State<ARModeScreen> with WidgetsBindingObserver {
  // Platform-specific AR controller
  dynamic _arController;
  final LocationService _locationService = LocationService();
  final PermissionsHandler _permissionsHandler = PermissionsHandler();
  
  bool _isLoading = true;
  bool _arAvailable = false;
  bool _cameraPermissionGranted = false;
  Position? _currentPosition;
  final double _heading = 0.0; // Device compass heading
  
  // Points of interest to show in AR
  List<PointOfInterest> _pointsOfInterest = [];
  
  // Device orientation
  // ignore: unused_field, prefer_final_fields
  DeviceOrientation _deviceOrientation = DeviceOrientation.portraitUp;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAR();
    
    // Lock screen to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Load destination data if destinationId is provided
    if (widget.destinationId != null) {
      context.read<DestinationBloc>().add(
        LoadDestinationDetails(destinationId: widget.destinationId!),
      );
    } else {
      // Add some default POIs for testing
      _addDefaultPOIs();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAR();
    
    // Reset preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-initialize AR when app is resumed
      _setupAR();
    } else if (state == AppLifecycleState.paused) {
      // Dispose AR when app is paused
      _disposeAR();
    }
  }

  Future<void> _setupAR() async {
    setState(() {
      _isLoading = true;
    });
    
    // Check camera permission
    _cameraPermissionGranted = await _permissionsHandler.requestCameraPermission();
    
    if (!_cameraPermissionGranted) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // Check if AR is available on this device
    _arAvailable = await _checkARAvailability();
    
    if (!_arAvailable) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // Get current location
    try {
      _currentPosition = await _locationService.getCurrentPosition();
    } catch (e) {
      print('Error getting current position: $e');
      
      // Use provided coordinates as fallback
      if (widget.latitude != null && widget.longitude != null) {
        _currentPosition = Position(
          latitude: widget.latitude!,
          longitude: widget.longitude!,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          timestamp: DateTime.now(),
        );
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _disposeAR() {
    if (_arController != null) {
      if (Platform.isAndroid && _arController is ArCoreController) {
        _arController.dispose();
      } else if (Platform.isIOS && _arController is ARKitController) {
        _arController.dispose();
      }
      _arController = null;
    }
  }

  Future<bool> _checkARAvailability() async {
    try {
      if (Platform.isAndroid) {
        return await ArCoreController.checkArCoreAvailability();
      } else if (Platform.isIOS) {
        // ARKit is available on iOS 11+ devices, but not all have necessary hardware
        // A proper check would require additional logic or a plugin update
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking AR availability: $e');
      return false;
    }
  }

  void _onARViewCreated(dynamic controller) {
    _arController = controller;
    
    if (Platform.isAndroid && controller is ArCoreController) {
      controller.onPlaneTap = _handlePlaneTapAndroid;
      controller.onNodeTap = _handleNodeTapAndroid;
    } else if (Platform.isIOS && controller is ARKitController) {
      controller.onNodeTap = _handleNodeTapIOS as ARKitTapResultHandler?;
      controller.updateAtTime = _updateARPositionIOS as Function(double time)?;
    }
    
    // Add POIs to AR view
    _addPointsOfInterestToAR();
  }

  void _handlePlaneTapAndroid(List<ArCoreHitTestResult> hits) {
    // Handle tap on a plane (surface) in AR
    final hit = hits.first;
    _addARObjectAndroid(hit.pose.translation as vector.Vector3);
  }

  void _handleNodeTapAndroid(String nodeName) {
    // Handle tap on an AR node (object)
    print('Node tapped: $nodeName');
    
    // Find the POI that corresponds to this node
    final poi = _pointsOfInterest.firstWhere(
      (poi) => 'node_${poi.id}' == nodeName,
      orElse: () => PointOfInterest(
        id: '',
        name: 'Unknown',
        type: 'unknown',
        latitude: 0,
        longitude: 0,
      ),
    );
    
    if (poi.id.isNotEmpty) {
      _showPOIDetails(poi);
    }
  }

  void _handleNodeTapIOS(String nodeName) {
    // Handle tap on an AR node (object) in iOS
    print('Node tapped: $nodeName');
    
    // Find the POI that corresponds to this node
    final poi = _pointsOfInterest.firstWhere(
      (poi) => 'node_${poi.id}' == nodeName,
      orElse: () => PointOfInterest(
        id: '',
        name: 'Unknown',
        type: 'unknown',
        latitude: 0,
        longitude: 0,
      ),
    );
    
    if (poi.id.isNotEmpty) {
      _showPOIDetails(poi);
    }
  }

  void _updateARPositionIOS(String? nodeName) {
    // Update AR positions in iOS based on device movement
    // This is called frequently by ARKit
  }

  void _addARObjectAndroid(vector.Vector3 position) {
    if (_arController == null || _arController is! ArCoreController) return;
    
    final material = ArCoreMaterial(
      color: Colors.blue,
      metallic: 1.0,
    );
    
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.1,
    );
    
    final node = ArCoreNode(
      shape: sphere,
      position: position,
    );
    
    _arController.addArCoreNode(node);
  }

  void _addPointsOfInterestToAR() {
    if (_currentPosition == null || _pointsOfInterest.isEmpty) return;
    
    // Calculate relative positions of POIs
    for (final poi in _pointsOfInterest) {
      final relativePosition = _calculateRelativePosition(poi);
      
      if (Platform.isAndroid && _arController is ArCoreController) {
        _addPOIToARAndroid(poi, relativePosition);
      } else if (Platform.isIOS && _arController is ARKitController) {
        _addPOIToARIOS(poi, relativePosition);
      }
    }
  }

  vector.Vector3 _calculateRelativePosition(PointOfInterest poi) {
    if (_currentPosition == null) {
      return vector.Vector3(0, 0, -2); // Default position if no location
    }
    
    // Calculate distance and bearing to the POI
    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      poi.latitude,
      poi.longitude,
    );
    
    final bearing = Geolocator.bearingBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      poi.latitude,
      poi.longitude,
    );
    
    // Convert to AR world coordinates
    // This is a simplified calculation; a real implementation would be more complex
    // and take into account altitude, heading, and the device's orientation
    
    // Scale factor to keep objects visible
    final scaleFactor = 0.1;
    final scaledDistance = distance * scaleFactor;
    
    // Calculate position relative to user
    // bearing is in degrees, convert to radians
    final bearingRadians = (bearing - _heading) * (pi / 180);
    
    final x = scaledDistance * sin(bearingRadians);
    final z = -scaledDistance * cos(bearingRadians);
    
    // y is up in AR space, use a small elevation to make objects visible
    const y = 0.5;
    
    return vector.Vector3(x, y, z);
  }

  void _addPOIToARAndroid(PointOfInterest poi, vector.Vector3 position) {
    if (_arController == null || _arController is! ArCoreController) return;
    
    final poiColor = _getPOIColor(poi.type);
    
    // Create material and shape
    final material = ArCoreMaterial(
      color: poiColor,
      metallic: 1.0,
    );
    
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.05,
    );
    
    // Create node
    final node = ArCoreNode(
      name: 'node_${poi.id}',
      shape: sphere,
      position: position,
    );
    
    // Add text node as child
    final textMaterial = ArCoreMaterial(
      color: Colors.white,
    );
    
    final textShape = ArCoreText(
      text: poi.name,
      materials: [textMaterial],
      size: vector.Vector3(0.3, 0.3, 0.3),
    );
    
    final textNode = ArCoreNode(
      name: 'text_${poi.id}',
      shape: textShape,
      position: vector.Vector3(0, 0.1, 0),
      rotation: vector.Vector4(0, 0, 0, 0),
    );
    
    node.children.add(textNode);
    
    // Add to AR view
    _arController.addArCoreNode(node);
  }

  void _addPOIToARIOS(PointOfInterest poi, vector.Vector3 position) {
    if (_arController == null || _arController is! ARKitController) return;
    
    final poiColor = _getPOIColor(poi.type);
    
    // Create a sphere for the POI
    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.color(poiColor),
      metalness: ARKitMaterialProperty.value(1.0),
    );
    
    final sphere = ARKitSphere(
      radius: 0.05,
      materials: [material],
    );
    
    // Create node
    final node = ARKitNode(
      name: 'node_${poi.id}',
      geometry: sphere,
      position: position,
    );
    
    // Add a text node
    final textNode = ARKitNode(
      name: 'text_${poi.id}',
      geometry: ARKitText(
        text: poi.name,
        extrusionDepth: 0.1,
        materials: [
          ARKitMaterial(
            diffuse: ARKitMaterialProperty.color(Colors.white),
          )
        ],
      ),
      position: vector.Vector3(position.x, position.y + 0.1, position.z),
      scale: vector.Vector3(0.01, 0.01, 0.01),
    );
    
    // Add to AR view
    _arController.add(node);
    _arController.add(textNode);
  }

  void _showPOIDetails(PointOfInterest poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildPOIDetailsSheet(poi),
    );
  }

  Widget _buildPOIDetailsSheet(PointOfInterest poi) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
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
                  poi.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getPOITypeName(poi.type),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getPOIColor(poi.type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                if (poi.description?.isNotEmpty ?? false) ...[
                  Text(poi.description!),
                  const SizedBox(height: 16),
                ],
                // Distance information
                if (_currentPosition != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_calculateDistance(poi.latitude, poi.longitude).toStringAsFixed(1)} km away',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Show on Map'),
                        onPressed: () {
                          // Close the bottom sheet
                          Navigator.pop(context);
                          
                          // Navigate to map screen
                          Navigator.pushReplacementNamed(
                            context,
                            '/maps',
                            arguments: {
                              'latitude': poi.latitude,
                              'longitude': poi.longitude,
                              'zoom': 15.0,
                              'markerTitle': poi.name,
                            },
                          );
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
                          // Add POI to user's itinerary
                          Navigator.pop(context);
                          
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
          ),
        );
      },
    );
  }

  double _calculateDistance(double lat, double lng) {
    if (_currentPosition == null) return 0;
    
    final distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    );
    
    // Convert to kilometers
    return distanceInMeters / 1000;
  }

  Color _getPOIColor(String type) {
    switch (type.toLowerCase()) {
      case 'attraction':
        return Colors.blue;
      case 'hotel':
      case 'accommodation':
        return Colors.purple;
      case 'restaurant':
      case 'dining':
        return Colors.orange;
      case 'transport':
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  String _getPOITypeName(String type) {
    switch (type.toLowerCase()) {
      case 'attraction':
        return 'Tourist Attraction';
      case 'hotel':
      case 'accommodation':
        return 'Accommodation';
      case 'restaurant':
      case 'dining':
        return 'Restaurant';
      case 'transport':
        return 'Transport Hub';
      default:
        return 'Point of Interest';
    }
  }

  void _addDefaultPOIs() {
    // Only add default POIs if we have current position
    if (_currentPosition == null && 
        (widget.latitude == null || widget.longitude == null)) {
      return;
    }
    
    final centerLat = _currentPosition?.latitude ?? widget.latitude!;
    final centerLng = _currentPosition?.longitude ?? widget.longitude!;
    
    // Create test POIs around the user's location
    _pointsOfInterest = [
      PointOfInterest(
        id: '1',
        name: 'Temple of the Sacred Tooth Relic',
        type: 'attraction',
        latitude: centerLat + 0.001,
        longitude: centerLng + 0.001,
        description: 'Sri Dalada Maligawa or the Temple of the Sacred Tooth Relic is a Buddhist temple located in Kandy, Sri Lanka.',
      ),
      PointOfInterest(
        id: '2',
        name: 'Cinnamon Grand Hotel',
        type: 'hotel',
        latitude: centerLat - 0.001,
        longitude: centerLng + 0.002,
        description: 'Luxury hotel with multiple restaurants and amenities.',
      ),
      PointOfInterest(
        id: '3',
        name: 'Ministry of Crab',
        type: 'restaurant',
        latitude: centerLat + 0.002,
        longitude: centerLng - 0.001,
        description: 'Famous seafood restaurant specializing in crab dishes.',
      ),
      PointOfInterest(
        id: '4',
        name: 'Colombo Fort Station',
        type: 'transport',
        latitude: centerLat - 0.002,
        longitude: centerLng - 0.002,
        description: 'Main railway station connecting Colombo to other parts of Sri Lanka.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'AR View',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: BlocConsumer<DestinationBloc, DestinationState>(
        listener: (context, state) {
          if (state is DestinationDetailsLoaded &&
              state.destination.id == widget.destinationId) {
            _loadPOIsFromDestination(state.destination);
          }
        },
        builder: (context, state) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressLoader(),
            );
          }
          
          if (!_cameraPermissionGranted) {
            return _buildPermissionDeniedView();
          }
          
          if (!_arAvailable) {
            return _buildARNotAvailableView();
          }
          
          return _buildARView();
        },
      ),
    );
  }

  Widget _buildARView() {
    if (Platform.isAndroid) {
      return ArCoreView(
        onArCoreViewCreated: _onARViewCreated,
        enableTapRecognizer: true,
      );
    } else if (Platform.isIOS) {
      return ARKitSceneView(
        onARKitViewCreated: _onARViewCreated,
        detectionImagesGroupName: null, // Add reference images if needed
      );
    } else {
      return const Center(
        child: Text('AR is not supported on this platform'),
      );
    }
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The AR feature needs access to your camera to display points of interest.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final status = await Permission.camera.request();
                if (status.isGranted) {
                  setState(() {
                    _cameraPermissionGranted = true;
                  });
                } else {
                  openAppSettings();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARNotAvailableView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'AR Not Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your device does not support AR features. Please use the regular map view instead.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate back to map view
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go to Map View'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Using AR View'),
        content: const Text(
          'Point your camera around you to see nearby points of interest. '
          'Tap on any marker to see more details. AR works best outdoors in good lighting conditions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _loadPOIsFromDestination(Destination destination) {
    final List<PointOfInterest> pois = [];
    
    // Load attractions
    if (destination.attractions != null) {
      for (final attraction in destination.attractions!) {
        if (attraction.latitude != null && attraction.longitude != null) {
          pois.add(
            PointOfInterest(
              id: attraction.id ?? 'att_${pois.length}',
              name: attraction.name ?? 'Unnamed Attraction',
              type: 'attraction',
              latitude: attraction.latitude!,
              longitude: attraction.longitude!,
              description: attraction.description,
            ),
          );
        }
      }
    }
    
    // Load accommodations
    if (destination.accommodations != null) {
      for (final accommodation in destination.accommodations!) {
        if (accommodation.latitude != null && accommodation.longitude != null) {
          pois.add(
            PointOfInterest(
              id: accommodation.id ?? 'acc_${pois.length}',
              name: accommodation.name ?? 'Unnamed Accommodation',
              type: 'hotel',
              latitude: accommodation.latitude!,
              longitude: accommodation.longitude!,
              description: accommodation.description,
            ),
          );
        }
      }
    }
    
    // Load restaurants
    if (destination.restaurants != null) {
      for (final restaurant in destination.restaurants!) {
        if (restaurant.latitude != null && restaurant.longitude != null) {
          pois.add(
            PointOfInterest(
              id: restaurant.id ?? 'res_${pois.length}',
              name: restaurant.name ?? 'Unnamed Restaurant',
              type: 'restaurant',
              latitude: restaurant.latitude!,
              longitude: restaurant.longitude!,
              description: restaurant.description,
            ),
          );
        }
      }
    }
    
    // Load transport hubs
    if (destination.transportHubs != null) {
      for (final hub in destination.transportHubs!) {
        if (hub.latitude != null && hub.longitude != null) {
          pois.add(
            PointOfInterest(
              id: hub.id ?? 'hub_${pois.length}',
              name: hub.name ?? 'Unnamed Transport Hub',
              type: 'transport',
              latitude: hub.latitude!,
              longitude: hub.longitude!,
              description: hub.description,
            ),
          );
        }
      }
    }
    
    setState(() {
      _pointsOfInterest = pois;
    });
    
    // Update AR view with new POIs
    if (_arController != null) {
      _addPointsOfInterestToAR();
    }
  }
}

class PermissionsHandler {
  requestCameraPermission() {}

  checkLocationPermission() {}
}

class ArCoreText {
}

class PointOfInterest {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String? description;
  
  PointOfInterest({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.description,
  });
}