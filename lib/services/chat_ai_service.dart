import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service that wraps Google Gemini API for chat functionality.
///
/// API key is loaded from .env file (GEMINI_API_KEY).
/// Each team member should have their own .env with their own key.
/// See .env.example for setup instructions.
class ChatAIService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Models to try in order (primary → fallback).
  static const List<String> _models = [
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ];

  late GenerativeModel _model;
  late ChatSession _chat;
  int _currentModelIndex = 0;

  static final ChatAIService _instance = ChatAIService._internal();
  factory ChatAIService() => _instance;

  static const _systemPrompt =
      '''You are "NextGen Scholars AI" — a friendly, knowledgeable, and professional AI assistant built into the NextGen Scholars mobile app.

Your primary role:
• Help users find, understand, and apply for scholarships worldwide.
• Answer any general knowledge questions the user asks.
• Provide career guidance, study tips, and academic advice.

Behavior rules:
1. Always be helpful, accurate, and encouraging.
2. When users ask about scholarships, provide detailed, actionable information.
3. For general questions (math, science, history, coding, etc.), answer thoroughly.
4. Support both English and Khmer (ខ្មែរ). Reply in the same language the user writes in.
5. Use bullet points, numbered lists, or clear formatting when helpful.
6. If you don't know something, say so honestly and suggest where to find the answer.
7. Keep responses concise but complete — avoid unnecessary filler.
8. Be warm and supportive — many users are students seeking guidance.

You can help with:
• Scholarship search & recommendations
• Application essay/CV/cover letter tips
• Interview preparation
• Deadline tracking advice
• Study abroad guidance
• Academic planning & career guidance
• General knowledge questions on any topic
• Math, science, coding, language learning, etc.

Remember: You are a real AI assistant with broad knowledge. Answer ALL questions to the best of your ability, not just scholarship-related ones.''';

  ChatAIService._internal() {
    _initModel(_models[_currentModelIndex]);
  }

  void _initModel(String modelName) {
    _model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
      systemInstruction: Content.system(_systemPrompt),
    );
    _chat = _model.startChat();
  }

  /// Switch to the next fallback model. Returns true if switched.
  bool _tryNextModel() {
    if (_currentModelIndex < _models.length - 1) {
      _currentModelIndex++;
      _initModel(_models[_currentModelIndex]);
      return true;
    }
    return false;
  }

  /// Send a message and get a streamed response.
  /// Automatically falls back to alternate models on rate-limit errors.
  Stream<String> sendMessageStream(String message) async* {
    final int totalAttempts = _models.length;

    for (int attempt = 0; attempt < totalAttempts; attempt++) {
      try {
        final content = Content.text(message);
        String fullResponse = '';

        await for (final response in _chat.sendMessageStream(content)) {
          final text = response.text;
          if (text != null) {
            fullResponse += text;
            yield fullResponse;
          }
        }

        if (fullResponse.isEmpty) {
          yield 'I apologize, but I couldn\'t generate a response. Please try again.';
        }
        return; // Success
      } catch (e) {
        final errorMsg = e.toString().toLowerCase();
        final isRateLimit = errorMsg.contains('quota') ||
            errorMsg.contains('429') ||
            errorMsg.contains('resource_exhausted') ||
            errorMsg.contains('rate');

        // Try fallback model on rate-limit errors
        if (isRateLimit && _tryNextModel()) {
          yield '⏳ Switching to backup model...';
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }

        if (_apiKey.isEmpty) {
          yield 'API key not set! Copy .env.example to .env and add your Gemini API key.\n\nGet a free key at: https://aistudio.google.com/app/apikey';
        } else if (errorMsg.contains('api_key_invalid') ||
            errorMsg.contains('api key') ||
            errorMsg.contains('invalid_argument')) {
          yield 'API key error. Please check your GEMINI_API_KEY in .env file.\n\nGet a free key at: https://aistudio.google.com/app/apikey';
        } else if (errorMsg.contains('401') || errorMsg.contains('403')) {
          yield 'Authentication error. Your API key may be expired or revoked.';
        } else if (isRateLimit) {
          yield 'The free tier quota is temporarily exhausted. Please wait 1-2 minutes and try again. 🕐';
        } else if (errorMsg.contains('network') ||
            errorMsg.contains('socket') ||
            errorMsg.contains('connection') ||
            errorMsg.contains('failed host lookup')) {
          yield 'No internet connection. Please check your network and try again.';
        } else {
          yield 'Sorry, something went wrong. Please try again.\n\nError: ${e.toString()}';
        }
        return;
      }
    }
  }

  /// Send a message and get a complete response (non-streaming).
  Future<String> sendMessage(String message) async {
    try {
      final content = Content.text(message);
      final response = await _chat.sendMessage(content);
      return response.text ??
          'I couldn\'t generate a response. Please try again.';
    } catch (e) {
      return 'Sorry, something went wrong: ${e.toString()}';
    }
  }

  /// Reset the chat history (start a new conversation).
  /// Also resets to primary model.
  void resetChat() {
    _currentModelIndex = 0;
    _initModel(_models[_currentModelIndex]);
  }
}
