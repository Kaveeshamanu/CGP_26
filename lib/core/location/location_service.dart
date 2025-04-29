import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taprobana_trails/config/constants.dart';

/// Represents the status of location services.
enum LocationStatus {
  notDetermined,
  denied,
  restricted,
  authorized,
  unknown,
}

/// Exception thrown when there's a location service error.
class LocationServiceException implements Exception {
  final String message;
  final String? code;

  LocationServiceException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'LocationServiceException: $message (Code: $code)';
}

/// Service class for location-related operations.
class LocationService {
  final _currentPositionController = StreamController<Position>.broadcast();
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _periodicLocationUpdateTimer;
  
  /// Stream of current position updates.
  Stream<Position> get currentPosition => _currentPositionController.stream;
  
  /// Gets the current position.
  Future<Position> getCurrentPosition({
    bool highAccuracy = true,
  }) async {
    try {
      // Check location service status
      final status = await checkLocationStatus();
      if (status != LocationStatus.authorized) {
        throw LocationServiceException(
          message: 'Location permission not granted',
          code: ErrorCodes.locationError,
        );
      }
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: highAccuracy 
            ? LocationAccuracy.high 
            : LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      );
    } on TimeoutException {
      throw LocationServiceException(
        message: 'Location request timed out',
        code: ErrorCodes.timeout,
      );
    } on LocationServiceDisabledException {
      throw LocationServiceException(
        message: 'Location services are disabled',
        code: ErrorCodes.locationError,
      );
    } catch (e) {
      throw LocationServiceException(
        message: 'Failed to get current location: ${e.toString()}',
        code: ErrorCodes.locationError,
      );
    }
  }
  
  /// Gets the last known position.
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('Error getting last known position: $e');
      return null;
    }
  }
  
  /// Gets the default position if current position is not available.
  Future<Position> getDefaultOrCurrentPosition() async {
    try {
      return await getCurrentPosition();
    } catch (e) {
      debugPrint('Using default position: $e');
      
      // Return a default position (center of Sri Lanka)
      return Position(
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        // Add these for Position object from geolocator 7.0.0 and above
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }
  
  /// Starts listening to position updates.
  Future<void> startLocationUpdates({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
    Duration interval = const Duration(seconds: 30),
  }) async {
    try {
      // Cancel any existing subscriptions
      await stopLocationUpdates();
      
      // Check location service status
      final status = await checkLocationStatus();
      if (status != LocationStatus.authorized) {
        throw LocationServiceException(
          message: 'Location permission not granted',
          code: ErrorCodes.locationError,
        );
      }
      
      // Get initial position
      final initialPosition = await getDefaultOrCurrentPosition();
      _currentPositionController.add(initialPosition);
      
      // Listen for continuous updates
      final LocationSettings locationSettings = Platform.isAndroid
          ? AndroidSettings(
              accuracy: accuracy,
              distanceFilter: distanceFilter,
              foregroundNotificationConfig: const ForegroundNotificationConfig(
                notificationText: "Taprobana Trails is tracking your location",
                notificationTitle: "Location Tracking",
                enableWakeLock: true,
              ),
            )
          : AppleSettings(
              accuracy: accuracy,
              activityType: ActivityType.fitness,
              distanceFilter: distanceFilter,
              pauseLocationUpdatesAutomatically: true,
              showBackgroundLocationIndicator: true,
            );
      
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _currentPositionController.add(position);
        },
        onError: (e) {
          debugPrint('Position stream error: $e');
        },
      );
      
      // Set up a periodic update as a fallback
      _periodicLocationUpdateTimer = Timer.periodic(interval, (_) async {
        try {
          final position = await getCurrentPosition();
          _currentPositionController.add(position);
        } catch (e) {
          debugPrint('Periodic location update error: $e');
        }
      });
    } catch (e) {
      debugPrint('Error starting location updates: $e');
      rethrow;
    }
  }
  
  /// Stops listening to position updates.
  Future<void> stopLocationUpdates() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    
    _periodicLocationUpdateTimer?.cancel();
    _periodicLocationUpdateTimer = null;
  }
  
  /// Checks the status of location services.
  Future<LocationStatus> checkLocationStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationStatus.restricted;
      }
      
      var permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationStatus.denied;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return LocationStatus.restricted;
      }
      
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        return LocationStatus.authorized;
      }
      
      return LocationStatus.unknown;
    } catch (e) {
      debugPrint('Error checking location status: $e');
      return LocationStatus.unknown;
    }
  }
  
  /// Requests location permission.
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse ||
             permission == LocationPermission.always;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }
  
  /// Opens the app settings.
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }
  
  /// Opens the location settings.
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error opening location settings: $e');
      return false;
    }
  }
  
  /// Gets the address from coordinates.
  Future<List<Placemark>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      return await placemarkFromCoordinates(latitude, longitude);
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      throw LocationServiceException(
        message: 'Failed to get address from coordinates: ${e.toString()}',
        code: ErrorCodes.locationError,
      );
    }
  }
  
  /// Gets formatted address from coordinates.
  Future<String> getFormattedAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await getAddressFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        // Build a formatted address
        final addressParts = <String>[];
        
        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }
        
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        
        return addressParts.join(', ');
      }
      
      return 'Unknown location';
    } catch (e) {
      debugPrint('Error getting formatted address: $e');
      return 'Unknown location';
    }
  }
  
  /// Gets coordinates from address.
  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
      throw LocationServiceException(
        message: 'Failed to get coordinates from address: ${e.toString()}',
        code: ErrorCodes.locationError,
      );
    }
  }
  
  /// Calculates distance between two locations in kilometers.
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    try {
      return Geolocator.distanceBetween(
        startLatitude, 
        startLongitude, 
        endLatitude, 
        endLongitude,
      ) / 1000; // Convert meters to kilometers
    } catch (e) {
      debugPrint('Error calculating distance: $e');
      return -1;
    }
  }
  
  /// Calculates bearing between two locations in degrees.
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    try {
      return Geolocator.bearingBetween(
        startLatitude, 
        startLongitude, 
        endLatitude, 
        endLongitude,
      );
    } catch (e) {
      debugPrint('Error calculating bearing: $e');
      return 0;
    }
  }
  
  /// Converts a LatLng to a Position.
  Position latLngToPosition(LatLng latLng) {
    return Position(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      // Add these for Position object from geolocator 7.0.0 and above
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
  
  /// Converts a Position to a LatLng.
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }
  
  /// Checks if location services are enabled.
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking if location services are enabled: $e');
      return false;
    }
  }
  
  /// Disposes the location service.
  void dispose() {
    stopLocationUpdates();
    _currentPositionController.close();
  }
}