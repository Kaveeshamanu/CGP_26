import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/config/app_config.dart';
import 'package:taprobana_trails/config/constants.dart';
import 'package:taprobana_trails/core/api/api_client.dart';
import 'package:taprobana_trails/core/storage/secure_storage.dart';
import 'package:taprobana_trails/data/models/ride.dart';

/// Exception thrown when there's a PickMe API error.
class PickMeApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  PickMeApiException({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() => 'PickMeApiException: $message (Code: $code, Status: $statusCode)';
}

/// Service class for interacting with the PickMe API.
class PickMeApiService {
  static const String _tokenKey = 'pickme_access_token';
  static const String _tokenExpiryKey = 'pickme_token_expiry';
  
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  final AppConfig _appConfig;
  final CancelToken _cancelToken = CancelToken();
  
  /// Creates a new [PickMeApiService].
  PickMeApiService({
    ApiClient? apiClient,
    SecureStorage? secureStorage,
    required AppConfig appConfig,
  }) : _appConfig = appConfig,
       _secureStorage = secureStorage ?? SecureStorage(),
       _apiClient = apiClient ?? ApiClient(
         baseUrl: ApiConstants.pickMeBaseUrl,
         secureStorage: secureStorage ?? SecureStorage(),
       );
  
  /// Initializes the PickMe API service.
  Future<void> initialize() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      final expiryString = await _secureStorage.read(key: _tokenExpiryKey);
      
      // Check if token exists and is not expired
      if (token != null && expiryString != null) {
        final expiry = DateTime.parse(expiryString);
        if (expiry.isAfter(DateTime.now())) {
          // Token is still valid
          return;
        }
      }
      
      // Token doesn't exist or is expired, request a new one
      await _requestAccessToken();
    } catch (e) {
      debugPrint('Error initializing PickMe API: $e');
      throw PickMeApiException(
        message: 'Failed to initialize PickMe API: ${e.toString()}',
      );
    }
  }
  
  /// Requests a new access token from the PickMe API.
  Future<void> _requestAccessToken() async {
    try {
      final response = await Dio().post(
        '${ApiConstants.pickMeBaseUrl}/auth/token',
        data: jsonEncode({
          'api_key': _appConfig.pickMeApiKey,
          'grant_type': 'client_credentials',
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final token = data['access_token'] as String;
        final expiresIn = data['expires_in'] as int? ?? 3600; // Default to 1 hour
        
        // Calculate expiry time
        final expiry = DateTime.now().add(Duration(seconds: expiresIn));
        
        // Save token and expiry time
        await _secureStorage.write(key: _tokenKey, value: token);
        await _secureStorage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());
      } else {
        throw PickMeApiException(
          message: 'Failed to get access token',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('Error requesting PickMe access token: $e');
      throw PickMeApiException(
        message: 'Failed to authenticate with PickMe API: ${e.toString()}',
      );
    }
  }
  
  /// Gets the auth token for API requests.
  Future<String?> _getAuthToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      final expiryString = await _secureStorage.read(key: _tokenExpiryKey);
      
      if (token == null || expiryString == null) {
        await _requestAccessToken();
        return await _secureStorage.read(key: _tokenKey);
      }
      
      final expiry = DateTime.parse(expiryString);
      if (expiry.isBefore(DateTime.now())) {
        await _requestAccessToken();
        return await _secureStorage.read(key: _tokenKey);
      }
      
      return token;
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }
  
  /// Gets the estimated ride price.
  /// 
  /// [startLatitude] and [startLongitude] define the starting point.
  /// [endLatitude] and [endLongitude] define the destination.
  Future<Map<String, dynamic>> getRidePriceEstimates({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    try {
      await initialize();
      final token = await _getAuthToken();
      
      if (token == null) {
        throw PickMeApiException(message: 'Authentication failed');
      }
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/estimates/price',
        data: {
          'start_latitude': startLatitude,
          'start_longitude': startLongitude,
          'end_latitude': endLatitude,
          'end_longitude': endLongitude,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        cancelToken: _cancelToken,
      );
      
      return response;
    } on NetworkException catch (e) {
      throw PickMeApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw PickMeApiException(message: e.toString());
    }
  }
  
  /// Gets the estimated time of arrival for a ride.
  /// 
  /// [latitude] and [longitude] define the pickup location.
  Future<Map<String, dynamic>> getRideTimeEstimates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await initialize();
      final token = await _getAuthToken();
      
      if (token == null) {
        throw PickMeApiException(message: 'Authentication failed');
      }
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/estimates/time',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        cancelToken: _cancelToken,
      );
      
      return response;
    } on NetworkException catch (e) {
      throw PickMeApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw PickMeApiException(message: e.toString());
    }
  }
  
  /// Gets a list of available ride options.
  /// 
  /// [startLatitude] and [startLongitude] define the starting point.
  /// [endLatitude] and [endLongitude] define the destination.
  Future<List<Ride>> getAvailableRides({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    try {
      final priceEstimates = await getRidePriceEstimates(
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        endLatitude: endLatitude,
        endLongitude: endLongitude,
      );
      
      final timeEstimates = await getRideTimeEstimates(
        latitude: startLatitude,
        longitude: startLongitude,
      );
      
      // Process and combine the estimates to create ride objects
      final List<Ride> rides = [];
      final priceData = priceEstimates['categories'] as List<dynamic>? ?? [];
      final timeData = timeEstimates['categories'] as List<dynamic>? ?? [];
      
      for (final price in priceData) {
        final categoryId = price['category_id'];
        final time = timeData.firstWhere(
          (t) => t['category_id'] == categoryId,
          orElse: () => {'eta': 0},
        );
        
        rides.add(Ride(
          id: categoryId,
          name: price['name'] ?? 'Unknown',
          estimatedPrice: 'LKR ${price['estimated_price'] ?? 'Unknown'}',
          estimatedDuration: time['eta'] != null
              ? Duration(minutes: time['eta'])
              : Duration.zero,
          estimatedDistance: price['distance'] != null
              ? double.parse(price['distance'].toString())
              : 0.0,
          currency: 'LKR',
          surge: price['surge'] == true,
          image: _getRideImage(price['name']),
          provider: 'PickMe',
        ));
      }
      
      return rides;
    } catch (e) {
      debugPrint('Error getting available rides: $e');
      return [];
    }
  }
  
  /// Requests a ride.
  /// 
  /// [categoryId] is the ID of the ride category to request.
  /// [startLatitude] and [startLongitude] define the starting point.
  /// [endLatitude] and [endLongitude] define the destination.
  Future<Map<String, dynamic>> requestRide({
    required String categoryId,
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
    String? startAddress,
    String? endAddress,
    String? paymentMethod = 'CASH', // CASH, CARD, etc.
  }) async {
    try {
      await initialize();
      final token = await _getAuthToken();
      
      if (token == null) {
        throw PickMeApiException(message: 'Authentication failed');
      }
      
      final data = {
        'category_id': categoryId,
        'pickup': {
          'latitude': startLatitude,
          'longitude': startLongitude,
        },
        'dropoff': {
          'latitude': endLatitude,
          'longitude': endLongitude,
        },
        'payment_method': paymentMethod,
      };
      
      // Add optional parameters if provided
      if (startAddress != null) {
        (data['pickup'] as Map<String, dynamic>)['address'] = startAddress;
      }
      
      if (endAddress != null) {
        (data['dropoff'] as Map<String, dynamic>)['address'] = endAddress;
      }
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/bookings',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        cancelToken: _cancelToken,
      );
      
      return response;
    } on NetworkException catch (e) {
      throw PickMeApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw PickMeApiException(message: e.toString());
    }
  }
  
  /// Checks the status of a ride request.
  /// 
  /// [bookingId] is the ID of the booking.
  Future<Map<String, dynamic>> checkRideStatus(String bookingId) async {
    try {
      await initialize();
      final token = await _getAuthToken();
      
      if (token == null) {
        throw PickMeApiException(message: 'Authentication failed');
      }
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/bookings/$bookingId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        cancelToken: _cancelToken,
      );
      
      return response;
    } on NetworkException catch (e) {
      throw PickMeApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw PickMeApiException(message: e.toString());
    }
  }
  
  /// Cancels a ride request.
  /// 
  /// [bookingId] is the ID of the booking.
  /// [reason] is the reason for cancellation.
  Future<bool> cancelRide(String bookingId, {String? reason}) async {
    try {
      await initialize();
      final token = await _getAuthToken();
      
      if (token == null) {
        throw PickMeApiException(message: 'Authentication failed');
      }
      
      final data = reason != null ? {'reason': reason} : null;
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/bookings/$bookingId/cancel',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        cancelToken: _cancelToken,
      );
      
      return response['status'] == 'SUCCESS';
    } on NetworkException catch (e) {
      throw PickMeApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw PickMeApiException(message: e.toString());
    }
  }
  
  /// Gets driver location.
  /// 
  /// [bookingId] is the ID of the booking.
  Future<Map<String, dynamic>> getDriverLocation(String bookingId) async {
    try {
      await initialize();
      final token = await _getAuthToken();
      
      if (token == null) {
        throw PickMeApiException(message: 'Authentication failed');
      }
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/bookings/$bookingId/driver-location',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        cancelToken: _cancelToken,
      );
      
      return response;
    } on NetworkException catch (e) {
      throw PickMeApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw PickMeApiException(message: e.toString());
    }
  }
  
  /// Gets a ride image based on the ride name.
  String _getRideImage(String? rideName) {
    if (rideName == null) return 'assets/images/pickme_default.png';
    
    switch (rideName.toLowerCase()) {
      case 'tuk':
        return 'assets/images/pickme_tuk.png';
      case 'car':
        return 'assets/images/pickme_car.png';
      case 'car plus':
        return 'assets/images/pickme_car_plus.png';
      case 'car premium':
        return 'assets/images/pickme_car_premium.png';
      case 'van':
        return 'assets/images/pickme_van.png';
      default:
        return 'assets/images/pickme_default.png';
    }
  }
  
  /// Cancels any ongoing requests.
  void dispose() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('Service disposed');
    }
  }
}