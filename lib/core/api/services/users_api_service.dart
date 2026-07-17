import 'base_api_service.dart';

class UsersApiService {
  final BaseApiService _base = BaseApiService();

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _base.get(endpoint: '/api/v1/users/me');
    if (res is Map<String, dynamic>) return res;
    return {};
  }

  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phone,
    String? bio,
    String? education,
    String? institution,
    String? dob,
    String? country,
    List<String>? interestedFields,
    String? jobTitle,
    String? department,
    bool? profileSetupComplete,
  }) async {
    final data = <String, dynamic>{};
    if (displayName != null) data['displayName'] = displayName;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (phone != null) data['phone'] = phone;
    if (bio != null) data['bio'] = bio;
    if (education != null) data['education'] = education;
    if (institution != null) data['institution'] = institution;
    if (dob != null) data['dob'] = dob;
    if (country != null) data['country'] = country;
    if (interestedFields != null) data['interestedFields'] = interestedFields;
    if (jobTitle != null) data['jobTitle'] = jobTitle;
    if (department != null) data['department'] = department;
    if (profileSetupComplete != null) {
      data['profileSetupComplete'] = profileSetupComplete;
    }

    final res = await _base.put(endpoint: '/api/v1/users/me', data: data);
    if (res is Map<String, dynamic>) return res;
    return {};
  }

  Future<void> deleteAccount() async {
    await _base.delete(endpoint: '/api/v1/users/me');
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _base.post(
      endpoint: '/api/v1/users/me/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  // ── Fill Info ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getFillInfo() async {
    final res = await _base.get(endpoint: '/api/v1/users/me/fill-info');
    if (res is Map<String, dynamic>) return res;
    return {};
  }

  Future<Map<String, dynamic>> updateFillInfo({
    required Map<String, dynamic> data,
  }) async {
    final res = await _base.put(
      endpoint: '/api/v1/users/me/fill-info',
      data: {'data': data},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<void> deleteFillInfo() async {
    await _base.delete(endpoint: '/api/v1/users/me/fill-info');
  }

  // ── Saved Scholarships ─────────────────────────────────────

  Future<List<dynamic>> getSavedScholarships() async {
    final res = await _base.get(endpoint: '/api/v1/users/me/saved-scholarships');
    if (res is List) return res;
    return [];
  }

  Future<Map<String, dynamic>> saveScholarship(String scholarshipId) async {
    final res = await _base.post(
      endpoint: '/api/v1/users/me/saved-scholarships/$scholarshipId',
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> unsaveScholarship(String scholarshipId) async {
    final res = await _base.delete(
      endpoint: '/api/v1/users/me/saved-scholarships/$scholarshipId',
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  // ── Viewed Scholarships ────────────────────────────────────

  Future<Map<String, dynamic>> markViewed(String scholarshipId) async {
    final res = await _base.post(
      endpoint: '/api/v1/users/me/viewed-scholarships',
      data: {'scholarshipId': scholarshipId},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<List<dynamic>> getViewedScholarships() async {
    final res = await _base.get(endpoint: '/api/v1/users/me/viewed-scholarships');
    if (res is Map<String, dynamic> && res.containsKey('items')) {
      return res['items'] as List<dynamic>? ?? [];
    }
    return [];
  }

  // ── Search History ─────────────────────────────────────────

  Future<Map<String, dynamic>> addSearchHistory({
    required String query,
    String category = '',
  }) async {
    final res = await _base.post(
      endpoint: '/api/v1/users/me/search-history',
      queryParameters: {'query': query, 'category': category},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<List<dynamic>> getRecentSearches({int limit = 10}) async {
    final res = await _base.get(
      endpoint: '/api/v1/users/me/search-history/recent',
      queryParameters: {'limit': limit},
    );
    if (res is Map<String, dynamic> && res.containsKey('items')) {
      return res['items'] as List<dynamic>? ?? [];
    }
    return [];
  }

  Future<List<dynamic>> getPopularSearches({int limit = 10}) async {
    final res = await _base.get(
      endpoint: '/api/v1/users/me/search-history/popular',
      queryParameters: {'limit': limit},
    );
    if (res is Map<String, dynamic> && res.containsKey('items')) {
      return res['items'] as List<dynamic>? ?? [];
    }
    return [];
  }

  Future<List<dynamic>> getSearchSuggestions({
    String q = '',
    int limit = 5,
  }) async {
    final res = await _base.get(
      endpoint: '/api/v1/users/me/search-history/suggestions',
      queryParameters: {'q': q, 'limit': limit},
    );
    if (res is Map<String, dynamic> && res.containsKey('items')) {
      return res['items'] as List<dynamic>? ?? [];
    }
    return [];
  }

  Future<void> clearSearchHistory() async {
    await _base.delete(endpoint: '/api/v1/users/me/search-history');
  }
}
