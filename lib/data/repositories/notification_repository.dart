import '../../database/database_helper.dart';
import '../models/notification_model.dart';

/// Repository for notification persistence.
class NotificationRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Insert a notification.
  Future<int> insert(NotificationModel notification) async {
    final db = await _db.database;
    return await db.insert(
      DatabaseHelper.tableNotifications,
      notification.toMap(),
    );
  }

  /// Get all notifications ordered by newest first.
  Future<List<NotificationModel>> getAll({int? limit}) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableNotifications,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return results.map((m) => NotificationModel.fromMap(m)).toList();
  }

  /// Get unread notifications.
  Future<List<NotificationModel>> getUnread() async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableNotifications,
      where: 'is_read = 0',
      orderBy: 'created_at DESC',
    );
    return results.map((m) => NotificationModel.fromMap(m)).toList();
  }

  /// Get notifications by type.
  Future<List<NotificationModel>> getByType(String type) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableNotifications,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => NotificationModel.fromMap(m)).toList();
  }

  /// Mark a notification as read.
  Future<int> markAsRead(int id) async {
    final db = await _db.database;
    return await db.update(
      DatabaseHelper.tableNotifications,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark all notifications as read.
  Future<int> markAllAsRead() async {
    final db = await _db.database;
    return await db.update(
      DatabaseHelper.tableNotifications,
      {'is_read': 1},
      where: 'is_read = 0',
    );
  }

  /// Get unread count.
  Future<int> unreadCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableNotifications} WHERE is_read = 0',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Delete a notification.
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      DatabaseHelper.tableNotifications,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete old notifications (older than N days).
  Future<int> deleteOlderThan(int days) async {
    final db = await _db.database;
    final cutoff =
        DateTime.now().subtract(Duration(days: days)).toIso8601String();
    return await db.delete(
      DatabaseHelper.tableNotifications,
      where: 'created_at < ? AND is_read = 1',
      whereArgs: [cutoff],
    );
  }

  /// Clear all notifications.
  Future<int> clearAll() async {
    final db = await _db.database;
    return await db.delete(DatabaseHelper.tableNotifications);
  }
}
