import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../data/repositories/application_draft_repository.dart';
import '../data/repositories/chat_message_repository.dart';
import '../data/repositories/saved_scholarship_repository.dart';
import '../data/repositories/search_history_repository.dart';

/// Syncs ALL local user data (SQLite + SharedPreferences) to/from Firestore.
///
/// Each user's data is stored under:
///   `users/{uid}/app_data/{collection}`
///
/// Data synced:
///   - saved_scholarships  (firestore IDs of bookmarked scholarships)
///   - search_history      (queries + counts)
///   - chat_messages       (AI chat sessions)
///   - application_drafts  (form data)
///   - viewed_scholarships (viewed scholarship IDs)
///   - display_settings    (font, text scale, display scale)
///
/// Fill Info is already synced separately by ApplicationData._syncToFirestore.
///
/// Data lifecycle:
///   - Backup  → after every significant write & on logout
///   - Restore → on login when local data is empty (e.g. after reinstall)
///   - Delete  → on account deletion or 30-day inactivity
class UserDataSyncService {
  static final UserDataSyncService _instance = UserDataSyncService._();
  factory UserDataSyncService() => _instance;
  UserDataSyncService._();

  static final _firestore = FirebaseFirestore.instance;

  // ─── Refs ──────────────────────────────────────────────────────────────────

  static DocumentReference _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  static CollectionReference _appData(String uid) =>
      _userDoc(uid).collection('app_data');

  // ═══════════════════════════════════════════════════════════════════════════
  //  BACKUP  (local → Firestore)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Backup ALL local user data to Firestore.
  /// Call on logout or periodically while user is active.
  Future<void> backupAll() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await Future.wait([
        _backupSavedScholarships(uid),
        _backupSearchHistory(uid),
        _backupChatMessages(uid),
        _backupApplicationDrafts(uid),
        _backupViewedScholarships(uid),
        _backupDisplaySettings(uid),
      ]);
      // Record last sync timestamp
      await _appData(uid).doc('_meta').set({
        'lastSyncAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('☁️ All user data backed up to Firestore');
    } catch (e) {
      debugPrint('⚠️ User data backup failed: $e');
    }
  }

  // ── Saved Scholarships ────────────────────────────────────────────────────

