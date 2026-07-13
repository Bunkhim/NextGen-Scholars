import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:scholarship_app/services/notification_service.dart';

// import 'package:your_app/models/app_notification.dart';
// import 'package:your_app/services/notification_service.dart';

class NotificationController extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  // State variables
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;

  // Getters for the UI
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Stream subscriptions to manage memory efficiently
  StreamSubscription<List<AppNotification>>? _notificationsSub;
  StreamSubscription<int>? _unreadCountSub;

  /// Initializes the controller and starts listening to Firestore streams.
  NotificationController() {
    _initStreams();
  }

  void _initStreams() {
    _isLoading = true;
    notifyListeners();

    // Listen to the notifications list
    _notificationsSub = _service.streamMyNotifications().listen(
      (data) {
        _notifications = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error streaming notifications: $error');
        _isLoading = false;
        notifyListeners();
      },
    );

    // Listen to the unread count
    _unreadCountSub = _service.streamUnreadCount().listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error streaming unread count: $error');
      },
    );
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      // No need to manually update the list/count or call notifyListeners(), 
      // the Firestore stream will trigger an update automatically.
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Marks all visible notifications as read.
  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  /// Dismisses a notification so it no longer appears for the user.
  Future<void> dismissNotification(String notificationId) async {
    try {
      await _service.dismissNotification(notificationId);
    } catch (e) {
      debugPrint('Error dismissing notification: $e');
    }
  }

  @override
  void dispose() {
    // Always cancel subscriptions to prevent memory leaks when the controller is destroyed
    _notificationsSub?.cancel();
    _unreadCountSub?.cancel();
    super.dispose();
  }
}