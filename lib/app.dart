import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:taprobana_trails/config/app_config.dart';
import 'package:taprobana_trails/config/routes.dart';
import 'package:taprobana_trails/config/theme.dart';
import 'package:taprobana_trails/bloc/auth/auth_bloc.dart';
import 'package:taprobana_trails/presentation/common/screens/splash_screen.dart';
import 'package:taprobana_trails/presentation/auth/login_screen.dart';
import 'package:taprobana_trails/presentation/home/home_screen.dart';

class TaprobanaTrailsApp extends StatelessWidget {
  final AppConfig appConfig;

  const TaprobanaTrailsApp({
    super.key,
    required this.appConfig,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taprobana Trails',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark theme
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('si', ''), // Sinhala
        Locale('ta', ''), // Tamil
      ],
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthUninitialized) {
            return const SplashScreen();
          }
          if (state is AuthAuthenticated) {
            return const HomeScreen();
          }
          if (state is AuthUnauthenticated) {
            return const LoginScreen();
          }
          return const SplashScreen(); // Default fallback
        },
      ),
    );
  }
}
