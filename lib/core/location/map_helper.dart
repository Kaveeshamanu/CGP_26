import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:taprobana_trails/config/app_config.dart';
import 'package:taprobana_trails/config/constants.dart';
import 'package:taprobana_trails/data/models/destination.dart';
import 'package:taprobana_trails/data/models/accommodation.dart';
import 'package:taprobana_trails/data/models/restaurant.dart';

/// Helper class for map-related operations.
class MapHelper {
  final AppConfig _appConfig;
  final PolylinePoints _polylinePoints;
  
  /// Creates a new [MapHelper].
  MapHelper({
    required AppConfig appConfig,
    PolylinePoints? polylinePoints,
  }) : _appConfig = appConfig,
       _polylinePoints = polylinePoints ?? PolylinePoints();
  
  /// Gets the Google Maps API key.
  String get _apiKey => _appConfig.googleMapsApiKey;
  
  /// Gets the initial camera position.
  CameraPosition getInitialCameraPosition({
    double? latitude,
    double? longitude,
    double zoom = AppConstants.defaultZoomLevel,
  }) {
    return CameraPosition(
      target: LatLng(
        latitude ?? AppConstants.defaultLatitude,
        longitude ?? AppConstants.defaultLongitude,
      ),
      zoom: zoom,
    );
  }
  
  /// Creates a marker with custom icon.
  Future<BitmapDescriptor> createCustomMarkerIcon(
    String assetPath, {
    int width = 80,
    int height = 80,
  }) async {
    try {
      final ByteData byteData = await rootBundle.load(assetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetWidth: width,
        targetHeight: height,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final data = await frameInfo.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
    } catch (e) {
      // Return default marker on error
      return BitmapDescriptor.defaultMarker;
    }
  }
  
  /// Creates a marker with custom network image.
  Future<BitmapDescriptor> createCustomMarkerIconFromUrl(
    String imageUrl, {
    int width = 80,
    int height = 80,
  }) async {
    try {
      // Download and cache the image
      final file = await DefaultCacheManager().getSingleFile(imageUrl);
      final bytes = await file.readAsBytes();
      
      // Decode and resize the image
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: width,
        targetHeight: height,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final data = await frameInfo.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
    } catch (e) {
      // Return default marker on error
      return BitmapDescriptor.defaultMarker;
    }
  }
  
  /// Creates markers for destinations.
  Future<Set<Marker>> createDestinationMarkers(
    List<Destination> destinations, {
    Function(Destination)? onTap,
    BitmapDescriptor? defaultIcon,
  }) async {
    final markers = <Marker>{};
    final icon = defaultIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    
    for (final destination in destinations) {
      markers.add(
        Marker(
          markerId: MarkerId('destination_${destination.id}'),
          position: LatLng(destination.latitude, destination.longitude),
          infoWindow: InfoWindow(
            title: destination.name,
            snippet: destination.category,
          ),
          icon: icon,
          onTap: onTap != null ? () => onTap(destination) : null,
        ),
      );
    }
    
    return markers;
  }
  
  /// Creates markers for accommodations.
  Future<Set<Marker>> createAccommodationMarkers(
    List<Accommodation> accommodations, {
    Function(Accommodation)? onTap,
    BitmapDescriptor? defaultIcon,
  }) async {
    final markers = <Marker>{};
    final icon = defaultIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    
    for (final accommodation in accommodations) {
      markers.add(
        Marker(
          markerId: MarkerId('accommodation_${accommodation.id}'),
          position: LatLng(accommodation.latitude, accommodation.longitude),
          infoWindow: InfoWindow(
            title: accommodation.name,
            snippet: '${accommodation.priceRange} · ${accommodation.rating} ★',
          ),
          icon: icon,
          onTap: onTap != null ? () => onTap(accommodation) : null,
        ),
      );
    }
    
    return markers;
  }
  
  /// Creates markers for restaurants.
  Future<Set<Marker>> createRestaurantMarkers(
    List<Restaurant> restaurants, {
    Function(Restaurant)? onTap,
    BitmapDescriptor? defaultIcon,
  }) async {
    final markers = <Marker>{};
    final icon = defaultIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    
    for (final restaurant in restaurants) {
      markers.add(
        Marker(
          markerId: MarkerId('restaurant_${restaurant.id}'),
          position: LatLng(restaurant.latitude, restaurant.longitude),
          infoWindow: InfoWindow(
            title: restaurant.name,
            snippet: '${restaurant.cuisine} · ${restaurant.priceRange} · ${restaurant.rating} ★',
          ),
          icon: icon,
          onTap: onTap != null ? () => onTap(restaurant) : null,
        ),
      );
    }
    
    return markers;
  }
  
  /// Gets polyline coordinates between two points.
  Future<List<LatLng>> getPolylineCoordinates(
    LatLng origin,
    LatLng destination, {
    TravelMode travelMode = TravelMode.driving,
    List<LatLng> waypoints = const [],
  }) async {
    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        _apiKey,
        PointLatLng(origin.latitude, origin.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: travelMode,
        wayPoints: waypoints.map((point) => 
          PointLatLng(point.latitude, point.longitude)
        ).toList(), request: null,
      );
      
      if (result.points.isNotEmpty) {
        return result.points.map((point) => 
          LatLng(point.latitude, point.longitude)
        ).toList();
      }
      
      // If no route found, return direct line
      return [origin, destination];
    } catch (e) {
      // On error, return direct line
      return [origin, destination];
    }
  }
  
