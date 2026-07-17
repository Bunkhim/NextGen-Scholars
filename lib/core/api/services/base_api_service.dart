import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api_config.dart';

class BaseApiService {
  final ApiConfig _apiConfig = ApiConfig();

  Future<dynamic> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _apiConfig.dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('BaseApiService GET error [$endpoint]: ${e.response?.statusCode} $e');
      return {'result': false, 'message': _extractMessage(e), 'data': null};
    }
  }

  Future<dynamic> post({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiConfig.dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      debugPrint('BaseApiService POST error: $e');
      return {'result': false, 'message': _extractMessage(e), 'data': null};
    }
  }

  Future<dynamic> put({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _apiConfig.dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('BaseApiService PUT error: $e');
      return {'result': false, 'message': _extractMessage(e), 'data': null};
    }
  }

  Future<dynamic> patch({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _apiConfig.dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('BaseApiService PATCH error: $e');
      return {'result': false, 'message': _extractMessage(e), 'data': null};
    }
  }

  Future<dynamic> delete({
    required String endpoint,
  }) async {
    try {
      final response = await _apiConfig.dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      debugPrint('BaseApiService DELETE error [$endpoint]: ${e.response?.statusCode} $e');
      return {'result': false, 'message': _extractMessage(e), 'data': null};
    }
  }

  String _extractMessage(DioException e) {
    if (e.response?.data is Map) {
      final detail = (e.response!.data as Map)['detail'];
      if (detail is String) return detail;
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Check your internet.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Check your internet.';
    }
    if (e.response?.statusCode == 401) {
      return 'Unauthorized. Please login again.';
    }
    return 'Server error. Please try again.';
  }
}
