import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scholarship_app/services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  // Settings
  final RxBool pushEnabled = true.obs;
  final RxBool newScholarshipsEnabled = false.obs;
  final RxBool settingsLoaded = false.obs;

  // Real-time notifications
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  StreamSubscription<List<AppNotification>>? _subscription;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _loadSettingsAndStream();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _loadSettingsAndStream() async {
    final prefs = await SharedPreferences.getInstance();
    pushEnabled.value = prefs.getBool('settings_push_notifications') ?? true;
    newScholarshipsEnabled.value =
        prefs.getBool('settings_new_scholarships') ?? false;
    settingsLoaded.value = true;

    // Listen to real-time notification stream and apply filter immediately
    _subscription = _notificationService.streamMyNotifications().listen((raw) {
      notifications.value = _applySettingsFilter(raw);
    });
  }

  /// Refreshes the local settings variables and re-applies filter if needed
  Future<void> refreshSettings() async {
    final prefs = await SharedPreferences.getInstance();
    pushEnabled.value = prefs.getBool('settings_push_notifications') ?? true;
    newScholarshipsEnabled.value =
        prefs.getBool('settings_new_scholarships') ?? false;
  }

  List<AppNotification> _applySettingsFilter(List<AppNotification> all) {
    if (!pushEnabled.value) return [];
    return all.where((n) {
      if (n.type == 'new_scholarship' && !newScholarshipsEnabled.value) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
  }

  Future<void> markAsRead(String id) async {
    await _notificationService.markAsRead(id);
  }

  Future<void> dismissNotification(String id) async {
    await _notificationService.dismissNotification(id);
  }
}
