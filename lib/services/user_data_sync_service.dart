import 'package:flutter/foundation.dart';
import 'package:scholarship_app/database/database_helper.dart';

class UserDataSyncService {
  static final UserDataSyncService _instance = UserDataSyncService._();
  factory UserDataSyncService() => _instance;
  UserDataSyncService._();

  Future<void> deleteAllLocalData() async {
    final db = await DatabaseHelper().database;
    await db.delete('saved_scholarships');
    await db.delete('viewed_scholarships');
    await db.delete('search_history');
    debugPrint('🗑️ All local user data deleted');
  }
}
