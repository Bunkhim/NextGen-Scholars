import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<List<AppNotification>>? _notificationsSub;
  StreamSubscription<int>? _unreadCountSub;

  NotificationController() {
    _initStreams();
  }

  void _initStreams() {
    isLoading.value = true;

    _notificationsSub = _service.streamMyNotifications().listen(
      (data) {
        notifications.assignAll(data);
        isLoading.value = false;
      },
      onError: (error) {
        debugPrint('Error streaming notifications: $error');
        isLoading.value = false;
      },
    );

    _unreadCountSub = _service.streamUnreadCount().listen(
      (count) {
        unreadCount.value = count;
      },
      onError: (error) {
        debugPrint('Error streaming unread count: $error');
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> dismissNotification(String notificationId) async {
    try {
      await _service.dismissNotification(notificationId);
    } catch (e) {
      debugPrint('Error dismissing notification: $e');
    }
  }

  @override
  void onClose() {
    _notificationsSub?.cancel();
    _unreadCountSub?.cancel();
    super.onClose();
  }
}
