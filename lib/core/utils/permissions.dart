import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taprobana_trails/config/constants.dart';

/// Exception thrown when there's a permission error.
class PermissionException implements Exception {
  final String message;
  final String? code;
  final Permission permission;

  PermissionException({
    required this.message,
    required this.permission,
    this.code,
  });

  @override
  String toString() => 'PermissionException: $message (Permission: ${permission.toString()}, Code: $code)';
}

/// Service class for handling app permissions.
class PermissionService {
  // Private constructor to prevent instantiation
  PermissionService._();
  
  /// Checks if location permissions are granted.
  static Future<bool> hasLocationPermission() async {
    if (Platform.isIOS) {
      return await Permission.locationWhenInUse.isGranted;
    } else {
      return await Permission.location.isGranted;
    }
  }
  
  /// Requests location permission.
  /// 
  /// [background] determines whether to request background location access.
  /// Returns true if the permission is granted.
  static Future<bool> requestLocationPermission({bool background = false}) async {
    try {
      Permission permission;
      
      if (Platform.isIOS) {
        permission = background
            ? Permission.locationAlways
            : Permission.locationWhenInUse;
      } else {
        permission = background
            ? Permission.locationAlways
            : Permission.location;
      }
      
      if (await permission.isGranted) {
        return true;
      }
      
      final status = await permission.request();
      
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        throw PermissionException(
          message: 'Location permission is permanently denied. Please enable it in app settings.',
          permission: permission,
          code: 'PERMISSION_PERMANENTLY_DENIED',
        );
      } else {
        return false;
      }
    } catch (e) {
      if (e is PermissionException) {
        rethrow;
      }
      
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }
  
