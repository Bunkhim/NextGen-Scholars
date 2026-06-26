part of 'notification_screen_view.dart';

class NotificationScreenViewController extends GetxController {
  final NotificationService notificationService = NotificationService();
  final pushEnabled = true.obs;
  final newScholarshipsEnabled = false.obs;
  final settingsLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotificationSettings();
  }

  Future<void> loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    pushEnabled.value = prefs.getBool('settings_push_notifications') ?? true;
    newScholarshipsEnabled.value =
        prefs.getBool('settings_new_scholarships') ?? false;
    settingsLoaded.value = true;
  }

  List<AppNotification> applySettingsFilter(List<AppNotification> all) {
    if (!pushEnabled.value) return [];
    return all.where((n) {
      if (n.type == 'new_scholarship' && !newScholarshipsEnabled.value) return false;
      return true;
    }).toList();
  }
}
