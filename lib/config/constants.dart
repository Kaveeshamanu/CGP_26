/// This file contains app-wide constants used throughout the Taprobana Trails app.
library;

/// API Constants
class ApiConstants {
  // Base URLs
  static const String apiBaseUrl = 'https://api.taprobanatrails.com';
  static const String assetsBaseUrl = 'https://assets.taprobanatrails.com';
  
  // Endpoints
  static const String destinationsEndpoint = '/destinations';
  static const String accommodationsEndpoint = '/accommodations';
  static const String restaurantsEndpoint = '/restaurants';
  static const String transportEndpoint = '/transport';
  static const String itinerariesEndpoint = '/itineraries';
  static const String reviewsEndpoint = '/reviews';
  static const String usersEndpoint = '/users';
  
  // Ride-hailing API paths
  static const String uberBaseUrl = 'https://api.uber.com/v1.2';
  static const String pickMeBaseUrl = 'https://api.pickme.lk/v2';
  
  // Weather API
  static const String weatherApiBaseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Timeout durations
  static const int connectionTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 15000; // 15 seconds
  
  // Error messages
  static const String defaultErrorMessage = 'Something went wrong. Please try again later.';
  static const String connectionErrorMessage = 'Please check your internet connection and try again.';
  static const String timeoutErrorMessage = 'The server is taking too long to respond. Please try again later.';
}

/// App Constants
class AppConstants {
  // App info
  static const String appName = 'Taprobana Trails';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Discover Sri Lanka\'s Wonders';
  static const String appDescription = 'All-in-one travel planning app for exploring Sri Lanka';
  
  // Legal
  static const String privacyPolicyUrl = 'https://taprobanatrails.com/privacy-policy';
  static const String termsAndConditionsUrl = 'https://taprobanatrails.com/terms-and-conditions';
  
  // Social media
  static const String facebookUrl = 'https://facebook.com/taprobanatrails';
  static const String instagramUrl = 'https://instagram.com/taprobanatrails';
  static const String twitterUrl = 'https://twitter.com/taprobanatrails';
  
  // Support
  static const String supportEmail = 'support@taprobanatrails.com';
  static const String supportPhone = '+94 11 234 5678';
  static const String supportWebsite = 'https://taprobanatrails.com/support';
  
  // App settings
  static const int searchResultsLimit = 50;
  static const int reviewsPerPage = 20;
  static const int defaultCacheDuration = 60 * 60 * 24; // 24 hours in seconds
  
  // Default map settings
  static const double defaultLatitude = 7.8731; // Sri Lanka center latitude
  static const double defaultLongitude = 80.7718; // Sri Lanka center longitude
  static const double defaultZoomLevel = 7.0;
}

/// UI Constants
class UIConstants {
  // Padding and margin
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  
  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircular = 100.0;
  
  // Font sizes
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeDisplay = 32.0;
  
  // Button sizes
  static const double buttonHeight = 52.0;
  static const double buttonSmallHeight = 40.0;
  static const double buttonIconSize = 24.0;
  
  // Card elements
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 16.0;
  
  // Image sizes
  static const double avatarSize = 40.0;
  static const double avatarSizeLarge = 80.0;
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeLarge = 32.0;
  static const double thumbnailHeight = 80.0;
  static const double bannerHeight = 200.0;
  
  // Animation durations
  static const int shortAnimationDuration = 200; // 0.2 seconds
  static const int mediumAnimationDuration = 400; // 0.4 seconds
  static const int longAnimationDuration = 800; // 0.8 seconds
}

/// Destination Categories
class DestinationCategories {
  static const String all = 'All';
  static const String beach = 'Beach';
  static const String wildlife = 'Wildlife';
  static const String heritage = 'Heritage';
  static const String mountain = 'Mountain';
  static const String city = 'City';
  static const String temple = 'Temple';
  static const String waterfall = 'Waterfall';
  static const String adventure = 'Adventure';
  
  static List<String> allCategories = [
    all,
    beach,
    heritage,
    wildlife,
    mountain,
    city,
    temple,
    waterfall,
    adventure,
  ];
}

/// Popular Destinations
class PopularDestinations {
  static const String colombo = 'Colombo';
  static const String kandy = 'Kandy';
  static const String galle = 'Galle';
  // ignore: constant_identifier_names
  static const String nuwara_eliya = 'Nuwara Eliya';
  static const String ella = 'Ella';
  static const String sigiriya = 'Sigiriya';
  static const String jaffna = 'Jaffna';
  static const String trincomalee = 'Trincomalee';
  // ignore: constant_identifier_names
  static const String arugam_bay = 'Arugam Bay';
  static const String mirissa = 'Mirissa';
  
  static List<String> featuredDestinations = [
    colombo,
    kandy,
    galle,
    sigiriya,
    ella,
    mirissa,
  ];
}

