import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';
import 'package:scholarship_app/core/services/websocket_service.dart';
import 'package:scholarship_app/services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final WebSocketService _ws = WebSocketService();

  // Settings
  final RxBool pushEnabled = true.obs;
  final RxBool newScholarshipsEnabled = false.obs;
  final RxBool settingsLoaded = false.obs;

  // Notifications
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;

  Timer? _pollTimer;

  int get filteredUnreadCount =>
      notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _loadSettingsAndFetch();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _ws.removeListener(this);
    super.onClose();
  }

  Future<void> _loadSettingsAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    pushEnabled.value = prefs.getBool('settings_push_notifications') ?? true;
    newScholarshipsEnabled.value =
        prefs.getBool('settings_new_scholarships') ?? false;
    settingsLoaded.value = true;

    await _fetchNotifications();

    _ws.addListener(this, (type, data) {
      if (type == 'notification') {
        _fetchNotifications();
      } else if (type == 'notification_read') {
        final id = data['notification_id'] as String?;
        if (id != null) _applyReadLocally(id);
      }
    });

    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchNotifications(),
    );
  }

  Future<void> _fetchNotifications() async {
    final raw = await _notificationService.fetchMyNotifications();
    notifications.value = _applySettingsFilter(raw);
    unreadCount.value = await _notificationService.fetchUnreadCount();
  }

  void _applyReadLocally(String notificationId) {
    final idx = notifications.indexWhere((n) => n.id == notificationId);
    if (idx == -1) return;
    final old = notifications[idx];
    notifications[idx] = AppNotification(
      id: old.id,
      title: old.title,
      titleKm: old.titleKm,
      body: old.body,
      bodyKm: old.bodyKm,
      type: old.type,
      targetUserId: old.targetUserId,
      referenceId: old.referenceId,
      createdAt: old.createdAt,
      readBy: [...old.readBy, JwtService().uidSync ?? ''],
      dismissedBy: old.dismissedBy,
    );
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

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
    final uid = JwtService().uidSync ?? '';
    for (var i = 0; i < notifications.length; i++) {
      final old = notifications[i];
      if (!old.readBy.contains(uid)) {
        notifications[i] = AppNotification(
          id: old.id,
          title: old.title,
          titleKm: old.titleKm,
          body: old.body,
          bodyKm: old.bodyKm,
          type: old.type,
          targetUserId: old.targetUserId,
          referenceId: old.referenceId,
          createdAt: old.createdAt,
          readBy: [...old.readBy, uid],
          dismissedBy: old.dismissedBy,
        );
      }
    }
    unreadCount.value = 0;
  }

  Future<void> markAsRead(String id) async {
    await _notificationService.markAsRead(id);
    _applyReadLocally(id);
  }

  Future<void> dismissNotification(String id) async {
    await _notificationService.dismissNotification(id);
    notifications.removeWhere((n) => n.id == id);
  }
}