  /// Public: sync saved scholarships to Firestore immediately.
  /// Call after every save / unsave operation.
  Future<void> syncSavedScholarships() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _backupSavedScholarships(uid);
    // Also update activity timestamp
    await _appData(uid).doc('_meta').set({
      'lastActivity': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _backupSavedScholarships(String uid) async {
    try {
      final repo = SavedScholarshipRepository();
      final ids = await repo.getSavedFirestoreIds(userId: uid);
      // Also get IDs without user_id (legacy)
      final legacyIds = await repo.getSavedFirestoreIds();
      final allIds = {...ids, ...legacyIds}.toList();

      await _appData(uid).doc('saved_scholarships').set({
        'firestoreIds': allIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('⚠️ Saved scholarships backup failed: $e');
    }
  }

  // ── Search History ────────────────────────────────────────────────────────

  Future<void> _backupSearchHistory(String uid) async {
    try {
      final repo = SearchHistoryRepository();
      final items = await repo.getRecent(limit: 100);
      final data = items
          .map((item) => {
                'query': item.query,
                'category': item.category,
                'searchCount': item.searchCount,
                'lastSearched': item.lastSearched?.toIso8601String(),
              })
          .toList();

      await _appData(uid).doc('search_history').set({
        'items': data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('⚠️ Search history backup failed: $e');
    }
  }

  // ── Chat Messages ─────────────────────────────────────────────────────────

  Future<void> _backupChatMessages(String uid) async {
    try {
      final repo = ChatMessageRepository();
      final sessions = await repo.getSessions();

      final sessionData = <Map<String, dynamic>>[];
      for (final session in sessions) {
        final messages = await repo.getSessionMessages(session.sessionId);
        sessionData.add({
          'sessionId': session.sessionId,
          'title': session.title,
          'messages': messages
              .map((m) => {
                    'role': m.role,
                    'content': m.content,
                    'modelUsed': m.modelUsed,
                    'createdAt': m.createdAt?.toIso8601String(),
                  })
              .toList(),
        });
      }

      // Firestore doc size limit is 1MB. If too large, only keep recent sessions.
      final encoded = sessionData.length;
      if (encoded > 50) {
        sessionData.removeRange(50, sessionData.length);
      }

      await _appData(uid).doc('chat_messages').set({
        'sessions': sessionData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('⚠️ Chat messages backup failed: $e');
    }
  }

  // ── Application Drafts ────────────────────────────────────────────────────

  Future<void> _backupApplicationDrafts(String uid) async {
    try {
      final repo = ApplicationDraftRepository();
      final drafts = await repo.getDrafts(userId: uid);
      // Also get drafts without userId (legacy)
      final legacyDrafts = await repo.getDrafts();
      final allDrafts = [...drafts, ...legacyDrafts];

      // De-duplicate by id
      final seen = <int>{};
      final unique = allDrafts.where((d) {
        if (d.id == null) return true;
        return seen.add(d.id!);
      }).toList();

      final data = unique
          .map((d) => {
                'scholarshipId': d.scholarshipId,
                'status': d.status,
                'firstName': d.firstName,
                'lastName': d.lastName,
                'email': d.email,
                'phoneNumber': d.phoneNumber,
                'gender': d.gender,
                'nationality': d.nationality,
                'dateOfBirth': d.dateOfBirth,
                'institution': d.institution,
                'degree': d.degree,
                'major': d.major,
                'graduationYear': d.graduationYear,
                'gpa': d.gpa,
                'languagesJson': d.languagesJson,
                'workExperienceJson': d.workExperienceJson,
                'researchJson': d.researchJson,
                'awardsJson': d.awardsJson,
                'referencesJson': d.referencesJson,
                'preferencesJson': d.preferencesJson,
                'updatedAt': d.updatedAt?.toIso8601String(),
              })
          .toList();

      await _appData(uid).doc('application_drafts').set({
        'drafts': data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('⚠️ Application drafts backup failed: $e');
    }
  }

  // ── Viewed Scholarships ───────────────────────────────────────────────────

  /// Public: sync viewed scholarships to Firestore immediately.
  /// Call after every markViewed operation.
  Future<void> syncViewedScholarships() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _backupViewedScholarships(uid);
    await _appData(uid).doc('_meta').set({
      'lastActivity': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _backupViewedScholarships(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('viewed_scholarship_ids') ?? [];

      await _appData(uid).doc('viewed_scholarships').set({
        'ids': ids,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('⚠️ Viewed scholarships backup failed: $e');
    }
  }

  // ── Display Settings ──────────────────────────────────────────────────────

  Future<void> _backupDisplaySettings(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await _appData(uid).doc('display_settings').set({
        'fontFamily': prefs.getString('display_font_family'),
        'textScale': prefs.getDouble('display_text_scale') ?? 1.0,
        'displayScale': prefs.getDouble('display_display_scale') ?? 1.0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('⚠️ Display settings backup failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  RESTORE  (Firestore → local)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Restore ALL user data from Firestore to local storage.
  /// Call on login when local data is missing (e.g. after reinstall).
  Future<void> restoreAll(String uid) async {
    try {
      // Check if cloud data exists and is not stale
      final meta = await _appData(uid).doc('_meta').get();
      if (!meta.exists) {
        debugPrint('☁️ No cloud backup found for user: $uid');
        return;
      }

      final metaData = meta.data() as Map<String, dynamic>?;
      if (metaData != null) {
        final ts = metaData['lastActivity'] as Timestamp?;
        if (ts != null) {
          final lastActivity = ts.toDate();
          if (DateTime.now().difference(lastActivity).inDays > 30) {
            debugPrint('☁️ Cloud data stale (>30 days) — deleting');
            await deleteAllCloudData(uid);
            return;
          }
        }
      }

      await Future.wait([
        _restoreSavedScholarships(uid),
        _restoreSearchHistory(uid),
        _restoreChatMessages(uid),
        _restoreApplicationDrafts(uid),
        _restoreViewedScholarships(uid),
        _restoreDisplaySettings(uid),
      ]);
      debugPrint('☁️ All user data restored from Firestore');
    } catch (e) {
      debugPrint('⚠️ User data restore failed: $e');
    }
  }

  // ── Saved Scholarships ────────────────────────────────────────────────────

  Future<void> _restoreSavedScholarships(String uid) async {
    try {
      final doc = await _appData(uid).doc('saved_scholarships').get();
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final ids = List<String>.from(data['firestoreIds'] ?? []);
      if (ids.isEmpty) return;

      // Check if local already has saved scholarships
      final repo = SavedScholarshipRepository();
      final existingIds = await repo.getSavedFirestoreIds(userId: uid);
      if (existingIds.isNotEmpty) return; // already have local data

      // Restore by linking to local scholarship records
      final db = await DatabaseHelper().database;
      for (final firestoreId in ids) {
        final rows = await db.query(
          DatabaseHelper.tableScholarships,
          columns: ['id'],
          where: 'firestore_id = ?',
          whereArgs: [firestoreId],
          limit: 1,
        );
        if (rows.isNotEmpty) {
          final scholarshipId = rows.first['id'] as int;
          final alreadySaved = await repo.isSaved(scholarshipId, userId: uid);
          if (!alreadySaved) {
            await db.insert(DatabaseHelper.tableSavedScholarships, {
              'scholarship_id': scholarshipId,
              'user_id': uid,
              'is_visible': 1,
              'priority': 0,
              'saved_at': DateTime.now().toIso8601String(),
            });
          }
        }
      }
      debugPrint('☁️ Saved scholarships restored');
    } catch (e) {
      debugPrint('⚠️ Saved scholarships restore failed: $e');
    }
  }

  // ── Search History ────────────────────────────────────────────────────────

  Future<void> _restoreSearchHistory(String uid) async {
    try {
      // Check if local already has search history
      final repo = SearchHistoryRepository();
      final existing = await repo.getRecent(limit: 1);
      if (existing.isNotEmpty) return;

      final doc = await _appData(uid).doc('search_history').get();
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
      final db = await DatabaseHelper().database;
      for (final item in items) {
        await db.insert(DatabaseHelper.tableSearchHistory, {
          'query': item['query'] ?? '',
          'category': item['category'],
          'search_count': item['searchCount'] ?? 1,
          'last_searched':
              item['lastSearched'] ?? DateTime.now().toIso8601String(),
        });
      }
      debugPrint('☁️ Search history restored (${items.length} items)');
    } catch (e) {
      debugPrint('⚠️ Search history restore failed: $e');
    }
  }

  // ── Chat Messages ─────────────────────────────────────────────────────────

  Future<void> _restoreChatMessages(String uid) async {
    try {
      // Check if local already has chat messages
      final repo = ChatMessageRepository();
      final existingSessions = await repo.getSessions();
      if (existingSessions.isNotEmpty) return;

      final doc = await _appData(uid).doc('chat_messages').get();
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final sessions = List<Map<String, dynamic>>.from(data['sessions'] ?? []);
      final db = await DatabaseHelper().database;
      for (final session in sessions) {
        final sessionId = session['sessionId'] as String?;
        if (sessionId == null) continue;
        final messages =
            List<Map<String, dynamic>>.from(session['messages'] ?? []);
        for (final msg in messages) {
          await db.insert(DatabaseHelper.tableChatMessages, {
            'session_id': sessionId,
            'role': msg['role'] ?? 'user',
            'content': msg['content'] ?? '',
            'model_used': msg['modelUsed'],
            'created_at': msg['createdAt'] ?? DateTime.now().toIso8601String(),
          });
        }
      }
      debugPrint('☁️ Chat messages restored (${sessions.length} sessions)');
    } catch (e) {
      debugPrint('⚠️ Chat messages restore failed: $e');
    }
  }

  // ── Application Drafts ────────────────────────────────────────────────────

  Future<void> _restoreApplicationDrafts(String uid) async {
    try {
      final repo = ApplicationDraftRepository();
      final existing = await repo.getDrafts(userId: uid);
      if (existing.isNotEmpty) return;

      final doc = await _appData(uid).doc('application_drafts').get();
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final drafts = List<Map<String, dynamic>>.from(data['drafts'] ?? []);
      final db = await DatabaseHelper().database;
      for (final draft in drafts) {
        await db.insert(DatabaseHelper.tableApplicationDrafts, {
          'user_id': uid,
          'scholarship_id': draft['scholarshipId'],
          'status': draft['status'] ?? 'draft',
          'first_name': draft['firstName'],
          'last_name': draft['lastName'],
          'email': draft['email'],
          'phone_number': draft['phoneNumber'],
          'gender': draft['gender'],
          'nationality': draft['nationality'],
          'date_of_birth': draft['dateOfBirth'],
          'institution': draft['institution'],
          'degree': draft['degree'],
          'major': draft['major'],
          'graduation_year': draft['graduationYear'],
          'gpa': draft['gpa'],
          'languages_json': draft['languagesJson'],
          'work_experience_json': draft['workExperienceJson'],
          'research_json': draft['researchJson'],
          'awards_json': draft['awardsJson'],
          'references_json': draft['referencesJson'],
          'preferences_json': draft['preferencesJson'],
          'updated_at': draft['updatedAt'] ?? DateTime.now().toIso8601String(),
        });
      }
      debugPrint('☁️ Application drafts restored (${drafts.length})');
    } catch (e) {
      debugPrint('⚠️ Application drafts restore failed: $e');
    }
  }

  // ── Viewed Scholarships ───────────────────────────────────────────────────

  Future<void> _restoreViewedScholarships(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList('viewed_scholarship_ids') ?? [];
      if (existing.isNotEmpty) return;

      final doc = await _appData(uid).doc('viewed_scholarships').get();
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final ids = List<String>.from(data['ids'] ?? []);
      if (ids.isNotEmpty) {
        await prefs.setStringList('viewed_scholarship_ids', ids);
        debugPrint('☁️ Viewed scholarships restored (${ids.length})');
      }
    } catch (e) {
      debugPrint('⚠️ Viewed scholarships restore failed: $e');
    }
  }

  // ── Display Settings ──────────────────────────────────────────────────────

  Future<void> _restoreDisplaySettings(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // If user already has display settings, skip
      if (prefs.containsKey('display_text_scale')) return;

      final doc = await _appData(uid).doc('display_settings').get();
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final fontFamily = data['fontFamily'] as String?;
      final textScale = (data['textScale'] as num?)?.toDouble() ?? 1.0;
      final displayScale = (data['displayScale'] as num?)?.toDouble() ?? 1.0;

      if (fontFamily != null) {
        await prefs.setString('display_font_family', fontFamily);
      }
      await prefs.setDouble('display_text_scale', textScale);
      await prefs.setDouble('display_display_scale', displayScale);

      debugPrint('☁️ Display settings restored');
    } catch (e) {
      debugPrint('⚠️ Display settings restore failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  DELETE  (remove cloud data)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Delete ALL cloud-backed user data (Firestore sub-collections).
  /// Call on account deletion.
  static Future<void> deleteAllCloudData(String uid) async {
    try {
      final docs = [
        'saved_scholarships',
        'search_history',
        'chat_messages',
        'application_drafts',
        'viewed_scholarships',
        'display_settings',
        '_meta',
      ];
      final batch = _firestore.batch();
      for (final docName in docs) {
        batch.delete(_appData(uid).doc(docName));
      }
      await batch.commit();
      debugPrint('🗑️ All cloud data deleted for user: $uid');
    } catch (e) {
      debugPrint('⚠️ Cloud data delete failed: $e');
    }
  }

  /// Delete all local SQLite data for the current user.
  static Future<void> deleteAllLocalData(String uid) async {
    try {
      final db = await DatabaseHelper().database;

      // Saved scholarships (delete both uid-matched AND legacy null rows)
      await db.delete(
        DatabaseHelper.tableSavedScholarships,
        where: 'user_id = ? OR user_id IS NULL',
        whereArgs: [uid],
      );

      // Application drafts (delete both uid-matched AND legacy null rows)
      await db.delete(
        DatabaseHelper.tableApplicationDrafts,
        where: 'user_id = ? OR user_id IS NULL',
        whereArgs: [uid],
      );

      // Chat messages (not user-scoped in schema, clear all)
      await db.delete(DatabaseHelper.tableChatMessages);

      // Search history (not user-scoped, clear all)
      await db.delete(DatabaseHelper.tableSearchHistory);

      // Notifications (not user-scoped, clear all)
      await db.delete(DatabaseHelper.tableNotifications);

      // Viewed scholarships (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('viewed_scholarship_ids');

      debugPrint('🗑️ All local data deleted for user: $uid');
    } catch (e) {
      debugPrint('⚠️ Local data delete failed: $e');
    }
  }

  /// Check if cloud data is stale (>30 days) and delete if so.
  /// Call during app startup / cleanup.
  static Future<void> cleanupStaleCloudData(String uid) async {
    try {
      final meta = await _appData(uid).doc('_meta').get();
      if (!meta.exists) return;
      final data = meta.data() as Map<String, dynamic>?;
      if (data == null) return;

      final ts = data['lastActivity'] as Timestamp?;
      if (ts == null) return;

      final lastActivity = ts.toDate();
      if (DateTime.now().difference(lastActivity).inDays > 30) {
        await deleteAllCloudData(uid);
        debugPrint('☁️ Stale cloud data cleaned up for user: $uid');
      }
    } catch (e) {
      debugPrint('⚠️ Stale data cleanup failed: $e');
    }
  }

  /// Record activity timestamp (call periodically).
  Future<void> recordActivity() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _appData(uid).doc('_meta').set({
        'lastActivity': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
