import 'package:scholarship_app/core/api/services/chat_api_service.dart';

/// Service that routes chat messages through the backend API.
///
/// The backend (POST /chat/ai) handles all Gemini interaction server-side.
/// No API key or direct Google API calls from the Flutter client.
class ChatAIService {
  final ChatApiService _api = ChatApiService();

  static final ChatAIService _instance = ChatAIService._internal();
  factory ChatAIService() => _instance;
  ChatAIService._internal();

  /// Send a message and get a complete response from the backend AI.
  Future<String> sendMessage(String message, {String? sessionId}) async {
    try {
      final res = await _api.aiChat(
        content: message,
        sessionId: sessionId,
      );
      final content = res['content'] as String? ?? '';
      if (content.isEmpty) {
        return 'I apologize, but I couldn\'t generate a response. Please try again.';
      }
      return content;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('429') || msg.contains('quota') || msg.contains('rate')) {
        return 'The service is temporarily busy. Please wait a moment and try again.';
      } else if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
        return 'No internet connection. Please check your network and try again.';
      }
      return 'Sorry, something went wrong. Please try again.';
    }
  }

  /// Reset session (no-op — backend manages sessions).
  void resetChat() {}
}
