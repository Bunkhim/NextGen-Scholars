import '../../database/database_helper.dart';
import '../models/search_history_model.dart';

/// Repository for search history management.
class SearchHistoryRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Add a search query (increments count if already exists).
  Future<int> addSearch(String query, {String? category}) async {
    final db = await _db.database;
    final trimmed = query.trim();
    if (trimmed.isEmpty) return 0;

    // Check if query already exists.
    final existing = await db.query(
      DatabaseHelper.tableSearchHistory,
      where: 'query = ?',
      whereArgs: [trimmed],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final currentCount = (existing.first['search_count'] as int?) ?? 1;
      return await db.update(
        DatabaseHelper.tableSearchHistory,
        {
          'search_count': currentCount + 1,
          'last_searched': DateTime.now().toIso8601String(),
          if (category != null) 'category': category,
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }

    return await db.insert(
      DatabaseHelper.tableSearchHistory,
      {
        'query': trimmed,
        'category': category,
        'search_count': 1,
        'last_searched': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get recent searches ordered by last searched.
  Future<List<SearchHistoryItem>> getRecent({int limit = 10}) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableSearchHistory,
      orderBy: 'last_searched DESC',
      limit: limit,
    );
    return results.map((m) => SearchHistoryItem.fromMap(m)).toList();
  }

  /// Get most popular searches.
  Future<List<SearchHistoryItem>> getPopular({int limit = 10}) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableSearchHistory,
      orderBy: 'search_count DESC',
      limit: limit,
    );
    return results.map((m) => SearchHistoryItem.fromMap(m)).toList();
  }

  /// Get search suggestions (prefix match).
  Future<List<String>> getSuggestions(String prefix, {int limit = 5}) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableSearchHistory,
      columns: ['query'],
      where: 'query LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: 'search_count DESC, last_searched DESC',
      limit: limit,
    );
    return results.map((r) => r['query'] as String).toList();
  }

  /// Delete a search entry.
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      DatabaseHelper.tableSearchHistory,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all search history.
  Future<int> clearAll() async {
    final db = await _db.database;
    return await db.delete(DatabaseHelper.tableSearchHistory);
  }
}
