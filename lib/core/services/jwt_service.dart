import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scholarship_app/core/api/api_config.dart';
import 'package:scholarship_app/core/api/services/auth_api_service.dart';
import 'package:scholarship_app/core/services/websocket_service.dart';

class JwtService {
  static final JwtService _instance = JwtService._internal();
  factory JwtService() => _instance;
  JwtService._internal();

  final AuthApiService _authApi = AuthApiService();

  static const _uidKey = 'jwt_user_uid';
  static const _emailKey = 'jwt_user_email';
  static const _nameKey = 'jwt_user_name';

  String? _cachedUid;
  String? _cachedEmail;
  String? _cachedName;
  bool _initialised = false;

  Future<void> _ensureInit() async {
    if (_initialised) return;
    final prefs = await SharedPreferences.getInstance();
    _cachedUid = prefs.getString(_uidKey);
    _cachedEmail = prefs.getString(_emailKey);
    _cachedName = prefs.getString(_nameKey);
    _initialised = true;
  }

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

  Future<bool> hasToken() => ApiConfig.hasToken;

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

  // ── User session helpers ────────────────────────────────────────

  Future<void> saveUserSession({
    required String uid,
    required String token,
    String? email,
    String? displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uidKey, uid);
    await prefs.setString(_emailKey, email ?? '');
    await prefs.setString(_nameKey, displayName ?? '');
    await ApiConfig.saveToken(token);
    _cachedUid = uid;
    _cachedEmail = email ?? '';
    _cachedName = displayName ?? '';
    WebSocketService().connect();
  }

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_uidKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await ApiConfig.clearToken();
    _cachedUid = null;
    _cachedEmail = null;
    _cachedName = null;
    WebSocketService().disconnect();
  }

  // Synchronous UID getter (reads from in-memory cache)
  String? get uidSync => _cachedUid;
  String? get emailSync => _cachedEmail;
  String? get displayNameSync => _cachedName;

  // Async getters (load from SharedPreferences if needed)
  Future<String?> get currentUid async {
    await _ensureInit();
    return _cachedUid;
  }

  Future<String?> get currentUserEmail async {
    await _ensureInit();
    return _cachedEmail;
  }

  Future<String?> get currentUserDisplayName async {
    await _ensureInit();
    return _cachedName;
  }
}
