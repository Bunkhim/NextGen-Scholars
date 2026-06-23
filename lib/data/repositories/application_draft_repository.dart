import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../models/application_draft_model.dart';

/// Repository for application draft persistence.
/// Ensures form data survives app restarts and supports multiple drafts.
class ApplicationDraftRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Save a new draft or update existing one.
  Future<int> save(ApplicationDraft draft) async {
    final db = await _db.database;

    if (draft.id != null) {
      return await db.update(
        DatabaseHelper.tableApplicationDrafts,
        draft.toMap(),
        where: 'id = ?',
        whereArgs: [draft.id],
      );
    }

    return await db.insert(
      DatabaseHelper.tableApplicationDrafts,
      draft.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get draft by id.
  Future<ApplicationDraft?> getById(int id) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableApplicationDrafts,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return ApplicationDraft.fromMap(results.first);
  }

  /// Get the most recent draft for a user.
  Future<ApplicationDraft?> getLatestDraft({String? userId}) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableApplicationDrafts,
      where: userId != null ? 'user_id = ? AND status = ?' : 'status = ?',
      whereArgs: userId != null
          ? [userId, ApplicationDraft.statusDraft]
          : [ApplicationDraft.statusDraft],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return ApplicationDraft.fromMap(results.first);
  }

  /// Get all drafts for a user.
  Future<List<ApplicationDraft>> getDrafts({String? userId}) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableApplicationDrafts,
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'updated_at DESC',
    );
    return results.map((m) => ApplicationDraft.fromMap(m)).toList();
  }

  /// Get drafts by status.
  Future<List<ApplicationDraft>> getByStatus(String status) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableApplicationDrafts,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'updated_at DESC',
    );
    return results.map((m) => ApplicationDraft.fromMap(m)).toList();
  }

  /// Update draft status (e.g., draft → submitted).
  Future<int> updateStatus(int id, String status) async {
    final db = await _db.database;
    return await db.update(
      DatabaseHelper.tableApplicationDrafts,
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update specific fields of a draft.
  Future<int> updateFields(int id, Map<String, dynamic> fields) async {
    final db = await _db.database;
    fields['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      DatabaseHelper.tableApplicationDrafts,
      fields,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a draft.
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      DatabaseHelper.tableApplicationDrafts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Count drafts by status.
  Future<int> countByStatus(String status) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableApplicationDrafts} WHERE status = ?',
      [status],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Delete old completed/rejected drafts.
  Future<int> cleanupOldDrafts({int keepDays = 90}) async {
    final db = await _db.database;
    final cutoff =
        DateTime.now().subtract(Duration(days: keepDays)).toIso8601String();
    return await db.delete(
      DatabaseHelper.tableApplicationDrafts,
      where: 'status IN (?, ?) AND updated_at < ?',
      whereArgs: [
        ApplicationDraft.statusRejected,
        ApplicationDraft.statusAccepted,
        cutoff,
      ],
    );
  }
}
