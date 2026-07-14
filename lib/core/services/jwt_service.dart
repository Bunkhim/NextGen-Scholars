import 'package:flutter/foundation.dart';
import 'package:scholarship_app/core/api/api_config.dart';
import 'package:scholarship_app/core/api/services/auth_api_service.dart';

class JwtService {
  static final JwtService _instance = JwtService._internal();
  factory JwtService() => _instance;
  JwtService._internal();

  final AuthApiService _authApi = AuthApiService();

  Future<bool> isTokenValid() async {
    final token = await ApiConfig.token;
    if (token == null || token.isEmpty) return false;

    try {
      final res = await _authApi.verifyToken(token: token);
      return res.containsKey('uid');
    } catch (e) {
      debugPrint('JwtService: token validation failed: $e');
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final res = await _authApi.refreshToken();
      if (res.containsKey('token')) {
        await ApiConfig.saveToken(res['token'] as String);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('JwtService: token refresh failed: $e');
      return false;
    }
  }

  Future<void> saveToken(String token) async {
    await ApiConfig.saveToken(token);
  }

  Future<void> clearToken() async {
    await ApiConfig.clearToken();
  }

  Future<String?> get token => ApiConfig.token;
}