  /// Checks if camera permission is granted.
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }
  
  /// Requests camera permission.
  /// 
  /// Returns true if the permission is granted.
  static Future<bool> requestCameraPermission() async {
    try {
      if (await Permission.camera.isGranted) {
        return true;
      }
      
      final status = await Permission.camera.request();
      
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        throw PermissionException(
          message: 'Camera permission is permanently denied. Please enable it in app settings.',
          permission: Permission.camera,
          code: 'PERMISSION_PERMANENTLY_DENIED',
        );
      } else {
        return false;
      }
    } catch (e) {
      if (e is PermissionException) {
        rethrow;
      }
      
      debugPrint('Error requesting camera permission: $e');
      return false;
    }
  }
  
  /// Checks if photo library permission is granted.
  static Future<bool> hasPhotoLibraryPermission() async {
    return await Permission.photos.isGranted;
  }
  
  /// Requests photo library permission.
  /// 
  /// Returns true if the permission is granted.
  static Future<bool> requestPhotoLibraryPermission() async {
    try {
      if (await Permission.photos.isGranted) {
        return true;
      }
      
      final status = await Permission.photos.request();
      
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        throw PermissionException(
          message: 'Photo library permission is permanently denied. Please enable it in app settings.',
          permission: Permission.photos,
          code: 'PERMISSION_PERMANENTLY_DENIED',
        );
      } else {
        return false;
      }
    } catch (e) {
      if (e is PermissionException) {
        rethrow;
      }
      
      debugPrint('Error requesting photo library permission: $e');
      return false;
    }
  }
  
  /// Checks if storage permission is granted.
  static Future<bool> hasStoragePermission() async {
    if (Platform.isIOS) {
      return true; // iOS doesn't need explicit storage permission
    } else {
      return await Permission.storage.isGranted;
    }
  }
  
  /// Requests storage permission.
  /// 
  /// Returns true if the permission is granted.
  static Future<bool> requestStoragePermission() async {
    if (Platform.isIOS) {
      return true; // iOS doesn't need explicit storage permission
    }
    
    try {
      if (await Permission.storage.isGranted) {
        return true;
      }
      
      final status = await Permission.storage.request();
      
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        throw PermissionException(
          message: 'Storage permission is permanently denied. Please enable it in app settings.',
          permission: Permission.storage,
          code: 'PERMISSION_PERMANENTLY_DENIED',
        );
      } else {
        return false;
      }
    } catch (e) {
      if (e is PermissionException) {
        rethrow;
      }
      
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }
  
  /// Checks if notifications permission is granted.
  static Future<bool> hasNotificationsPermission() async {
    return await Permission.notification.isGranted;
  }
  
  /// Requests notification permission.
  /// 
  /// Returns true if the permission is granted.
  static Future<bool> requestNotificationsPermission() async {
    try {
      if (await Permission.notification.isGranted) {
        return true;
      }
      
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        throw PermissionException(
          message: 'Notification permission is permanently denied. Please enable it in app settings.',
          permission: Permission.notification,
          code: 'PERMISSION_PERMANENTLY_DENIED',
        );
      } else {
        return false;
      }
    } catch (e) {
      if (e is PermissionException) {
        rethrow;
      }
      
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }
  
  /// Checks if microphone permission is granted.
  static Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }
  
  /// Requests microphone permission.
  /// 
  /// Returns true if the permission is granted.
  static Future<bool> requestMicrophonePermission() async {
    try {
      if (await Permission.microphone.isGranted) {
        return true;
      }
      
      final status = await Permission.microphone.request();
      
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        throw PermissionException(
          message: 'Microphone permission is permanently denied. Please enable it in app settings.',
          permission: Permission.microphone,
          code: 'PERMISSION_PERMANENTLY_DENIED',
        );
      } else {
        return false;
      }
    } catch (e) {
      if (e is PermissionException) {
        rethrow;
      }
      
      debugPrint('Error requesting microphone permission: $e');
      return false;
    }
  }
  
  /// Opens the app settings.
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
  
  /// Gets the status of a permission.
  static Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return await permission.status;
  }
  
  /// Checks if multiple permissions are granted.
  /// 
  /// [permissions] is the list of permissions to check.
  /// Returns true if all permissions are granted.
  static Future<bool> hasPermissions(List<Permission> permissions) async {
    for (final permission in permissions) {
      if (!await permission.isGranted) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Requests multiple permissions.
  /// 
  /// [permissions] is the list of permissions to request.
  /// Returns a map of permission to status.
  static Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }
  
  /// Gets a friendly name for a permission.
  static String getPermissionFriendlyName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera';
      case Permission.photos:
        return 'Photos';
      case Permission.storage:
        return 'Storage';
      case Permission.location:
      case Permission.locationAlways:
      case Permission.locationWhenInUse:
        return 'Location';
      case Permission.microphone:
        return 'Microphone';
      case Permission.notification:
        return 'Notifications';
      case Permission.phone:
        return 'Phone';
      case Permission.contacts:
        return 'Contacts';
      case Permission.calendar:
        return 'Calendar';
      case Permission.speech:
        return 'Speech Recognition';
      case Permission.bluetooth:
        return 'Bluetooth';
      default:
        return permission.toString().split('.').last;
    }
  }
  
  /// Gets a description of why a permission is needed.
  static String getPermissionRationale(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'We need camera access to take photos for reviews and share your experiences.';
      case Permission.photos:
        return 'We need access to your photos to upload images for reviews and profile pictures.';
      case Permission.storage:
        return 'We need storage access to save offline maps and itineraries for use without internet.';
      case Permission.location:
      case Permission.locationAlways:
      case Permission.locationWhenInUse:
        return 'We need location access to show you nearby attractions, accommodations, and provide navigation.';
      case Permission.microphone:
        return 'We need microphone access for voice search and audio notes in your itinerary.';
      case Permission.notification:
        return 'We need to send you notifications about booking confirmations, travel alerts, and deals.';
      default:
        return 'This permission is required for app functionality.';
    }
  }
  
  /// Gets the permissions needed for a specific feature.
  static List<Permission> getPermissionsForFeature(String feature) {
    switch (feature.toLowerCase()) {
      case 'maps':
      case 'navigation':
        return [Permission.location];
      case 'offline maps':
        return [Permission.location, Permission.storage];
      case 'camera':
      case 'photo upload':
        return [Permission.camera, Permission.photos];
      case 'reviews':
        return [Permission.photos];
      case 'itinerary sharing':
        return [Permission.contacts];
      case 'voice search':
        return [Permission.microphone];
      case 'ar mode':
        return [Permission.camera, Permission.location];
      case 'notifications':
        return [Permission.notification];
      default:
        return [];
    }
  }
  
  /// Checks if the permissions needed for a feature are granted.
  static Future<bool> hasFeaturePermissions(String feature) async {
    final permissions = getPermissionsForFeature(feature);
    return await hasPermissions(permissions);
  }
  
  /// Requests the permissions needed for a feature.
  /// 
  /// [feature] is the name of the feature.
  /// Returns true if all permissions are granted.
  static Future<bool> requestFeaturePermissions(String feature) async {
    final permissions = getPermissionsForFeature(feature);
    
    if (permissions.isEmpty) {
      return true;
    }
    
    final statuses = await requestPermissions(permissions);
    
    return statuses.values.every((status) => status.isGranted);
  }
  
  /// Handles permission result and provides guidance for denied permissions.
  static String handlePermissionResult(PermissionStatus status, Permission permission) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Please grant ${getPermissionFriendlyName(permission)} permission to use this feature. ${getPermissionRationale(permission)}';
      case PermissionStatus.restricted:
        return '${getPermissionFriendlyName(permission)} permission is restricted. Please check your device settings.';
      case PermissionStatus.limited:
        return '${getPermissionFriendlyName(permission)} permission is limited. Some features may not work as expected.';
      case PermissionStatus.permanentlyDenied:
        return '${getPermissionFriendlyName(permission)} permission is permanently denied. Please enable it in app settings.';
      default:
        return 'Unknown permission status';
    }
  }
}