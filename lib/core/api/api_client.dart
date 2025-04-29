import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/config/constants.dart';
import 'package:taprobana_trails/core/storage/secure_storage.dart';

/// Exception thrown when there's a network error.
class NetworkException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  NetworkException({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() => 'NetworkException: $message (Code: $code, Status: $statusCode)';
}

/// API client for making HTTP requests with error handling and token management.
class ApiClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;
  final String baseUrl;
  
  /// Creates a new [ApiClient] instance.
  ApiClient({
    required this.baseUrl,
    required SecureStorage secureStorage,
    Dio? dio,
  }) : _secureStorage = secureStorage {
    _dio = dio ?? Dio();
    _initializeDio();
  }
  
  /// Initializes Dio with default settings and interceptors.
  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      responseType: ResponseType.json,
      contentType: 'application/json',
      validateStatus: (status) => status != null && status < 500,
    );
    
    // Add request interceptor for auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    ));
    
    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }
  
  /// Request interceptor to add auth token.
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token if available
    final token = await _secureStorage.read(key: StorageKeys.authToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }
  
  /// Response interceptor to handle token refresh.
  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Handle token refresh if needed
    if (response.statusCode == 401) {
      try {
        await _refreshToken();
        // Retry the original request with new token
        final token = await _secureStorage.read(key: StorageKeys.authToken);
        if (token != null && token.isNotEmpty) {
          response.requestOptions.headers['Authorization'] = 'Bearer $token';
          final retryResponse = await _dio.fetch(response.requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        // If token refresh fails, proceed with 401 response
        debugPrint('Token refresh failed: $e');
      }
    }
    
    return handler.next(response);
  }
  
  /// Error interceptor to handle network errors.
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    String errorMessage = ApiConstants.defaultErrorMessage;
    String? errorCode;
    int? statusCode = err.response?.statusCode;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = ApiConstants.timeoutErrorMessage;
        errorCode = ErrorCodes.timeout;
        break;
      
      case DioExceptionType.badResponse:
        // Handle API error responses
        if (err.response != null) {
          try {
            final responseData = err.response!.data;
            
            if (responseData is Map<String, dynamic>) {
              errorMessage = responseData['message'] ?? errorMessage;
              errorCode = responseData['code'];
            } else if (responseData is String) {
              errorMessage = responseData;
            }
          } catch (e) {
            debugPrint('Error parsing error response: $e');
          }
        }
        break;
      
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled';
        errorCode = 'REQUEST_CANCELLED';
        break;
      
      case DioExceptionType.unknown:
        // Check if it's a network connectivity issue
        if (err.error is SocketException || err.error is HttpException) {
          errorMessage = ApiConstants.connectionErrorMessage;
          errorCode = ErrorCodes.noInternet;
        }
        break;
        
      default:
        errorMessage = err.message ?? errorMessage;
        break;
    }
    
    final exception = NetworkException(
      message: errorMessage,
      code: errorCode,
      statusCode: statusCode,
    );
    
    return handler.reject(err.copyWith(error: exception));
  }
  
  /// Refreshes the authentication token.
  Future<void> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);
      
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available');
      }
      
      // Create a new Dio instance for token refresh to avoid infinite loops
      final tokenDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      ));
      
      final response = await tokenDio.post(
        '/auth/refresh',
        data: jsonEncode({'refresh_token': refreshToken}),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        if (data.containsKey('access_token')) {
          await _secureStorage.write(
            key: StorageKeys.authToken,
            value: data['access_token'],
          );
          
          if (data.containsKey('refresh_token')) {
            await _secureStorage.write(
              key: StorageKeys.refreshToken,
              value: data['refresh_token'],
            );
          }
        } else {
          throw Exception('Invalid token response');
        }
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      
      // Clear tokens if refresh fails
      await _secureStorage.delete(key: StorageKeys.authToken);
      await _secureStorage.delete(key: StorageKeys.refreshToken);
      
      rethrow;
    }
  }
  
  /// Makes a GET request to the specified path.
  /// 
  /// [path] is the URL path to make the request to.
  /// [queryParameters] are the query parameters to add to the URL.
  /// [options] are the additional Dio request options.
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
  
  /// Makes a POST request to the specified path.
  /// 
  /// [path] is the URL path to make the request to.
  /// [data] is the request body.
  /// [queryParameters] are the query parameters to add to the URL.
  /// [options] are the additional Dio request options.
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
  
  /// Makes a PUT request to the specified path.
  /// 
  /// [path] is the URL path to make the request to.
  /// [data] is the request body.
  /// [queryParameters] are the query parameters to add to the URL.
  /// [options] are the additional Dio request options.
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
  
  /// Makes a PATCH request to the specified path.
  /// 
  /// [path] is the URL path to make the request to.
  /// [data] is the request body.
  /// [queryParameters] are the query parameters to add to the URL.
  /// [options] are the additional Dio request options.
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
  
  /// Makes a DELETE request to the specified path.
  /// 
  /// [path] is the URL path to make the request to.
  /// [data] is the request body.
  /// [queryParameters] are the query parameters to add to the URL.
  /// [options] are the additional Dio request options.
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
  
  /// Downloads a file from the specified URL.
  /// 
  /// [url] is the URL to download the file from.
  /// [savePath] is the path to save the file to.
  Future<void> download(
    String url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
  
  /// Handles the HTTP response.
  /// 
  /// [response] is the HTTP response to handle.
  T _handleResponse<T>(Response<T> response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      if (response.data != null) {
        return response.data as T;
      } else {
        throw NetworkException(
          message: 'Response data is null',
          statusCode: response.statusCode,
        );
      }
    } else {
      throw NetworkException(
        message: 'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
  
  /// Handles Dio errors and converts them to NetworkException.
  /// 
  /// [error] is the Dio error to handle.
  NetworkException _handleDioError(DioException error) {
    if (error.error is NetworkException) {
      return error.error as NetworkException;
    }
    
    return NetworkException(
      message: 'Unknown error occurred: ${error.message}',
      statusCode: error.response?.statusCode,
    );
  }
  
  /// Creates a new instance of [ApiClient] for a specific domain.
  /// 
  /// [domain] is the specific domain or service name to use.
  ApiClient forDomain(String domain) {
    return ApiClient(
      baseUrl: domain,
      secureStorage: _secureStorage,
    );
  }
  
  /// Closes the Dio client.
  void close() {
    _dio.close();
  }
}