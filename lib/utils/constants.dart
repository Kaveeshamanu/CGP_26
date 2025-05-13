class AppConstants {
  // API Endpoints
  static const String baseUrl = 'https://api.taprobantrails.com/v1';
  static const String authEndpoint = '$baseUrl/auth';
  static const String placesEndpoint = '$baseUrl/places';
  static const String accommodationsEndpoint = '$baseUrl/accommodations';
  static const String transportationEndpoint = '$baseUrl/transportation';
  static const String itinerariesEndpoint = '$baseUrl/itineraries';

  // Storage Keys
  static const String userKey = 'user';
  static const String tokenKey = 'token';
  static const String offlineModeKey = 'offline_mode';
  static const String languageKey = 'language';

  // App Settings
  static const int cacheDurationDays = 7;
  static const List<String> supportedLanguages = ['en', 'si', 'ta', 'zh', 'fr', 'de', 'ru'];
}