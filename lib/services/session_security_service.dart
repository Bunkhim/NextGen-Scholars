import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enforces weekly re-authentication to protect user accounts.
///
/// Users must login at least once every 7 days. If the session expires,
/// Firebase Auth is signed out and the user is sent back to login.
class SessionSecurityService {
  static final SessionSecurityService _instance = SessionSecurityService._();
  factory SessionSecurityService() => _instance;
  SessionSecurityService._();

  static const String _lastLoginKey = 'security_last_login_ms';
  static const Duration sessionTimeout = Duration(days: 7);

  // ──────────────────────────────────────────────────────
  //  Record login — call after every successful auth
  // ──────────────────────────────────────────────────────

  /// Save the current timestamp as the last login time.
  Future<void> recordLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastLoginKey, DateTime.now().millisecondsSinceEpoch);
    debugPrint('🔐 Session login recorded');
  }

  // ──────────────────────────────────────────────────────
  //  Check session — call on app startup (splash screen)
  // ──────────────────────────────────────────────────────

  /// Returns `true` if the user's session is still valid (logged in < 7 days ago).
  /// Returns `false` if session expired or no login timestamp exists.
  Future<bool> isSessionValid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final lastLoginMs = prefs.getInt(_lastLoginKey);

    if (lastLoginMs == null) {
      // No recorded login — session is invalid (force re-login)
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

  // ──────────────────────────────────────────────────────
  //  Force logout — sign out Firebase + Google
  // ──────────────────────────────────────────────────────

  /// Sign out the user due to expired session.
  /// Does NOT clear the login timestamp (it stays expired).
  Future<void> forceLogout() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (_) {}

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    debugPrint('🔐 Forced logout due to expired session');
  }

  // ──────────────────────────────────────────────────────
  //  Clear on explicit logout
  // ──────────────────────────────────────────────────────

  /// Clear the login timestamp (call on explicit user logout).
  Future<void> clearLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastLoginKey);
  }
}
