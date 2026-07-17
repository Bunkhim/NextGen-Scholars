import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';
import 'package:scholarship_app/core/services/websocket_service.dart';
import 'package:scholarship_app/services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();
  final WebSocketService _ws = WebSocketService();

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = true.obs;

  Timer? _pollTimer;

  NotificationController() {
    _init();
  }

  void _init() {
    _loadNotifications();

    _ws.addListener(this, (type, data) {
      if (type == 'notification') {
        _loadNotifications();
      } else if (type == 'notification_read') {
        final id = data['notification_id'] as String?;
        if (id != null) _applyReadLocally(id);
      }
    });

    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadNotifications(),
    );
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await _service.fetchMyNotifications();
      notifications.assignAll(data);
      unreadCount.value = await _service.fetchUnreadCount();
      isLoading.value = false;
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      isLoading.value = false;
    }
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

  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      _applyReadLocally(notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
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
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> dismissNotification(String notificationId) async {
    try {
      await _service.dismissNotification(notificationId);
      notifications.removeWhere((n) => n.id == notificationId);
    } catch (e) {
      debugPrint('Error dismissing notification: $e');
    }
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _ws.removeListener(this);
    super.onClose();
  }
}
