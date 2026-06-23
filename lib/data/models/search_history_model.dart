/// Search history model for SQLite storage.
class SearchHistoryItem {
  final int? id;
  final String query;
  final String? category;
  final int searchCount;
  final DateTime? lastSearched;
  final DateTime? createdAt;

  const SearchHistoryItem({
    this.id,
    required this.query,
    this.category,
    this.searchCount = 1,
    this.lastSearched,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'query': query,
      'category': category,
      'search_count': searchCount,
      'last_searched': DateTime.now().toIso8601String(),
    };
  }

  factory SearchHistoryItem.fromMap(Map<String, dynamic> map) {
    return SearchHistoryItem(
      id: map['id'] as int?,
      query: (map['query'] as String?) ?? '',
      category: map['category'] as String?,
      searchCount: (map['search_count'] as int?) ?? 1,
      lastSearched: map['last_searched'] != null
          ? DateTime.tryParse(map['last_searched'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  @override
  String toString() => 'SearchHistoryItem(query: $query, count: $searchCount)';
}
