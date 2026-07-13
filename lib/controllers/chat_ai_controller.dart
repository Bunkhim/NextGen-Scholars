import 'dart:async';

import 'package:get/get.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/services/chat_ai_service.dart';

/// A single chat bubble. Public (unlike the screen's old private
/// `_ChatMessage`) so the controller can expose a reactive list of them.
class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});
}

/// Controller for [ChatAIScreen].
///
/// Owns the message list, typing state, session id, and the AI response
/// stream. The screen keeps a small `StatefulWidget` shell only for the
/// typing-dot `AnimationController` (needs `vsync`, which a `GetxController`
/// can't provide) and for the `TextEditingController`/`ScrollController` —
/// everything else routes through here.
class ChatAIController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;

  String sessionId = '';

  final ChatAIService _aiService = ChatAIService();
  final ChatMessageRepository _chatRepo = ChatMessageRepository();
  StreamSubscription<String>? _streamSub;

  @override
  void onInit() {
    super.onInit();
    sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _loadLastSession();
  }

  @override
  void onClose() {
    _streamSub?.cancel();
    super.onClose();
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

  /// Sends [text] and streams the AI reply into the last message bubble.
  ///
  /// [errorFallbackText] is passed in (already translated) rather than
  /// looked up here, since the controller has no `BuildContext` for
  /// `AppLocalizations`.
  void sendMessage(String text, {required String errorFallbackText}) {
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

    _streamSub?.cancel();
    _streamSub = _aiService.sendMessageStream(trimmed).listen(
      (partialResponse) {
        messages[messages.length - 1] =
            ChatMessage(text: partialResponse, isUser: false);
      },
      onDone: () {
        isTyping.value = false;
        if (messages.isNotEmpty && !messages.last.isUser) {
          _chatRepo.insert(ChatMessageModel(
            sessionId: sessionId,
            role: ChatMessageModel.roleAssistant,
            content: messages.last.text,
          ));
        }
      },
      onError: (error) {
        isTyping.value = false;
        if (messages.isNotEmpty) {
          messages[messages.length - 1] =
              ChatMessage(text: errorFallbackText, isUser: false);
        }
      },
    );
  }

  void startNewChat() {
    _streamSub?.cancel();
    _aiService.resetChat();
    messages.clear();
    isTyping.value = false;
    sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }
}