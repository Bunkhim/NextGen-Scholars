import 'package:flutter/foundation.dart';

import '../../services/user_data_sync_service.dart';
import '../../database/database_helper.dart';
import '../models/saved_scholarship_model.dart';

/// Repository for saved (bookmarked) scholarships.
class SavedScholarshipRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Save (bookmark) a scholarship.
  ///
  /// If a hidden (is_visible = 0) row already exists for this scholarship,
  /// it is restored instead of inserting a duplicate row.
  Future<int> save(SavedScholarshipModel saved) async {
    final db = await _db.database;

    // Determine the WHERE clause and args, handling nullable userId.
    final hasUserId = saved.userId != null;
    final where = hasUserId
        ? 'scholarship_id = ? AND user_id = ?'
        : 'scholarship_id = ? AND user_id IS NULL';
    final whereArgs = hasUserId
        ? [saved.scholarshipId, saved.userId]
        : [saved.scholarshipId];

    // Check for any existing row, visible or hidden.
    final existing = await db.query(
      DatabaseHelper.tableSavedScholarships,
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      final isVisible = (existing.first['is_visible'] as int?) ?? 1;
      // Restore visibility if the row was previously soft-deleted.
      if (isVisible == 0) {
        await db.update(
          DatabaseHelper.tableSavedScholarships,
          {'is_visible': 1, 'saved_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      _triggerCloudSync();
      return id;
    }

    final newId = await db.insert(
      DatabaseHelper.tableSavedScholarships,
      saved.toMap(),
    );
    _triggerCloudSync();
    return newId;
  }

  /// Remove a saved scholarship.
  Future<int> remove(int id) async {
    final db = await _db.database;
    final result = await db.delete(
      DatabaseHelper.tableSavedScholarships,
      where: 'id = ?',
      whereArgs: [id],
    );
    _triggerCloudSync();
    return result;
  }

  /// Remove by scholarship_id (unsave).
  Future<int> unsave(int scholarshipId, {String? userId}) async {
    final db = await _db.database;
    final hasUserId = userId != null;
    final where = hasUserId
        ? 'scholarship_id = ? AND user_id = ?'
        : 'scholarship_id = ? AND user_id IS NULL';
    final whereArgs = hasUserId ? [scholarshipId, userId] : [scholarshipId];
    final result = await db.delete(
      DatabaseHelper.tableSavedScholarships,
      where: where,
      whereArgs: whereArgs,
    );
    _triggerCloudSync();
    return result;
  }

  /// Check if a scholarship is saved.
  Future<bool> isSaved(int scholarshipId, {String? userId}) async {
    final db = await _db.database;
    final hasUserId = userId != null;
    final where = hasUserId
        ? 'scholarship_id = ? AND user_id = ?'
        : 'scholarship_id = ? AND user_id IS NULL';
    final whereArgs = hasUserId ? [scholarshipId, userId] : [scholarshipId];
    final results = await db.query(
      DatabaseHelper.tableSavedScholarships,
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    return results.isNotEmpty;
  }

  /// Get all saved scholarships with full scholarship data (JOIN).
  Future<List<Map<String, dynamic>>> getSavedWithDetails({
    String? userId,
    String orderBy = 'saved_at DESC',
  }) async {
    final db = await _db.database;
    final userFilter =
        userId != null ? 'AND ss.user_id = ?' : 'AND ss.user_id IS NULL';
    final args = userId != null ? [userId] : <dynamic>[];

    final results = await db.rawQuery('''
      SELECT 
        ss.id as saved_id,
        ss.notes,
        ss.is_visible,
        ss.priority,
        ss.saved_at,
        s.*
      FROM ${DatabaseHelper.tableSavedScholarships} ss
      INNER JOIN ${DatabaseHelper.tableScholarships} s 
        ON ss.scholarship_id = s.id
      WHERE ss.is_visible = 1
        AND s.is_active = 1
        $userFilter
      ORDER BY $orderBy
    ''', args);

    return results;
  }

  /// Get all saved scholarship models (without JOIN).
  Future<List<SavedScholarshipModel>> getAll({String? userId}) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableSavedScholarships,
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'saved_at DESC',
    );
    return results.map((m) => SavedScholarshipModel.fromMap(m)).toList();
  }

  /// Soft-hide a saved scholarship (for undo support).
  Future<int> hide(int id) async {
    final db = await _db.database;
    return await db.update(
      DatabaseHelper.tableSavedScholarships,
      {'is_visible': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Restore a hidden saved scholarship.
  Future<int> restore(int id) async {
    final db = await _db.database;
    return await db.update(
      DatabaseHelper.tableSavedScholarships,
      {'is_visible': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Return all Firestore doc IDs that the user has saved.
  Future<List<String>> getSavedFirestoreIds({String? userId}) async {
    final db = await _db.database;
    final userFilter =
        userId != null ? 'AND ss.user_id = ?' : 'AND ss.user_id IS NULL';
    final args = userId != null ? [userId] : <dynamic>[];
    final results = await db.rawQuery('''
      SELECT s.firestore_id
      FROM ${DatabaseHelper.tableSavedScholarships} ss
      INNER JOIN ${DatabaseHelper.tableScholarships} s
        ON ss.scholarship_id = s.id
      WHERE ss.is_visible = 1
        AND s.firestore_id IS NOT NULL
        $userFilter
    ''', args);
    return results
        .map((r) => r['firestore_id'] as String)
        .where((id) => id.isNotEmpty)
        .toList();
  }

  /// Soft-hide (unsave) by Firestore doc ID.
  Future<void> unsaveByFirestoreId(String firestoreId, {String? userId}) async {
    final db = await _db.database;
    final userFilter =
        userId != null ? 'AND user_id = ?' : 'AND (user_id IS NULL)';
    final args = userId != null ? [firestoreId, userId] : [firestoreId];
    await db.rawUpdate('''
      UPDATE ${DatabaseHelper.tableSavedScholarships}
      SET is_visible = 0
      WHERE scholarship_id IN (
        SELECT id FROM ${DatabaseHelper.tableScholarships}
        WHERE firestore_id = ?
      ) $userFilter
    ''', args);
    _triggerCloudSync();
  }

  /// Update note on a saved scholarship.
  Future<int> updateNote(int id, String note) async {
    final db = await _db.database;
    return await db.update(
      DatabaseHelper.tableSavedScholarships,
      {'notes': note},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Fire-and-forget Firestore sync after any local change.
  void _triggerCloudSync() {
    Future.microtask(() async {
      try {
        await UserDataSyncService().syncSavedScholarships();
      } catch (e) {
        debugPrint('⚠️ Saved scholarships cloud sync failed: $e');
      }
    });
  }

  /// Count saved scholarships.
  Future<int> count({String? userId}) async {
    final db = await _db.database;
    final userFilter = userId != null ? 'AND user_id = ?' : '';
    final args = userId != null ? [userId] : <dynamic>[];
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableSavedScholarships} WHERE is_visible = 1 $userFilter',
      args,
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
