import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Production-grade SQLite database helper with migration support.
///
/// Manages the lifecycle of the SQLite database, including creation,
/// versioned migrations, and singleton access pattern.
class DatabaseHelper {
  // ── Singleton ───────────────────────────────────────────────────────────────
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // ── Constants ───────────────────────────────────────────────────────────────
  static const String _databaseName = 'scholarship_app.db';
  static const int _databaseVersion = 4;

  // Table names
  static const String tableUserProfile = 'user_profiles';
  static const String tableScholarships = 'scholarships';
  static const String tableChatMessages = 'chat_messages';
  static const String tableSearchHistory = 'search_history';
  static const String tableNotifications = 'notifications';
  static const String tableApplicationDrafts = 'application_drafts';

  // ── Database Access ─────────────────────────────────────────────────────────

  /// Returns the database instance, creating it if necessary.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  // ── Configuration ───────────────────────────────────────────────────────────

  /// Enable foreign keys for referential integrity.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ── Schema Creation ─────────────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // ── User Profile ──────────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE $tableUserProfile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebase_uid TEXT UNIQUE,
        first_name TEXT,
        last_name TEXT,
        email TEXT,
        phone_number TEXT,
        gender TEXT,
        nationality TEXT,
        date_of_birth TEXT,
        profile_image_path TEXT,
        institution TEXT,
        degree TEXT,
        major TEXT,
        graduation_year INTEGER,
        gpa TEXT,
        spoken_language TEXT,
        english_level TEXT,
        ielts_certificate TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // ── Scholarships (bilingual EN/KM support) ───────────────────────────────
    batch.execute('''
      CREATE TABLE $tableScholarships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        title_km TEXT,
        institution TEXT NOT NULL,
        institution_km TEXT,
        country TEXT NOT NULL,
        country_km TEXT,
        type TEXT NOT NULL,
        type_km TEXT,
        description TEXT,
        description_km TEXT,
        deadline TEXT,
        amount TEXT,
        currency TEXT DEFAULT 'USD',
        eligibility TEXT,
        eligibility_km TEXT,
        benefits TEXT,
        benefits_km TEXT,
        required_documents TEXT,
        required_documents_km TEXT,
        application_url TEXT,
        image_url TEXT,
        logo_url TEXT,
        level TEXT,
        field_of_study TEXT,
        firestore_id TEXT,
        number_of_places INTEGER DEFAULT 0,
        open_date TEXT,
        is_featured INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // ── Chat Messages ─────────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE $tableChatMessages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('user', 'assistant', 'system')),
        content TEXT NOT NULL,
        model_used TEXT,
        token_count INTEGER,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // ── Search History ────────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE $tableSearchHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        category TEXT,
        search_count INTEGER DEFAULT 1,
        last_searched TEXT NOT NULL DEFAULT (datetime('now')),
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // ── Notifications (bilingual EN/KM) ───────────────────────────────────────
    batch.execute('''
      CREATE TABLE $tableNotifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        title_km TEXT,
        body TEXT NOT NULL,
        body_km TEXT,
        type TEXT DEFAULT 'system',
        reference_id TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // ── Application Drafts (JSON for complex nested data) ─────────────────────
    batch.execute('''
      CREATE TABLE $tableApplicationDrafts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        status TEXT DEFAULT 'draft',
        scholarship_id TEXT,
        first_name TEXT,
        last_name TEXT,
        email TEXT,
        phone_number TEXT,
        gender TEXT,
        nationality TEXT,
        date_of_birth TEXT,
        profile_image_path TEXT,
        institution TEXT,
        degree TEXT,
        major TEXT,
        graduation_year INTEGER,
        gpa TEXT,
        languages_json TEXT,
        work_experience_json TEXT,
        research_json TEXT,
        awards_json TEXT,
        references_json TEXT,
        preferences_json TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // ── Indexes for performance ───────────────────────────────────────────────
    batch.execute(
        'CREATE INDEX idx_scholarships_deadline ON $tableScholarships(deadline)');
    batch.execute(
        'CREATE INDEX idx_scholarships_country ON $tableScholarships(country)');
    batch.execute(
        'CREATE INDEX idx_scholarships_active ON $tableScholarships(is_active)');
    batch.execute(
        'CREATE INDEX idx_scholarships_firestore_id ON $tableScholarships(firestore_id)');
    batch.execute(
        'CREATE INDEX idx_chat_session ON $tableChatMessages(session_id)');
    batch.execute(
        'CREATE INDEX idx_chat_created ON $tableChatMessages(created_at)');
    batch.execute(
        'CREATE INDEX idx_notifications_read ON $tableNotifications(is_read)');
    batch.execute(
        'CREATE INDEX idx_notifications_type ON $tableNotifications(type)');
    batch.execute(
        'CREATE INDEX idx_drafts_status ON $tableApplicationDrafts(status)');
    batch.execute(
        'CREATE INDEX idx_drafts_user ON $tableApplicationDrafts(user_id)');
    batch
        .execute('CREATE INDEX idx_search_query ON $tableSearchHistory(query)');

    await batch.commit(noResult: true);
  }

  // ── Migrations ──────────────────────────────────────────────────────────────

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE $tableScholarships ADD COLUMN firestore_id TEXT');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_scholarships_firestore_id ON $tableScholarships(firestore_id)');
    }
    if (oldVersion < 3) {
      // Ignore errors if columns already exist (safe migration).
      try {
        await db.execute(
            'ALTER TABLE $tableScholarships ADD COLUMN number_of_places INTEGER DEFAULT 0');
      } catch (_) {}
      try {
        await db.execute(
            'ALTER TABLE $tableScholarships ADD COLUMN open_date TEXT');
      } catch (_) {}
    }
    if (oldVersion < 4) {
      try {
        await db
            .execute('ALTER TABLE $tableScholarships ADD COLUMN logo_url TEXT');
      } catch (_) {}
    }
  }

  // ── Utility Methods ─────────────────────────────────────────────────────────

  /// Close the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete and recreate the database (use with caution).
  Future<void> resetDatabase() async {
    await close();
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    await deleteDatabase(path);
    _database = null;
  }

  /// Get database file size in bytes for diagnostics.
  Future<int> getDatabaseSize() async {
    // Return 0 if file doesn't exist yet
    try {
      final db = await database;
      final result = await db.rawQuery("PRAGMA page_count");
      final pageCount = result.first.values.first as int;
      final result2 = await db.rawQuery("PRAGMA page_size");
      final pageSize = result2.first.values.first as int;
      return pageCount * pageSize;
    } catch (_) {
      return 0;
    }
  }
}
