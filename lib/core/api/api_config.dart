import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as getx;
import 'package:scholarship_app/routes/app_routes.dart';

class ApiConfig {
  late final Dio dio;
  static const _tokenKey = 'jwt_token';
  static const _storage = FlutterSecureStorage();

  ApiConfig() {
    final baseUrl = dotenv.env['BACKEND_API_URL'] ?? '';
    if (baseUrl.isEmpty) {
      debugPrint('[API] BACKEND_API_URL not set in .env');
    }

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final existingToken = await _storage.read(key: _tokenKey);
          if (existingToken != null && existingToken.isNotEmpty) {
            await _storage.delete(key: _tokenKey);
            getx.Get.offAllNamed(AppRoutes.loginScreen);
          }
        }
        handler.next(error);
      },
    ));
  }

  static Future<bool> get hasToken async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<String?> get token async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
