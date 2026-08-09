import 'package:scholarship_app/core/api/services/notifications_api_service.dart';

class NotificationPreferences {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool deadlineReminders;
  final bool newScholarships;
  final String email;

  const NotificationPreferences({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.deadlineReminders,
    required this.newScholarships,
    required this.email,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      pushEnabled: (map['pushEnabled'] as bool?) ?? true,
      emailEnabled: (map['emailEnabled'] as bool?) ?? true,
      deadlineReminders: (map['deadlineReminders'] as bool?) ?? true,
      newScholarships: (map['newScholarships'] as bool?) ?? true,
      email: (map['email'] as String?) ?? '',
    );
  }
}

class NotificationPreferencesService {
  static final NotificationPreferencesService _instance =
      NotificationPreferencesService._();
  factory NotificationPreferencesService() => _instance;
  NotificationPreferencesService._();

  final NotificationsApiService _api = NotificationsApiService();

  Future<NotificationPreferences?> fetch() async {
    try {
      final result = await _api.getPreferences();
      if (result == null) return null;
      return NotificationPreferences.fromMap(result);
    } catch (_) {
      return null;
    }
  }

  Future<bool> update(String key, dynamic value) async {
    try {
      final result = await _api.updatePreferences({key: value});
      return result != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateAll({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? deadlineReminders,
    bool? newScholarships,
    String? email,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (pushEnabled != null) map['pushEnabled'] = pushEnabled;
      if (emailEnabled != null) map['emailEnabled'] = emailEnabled;
      if (deadlineReminders != null) {
        map['deadlineReminders'] = deadlineReminders;
      }
      if (newScholarships != null) map['newScholarships'] = newScholarships;
      if (email != null) map['email'] = email;
      if (map.isEmpty) return true;
      final result = await _api.updatePreferences(map);
      return result != null;
    } catch (_) {
      return false;
    }
  }
}
