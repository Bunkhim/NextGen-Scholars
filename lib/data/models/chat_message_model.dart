/// Chat message model for SQLite storage.
/// Stores both user messages and AI responses for conversation history.
class ChatMessageModel {
  final int? id;
  final String sessionId;
  final String role;
  final String content;
  final String? modelUsed;
  final int? tokenCount;
  final DateTime? createdAt;

  /// Role constants.
  static const String roleUser = 'user';
  static const String roleAssistant = 'assistant';
  static const String roleSystem = 'system';

  const ChatMessageModel({
    this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.modelUsed,
    this.tokenCount,
    this.createdAt,
  });

  ChatMessageModel copyWith({
    int? id,
    String? sessionId,
    String? role,
    String? content,
    String? modelUsed,
    int? tokenCount,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      modelUsed: modelUsed ?? this.modelUsed,
      tokenCount: tokenCount ?? this.tokenCount,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'role': role,
      'content': content,
      'model_used': modelUsed,
      'token_count': tokenCount,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as int?,
      sessionId: (map['session_id'] as String?) ?? '',
      role: (map['role'] as String?) ?? roleUser,
      content: (map['content'] as String?) ?? '',
      modelUsed: map['model_used'] as String?,
      tokenCount: map['token_count'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  bool get isUser => role == roleUser;
  bool get isAssistant => role == roleAssistant;

  @override
  String toString() =>
      'ChatMessageModel(id: $id, role: $role, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
}

/// Chat session summary for session list display.
class ChatSession {
  final String sessionId;
  final String? title;
  final DateTime? lastMessageAt;
  final int messageCount;

  const ChatSession({
    required this.sessionId,
    this.title,
    this.lastMessageAt,
    this.messageCount = 0,
  });

  @override
  String toString() =>
      'ChatSession(id: $sessionId, title: $title, messages: $messageCount)';
}
