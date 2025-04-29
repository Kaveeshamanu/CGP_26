import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:taprobana_trails/presentation/maps/ar_mode_screen.dart' show PermissionsHandler;

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../core/utils/permissions.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final PermissionsHandler _permissionsHandler = PermissionsHandler();
  
  int _currentPage = 0;
  bool _isLastPage = false;
  
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Explore Sri Lanka',
      description: 'Discover the wonders of Sri Lanka with curated destinations, hidden gems, and local experiences.',
      animation: 'assets/animations/explore.json',
      backgroundColor: const Color(0xFF1A237E),
      textColor: Colors.white,
    ),
    OnboardingPageData(
      title: 'Plan Your Journey',
      description: 'Create personalized itineraries, book accommodations, and organize your perfect trip with ease.',
      animation: 'assets/animations/plan.json',
      backgroundColor: const Color(0xFF00796B),
      textColor: Colors.white,
    ),
    OnboardingPageData(
      title: 'Navigate Like a Local',
      description: 'Get around effortlessly with transport booking, offline maps, and real-time navigation features.',
      animation: 'assets/animations/navigate.json',
      backgroundColor: const Color(0xFF4A148C),
      textColor: Colors.white,
    ),
    OnboardingPageData(
      title: 'Immerse in Culture',
      description: 'Connect with local traditions, languages, and customs through helpful guides and translation tools.',
      animation: 'assets/animations/culture.json',
      backgroundColor: const Color(0xFF880E4F),
      textColor: Colors.white,
    ),
    OnboardingPageData(
      title: 'Ready to Explore?',
      description: 'Your Sri Lankan adventure awaits! Create an account or sign in to start your journey.',
      animation: 'assets/animations/ready.json',
      backgroundColor: AppTheme.primaryColor,
      textColor: Colors.white,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    
    // Request initial permissions
    _requestInitialPermissions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _requestInitialPermissions() async {
    // Request location permission as it's critical for the app
    await _permissionsHandler.requestLocationPermission();
  }

  Future<void> _completeOnboarding() async {
    // Save that onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    // Navigate to the appropriate screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  void _nextPage() {
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _isLastPage = index == _pages.length - 1;
              });
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              return OnboardingPage(
                title: page.title,
                description: page.description,
                animation: page.animation,
                backgroundColor: page.backgroundColor,
                textColor: page.textColor,
              );
            },
          ),
          
          // Skip button
          if (!_isLastPage)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // Bottom controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: WormEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.5),
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Next button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: _pages[_currentPage].backgroundColor,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _isLastPage ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Additional options on last page
                if (_isLastPage) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Navigate to login screen
                          _completeOnboarding();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          // Navigate to register screen
                          _completeOnboarding();
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final String animation;
  final Color backgroundColor;
  final Color textColor;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.animation,
    required this.backgroundColor,
    required this.textColor,
  });
}