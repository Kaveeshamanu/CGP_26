import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/buttons.dart';

/// Error screen to display when something goes wrong in the app
class ErrorScreen extends StatelessWidget {
  final String? title;
  final String? message;
  final String? errorCode;
  final VoidCallback? onRetry;
  final bool isConnectivityError;
  final bool isNotFoundError;
  final bool showHomeButton;

  const ErrorScreen({
    super.key,
    this.title,
    this.message,
    this.errorCode,
    this.onRetry,
    this.isConnectivityError = false,
    this.isNotFoundError = false,
    this.showHomeButton = true,
  });

  /// Factory constructor for creating a connectivity error screen
  factory ErrorScreen.connectivity({
    VoidCallback? onRetry,
    bool showHomeButton = true,
  }) {
    return ErrorScreen(
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      isConnectivityError: true,
      onRetry: onRetry,
      showHomeButton: showHomeButton,
    );
  }

  /// Factory constructor for creating a not found error screen
  factory ErrorScreen.notFound({
    String? message,
    bool showHomeButton = true,
  }) {
    return ErrorScreen(
      title: 'Not Found',
      message: message ?? 'The resource you requested could not be found.',
      isNotFoundError: true,
      showHomeButton: showHomeButton,
    );
  }

  /// Factory constructor for creating a generic error screen
  factory ErrorScreen.generic({
    String? title,
    String? message,
    String? errorCode,
    VoidCallback? onRetry,
    bool showHomeButton = true,
  }) {
    return ErrorScreen(
      title: title ?? 'Something Went Wrong',
      message:
          message ?? 'An unexpected error occurred. Please try again later.',
      errorCode: errorCode,
      onRetry: onRetry,
      showHomeButton: showHomeButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              SvgPicture.asset(
                'assets/images/app_logo.svg',
                height: 50,
              ),
              const SizedBox(height: 40.0),

              // Error animation
              _buildErrorAnimation(),
              const SizedBox(height: 32.0),

              // Error title
              Text(
                title ?? 'Error',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),

              // Error message
              Text(
                message ?? 'An unexpected error occurred.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              // Error code (if provided)
              if (errorCode != null) ...[
                const SizedBox(height: 8.0),
                Text(
                  'Error Code: $errorCode',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 40.0),

              // Retry button
              if (onRetry != null) _buildRetryButton(context),

              // Home button
              if (showHomeButton) ...[
                const SizedBox(height: 16.0),
                _buildHomeButton(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorAnimation() {
    String animationAsset;
    double height = 200.0;

    if (isConnectivityError) {
      animationAsset = 'assets/animations/no_connection.json';
    } else if (isNotFoundError) {
      animationAsset = 'assets/animations/not_found.json';
    } else {
      animationAsset = 'assets/animations/error.json';
    }

    return Lottie.asset(
      animationAsset,
      height: height,
      repeat: true,
      fit: BoxFit.contain,
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        // If it's a connectivity error, we can't check connectivity
        // since ConnectivityHelper is not available. Simply call onRetry
        onRetry?.call();
      },
      icon: isConnectivityError
          ? const Icon(Icons.wifi)
          : const Icon(Icons.refresh),
      label: Text(isConnectivityError ? 'Try Again' : 'Retry'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        // Navigate to home screen and clear the stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      },
      icon: const Icon(Icons.home),
      label: const Text('Go to Home'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
