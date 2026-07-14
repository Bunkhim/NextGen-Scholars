import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';

/// Model representing a Firestore notification.
class AppNotification {
  final String id;
  final String title;
  final String? titleKm;
  final String body;
  final String? bodyKm;
  final String
      type; // 'new_scholarship' | 'new_application' | 'application_status' | 'system'
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

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      titleKm: data['titleKm'] as String?,
      body: (data['body'] as String?) ?? '',
      bodyKm: data['bodyKm'] as String?,
      type: (data['type'] as String?) ?? 'system',
      targetUserId: data['targetUserId'] as String?,
      referenceId: data['referenceId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      readBy: List<String>.from(data['readBy'] ?? []),
      dismissedBy: List<String>.from(data['dismissedBy'] ?? []),
    );
  }
}

/// Service to query Firestore notifications for the current user.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _db = FirebaseFirestore.instance;
  CollectionReference get _notifications => _db.collection('notifications');

  String get _uid => JwtService().uidSync ?? '';

  /// Stream notifications relevant to the current user.
  /// Returns broadcast notifications (targetUserId == null) + user-specific ones.
  Stream<List<AppNotification>> streamMyNotifications({int limit = 50}) {
    // We query all notifications ordered by createdAt desc and filter client-side
    // because Firestore doesn't support OR queries on different fields easily.
    return _notifications
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .where((n) =>
              // Exclude admin-only notifications
              n.type != 'new_application' &&
              // Exclude notifications dismissed by this user
              !n.dismissedBy.contains(_uid) &&
              (n.targetUserId == null ||
                  n.targetUserId == '' ||
                  n.targetUserId == _uid))
          .toList();
    });
  }

  /// Get unread notification count for the current user.
  Stream<int> streamUnreadCount() {
    return streamMyNotifications().map((list) {
      return list.where((n) => !n.isRead).length;
    });
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    if (_uid.isEmpty) return;
    await _notifications.doc(notificationId).update({
      'readBy': FieldValue.arrayUnion([_uid]),
    });
  }

  /// Mark all visible notifications as read.
  Future<void> markAllAsRead() async {
    if (_uid.isEmpty) return;
    final snap = await _notifications.get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final target = data['targetUserId'] as String?;
      if (target == null || target.isEmpty || target == _uid) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([_uid]),
        });
      }
    }
    await batch.commit();
  }

  /// Dismiss (hide) a notification for the current user.
  Future<void> dismissNotification(String notificationId) async {
    if (_uid.isEmpty) return;
    await _notifications.doc(notificationId).update({
      'dismissedBy': FieldValue.arrayUnion([_uid]),
    });
  }
}
