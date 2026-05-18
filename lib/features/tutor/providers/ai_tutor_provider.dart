import 'package:flutter/material.dart';
import '../services/ai_tutor_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AITutorProvider extends ChangeNotifier {
  final AITutorService _tutorService = AITutorService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  AITutorProvider() {
    // Initial greeting
    _messages.add(ChatMessage(
      text: "Hello! I'm your AI Tutor. How can I help you with your studies today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    try {
      final chatHistory = _messages.map((m) => {
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text,
      }).toList();

      final response = await _tutorService.getTutorResponse(chatHistory);

      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        text: "Sorry, I'm having trouble connecting. Error: $e",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessage(
      text: "Chat cleared. How can I help you now?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}
