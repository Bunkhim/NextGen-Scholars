import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scholarship_app/services/user_data_sync_service.dart';

// import 'package:your_app/services/user_data_sync_service.dart';

class UserDataSyncController extends ChangeNotifier {
  final UserDataSyncService _service = UserDataSyncService();

  bool _isLoading = false;

  /// Exposes the loading state for UI progress indicators.
  bool get isLoading => _isLoading;

  /// Helper to safely get the current user ID
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Backs up all local user data to Firestore.
  Future<void> backupAll() async {
    if (_uid == null) return;
    
    _setLoading(true);
    try {
      await _service.backupAll();
    } catch (e) {
      debugPrint('Controller error during backupAll: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Restores all user data from Firestore to local storage.
  /// Typically called during post-login initialization.
  Future<void> restoreAll() async {
    final uid = _uid;
    if (uid == null) return;

    _setLoading(true);
    try {
      await _service.restoreAll(uid);
    } catch (e) {
      debugPrint('Controller error during restoreAll: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Syncs just the saved scholarships immediately.
  Future<void> syncSavedScholarships() async {
    try {
      await _service.syncSavedScholarships();
    } catch (e) {
      debugPrint('Controller error syncing saved scholarships: $e');
    }
  }

  /// Syncs just the viewed scholarships immediately.
  Future<void> syncViewedScholarships() async {
    try {
      await _service.syncViewedScholarships();
    } catch (e) {
      debugPrint('Controller error syncing viewed scholarships: $e');
    }
  }

  /// Records user activity without blocking the UI.
  Future<void> recordActivity() async {
    try {
      await _service.recordActivity();
    } catch (e) {
      debugPrint('Controller error recording activity: $e');
    }
  }

  /// Wipes all data (local and cloud) for the current user.
  /// Used during account deletion.
  Future<void> deleteUserAccountData() async {
    final uid = _uid;
    if (uid == null) return;

    _setLoading(true);
    try {
      // Calling the static methods on the service class
      await UserDataSyncService.deleteAllCloudData(uid);
      await UserDataSyncService.deleteAllLocalData(uid);
    } catch (e) {
      debugPrint('Controller error deleting account data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cleans up cloud data if the user has been inactive for >30 days.
  Future<void> cleanupStaleData() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await UserDataSyncService.cleanupStaleCloudData(uid);
    } catch (e) {
      debugPrint('Controller error cleaning up stale data: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}