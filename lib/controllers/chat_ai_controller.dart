import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/services/chat_ai_service.dart';

/// A single chat bubble.
class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});
}

/// Controller for [ChatAIScreen].
///
/// Owns the message list, typing state, session id, and the AI response.
/// The screen keeps a small `StatefulWidget` shell only for the
/// typing-dot `AnimationController` (needs `vsync`, which a `GetxController`
/// can't provide) and for the `TextEditingController`/`ScrollController` —
/// everything else routes through here.
class ChatAIController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;

  String sessionId = '';
  CancelToken? _cancelToken;

  final ChatAIService _aiService = ChatAIService();
  final ChatMessageRepository _chatRepo = ChatMessageRepository();

  @override
  void onInit() {
    super.onInit();
    sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _loadLastSession();
  }

  /// Load the most recent chat session if it exists.
  Future<void> _loadLastSession() async {
    try {
      final sessions = await _chatRepo.getSessions();
      if (sessions.isNotEmpty) {
        sessionId = sessions.first.sessionId;
        final msgs = await _chatRepo.getSessionMessages(sessionId);
        if (msgs.isNotEmpty) {
          messages.assignAll(
            msgs.map((m) => ChatMessage(text: m.content, isUser: m.isUser)),
          );
        }
      }
    } catch (_) {
      // Silently fall back to empty chat if DB fails.
    }
  }

  /// Sends [text] and awaits the AI reply.
  ///
  /// [errorFallbackText] is passed in (already translated) rather than
  /// looked up here, since the controller has no `BuildContext` for
  /// `AppLocalizations`.
  Future<void> sendMessage(String text, {required String errorFallbackText}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isTyping.value) return;

    messages.add(ChatMessage(text: trimmed, isUser: true));
    messages.add(const ChatMessage(text: '', isUser: false)); // placeholder
    isTyping.value = true;

    _chatRepo.insert(ChatMessageModel(
      sessionId: sessionId,
      role: ChatMessageModel.roleUser,
      content: trimmed,
    ));

    _cancelToken = CancelToken();
    try {
      final response = await _aiService.sendMessage(
        trimmed,
        sessionId: sessionId,
        cancelToken: _cancelToken,
      );
      if (messages.isNotEmpty && !messages.last.isUser) {
        messages[messages.length - 1] = ChatMessage(text: response, isUser: false);
      }
      if (messages.isNotEmpty && !messages.last.isUser) {
        _chatRepo.insert(ChatMessageModel(
          sessionId: sessionId,
          role: ChatMessageModel.roleAssistant,
          content: messages.last.text,
        ));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        if (messages.isNotEmpty && !messages.last.isUser) {
          messages[messages.length - 1] =
              const ChatMessage(text: '(Generation stopped)', isUser: false);
        }
      } else {
        if (messages.isNotEmpty && !messages.last.isUser) {
          messages[messages.length - 1] =
              ChatMessage(text: errorFallbackText, isUser: false);
        }
      }
    } catch (_) {
      if (messages.isNotEmpty && !messages.last.isUser) {
        messages[messages.length - 1] =
            ChatMessage(text: errorFallbackText, isUser: false);
      }
    } finally {
      _cancelToken = null;
      isTyping.value = false;
    }
  }

  void cancelRequest() {
    _cancelToken?.cancel('User cancelled');
  }

  void startNewChat() {
    messages.clear();
    isTyping.value = false;
    sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }
}
