// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/controllers/chat_ai_controller.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

class ChatAIScreen extends StatefulWidget {
  const ChatAIScreen({super.key});

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

class _ChatAIScreenState extends State<ChatAIScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _dotController;

  final ChatAIController controller = Get.put(ChatAIController());

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // Scroll to bottom whenever new messages arrive or typing starts/stops.
    ever(controller.messages, (_) => _scrollToBottom());
    ever(controller.isTyping, (_) => _scrollToBottom());

    if (controller.messages.isNotEmpty) _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final t = AppLocalizations.of(context);
    controller.sendMessage(
      _messageController.text,
      errorFallbackText: t.translate('chatAIErrorGeneric'),
    );
    _messageController.clear();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: WallpaperService().hasAny
          ? Colors.transparent
          : cs.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: WallpaperService().hasTheme
            ? WallpaperService().appBarColor
            : cs.surface,
        surfaceTintColor:
            WallpaperService().hasTheme ? Colors.transparent : cs.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // AI Avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: WallpaperService().hasTheme
                      ? [
                          WallpaperService().themedPrimary(cs),
                          WallpaperService().themedPrimary(cs).withOpacity(0.7)
                        ]
                      : [cs.primary, cs.primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (WallpaperService().hasTheme
                            ? WallpaperService().themedPrimary(cs)
                            : cs.primary)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.translate('chatAITitle'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: WallpaperService().hasTheme
                          ? WallpaperService().onThemeColor
                          : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        t.translate('chatAIOnline'),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: WallpaperService().hasTheme
                              ? WallpaperService().onThemeColor.withOpacity(0.7)
                              : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment_outlined,
                color: WallpaperService().hasTheme
                    ? WallpaperService().onThemeColor
                    : cs.onSurfaceVariant,
                size: 22),
            tooltip: 'New Chat',
            onPressed: controller.startNewChat,
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 0.5,
            color: cs.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Obx(() {
              final messages = controller.messages;
              final isTyping = controller.isTyping.value;

              if (messages.isEmpty) {
                return _buildEmptyState(cs, t, isDark);
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && isTyping) {
                    return _buildTypingIndicator(cs);
                  }
                  return _buildMessageBubble(messages[index], cs, isDark);
                },
              );
            }),
          ),

          // Input area
          _buildInputArea(cs, t, isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs, AppLocalizations t, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AI Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: WallpaperService().hasTheme
                      ? [
                          WallpaperService()
                              .themedPrimary(cs)
                              .withOpacity(0.15),
                          WallpaperService()
                              .themedPrimary(cs)
                              .withOpacity(0.08),
                        ]
                      : [
                          cs.primary.withOpacity(0.12),
                          cs.primary.withOpacity(0.08),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 36,
                color: WallpaperService().themedPrimary(cs),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t.translate('chatAIWelcome'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: WallpaperService().themedOnSurface(cs),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.translate('chatAIWelcomeSubtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: WallpaperService().themedOnSurfaceVariant(cs),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Suggestion chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip(
                    t.translate('chatAISuggestion1'), cs, isDark),
                _buildSuggestionChip(
                    t.translate('chatAISuggestion2'), cs, isDark),
                _buildSuggestionChip(
                    t.translate('chatAISuggestion3'), cs, isDark),
                _buildSuggestionChip(
                    t.translate('chatAISuggestion4'), cs, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text, ColorScheme cs, bool isDark) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return GestureDetector(
      onTap: () {
        _messageController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: themed
              ? Colors.white.withOpacity(ws.isThemeDark ? 0.10 : 0.45)
              : isDark
                  ? cs.surfaceContainerHighest
                  : cs.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themed ? ws.glassBorder : cs.primary.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            color: ws.themedPrimary(cs),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
      ChatMessage message, ColorScheme cs, bool isDark) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: WallpaperService().hasTheme
                      ? [
                          WallpaperService().themedPrimary(cs),
                          WallpaperService().themedPrimary(cs).withOpacity(0.7)
                        ]
                      : [cs.primary, cs.primary.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? cs.primary
                    : WallpaperService().hasTheme
                        ? WallpaperService().cardColor
                        : isDark
                            ? cs.surfaceContainerHighest
                            : cs.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? cs.onPrimary : cs.onSurface,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: WallpaperService().hasTheme
                    ? [
                        WallpaperService().themedPrimary(cs),
                        WallpaperService().themedPrimary(cs).withOpacity(0.7)
                      ]
                    : [cs.primary, cs.primary.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: WallpaperService().hasTheme
                  ? WallpaperService().cardColor
                  : cs.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: AnimatedBuilder(
              animation: _dotController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.2;
                    final t = ((_dotController.value - delay) % 1.0);
                    final scale =
                        t < 0.5 ? 1.0 + t * 0.6 : 1.3 - (t - 0.5) * 0.6;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.scale(
                        scale: scale.clamp(0.8, 1.3),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ColorScheme cs, AppLocalizations t, bool isDark) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: themed ? ws.cardColor : cs.surface,
        border: Border(
          top: BorderSide(
            color: themed ? ws.glassBorder : cs.outlineVariant.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: themed
                  ? ws.glassInput(radius: 24)
                  : BoxDecoration(
                      color: isDark
                          ? cs.surfaceContainerHighest
                          : cs.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                maxLength: 2000,
                maxLines: 5,
                minLines: 1,
                style: TextStyle(
                    fontSize: 14,
                    color: themed ? ws.onThemeColor : cs.onSurface),
                decoration: InputDecoration(
                  hintText: t.translate('chatAIInputHint'),
                  hintStyle: TextStyle(
                    color: cs.onSurfaceVariant.withOpacity(0.5),
                    fontSize: 13.5,
                  ),
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final isTyping = controller.isTyping.value;
            return GestureDetector(
              onTap: isTyping ? null : _sendMessage,
              child: AnimatedOpacity(
                opacity: isTyping ? 0.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themed
                          ? [
                              ws.themedPrimary(cs),
                              ws.themedPrimary(cs).withOpacity(0.7)
                            ]
                          : [cs.primary, cs.primary.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: (themed ? ws.themedPrimary(cs) : cs.primary)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isTyping ? Icons.hourglass_top_rounded : Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}