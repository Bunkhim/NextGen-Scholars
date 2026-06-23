import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../models/scholarship_model.dart';

/// Repository for scholarship CRUD operations with search and filtering.
class ScholarshipRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Insert a new scholarship.
  Future<int> insert(Scholarship scholarship) async {
    final db = await _db.database;
    return await db.insert(
      DatabaseHelper.tableScholarships,
      scholarship.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple scholarships in a batch.
  Future<void> insertAll(List<Scholarship> scholarships) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final s in scholarships) {
      batch.insert(
        DatabaseHelper.tableScholarships,
        s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Get scholarship by id.
  Future<Scholarship?> getById(int id) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableScholarships,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Scholarship.fromMap(results.first);
  }

  /// Get all active scholarships ordered by deadline.
  Future<List<Scholarship>> getAll({
    int? limit,
    int? offset,
    String orderBy = 'deadline ASC',
  }) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableScholarships,
      where: 'is_active = 1',
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return results.map((m) => Scholarship.fromMap(m)).toList();
  }

  /// Get featured scholarships.
  Future<List<Scholarship>> getFeatured({int limit = 10}) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableScholarships,
      where: 'is_featured = 1 AND is_active = 1',
      orderBy: 'deadline ASC',
      limit: limit,
    );
    return results.map((m) => Scholarship.fromMap(m)).toList();
  }

  /// Search scholarships by keyword (title, institution, country, description).
  Future<List<Scholarship>> search(String keyword, {int limit = 50}) async {
    final db = await _db.database;
    final query = '%$keyword%';
    final results = await db.query(
      DatabaseHelper.tableScholarships,
      where: '''
        is_active = 1 AND (
          title LIKE ? OR title_km LIKE ? OR
          institution LIKE ? OR institution_km LIKE ? OR
          country LIKE ? OR country_km LIKE ? OR
          description LIKE ? OR description_km LIKE ? OR
          field_of_study LIKE ?
        )
      ''',
      whereArgs: [
        query,
        query,
        query,
        query,
        query,
        query,
        query,
        query,
        query,
      ],
      orderBy: 'deadline ASC',
      limit: limit,
    );
    return results.map((m) => Scholarship.fromMap(m)).toList();
  }

  /// Filter scholarships by country, type, level.
  Future<List<Scholarship>> filter({
    String? country,
    String? type,
    String? level,
    bool? isFeatured,
    int? limit,
  }) async {
    final db = await _db.database;
    final where = <String>['is_active = 1'];
    final args = <dynamic>[];

    if (country != null) {
      where.add('(country = ? OR country_km = ?)');
      args.addAll([country, country]);
    }
    if (type != null) {
      where.add('(type = ? OR type_km = ?)');
      args.addAll([type, type]);
    }
    if (level != null) {
      where.add('level = ?');
      args.add(level);
    }
    if (isFeatured != null) {
      where.add('is_featured = ?');
      args.add(isFeatured ? 1 : 0);
    }

    final results = await db.query(
      DatabaseHelper.tableScholarships,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'deadline ASC',
      limit: limit,
    );
    return results.map((m) => Scholarship.fromMap(m)).toList();
  }

  /// Get scholarships expiring within N days.
  Future<List<Scholarship>> getExpiringSoon({int days = 30}) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final deadline = DateTime.now().add(Duration(days: days)).toIso8601String();
    final results = await db.query(
      DatabaseHelper.tableScholarships,
      where: 'is_active = 1 AND deadline >= ? AND deadline <= ?',
      whereArgs: [now, deadline],
      orderBy: 'deadline ASC',
    );
    return results.map((m) => Scholarship.fromMap(m)).toList();
  }

  /// Update a scholarship.
  Future<int> update(Scholarship scholarship) async {
    final db = await _db.database;
    return await db.update(
      DatabaseHelper.tableScholarships,
      scholarship.toMap(),
      where: 'id = ?',
      whereArgs: [scholarship.id],
    );
  }

  /// Deactivate (soft-delete) a scholarship.
  Future<int> deactivate(int id) async {
    final db = await _db.database;
    return await db.update(
      DatabaseHelper.tableScholarships,
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hard-delete a scholarship.
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      DatabaseHelper.tableScholarships,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Find an existing SQLite scholarship by Firestore doc ID, or insert it and
  /// return the auto-generated SQLite integer ID.
  Future<int> findOrInsertByFirestoreId({
    required String firestoreId,
    required Scholarship scholarship,
  }) async {
    return upsertByFirestoreId(
        firestoreId: firestoreId, scholarship: scholarship);
  }

  /// Insert or update a scholarship row by its Firestore document ID.
  /// Returns the SQLite integer primary key.
  Future<int> upsertByFirestoreId({
    required String firestoreId,
    required Scholarship scholarship,
  }) async {
    final db = await _db.database;
    final existing = await db.query(
      DatabaseHelper.tableScholarships,
      columns: ['id'],
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
      limit: 1,
    );
    final map = scholarship.toMap();
    map['firestore_id'] = firestoreId;

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      await db.update(
        DatabaseHelper.tableScholarships,
        map,
        where: 'id = ?',
        whereArgs: [id],
      );
      return id;
    }
    return await db.insert(DatabaseHelper.tableScholarships, map);
  }

  /// Sync the is_active flag for all locally-cached scholarships based on
  /// the list of currently-active Firestore doc IDs.
  ///
  /// - Scholarships whose firestore_id IS in [activeFirestoreIds] → is_active = 1
  /// - Scholarships whose firestore_id is NOT in the list → is_active = 0
  /// Returns true if any rows were changed.
  Future<bool> syncActiveStatus(List<String> activeFirestoreIds) async {
    final db = await _db.database;

    // Fetch all local scholarships that have a firestore_id.
    final locals = await db.query(
      DatabaseHelper.tableScholarships,
      columns: ['id', 'firestore_id', 'is_active'],
      where: 'firestore_id IS NOT NULL',
    );

    if (locals.isEmpty) return false;

    final activeSet = activeFirestoreIds.toSet();
    int changed = 0;

    final batch = db.batch();
    for (final row in locals) {
      final fid = row['firestore_id'] as String;
      final currentActive = (row['is_active'] as int?) ?? 1;
      final shouldBeActive = activeSet.contains(fid) ? 1 : 0;

      if (currentActive != shouldBeActive) {
        batch.update(
          DatabaseHelper.tableScholarships,
          {'is_active': shouldBeActive},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
        changed++;
      }
    }

    if (changed > 0) {
      await batch.commit(noResult: true);
    }
    return changed > 0;
  }

  /// Count total active scholarships.
  Future<int> count() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableScholarships} WHERE is_active = 1',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Get distinct countries for filter options.
  Future<List<String>> getCountries() async {
    final db = await _db.database;
    final results = await db.rawQuery(
      'SELECT DISTINCT country FROM ${DatabaseHelper.tableScholarships} WHERE is_active = 1 AND country IS NOT NULL ORDER BY country',
    );
    return results.map((r) => r['country'] as String).toList();
  }

  /// Get distinct types for filter options.
  Future<List<String>> getTypes() async {
    final db = await _db.database;
    final results = await db.rawQuery(
      'SELECT DISTINCT type FROM ${DatabaseHelper.tableScholarships} WHERE is_active = 1 AND type IS NOT NULL ORDER BY type',
    );
    return results.map((r) => r['type'] as String).toList();
  }
}