  /// Creates a polyline between two points.
  Future<Set<Polyline>> createPolyline(
    LatLng origin,
    LatLng destination, {
    String id = 'route',
    Color color = Colors.blue,
    int width = 5,
    TravelMode travelMode = TravelMode.driving,
    List<LatLng> waypoints = const [],
  }) async {
    final polylineCoordinates = await getPolylineCoordinates(
      origin,
      destination,
      travelMode: travelMode,
      waypoints: waypoints,
    );
    
    return {
      Polyline(
        polylineId: PolylineId(id),
        points: polylineCoordinates,
        color: color,
        width: width,
      ),
    };
  }
  
  /// Creates a circle overlay at a location.
  Circle createCircle(
    LatLng center, {
    String id = 'circle',
    double radius = 500,
    Color fillColor = const Color(0x404285F4),
    Color strokeColor = const Color(0xFF4285F4),
    int strokeWidth = 1,
  }) {
    return Circle(
      circleId: CircleId(id),
      center: center,
      radius: radius,
      fillColor: fillColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
  }
  
  /// Gets the bounds that include all the given locations.
  LatLngBounds getBounds(List<LatLng> locations) {
    if (locations.isEmpty) {
      // Default to Sri Lanka bounds
      return LatLngBounds(
        southwest: const LatLng(5.9, 79.5),
        northeast: const LatLng(9.9, 81.9),
      );
    }
    
    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;
    
    for (final location in locations) {
      if (location.latitude < minLat) minLat = location.latitude;
      if (location.latitude > maxLat) maxLat = location.latitude;
      if (location.longitude < minLng) minLng = location.longitude;
      if (location.longitude > maxLng) maxLng = location.longitude;
    }
    
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
  
  /// Gets the camera position to fit all the given locations.
  CameraUpdate getCameraUpdateForBounds(
    List<LatLng> locations, {
    EdgeInsets padding = const EdgeInsets.all(50),
  }) {
    return CameraUpdate.newLatLngBounds(
      getBounds(locations),
      padding.left + padding.right,
    );
  }
  
  /// Gets the center point of multiple locations.
  LatLng getCenterPoint(List<LatLng> locations) {
    if (locations.isEmpty) {
      return LatLng(
        AppConstants.defaultLatitude,
        AppConstants.defaultLongitude,
      );
    }
    
    double totalLat = 0;
    double totalLng = 0;
    
    for (final location in locations) {
      totalLat += location.latitude;
      totalLng += location.longitude;
    }
    
    return LatLng(
      totalLat / locations.length,
      totalLng / locations.length,
    );
  }
  
  /// Gets the URL for a static map image.
  String getStaticMapUrl({
    required double latitude,
    required double longitude,
    int width = 600,
    int height = 300,
    int zoom = 14,
    String markerColor = 'red',
  }) {
    return 'https://maps.googleapis.com/maps/api/staticmap?'
      'center=$latitude,$longitude'
      '&zoom=$zoom'
      '&size=${width}x$height'
      '&markers=color:$markerColor%7C$latitude,$longitude'
      '&key=$_apiKey()';
  }
  
  /// Gets the URL for a directions static map image.
  String getDirectionsStaticMapUrl({
    required LatLng origin,
    required LatLng destination,
    int width = 600,
    int height = 300,
    String originMarkerColor = 'green',
    String destinationMarkerColor = 'red',
    String pathColor = '0x4285F4FF',
    int pathWeight = 5,
  }) {
    return 'https://maps.googleapis.com/maps/api/staticmap?'
      'size=${width}x$height'
      '&markers=color:$originMarkerColor%7C${origin.latitude},${origin.longitude}'
      '&markers=color:$destinationMarkerColor%7C${destination.latitude},${destination.longitude}'
      '&path=color:$pathColor|weight:$pathWeight|${origin.latitude},${origin.longitude}|${destination.latitude},${destination.longitude}'
      '&key=$_apiKey()';
  }
  
  /// Gets the URL for directions to a location.
  String getDirectionsUrl({
    required LatLng origin,
    required LatLng destination,
    TravelMode travelMode = TravelMode.driving,
  }) {
    String mode;
    switch (travelMode) {
      case TravelMode.driving:
        mode = 'driving';
        break;
      case TravelMode.walking:
        mode = 'walking';
        break;
      case TravelMode.bicycling:
        mode = 'bicycling';
        break;
      case TravelMode.transit:
        mode = 'transit';
        break;
      // ignore: unreachable_switch_default
      default:
        mode = 'driving';
    }
    
    return 'https://www.google.com/maps/dir/?'
      'api=1'
      '&origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&travelmode=$mode';
  }
  
  /// Gets map style JSON.
  Future<String?> getMapStyle(bool darkMode) async {
    try {
      final path = darkMode
          ? 'assets/map_styles/dark_map_style.json'
          : 'assets/map_styles/light_map_style.json';
      
      return await rootBundle.loadString(path);
    } catch (e) {
      return null;
    }
  }
  
  /// Creates a custom marker widget.
  Future<Uint8List> createCustomMarkerBitmap(
    Widget markerWidget, {
    int width = 120,
    int height = 120,
  }) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final BuildContext? context = null; // Ideally should pass a context, but using null for this utility
    
    // Create a size that is scaled based on the widget's intended size
    final Size logicalSize = Size(width.toDouble(), height.toDouble());
    
    // Draw the widget onto the canvas
    final renderObject = (markerWidget as RepaintBoundary).createRenderObject(context!);
    renderObject.paint(canvas as PaintingContext, Offset.zero);
    
    // Convert the canvas to an image
    final ui.Image image = await pictureRecorder.endRecording().toImage(
      logicalSize.width.round(),
      logicalSize.height.round(),
    );
    
    // Convert the image to bytes
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
}