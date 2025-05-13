import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taprobana_trails_app/firebase_options.dart';
import 'package:taprobana_trails_app/screens/auth/login_screen.dart';
import 'package:taprobana_trails_app/screens/home_screen.dart';
import 'package:taprobana_trails_app/services/auth_service.dart';
import 'package:taprobana_trails_app/services/booking_service.dart';
import 'package:taprobana_trails_app/services/location_service.dart';
import 'package:taprobana_trails_app/services/offline_manager.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(prefs);
  final offlineManager = OfflineManager(prefs);
  final locationService = LocationService();
  final bookingService = BookingService();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => offlineManager),
        ChangeNotifierProvider(create: (_) => locationService),
        ChangeNotifierProvider(create: (_) => bookingService),
      ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Taprobana Trails',
          theme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: Consumer<AuthService>(
            builder: (context, authService, _) {
              return authService.isAuthenticated ? HomeScreen() : LoginScreen();
            },
          ),
        );
      },
    );
  }
}