import '../core/api/services/users_api_service.dart';
import 'scholarship_service.dart';

class SavedScholarshipService {
  final UsersApiService _api = UsersApiService();

  Future<List<FirestoreScholarship>> getSavedScholarships() async {
    final items = await _api.getSavedScholarships();
    return items.whereType<Map<String, dynamic>>().map((json) {
      final s = FirestoreScholarship.fromJson(json);
      s.isFavorite = true;
      return s;
    }).toList();
  }

  Future<Set<String>> getSavedIds() async {
    final items = await _api.getSavedScholarships();
    return items
        .whereType<Map<String, dynamic>>()
        .map((item) => (item['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<int> getSavedCount() async {
    final items = await _api.getSavedScholarships();
    return items.length;
  }

  Future<void> saveScholarship(String id) async {
    await _api.saveScholarship(id);
  }

  Future<void> unsaveScholarship(String id) async {
    await _api.unsaveScholarship(id);
  }
}
