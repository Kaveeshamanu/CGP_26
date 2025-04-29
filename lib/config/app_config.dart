import 'package:flutter/foundation.dart';

/// Configuration class for the Taprobana Trails app.
/// Contains environment-specific configurations and feature flags.
class AppConfig {
  /// Base URL for the API
  final String apiBaseUrl;
  
  /// API key for the Google Maps API
  final String googleMapsApiKey;
  
  /// API key for the Uber API
  final String uberApiKey;
  
  /// API key for the PickMe API
  final String pickMeApiKey;
  
  /// Whether to enable analytics
  final bool enableAnalytics;
  
  /// Whether to enable crash reporting
  final bool enableCrashReporting;
  
  /// Whether to show debug overlays
  final bool showDebugOverlay;
  
  /// Whether to enable offline mode features
  final bool enableOfflineMode;
  
  /// Whether to enable AR features
  final bool enableAR;
  
  const AppConfig({
    required this.apiBaseUrl,
    required this.googleMapsApiKey,
    required this.uberApiKey,
    required this.pickMeApiKey,
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.showDebugOverlay,
    required this.enableOfflineMode,
    required this.enableAR,
  });
  
  /// Factory for development environment
  factory AppConfig.development() {
    return const AppConfig(
      apiBaseUrl: 'https://dev-api.taprobanatrails.com',
      googleMapsApiKey: 'YOUR_DEV_GOOGLE_MAPS_API_KEY',
      uberApiKey: 'YOUR_DEV_UBER_API_KEY',
      pickMeApiKey: 'YOUR_DEV_PICKME_API_KEY',
      enableAnalytics: false,
      enableCrashReporting: false,
      showDebugOverlay: true,
      enableOfflineMode: true,
      enableAR: kDebugMode ? false : true, // Disable AR in debug mode for better performance
    );
  }
  
  /// Factory for staging environment
  factory AppConfig.staging() {
    return const AppConfig(
      apiBaseUrl: 'https://staging-api.taprobanatrails.com',
      googleMapsApiKey: 'YOUR_STAGING_GOOGLE_MAPS_API_KEY',
      uberApiKey: 'YOUR_STAGING_UBER_API_KEY',
      pickMeApiKey: 'YOUR_STAGING_PICKME_API_KEY',
      enableAnalytics: true,
      enableCrashReporting: true,
      showDebugOverlay: false,
      enableOfflineMode: true,
      enableAR: true,
    );
  }
  
  /// Factory for production environment
  factory AppConfig.production() {
    return const AppConfig(
      apiBaseUrl: 'https://api.taprobanatrails.com',
      googleMapsApiKey: 'YOUR_PROD_GOOGLE_MAPS_API_KEY',
      uberApiKey: 'YOUR_PROD_UBER_API_KEY',
      pickMeApiKey: 'YOUR_PROD_PICKME_API_KEY',
      enableAnalytics: true,
      enableCrashReporting: true,
      showDebugOverlay: false,
      enableOfflineMode: true,
      enableAR: true,
    );
  }
}

