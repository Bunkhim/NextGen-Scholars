part of 'chat_ai_screen_view.dart';

class ChatAiScreenViewController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;

  final ChatAIService aiService = ChatAIService();
  final ChatMessageRepository chatRepo = ChatMessageRepository();
  StreamSubscription<String>? streamSub;
  String currentSessionId = '';

  @override
  void onInit() {
    super.onInit();
    currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    streamSub?.cancel();
    super.onClose();
  }

  void loadLastSession(VoidCallback scrollToBottom) async {
    try {
      final sessions = await chatRepo.getSessions();
      if (sessions.isNotEmpty) {
        currentSessionId = sessions.first.sessionId;
        final msgs = await chatRepo.getSessionMessages(currentSessionId);
        if (msgs.isNotEmpty) {
          messages.clear();
          for (final msg in msgs) {
            messages.add(ChatMessage(
              text: msg.content,
              isUser: msg.isUser,
            ));
          }
          scrollToBottom();
        }
      }
    } catch (_) {}
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty || isTyping.value) return;

    messages.add(ChatMessage(text: text, isUser: true));
    messageController.clear();
    isTyping.value = true;
    messages.add(ChatMessage(text: '', isUser: false));

    chatRepo.insert(ChatMessageModel(
      sessionId: currentSessionId,
      role: ChatMessageModel.roleUser,
      content: text,
    ));

    streamSub?.cancel();
    streamSub = aiService.sendMessageStream(text).listen(
      (partialResponse) {
        messages.last = ChatMessage(text: partialResponse, isUser: false);
      },
      onDone: () {
        isTyping.value = false;
        if (messages.isNotEmpty && !messages.last.isUser) {
          chatRepo.insert(ChatMessageModel(
            sessionId: currentSessionId,
            role: ChatMessageModel.roleAssistant,
            content: messages.last.text,
          ));
        }
      },
      onError: (error) {
        isTyping.value = false;
        messages.last = ChatMessage(
          text: 'Sorry, something went wrong. Please try again.',
          isUser: false,
        );
      },
    );
  }

  void startNewChat() {
    streamSub?.cancel();
    aiService.resetChat();
    messages.clear();
    isTyping.value = false;
    currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void dispose() {
    streamSub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
