import 'base_api_service.dart';

class NotificationsApiService {
  final BaseApiService _base = BaseApiService();

  Future<List<dynamic>> listNotifications({int limit = 50, String? since}) async {
    final params = <String, dynamic>{'limit': limit};
    if (since != null) params['since'] = since;

    final res = await _base.get(
      endpoint: '/api/v1/notifications',
      queryParameters: params,
    );
    if (res is List) return res;
    return [];
  }

  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    final res = await _base.patch(
      endpoint: '/api/v1/notifications/$notificationId/read',
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    final res = await _base.post(endpoint: '/api/v1/notifications/read-all');
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> dismissNotification(String notificationId) async {
    final res = await _base.patch(
      endpoint: '/api/v1/notifications/$notificationId/dismiss',
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<int> getUnreadCount() async {
    final res = await _base.get(endpoint: '/api/v1/notifications/unread-count');
    if (res is Map<String, dynamic> && res.containsKey('count')) {
      return res['count'] as int? ?? 0;
    }
    return 0;
  }

  Future<Map<String, dynamic>?> getPreferences() async {
    final res = await _base.get(endpoint: '/api/v1/notifications/preferences');
    if (res is Map<String, dynamic>) return res;
    return null;
  }

  Future<Map<String, dynamic>?> updatePreferences(
      Map<String, dynamic> data) async {
    final res =
        await _base.put(endpoint: '/api/v1/notifications/preferences', data: data);
    if (res is Map<String, dynamic>) return res;
    return null;
  }

  Future<bool> registerDeviceToken(
      String token, String platform) async {
    final res = await _base.post(
      endpoint: '/api/v1/notifications/device-token',
      data: {'token': token, 'platform': platform},
    );
    return res is Map<String, dynamic> && (res['success'] ?? false) == true;
  }
}
