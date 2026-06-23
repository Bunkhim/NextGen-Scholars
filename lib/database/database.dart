/// Scholarship App Database Layer
///
/// Production-grade SQLite integration with:
/// - DatabaseHelper: Singleton with migration support
/// - Models: Type-safe data classes with toMap/fromMap
/// - Repositories: Clean CRUD API for each table
///
/// Usage:
/// ```dart
/// import 'package:scholarship_app/database/database.dart';
///
/// final repo = ScholarshipRepository();
/// final scholarships = await repo.getAll();
/// ```
export 'database_helper.dart';
export '../data/models/models.dart';
export '../data/repositories/repositories.dart';
