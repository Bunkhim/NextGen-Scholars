import 'base_api_service.dart';

class ApplicationsApiService {
  final BaseApiService _base = BaseApiService();

  Future<Map<String, dynamic>> apply({required String scholarshipId}) async {
    final res = await _base.post(
      endpoint: '/api/v1/applications/?scholarship_id=$scholarshipId',
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<List<dynamic>> myApplications() async {
    final res = await _base.get(endpoint: '/api/v1/applications/my');
    if (res is List) return res;
    if (res is Map<String, dynamic> && res.containsKey('items')) {
      return res['items'] as List<dynamic>? ?? [];
    }
    return [];
  }

  Future<Map<String, dynamic>> checkApplication({
    required String scholarshipId,
  }) async {
    final res = await _base.get(
      endpoint: '/api/v1/applications/check',
      queryParameters: {'scholarship_id': scholarshipId},
    );
    if (res is Map<String, dynamic>) return res;
    return {'applied': false};
  }

  Future<Map<String, dynamic>> getApplication(String id) async {
    final res = await _base.get(endpoint: '/api/v1/applications/$id');
    if (res is Map<String, dynamic>) return res;
    return {};
  }
}
