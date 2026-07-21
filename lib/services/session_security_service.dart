import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionSecurityService {
  static final SessionSecurityService _instance = SessionSecurityService._();
  factory SessionSecurityService() => _instance;
  SessionSecurityService._();

  static const String _lastLoginKey = 'security_last_login_ms';
  static const Duration sessionTimeout = Duration(days: 7);

  Future<void> recordLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastLoginKey, DateTime.now().millisecondsSinceEpoch);
    debugPrint('🔐 Session login recorded');
  }

  Future<bool> isSessionValid() async {
    final hasToken = await JwtService().hasToken();
    if (!hasToken) return false;

    final prefs = await SharedPreferences.getInstance();
    final lastLoginMs = prefs.getInt(_lastLoginKey);

    if (lastLoginMs == null) {
      debugPrint('🔐 No login timestamp found — session invalid');
      return false;
    }

    final lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginMs);
    final elapsed = DateTime.now().difference(lastLogin);

    if (elapsed > sessionTimeout) {
      debugPrint(
          '🔐 Session expired (${elapsed.inDays} days since last login)');
      return false;
    }

    debugPrint(
        '🔐 Session valid (${elapsed.inDays}d ${elapsed.inHours % 24}h since last login)');
    return true;
  }

  Future<void> forceLogout() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (_) {}

    await JwtService().clearUserSession();
    debugPrint('🔐 Forced logout due to expired session');
  }

  Future<void> clearLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastLoginKey);
  }
}
