/// Notification model for SQLite storage.
class NotificationModel {
  final int? id;
  final String title;
  final String? titleKm;
  final String body;
  final String? bodyKm;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime? createdAt;

  /// Notification type constants.
  static const String typeScholarship = 'scholarship';
  static const String typeDeadline = 'deadline';
  static const String typeApplication = 'application';
  static const String typeSystem = 'system';
  static const String typePromotion = 'promotion';

  const NotificationModel({
    this.id,
    required this.title,
    this.titleKm,
    required this.body,
    this.bodyKm,
    this.type = typeSystem,
    this.referenceId,
    this.isRead = false,
    this.createdAt,
  });

  NotificationModel copyWith({
    int? id,
    String? title,
    String? titleKm,
    String? body,
    String? bodyKm,
    String? type,
    String? referenceId,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleKm: titleKm ?? this.titleKm,
      body: body ?? this.body,
      bodyKm: bodyKm ?? this.bodyKm,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'title_km': titleKm,
      'body': body,
      'body_km': bodyKm,
      'type': type,
      'reference_id': referenceId,
      'is_read': isRead ? 1 : 0,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      titleKm: map['title_km'] as String?,
      body: (map['body'] as String?) ?? '',
      bodyKm: map['body_km'] as String?,
      type: (map['type'] as String?) ?? typeSystem,
      referenceId: map['reference_id'] as String?,
      isRead: (map['is_read'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'NotificationModel(id: $id, title: $title, isRead: $isRead)';
}
