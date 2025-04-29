import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../core/utils/connectivity.dart';
import '../widgets/loaders.dart';
import 'error_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _hasError = false;
  bool _isConnected = true;
  String _appVersion = '';
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAppState('');
  }
  
  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
  }
  
  Future<void> _checkAppState(dynamic ConnectivityHelper) async {
    try {
      // Get app version
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'v${packageInfo.version}';
      });
      
      // Check connectivity
      _isConnected = await ConnectivityHelper.isConnected();
      if (!_isConnected) {
        setState(() {
          _hasError = true;
        });
        return;
      }
      
      // Dispatch check auth state event after a delay to allow animations to play
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          context.read<AuthBloc>().add(AuthCheckRequested());
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }
  
  void _retryConnection() {
    setState(() {
      _hasError = false;
    });
    _checkAppState('');
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && !_isConnected) {
      return ErrorScreen.connectivity(
        onRetry: _retryConnection,
        showHomeButton: false,
      );
    }
    
    if (_hasError) {
      return ErrorScreen.generic(
        title: 'Startup Error',
        message: 'Failed to start the application. Please try again.',
        onRetry: _retryConnection,
        showHomeButton: false,
      );
    }
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // User is logged in, navigate to home
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is Unauthenticated) {
          // User is not logged in, navigate to onboarding or welcome screen
          if (state.isFirstLaunch) {
            Navigator.pushReplacementNamed(context, '/onboarding');
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        } else if (state is AuthError) {
          setState(() {
            _hasError = true;
          });
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Logo animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeInAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/images/app_logo.svg',
                    height: 120,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                
                // App name
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeInAnimation,
                      child: child,
                    );
                  },
                  child: Text(
                    'Taprobana Trails',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                
                // Tagline
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeInAnimation,
                      child: child,
                    );
                  },
                  child: Text(
                    'Explore Sri Lanka\'s wonders',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Loading indicator
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const FadeInLoader(
                        color: Colors.white,
                        size: 32.0,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                const Spacer(),
                
                // Version info
                Text(
                  _appVersion,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Authenticated {
}