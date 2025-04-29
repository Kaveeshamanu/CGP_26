import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taprobana_trails/app.dart';
import 'package:taprobana_trails/core/auth/auth_service.dart';
import 'package:taprobana_trails/data/repositories/user_repository.dart';
import 'package:taprobana_trails/bloc/auth/auth_bloc.dart';
import 'package:taprobana_trails/config/app_config.dart';
import 'package:taprobana_trails/firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Keep splash screen until app is fully loaded
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services and repositories
  final authService = AuthService();
  final userRepository = UserRepository();

  // Run app
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: authService,
            userRepository: userRepository,
          )..add(AppStarted()),
        ),
        // Add other BlocProviders here
      ],
      child: TaprobanaTrailsApp(
        appConfig: AppConfig.production(),
      ),
    ),
  );
  
  // Remove splash screen when app is ready
  FlutterNativeSplash.remove();
}