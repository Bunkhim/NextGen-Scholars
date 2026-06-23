import '../../database/database_helper.dart';
import '../models/chat_message_model.dart';

/// Repository for chat message persistence.
/// Supports multiple chat sessions with history.
class ChatMessageRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Save a single message.
  Future<int> insert(ChatMessageModel message) async {
    final db = await _db.database;
    return await db.insert(
      DatabaseHelper.tableChatMessages,
      message.toMap(),
    );
  }

  /// Save user message and assistant response as a pair.
  Future<void> saveConversationPair({
    required String sessionId,
    required String userMessage,
    required String assistantResponse,
    String? modelUsed,
  }) async {
    final db = await _db.database;
    final batch = db.batch();

    batch.insert(DatabaseHelper.tableChatMessages, {
      'session_id': sessionId,
      'role': ChatMessageModel.roleUser,
      'content': userMessage,
    });

    batch.insert(DatabaseHelper.tableChatMessages, {
      'session_id': sessionId,
      'role': ChatMessageModel.roleAssistant,
      'content': assistantResponse,
      'model_used': modelUsed,
    });

    await batch.commit(noResult: true);
  }

  /// Get all messages for a session, ordered chronologically.
  Future<List<ChatMessageModel>> getSessionMessages(String sessionId) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableChatMessages,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC, id ASC',
    );
    return results.map((m) => ChatMessageModel.fromMap(m)).toList();
  }

  /// Get all unique sessions with their last message.
  Future<List<ChatSession>> getSessions() async {
    final db = await _db.database;
    final results = await db.rawQuery('''
      SELECT 
        session_id,
        MAX(created_at) as last_message_at,
        COUNT(*) as message_count,
        (
          SELECT content FROM ${DatabaseHelper.tableChatMessages} c2
          WHERE c2.session_id = c1.session_id AND c2.role = 'user'
          ORDER BY c2.created_at ASC
          LIMIT 1
        ) as first_user_message
      FROM ${DatabaseHelper.tableChatMessages} c1
      GROUP BY session_id
      ORDER BY last_message_at DESC
    ''');

    return results.map((row) {
      final firstMsg = row['first_user_message'] as String?;
      // Use first user message as session title (truncated).
      final title = firstMsg != null && firstMsg.length > 60
          ? '${firstMsg.substring(0, 60)}...'
          : firstMsg;

      return ChatSession(
        sessionId: row['session_id'] as String,
        title: title,
        lastMessageAt: row['last_message_at'] != null
            ? DateTime.tryParse(row['last_message_at'] as String)
            : null,
        messageCount: (row['message_count'] as int?) ?? 0,
      );
    }).toList();
  }

  /// Delete all messages in a session.
  Future<int> deleteSession(String sessionId) async {
    final db = await _db.database;
    return await db.delete(
      DatabaseHelper.tableChatMessages,
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Delete all chat history.
  Future<int> deleteAll() async {
    final db = await _db.database;
    return await db.delete(DatabaseHelper.tableChatMessages);
  }

  /// Count messages in a session.
  Future<int> countInSession(String sessionId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableChatMessages} WHERE session_id = ?',
      [sessionId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Count total sessions.
  Future<int> sessionCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT session_id) as count FROM ${DatabaseHelper.tableChatMessages}',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Get the last N messages for context (useful for AI prompts).
  Future<List<ChatMessageModel>> getRecentMessages(
    String sessionId, {
    int limit = 20,
  }) async {
    final db = await _db.database;
    final results = await db.query(
      DatabaseHelper.tableChatMessages,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at DESC, id DESC',
      limit: limit,
    );
    // Reverse to get chronological order.
    return results.reversed.map((m) => ChatMessageModel.fromMap(m)).toList();
  }
}
