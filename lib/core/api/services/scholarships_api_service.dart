import 'base_api_service.dart';

class ScholarshipsApiService {
  final BaseApiService _base = BaseApiService();

  Future<Map<String, dynamic>> listScholarships({
    bool active = true,
    String? country,
    String? degree,
    String? funding,
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{
      'active': active,
      'skip': skip,
      'limit': limit,
    };
    if (country != null) params['country'] = country;
    if (degree != null) params['degree'] = degree;
    if (funding != null) params['funding'] = funding;
    if (search != null) params['search'] = search;

    final res = await _base.get(
      endpoint: '/api/v1/scholarships/',
      queryParameters: params,
    );
    if (res is Map<String, dynamic>) return res;
    return {'items': [], 'total': 0};
  }

  Future<Map<String, dynamic>> getScholarship(String id) async {
    final res = await _base.get(endpoint: '/api/v1/scholarships/$id');
    if (res is Map<String, dynamic>) return res;
    return {};
  }

  Future<Map<String, dynamic>> getFilters() async {
    final res = await _base.get(endpoint: '/api/v1/scholarships/filters');
    if (res is Map<String, dynamic>) return res;
    return {};
  }

  Future<Map<String, dynamic>> match({
    String destinationCountry = '',
    String preferredDegree = '',
    String preferredMajor = '',
    String preferredUniversity = '',
  }) async {
    final res = await _base.post(
      endpoint: '/api/v1/scholarships/match',
      data: {
        'destinationCountry': destinationCountry,
        'preferredDegree': preferredDegree,
        'preferredMajor': preferredMajor,
        'preferredUniversity': preferredUniversity,
      },
    );
    if (res is Map<String, dynamic>) return res;
    return {'items': [], 'total': 0};
  }

  Future<Map<String, dynamic>> getApplicationCount(String id) async {
    final res = await _base.get(
      endpoint: '/api/v1/scholarships/$id/application-count',
    );
    if (res is Map<String, dynamic>) return res;
    return {'count': 0};
  }
}
