import 'package:scholarship_app/core/api/services/users_api_service.dart';

/// Tracks which scholarships the user has viewed via the backend API.
class ViewedScholarshipService {
  static final ViewedScholarshipService _instance =
      ViewedScholarshipService._();
  factory ViewedScholarshipService() => _instance;
  ViewedScholarshipService._();

  final UsersApiService _api = UsersApiService();

  /// Record that a scholarship was viewed.
  Future<void> markViewed(String scholarshipId) async {
    try {
      await _api.markViewed(scholarshipId);
    } catch (_) {
      // Fire-and-forget — don't block UI on failure
    }
  }

  /// Get the count of unique viewed scholarships from the backend.
  Future<int> count() async {
    try {
      final items = await _api.getViewedScholarships();
      return items.length;
    } catch (_) {
      return 0;
    }
  }

  /// Get all viewed scholarship IDs from the backend.
  Future<List<String>> getViewedIds() async {
    try {
      final items = await _api.getViewedScholarships();
      return items
          .map((e) => (e is Map<String, dynamic>
              ? (e['scholarshipId'] ?? e['id'] ?? '').toString()
              : ''))
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
