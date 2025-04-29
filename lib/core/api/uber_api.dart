import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/config/app_config.dart';
import 'package:taprobana_trails/config/constants.dart';
import 'package:taprobana_trails/core/api/api_client.dart';
import 'package:taprobana_trails/core/storage/secure_storage.dart';
import 'package:taprobana_trails/data/models/ride.dart';

/// Exception thrown when there's an Uber API error.
class UberApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  UberApiException({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() => 'UberApiException: $message (Code: $code, Status: $statusCode)';
}

/// Service class for interacting with the Uber API.
class UberApiService {
  static const String _tokenKey = 'uber_access_token';
  static const String _tokenExpiryKey = 'uber_token_expiry';
  
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  final AppConfig _appConfig;
  final CancelToken _cancelToken = CancelToken();
  
  /// Creates a new [UberApiService].
  UberApiService({
    ApiClient? apiClient,
    SecureStorage? secureStorage,
    required AppConfig appConfig,
  }) : _appConfig = appConfig,
       _secureStorage = secureStorage ?? SecureStorage(),
       _apiClient = apiClient ?? ApiClient(
         baseUrl: ApiConstants.uberBaseUrl,
         secureStorage: secureStorage ?? SecureStorage(),
       );
  
  /// Initializes the Uber API service.
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
      debugPrint('Error initializing Uber API: $e');
      throw UberApiException(
        message: 'Failed to initialize Uber API: ${e.toString()}',
      );
    }
  }
  
  /// Requests a new access token from the Uber API.
  Future<void> _requestAccessToken() async {
    try {
      final response = await Dio().post(
        'https://login.uber.com/oauth/v2/token',
        data: {
          'client_id': _appConfig.uberApiKey,
          'client_secret': 'YOUR_CLIENT_SECRET', // In a real app, this would be securely stored
          'grant_type': 'client_credentials',
          'scope': 'rides.request',
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final token = data['access_token'] as String;
        final expiresIn = data['expires_in'] as int? ?? 86400; // Default to 24 hours
        
        // Calculate expiry time
        final expiry = DateTime.now().add(Duration(seconds: expiresIn));
        
        // Save token and expiry time
        await _secureStorage.write(key: _tokenKey, value: token);
        await _secureStorage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());
      } else {
        throw UberApiException(
          message: 'Failed to get access token: ${response.data}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('Error requesting Uber access token: $e');
      throw UberApiException(
        message: 'Failed to authenticate with Uber API: ${e.toString()}',
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
        throw UberApiException(message: 'Authentication failed');
      }
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/estimates/price',
        queryParameters: {
          'start_latitude': startLatitude.toString(),
          'start_longitude': startLongitude.toString(),
          'end_latitude': endLatitude.toString(),
          'end_longitude': endLongitude.toString(),
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
      throw UberApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UberApiException(message: e.toString());
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
        throw UberApiException(message: 'Authentication failed');
      }
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/estimates/time',
        queryParameters: {
          'start_latitude': latitude.toString(),
          'start_longitude': longitude.toString(),
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
      throw UberApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UberApiException(message: e.toString());
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
      final priceData = priceEstimates['prices'] as List<dynamic>? ?? [];
      final timeData = timeEstimates['times'] as List<dynamic>? ?? [];
      
      for (final price in priceData) {
        final productId = price['product_id'];
        final time = timeData.firstWhere(
          (t) => t['product_id'] == productId,
          orElse: () => {'estimate': 0},
        );
        
        rides.add(Ride(
          id: productId,
          name: price['display_name'] ?? 'Unknown',
          estimatedPrice: price['estimate'] ?? 'Unknown',
          estimatedDuration: time['estimate'] != null
              ? Duration(seconds: time['estimate'] ~/ 1000)
              : Duration.zero,
          estimatedDistance: price['distance'] != null
              ? double.parse(price['distance'].toString())
              : 0.0,
          currency: price['currency_code'] ?? 'LKR',
          surge: price['surge_multiplier'] != null && price['surge_multiplier'] > 1.0,
          image: _getRideImage(price['display_name']),
          provider: 'Uber',
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
  /// [productId] is the ID of the ride product to request.
  /// [startLatitude] and [startLongitude] define the starting point.
  /// [endLatitude] and [endLongitude] define the destination.
  Future<Map<String, dynamic>> requestRide({
    required String productId,
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
    String? startAddress,
    String? endAddress,
  }) async {
    try {
      await initialize();
      final token = await _getAuthToken();
      
      if (token == null) {
        throw UberApiException(message: 'Authentication failed');
      }
      
      final data = {
        'product_id': productId,
        'start_latitude': startLatitude,
        'start_longitude': startLongitude,
        'end_latitude': endLatitude,
        'end_longitude': endLongitude,
      };
      
      if (startAddress != null) {
        data['start_address'] = startAddress;
      }
      
      if (endAddress != null) {
        data['end_address'] = endAddress;
      }
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/requests',
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
      throw UberApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UberApiException(message: e.toString());
    }
  }
  
  /// Checks the status of a ride request.
  /// 
  /// [requestId] is the ID of the ride request.
  Future<Map<String, dynamic>> checkRideStatus(String requestId) async {
    try {
      await initialize();
      final token = await _getAuthToken();
      
      if (token == null) {
        throw UberApiException(message: 'Authentication failed');
      }
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/requests/$requestId',
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
      throw UberApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UberApiException(message: e.toString());
    }
  }
  
  /// Cancels a ride request.
  /// 
  /// [requestId] is the ID of the ride request.
  Future<bool> cancelRide(String requestId) async {
    try {
      await initialize();
      final token = await _getAuthToken();
      
      if (token == null) {
        throw UberApiException(message: 'Authentication failed');
      }
      
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '/requests/$requestId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        cancelToken: _cancelToken,
      );
      
      return response['status'] == 'cancelled';
    } on NetworkException catch (e) {
      throw UberApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UberApiException(message: e.toString());
    }
  }
  
  /// Gets estimated ride fare.
  /// 
  /// [productId] is the ID of the ride product.
  /// [startLatitude] and [startLongitude] define the starting point.
  /// [endLatitude] and [endLongitude] define the destination.
  Future<Map<String, dynamic>> getRideFareEstimate({
    required String productId,
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    try {
      await initialize();
      final token = await _getAuthToken();
      
      if (token == null) {
        throw UberApiException(message: 'Authentication failed');
      }
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/requests/estimate',
        data: {
          'product_id': productId,
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
      throw UberApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UberApiException(message: e.toString());
    }
  }
  
  /// Gets available ride products in the area.
  /// 
  /// [latitude] and [longitude] define the location to check.
  Future<List<Map<String, dynamic>>> getProducts({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await initialize();
      final token = await _getAuthToken();
      
      if (token == null) {
        throw UberApiException(message: 'Authentication failed');
      }
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/products',
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        cancelToken: _cancelToken,
      );
      
      return (response['products'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ?? [];
    } on NetworkException catch (e) {
      throw UberApiException(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UberApiException(message: e.toString());
    }
  }
  
  /// Gets a ride image based on the ride name.
  String _getRideImage(String? rideName) {
    if (rideName == null) return 'assets/images/uber_default.png';
    
    switch (rideName.toLowerCase()) {
      case 'uberx':
        return 'assets/images/uber_x.png';
      case 'uberxl':
        return 'assets/images/uber_xl.png';
      case 'uber black':
        return 'assets/images/uber_black.png';
      case 'uber suv':
        return 'assets/images/uber_suv.png';
      case 'uber auto':
        return 'assets/images/uber_auto.png';
      case 'uber moto':
        return 'assets/images/uber_moto.png';
      default:
        return 'assets/images/uber_default.png';
    }
  }
  
  /// Cancels any ongoing requests.
  void dispose() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('Service disposed');
    }
  }
}