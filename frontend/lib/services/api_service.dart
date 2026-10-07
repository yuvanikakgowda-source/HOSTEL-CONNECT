// frontend/lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';

class ApiService {
  late Dio dio;
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 70),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
          );
          return handler.next(error);
        },
      ),
    );
  }

  // Set authorization token
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authorization token
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  // POST request
  Future<Response> post(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  String _handleError(DioException error) {
    String message = AppConstants.errorGeneric;

    if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout. Please try again.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Request timeout. Please try again.';
    } else if (error.response != null) {
      message = error.response?.data?['message'] ?? AppConstants.errorGeneric;
    }

    return message;
  }
}
