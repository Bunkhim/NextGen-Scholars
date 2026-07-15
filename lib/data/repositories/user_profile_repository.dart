import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../models/user_profile_model.dart';

/// Repository for user profile CRUD operations.
class UserProfileRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Insert or update the user profile (upsert by firebase_uid).
  Future<int> saveProfile(UserProfile profile) async {
    final db = await _db.database;

    if (profile.firebaseUid != null) {
      final existing = await getByFirebaseUid(profile.firebaseUid!);
      if (existing != null) {
        return await db.update(
          DatabaseHelper.tableUserProfile,
          profile.toMap(),
          where: 'firebase_uid = ?',
          whereArgs: [profile.firebaseUid],
        );
      }
    }

    return await db.insert(
      DatabaseHelper.tableUserProfile,
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get profile by auto-increment id.
  Future<UserProfile?> getById(int id) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableUserProfile,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserProfile.fromMap(results.first);
  }

  /// Get profile by UID.
  Future<UserProfile?> getByFirebaseUid(String uid) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableUserProfile,
      where: 'firebase_uid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserProfile.fromMap(results.first);
  }

  /// Get the first (default) profile.
  Future<UserProfile?> getDefaultProfile() async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableUserProfile,
      orderBy: 'created_at ASC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserProfile.fromMap(results.first);
  }

  /// Update specific fields.
  Future<int> updateFields(int id, Map<String, dynamic> fields) async {
    final db = await _db.database;
    fields['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      DatabaseHelper.tableUserProfile,
      fields,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a profile.
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      DatabaseHelper.tableUserProfile,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Check if any profile exists.
  Future<bool> hasProfile() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableUserProfile}',
    );
    return (result.first['count'] as int) > 0;
  }
}
