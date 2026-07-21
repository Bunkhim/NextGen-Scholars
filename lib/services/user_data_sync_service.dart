import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';

/// Manages local data cleanup for the current user.
///
/// Previously synced local data to/from Firestore. Now that the backend API
/// is the source of truth for all user data (saved scholarships, search
/// history, viewed scholarships, chat messages, fill info), the Firestore
/// sync layer has been removed. This service now only handles local data
/// cleanup on logout/account deletion.
class UserDataSyncService {
  static final UserDataSyncService _instance = UserDataSyncService._();
  factory UserDataSyncService() => _instance;
  UserDataSyncService._();

  /// No-op — backend is the source of truth.
  Future<void> backupAll() async {}

  /// No-op — backend is the source of truth.
  Future<void> restoreAll(String uid) async {}

  /// No-op — saved scholarships are synced via backend API.
  Future<void> syncSavedScholarships() async {}

  /// No-op — viewed scholarships are synced via backend API.
  Future<void> syncViewedScholarships() async {}

  /// No-op — backend handles cloud data lifecycle.
  static Future<void> deleteAllCloudData(String uid) async {}

  /// Delete all local SQLite data and SharedPreferences for the current user.
  static Future<void> deleteAllLocalData(String uid) async {
    try {
      final db = await DatabaseHelper().database;

      await db.delete(
        DatabaseHelper.tableApplicationDrafts,
        where: 'user_id = ? OR user_id IS NULL',
        whereArgs: [uid],
      );

      await db.delete(DatabaseHelper.tableChatMessages);
      await db.delete(DatabaseHelper.tableSearchHistory);
      await db.delete(DatabaseHelper.tableNotifications);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('viewed_scholarship_ids');

      debugPrint('🗑️ All local data deleted for user: $uid');
    } catch (e) {
      debugPrint('⚠️ Local data delete failed: $e');
    }
  }

  /// No-op — backend handles stale data.
  static Future<void> cleanupStaleCloudData(String uid) async {}

  /// No-op — backend tracks activity.
  Future<void> recordActivity() async {}
}
