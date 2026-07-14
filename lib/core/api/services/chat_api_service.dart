import 'base_api_service.dart';

class ChatApiService {
  final BaseApiService _base = BaseApiService();

  Future<Map<String, dynamic>> aiChat({
    required String content,
    String model = 'gemini-2.5-flash',
    String? sessionId,
  }) async {
    final data = <String, dynamic>{
      'content': content,
      'model': model,
    };
    if (sessionId != null) data['sessionId'] = sessionId;

    final res = await _base.post(endpoint: '/api/v1/chat/ai', data: data);
    if (res is Map<String, dynamic>) return res;
    return {'content': '', 'role': 'assistant', 'modelUsed': model};
  }

  Future<Map<String, dynamic>> sendMessage({
    required String content,
    String role = 'user',
    String? sessionId,
  }) async {
    final data = <String, dynamic>{
      'content': content,
      'role': role,
    };
    if (sessionId != null) data['sessionId'] = sessionId;

    final res = await _base.post(endpoint: '/api/v1/chat/messages', data: data);
    if (res is Map<String, dynamic>) return res;
    return {};
  }

  Future<List<dynamic>> getMessages({int limit = 100}) async {
    final res = await _base.get(
      endpoint: '/api/v1/chat/messages',
      queryParameters: {'limit': limit},
    );
    if (res is List) return res;
    return [];
  }

  Future<Map<String, dynamic>> createSession({String? title}) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;

    final res = await _base.post(endpoint: '/api/v1/chat/sessions', data: data);
    if (res is Map<String, dynamic>) return res;
    return {};
  }

  Future<List<dynamic>> listSessions() async {
    final res = await _base.get(endpoint: '/api/v1/chat/sessions');
    if (res is List) return res;
    return [];
  }

  Future<List<dynamic>> getSessionMessages(String sessionId) async {
    final res = await _base.get(
      endpoint: '/api/v1/chat/sessions/$sessionId/messages',
    );
    if (res is List) return res;
    return [];
  }

  Future<Map<String, dynamic>> deleteSession(String sessionId) async {
    final res = await _base.delete(
      endpoint: '/api/v1/chat/sessions/$sessionId',
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }
}
