import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_data_sync_service.dart';

/// Tracks which scholarships the user has viewed using SharedPreferences.
class ViewedScholarshipService {
  static final ViewedScholarshipService _instance =
      ViewedScholarshipService._();
  factory ViewedScholarshipService() => _instance;
  ViewedScholarshipService._();

  static const _key = 'viewed_scholarship_ids';

  /// Record that a scholarship was viewed.
  Future<void> markViewed(String scholarshipId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    if (!ids.contains(scholarshipId)) {
      ids.add(scholarshipId);
      await prefs.setStringList(_key, ids);
      // Sync to Firestore so data survives uninstall
      _triggerCloudSync();
    }
  }

  /// Fire-and-forget Firestore sync after a view is recorded.
  void _triggerCloudSync() {
    Future.microtask(() async {
      try {
        await UserDataSyncService().syncViewedScholarships();
      } catch (e) {
        debugPrint('⚠️ Viewed scholarships cloud sync failed: $e');
      }
    });
  }

  /// Get the count of unique viewed scholarships.
  Future<int> count() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    return ids.length;
  }

  /// Get all viewed scholarship IDs.
  Future<List<String>> getViewedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}
