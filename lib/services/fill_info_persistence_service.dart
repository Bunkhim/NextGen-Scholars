import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:scholarship_app/services/application_data.dart';

/// Manages persistent Fill Info data lifecycle tied to user accounts.
///
/// Responsibilities:
/// - Scope Fill Info data per Firebase UID
/// - Preserve data across logout (don't clear)
/// - Clean up data after 30 days of inactivity
/// - Clean up data on account deletion
class FillInfoPersistenceService {
  static final FillInfoPersistenceService _instance =
      FillInfoPersistenceService._();
  factory FillInfoPersistenceService() => _instance;
  FillInfoPersistenceService._();

  final _appData = ApplicationData();

  // ──────────────────────────────────────────────────────
  //  Startup — call once in main() before runApp
  // ──────────────────────────────────────────────────────

  /// Run stale-data cleanup, then restore Fill Info if a user is already
  /// logged in (e.g. app relaunch without explicit logout).
  Future<void> initialize() async {
    // 1. Purge any user data older than 30 days
    await ApplicationData.cleanupStaleData();

    // 2. If a user is still signed in, load their stored Fill Info
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _appData.setActiveUser(user.uid);
      debugPrint('📋 Fill Info loaded for user: ${user.uid}');
    } else {
      // No user signed in — keep memory clean
      _appData.clearAll();
    }
  }

  // ──────────────────────────────────────────────────────
  //  Login / Signup — call after successful auth
  // ──────────────────────────────────────────────────────

  /// After a successful login or signup, set the active user so that
  /// Fill Info is scoped to their account and previously saved data is
  /// restored automatically.
  Future<void> onUserLoggedIn(String uid) async {
    await _appData.setActiveUser(uid);
    debugPrint('📋 Fill Info restored for user: $uid');
  }

  // ──────────────────────────────────────────────────────
  //  Logout — keep data, record last activity
  // ──────────────────────────────────────────────────────

  /// On logout, record last activity so the 30-day timer starts,
  /// then detach from the current user without deleting stored data.
  Future<void> onUserLoggedOut() async {
    await _appData.clearActiveUser();
    debugPrint('📋 Fill Info detached (data preserved for next login)');
  }

  // ──────────────────────────────────────────────────────
  //  Account Deletion — permanently remove user data
  // ──────────────────────────────────────────────────────

  /// Permanently delete all Fill Info for the given user.
  /// Call this before or after deleting the Firebase Auth account.
  Future<void> onAccountDeleted(String uid) async {
    await ApplicationData.deleteUserData(uid);
    _appData.clearAll();
    debugPrint('🗑️ Fill Info permanently deleted for user: $uid');
  }
}
