import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/config/constants.dart';

/// Represents the connectivity status.
enum ConnectivityStatus {
  /// Connected to WiFi network
  wifi,
  
  /// Connected to mobile network
  mobile,
  
  /// No internet connection
  offline,
  
  /// Connection status unknown
  unknown,
}

/// Exception thrown when there's a connectivity error.
class ConnectivityException implements Exception {
  final String message;
  final String? code;

  ConnectivityException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'ConnectivityException: $message (Code: $code)';
}

/// Service class for handling network connectivity.
class ConnectivityService {
  static const Duration _pingTimeout = Duration(seconds: 5);
  static const Duration _checkDelay = Duration(milliseconds: 500);
  static const List<String> _pingEndpoints = [
    'google.com',
    'apple.com',
    'cloudflare.com',
  ];
  
  final Connectivity _connectivity;
  final StreamController<ConnectivityStatus> _controller = StreamController<ConnectivityStatus>.broadcast();
  
  ConnectivityStatus _lastStatus = ConnectivityStatus.unknown;
  Timer? _periodicCheckTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  /// Stream of connectivity status changes.
  Stream<ConnectivityStatus> get status => _controller.stream;
  
  /// Gets the current connectivity status.
  ConnectivityStatus get currentStatus => _lastStatus;
  
  /// Creates a new [ConnectivityService] instance.
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();
  
  /// Initializes the connectivity service.
  Future<void> initialize() async {
    try {
      // Get initial connectivity status
      final initialStatus = await checkConnectivity();
      _lastStatus = initialStatus;
      _controller.add(initialStatus);
      
      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus as void Function(List<ConnectivityResult> event)?) as StreamSubscription<ConnectivityResult>?;
      
      // Set up periodic connectivity check
      _periodicCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
        final currentStatus = await checkConnectivity();
        if (currentStatus != _lastStatus) {
          _lastStatus = currentStatus;
          _controller.add(currentStatus);
        }
      });
    } catch (e) {
      debugPrint('Error initializing connectivity service: $e');
    }
  }
  
  /// Updates the connection status when connectivity changes.
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    // Add a small delay to allow the connection to stabilize
    await Future.delayed(_checkDelay);
    
    final status = await _getStatusFromResult(result);
    
    if (status != _lastStatus) {
      _lastStatus = status;
      _controller.add(status);
    }
  }
  
  /// Gets the connectivity status from a ConnectivityResult.
  Future<ConnectivityStatus> _getStatusFromResult(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        // Verify internet access on WiFi
        if (await _hasInternetAccess()) {
          return ConnectivityStatus.wifi;
        }
        return ConnectivityStatus.offline;
      
      case ConnectivityResult.mobile:
        // Verify internet access on mobile
        if (await _hasInternetAccess()) {
          return ConnectivityStatus.mobile;
        }
        return ConnectivityStatus.offline;
      
      case ConnectivityResult.none:
        return ConnectivityStatus.offline;
      
      default:
        return ConnectivityStatus.unknown;
    }
  }
  
  /// Checks if the device has internet access.
  Future<bool> _hasInternetAccess() async {
    try {
      // Try to ping multiple endpoints in case one is blocked
      for (final endpoint in _pingEndpoints) {
        try {
          final result = await InternetAddress.lookup(endpoint)
              .timeout(_pingTimeout);
          
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            return true;
          }
        } catch (_) {
          // Continue to the next endpoint if this one fails
          continue;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking internet access: $e');
      return false;
    }
  }
  
  /// Checks the current connectivity status.
  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return await _getStatusFromResult(result as ConnectivityResult);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return ConnectivityStatus.unknown;
    }
  }
  
  /// Checks if the device is currently online.
  Future<bool> isOnline() async {
    final status = await checkConnectivity();
    return status == ConnectivityStatus.wifi || status == ConnectivityStatus.mobile;
  }
  
  /// Throws a ConnectivityException if the device is offline.
  Future<void> throwIfOffline() async {
    if (!await isOnline()) {
      throw ConnectivityException(
        message: ApiConstants.connectionErrorMessage,
        code: ErrorCodes.noInternet,
      );
    }
  }
  
  /// Gets the current connection type as a string.
  Future<String> getConnectionType() async {
    final status = await checkConnectivity();
    
    switch (status) {
      case ConnectivityStatus.wifi:
        return 'WiFi';
      case ConnectivityStatus.mobile:
        return 'Mobile Data';
      case ConnectivityStatus.offline:
        return 'Offline';
      case ConnectivityStatus.unknown:
        return 'Unknown';
    }
  }
  
  /// Executes a function with connectivity check.
  /// 
  /// [function] is the function to execute.
  /// Returns the result of the function.
  /// Throws a ConnectivityException if the device is offline.
  Future<T> withConnectivity<T>(Future<T> Function() function) async {
    try {
      await throwIfOffline();
      return await function();
    } on ConnectivityException {
      rethrow;
    } catch (e) {
      debugPrint('Error executing function with connectivity: $e');
      rethrow;
    }
  }
  
  /// Disposes the connectivity service.
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicCheckTimer?.cancel();
    _controller.close();
  }
}

/// Global utility functions for connectivity.
class ConnectivityUtils {
  /// Checks if a request should be retried based on the error.
  static bool shouldRetry(dynamic error) {
    if (error is SocketException ||
        error is TimeoutException ||
        (error is ConnectivityException && error.code == ErrorCodes.noInternet)) {
      return true;
    }
    
    return false;
  }
  
  /// Gets an exponential backoff duration for retries.
  static Duration getBackoffDuration(int retryCount) {
    // Base duration is 1 second
    // Exponential backoff with jitter: 1s, ~2s, ~4s, ~8s, etc.
    final baseMs = 1000 * (1 << (retryCount - 1));
    final jitterMs = (baseMs * 0.2 * (1 - 2 * DateTime.now().millisecond / 1000)).round();
    
    // Cap at 30 seconds
    final durationMs = (baseMs + jitterMs).clamp(0, 30000);
    
    return Duration(milliseconds: durationMs);
  }
  
  /// Gets a user-friendly message for connectivity errors.
  static String getFriendlyErrorMessage(dynamic error) {
    if (error is ConnectivityException) {
      return error.message;
    } else if (error is SocketException) {
      return ApiConstants.connectionErrorMessage;
    } else if (error is TimeoutException) {
      return ApiConstants.timeoutErrorMessage;
    }
    
    return ApiConstants.defaultErrorMessage;
  }

  isConnected() {}
}