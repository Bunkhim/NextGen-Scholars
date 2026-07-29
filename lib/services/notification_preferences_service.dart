import 'package:cloud_functions/cloud_functions.dart';

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

  Future<NotificationPreferences?> fetch() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('getNotificationPreferences')
          .call();
      return NotificationPreferences.fromMap(
          result.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> update(String key, dynamic value) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('updateNotificationPreferences')
          .call({key: value});
      return true;
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
      await FirebaseFunctions.instance
          .httpsCallable('updateNotificationPreferences')
          .call(map);
      return true;
    } catch (_) {
      return false;
    }
  }
}
