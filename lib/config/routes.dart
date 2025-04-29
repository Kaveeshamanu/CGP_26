import 'package:flutter/material.dart';
import 'package:taprobana_trails/presentation/common/screens/error_screen.dart';
import 'package:taprobana_trails/presentation/common/screens/splash_screen.dart';
import 'package:taprobana_trails/presentation/onboarding/onboarding_screen.dart';
import 'package:taprobana_trails/presentation/auth/login_screen.dart';
import 'package:taprobana_trails/presentation/auth/register_screen.dart';
import 'package:taprobana_trails/presentation/auth/profile_setup_screen.dart';
// Replace this import with the parent library
import 'package:taprobana_trails/presentation/auth/auth_screens.dart'; // This should contain forgot_password_screen
import 'package:taprobana_trails/presentation/home/home_screen.dart';
import 'package:taprobana_trails/presentation/destinations/destination_discovery_screen.dart';
import 'package:taprobana_trails/presentation/destinations/destination_details_screen.dart';
import 'package:taprobana_trails/presentation/maps/map_screen.dart';
import 'package:taprobana_trails/presentation/maps/ar_mode_screen.dart';
import 'package:taprobana_trails/presentation/accommodation/accommodation_list_screen.dart';
import 'package:taprobana_trails/presentation/accommodation/hotel_details_screen.dart';
import 'package:taprobana_trails/presentation/accommodation/booking_screen.dart';
import 'package:taprobana_trails/presentation/dining/restaurant_list_screen.dart';
import 'package:taprobana_trails/presentation/dining/restaurant_details_screen.dart';
import 'package:taprobana_trails/presentation/dining/reservation_screen.dart';
import 'package:taprobana_trails/presentation/transportation/transport_hub_screen.dart';
import 'package:taprobana_trails/presentation/transportation/transport_booking_screen.dart';
import 'package:taprobana_trails/presentation/itinerary/itinerary_planner_screen.dart';
import 'package:taprobana_trails/presentation/itinerary/day_schedule_screen.dart';
import 'package:taprobana_trails/presentation/language_culture/translator_screen.dart';
import 'package:taprobana_trails/presentation/language_culture/cultural_info_screen.dart';
import 'package:taprobana_trails/presentation/community/forum_screen.dart';
import 'package:taprobana_trails/presentation/community/review_screen.dart';
import 'package:taprobana_trails/presentation/deals/deals_screen.dart';
import 'package:taprobana_trails/presentation/safety/safety_screen.dart';
import 'package:taprobana_trails/presentation/safety/emergency_screen.dart';
import 'package:taprobana_trails/presentation/profile/profile_screen.dart';
import 'package:taprobana_trails/presentation/profile/settings_screen.dart';
import 'package:taprobana_trails/presentation/notifications/notification_center_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileSetup = '/profile-setup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String destinationDiscovery = '/destination-discovery';
  static const String destinationDetails = '/destination-details';
  static const String maps = '/maps';
  static const String arMode = '/ar-mode';
  static const String accommodationList = '/accommodation-list';
  static const String hotelDetails = '/hotel-details';
  static const String booking = '/booking';
  static const String restaurantList = '/restaurant-list';
  static const String restaurantDetails = '/restaurant-details';
  static const String reservation = '/reservation';
  static const String transportHub = '/transport-hub';
  static const String transportBooking = '/transport-booking';
  static const String itineraryPlanner = '/itinerary-planner';
  static const String daySchedule = '/day-schedule';
  static const String translator = '/translator';
  static const String culturalInfo = '/cultural-info';
  static const String forum = '/forum';
  static const String review = '/review';
  static const String deals = '/deals';
  static const String safety = '/safety';
  static const String emergency = '/emergency';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  static String notificationCenter = '/notification-center';
  static String itineraryDetails = '/itinerary-details';
  static String dealDetails = '/deal-details';
  static String restaurantReservation = '/restaurant-reservation';
  static String reservationConfirmation = '/reservation-confirmation';
  
  
  // Prevent instantiation
  AppRoutes._();
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case AppRoutes.profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());
      
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case AppRoutes.destinationDiscovery:
        return MaterialPageRoute(builder: (_) => const DestinationDiscoveryScreen());
      
      case AppRoutes.destinationDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DestinationDetailsScreen(
            destinationId: args['destinationId'],
          ),
        );
      
      case AppRoutes.maps:
        return MaterialPageRoute(builder: (_) => const MapScreen());
      
      case AppRoutes.arMode:
        return MaterialPageRoute(builder: (_) => const ARModeScreen());
      
      case AppRoutes.accommodationList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AccommodationListScreen(
            destinationId: args?['destinationId'],
          ),
        );
      
      case AppRoutes.hotelDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => HotelDetailsScreen(
            hotelId: args['hotelId'],
          ),
        );
      
      case AppRoutes.booking:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookingScreen(
            hotelId: args['hotelId'],
            roomType: args['roomType'],
          ),
        );
      
      case AppRoutes.restaurantList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RestaurantListScreen(
            destinationId: args?['destinationId'],
          ),
        );
      
      case AppRoutes.restaurantDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RestaurantDetailsScreen(
            restaurantId: args['restaurantId'],
          ),
        );
      
      case AppRoutes.reservation:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReservationScreen(
            restaurantId: args['restaurantId'],
          ),
        );
      
      case AppRoutes.transportHub:
        return MaterialPageRoute(builder: (_) => const TransportHubScreen());
      
      case AppRoutes.transportBooking:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TransportBookingScreen(
            transportType: args['transportType'], transportOption: null,
          ),
        );
      
      case AppRoutes.itineraryPlanner:
        return MaterialPageRoute(builder: (_) => const ItineraryPlannerScreen());
      
      case AppRoutes.daySchedule:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DayScheduleScreen(
            date: args['date'],
            itineraryId: args['itineraryId'], day: null,
          ),
        );
      
      case AppRoutes.translator:
        return MaterialPageRoute(builder: (_) => const TranslatorScreen());
      
      case AppRoutes.culturalInfo:
        return MaterialPageRoute(builder: (_) => const CulturalInfoScreen());
      
      case AppRoutes.forum:
        return MaterialPageRoute(builder: (_) => const ForumScreen());
      
      case AppRoutes.review:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReviewScreen(
            entityId: args['entityId'],
            entityType: args['entityType'],
          ),
        );
      
      case AppRoutes.deals:
        return MaterialPageRoute(builder: (_) => const DealsScreen());
      
      case AppRoutes.safety:
        return MaterialPageRoute(builder: (_) => const SafetyScreen());
      
      case AppRoutes.emergency:
        return MaterialPageRoute(builder: (_) => const EmergencyScreen());
      
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationCenterScreen());
        
      default:
        return MaterialPageRoute(
          builder: (_) => ErrorScreen(
            message: 'Route ${settings.name} not found',
          ),
        );
    }
  }
  
  // Prevent instantiation
  AppRouter._();
}