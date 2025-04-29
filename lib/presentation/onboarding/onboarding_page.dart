import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String animation;
  final Color backgroundColor;
  final Color textColor;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.animation,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Animation
              Lottie.asset(
                animation,
                height: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.contain,
              ),
              
              const Spacer(),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}