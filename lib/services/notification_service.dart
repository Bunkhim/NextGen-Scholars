import 'package:scholarship_app/core/api/services/notifications_api_service.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';

/// Model representing a notification from the backend.
class AppNotification {
  final String id;
  final String title;
  final String? titleKm;
  final String body;
  final String? bodyKm;
  final String type;
  final String? targetUserId;
  final String? referenceId;
  final DateTime? createdAt;
  final List<String> readBy;
  final List<String> dismissedBy;

  const AppNotification({
    required this.id,
    required this.title,
    this.titleKm,
    required this.body,
    this.bodyKm,
    required this.type,
    this.targetUserId,
    this.referenceId,
    this.createdAt,
    this.readBy = const [],
    this.dismissedBy = const [],
  });

  bool get isRead {
    final uid = JwtService().uidSync ?? '';
    return readBy.contains(uid);
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? json['_id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      titleKm: json['titleKm'] as String?,
      body: (json['body'] ?? '') as String,
      bodyKm: json['bodyKm'] as String?,
      type: (json['type'] ?? 'system') as String,
      targetUserId: json['targetUserId'] as String?,
      referenceId: json['referenceId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      readBy: List<String>.from(json['readBy'] ?? []),
      dismissedBy: List<String>.from(json['dismissedBy'] ?? []),
    );
  }
}

/// Service to query notifications from the backend API.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final NotificationsApiService _api = NotificationsApiService();

  String get _uid => JwtService().uidSync ?? '';

  /// Fetch notifications from the backend API.
  Future<List<AppNotification>> fetchMyNotifications({int limit = 50}) async {
    final raw = await _api.listNotifications(limit: limit);
    final uid = _uid;
    return raw
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .where((n) =>
            n.type != 'new_application' &&
            !n.dismissedBy.contains(uid) &&
            (n.targetUserId == null ||
                n.targetUserId == '' ||
                n.targetUserId == uid))
        .toList();
  }

  /// Get unread notification count from the backend.
  Future<int> fetchUnreadCount() async {
    return _api.getUnreadCount();
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _api.markAsRead(notificationId);
  }

  /// Mark all visible notifications as read.
  Future<void> markAllAsRead() async {
    await _api.markAllAsRead();
  }

  /// Dismiss (hide) a notification for the current user.
  Future<void> dismissNotification(String notificationId) async {
    await _api.dismissNotification(notificationId);
  }
}