/// Transportation Types
class TransportationTypes {
  static const String bus = 'Bus';
  static const String train = 'Train';
  static const String taxi = 'Taxi';
  static const String uber = 'Uber';
  static const String pickMe = 'PickMe';
  static const String tuktuk = 'Tuk-tuk';
  static const String ferry = 'Ferry';
  static const String flight = 'Flight';
  static const String rental = 'Rental';
  
  static List<String> allTypes = [
    bus,
    train,
    taxi,
    uber,
    pickMe,
    tuktuk,
    ferry,
    flight,
    rental,
  ];
  
  static List<String> publicTransport = [
    bus,
    train,
    ferry,
    flight,
  ];
  
  static List<String> rideHailing = [
    uber,
    pickMe,
    taxi,
    tuktuk,
  ];
}

/// Accommodation Types
class AccommodationTypes {
  static const String hotel = 'Hotel';
  static const String resort = 'Resort';
  static const String hostel = 'Hostel';
  static const String guesthouse = 'Guesthouse';
  static const String villa = 'Villa';
  static const String apartment = 'Apartment';
  static const String homestay = 'Homestay';
  static const String bungalow = 'Bungalow';
  
  static List<String> allTypes = [
    hotel,
    resort,
    hostel,
    guesthouse,
    villa,
    apartment,
    homestay,
    bungalow,
  ];
}

/// Storage Keys
class StorageKeys {
  // User preferences
  static const String isDarkMode = 'isDarkMode';
  static const String preferredLanguage = 'preferredLanguage';
  static const String preferredCurrency = 'preferredCurrency';
  static const String hasCompletedOnboarding = 'hasCompletedOnboarding';
  
  // Auth related
  static const String authToken = 'authToken';
  static const String refreshToken = 'refreshToken';
  static const String userId = 'userId';
  static const String userEmail = 'userEmail';
  
  // App state
  static const String lastSearchQuery = 'lastSearchQuery';
  static const String lastViewedDestinationId = 'lastViewedDestinationId';
  static const String recentSearches = 'recentSearches';
  static const String cachedHomeData = 'cachedHomeData';
  static const String cachedItineraries = 'cachedItineraries';
  static const String offlineMapsDownloaded = 'offlineMapsDownloaded';
  
  // Notification preferences
  static const String enablePushNotifications = 'enablePushNotifications';
  static const String enableBookingNotifications = 'enableBookingNotifications';
  static const String enablePromoNotifications = 'enablePromoNotifications';
  static const String enableSystemNotifications = 'enableSystemNotifications';
}

/// Notification Channels
class NotificationChannels {
  static const String bookings = 'bookings';
  static const String deals = 'deals';
  static const String reminders = 'reminders';
  static const String system = 'system';
  static const String itinerary = 'itinerary';
  static const String social = 'social';
  static const String weather = 'weather';
  static const String travel = 'travel';
}

/// Error Codes
class ErrorCodes {
  static const String noInternet = 'NO_INTERNET';
  static const String serverError = 'SERVER_ERROR';
  static const String timeout = 'TIMEOUT';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String notFound = 'NOT_FOUND';
  static const String validationError = 'VALIDATION_ERROR';
  static const String paymentFailed = 'PAYMENT_FAILED';
  static const String bookingFailed = 'BOOKING_FAILED';
  static const String locationError = 'LOCATION_ERROR';
}

/// App Assets
class AppAssets {
  // Logo
  static const String logo = 'assets/images/logo.png';
  static const String logoWhite = 'assets/images/logo_white.png';
  static const String logoWithText = 'assets/images/logo_with_text.png';
  
  // Animations
  static const String splashAnimation = 'assets/animations/splash_animation.json';
  static const String loadingAnimation = 'assets/animations/loading_animation.json';
  static const String successAnimation = 'assets/animations/success_animation.json';
  static const String errorAnimation = 'assets/animations/error_animation.json';
  
  // Onboarding
  static const String onboarding1 = 'assets/images/onboarding_1.png';
  static const String onboarding2 = 'assets/images/onboarding_2.png';
  static const String onboarding3 = 'assets/images/onboarding_3.png';
  static const String onboarding4 = 'assets/images/onboarding_4.png';
  
  // Icons
  static const String iconMap = 'assets/icons/map.png';
  static const String iconHotel = 'assets/icons/hotel.png';
  static const String iconFood = 'assets/icons/food.png';
  static const String iconTransport = 'assets/icons/transport.png';
  static const String iconItinerary = 'assets/icons/itinerary.png';
  static const String iconSafety = 'assets/icons/safety.png';
  
  // Placeholder images
  static const String placeholderDestination = 'assets/images/placeholder_destination.png';
  static const String placeholderHotel = 'assets/images/placeholder_hotel.png';
  static const String placeholderRestaurant = 'assets/images/placeholder_restaurant.png';
  static const String placeholderProfile = 'assets/images/placeholder_profile.png';
  
  // Credit cards
  static const String visa = 'assets/icons/visa.png';
  static const String mastercard = 'assets/icons/mastercard.png';
  static const String amex = 'assets/icons/amex.png';
}