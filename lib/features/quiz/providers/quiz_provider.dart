import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/quiz_settings.dart';
import '../services/quiz_service.dart';
import '../services/groq_ai_service.dart';

class QuizProvider extends ChangeNotifier {
  final QuizService _quizService = QuizService();
  final GroqAIService _groqService = GroqAIService();

  QuizSettings _settings = QuizSettings();
  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  List<int?> _userAnswers = [];
  String? _errorMessage;

  QuizSettings get settings => _settings;
  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get isAnswered => _isAnswered;
  List<int?> get userAnswers => _userAnswers;
  String? get errorMessage => _errorMessage;

  QuestionModel get currentQuestion => _questions[_currentIndex];
  bool get isLastQuestion => _currentIndex == _questions.length - 1;

  void updateSettings(QuizSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  Future<void> loadQuestions(String subjectTitle) async {
    _isLoading = true;
    _currentIndex = 0;
    _score = 0;
    _selectedOptionIndex = null;
    _isAnswered = false;
    _userAnswers = [];
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. If user entered a specific TOPIC, use specialized Groq AI (Llama 3)
      if (_settings.topic != null && _settings.topic!.isNotEmpty) {
        _questions = await _groqService.generateQuestions(
          source: _settings.topic!,
          count: _settings.questionCount,
        );
      } 
      // 2. Standard Subject - Use Groq AI
      else {
        _questions = await _groqService.generateQuestions(
          source: subjectTitle,
          count: _settings.questionCount,
        );
      }
    } catch (e) {
      debugPrint('AI Generation Error, falling back to Firebase Library: $e');
      try {
        _questions = await _quizService.getQuestionsForSubject(subjectTitle);
      } catch (firebaseError) {
        debugPrint('Firebase fallback failed: $firebaseError');
        _questions = await _quizService.getQuestionsForSubject('General');
      }
    }

    if (_questions.length > _settings.questionCount) {
      _questions = _questions.sublist(0, _settings.questionCount);
    }

    _userAnswers = List.filled(_questions.length, null);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAIQuestionsFromText(String text) async {
    _isLoading = true;
    _currentIndex = 0;
    _score = 0;
    _isAnswered = false;
    _userAnswers = [];
    _errorMessage = null;
    notifyListeners();

    try {
      _questions = await _groqService.generateQuestions(
        source: text,
        count: _settings.questionCount,
        isFile: true,
      );
      _userAnswers = List.filled(_questions.length, null);
    } catch (e) {
      debugPrint('Groq Parse Error: $e');
      _errorMessage = "AI generation failed. Please try again or use a different file.";
      _questions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectOption(int index) {
    if (_isAnswered) return;
    _selectedOptionIndex = index;
    notifyListeners();
  }

  void submitAnswer() {
    if (_selectedOptionIndex == null || _isAnswered) return;

    _isAnswered = true;
    _userAnswers[_currentIndex] = _selectedOptionIndex;
    if (_selectedOptionIndex == currentQuestion.correctOptionIndex) {
      _score++;
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _selectedOptionIndex = _userAnswers.length > _currentIndex ? _userAnswers[_currentIndex] : null;
      _isAnswered = _selectedOptionIndex != null;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0 && _settings.allowBack) {
      _currentIndex--;
      _selectedOptionIndex = _userAnswers[_currentIndex];
      _isAnswered = true;
      notifyListeners();
    }
  }

  final List<Map<String, dynamic>> _quizHistory = [];
  List<Map<String, dynamic>> get quizHistory => _quizHistory;

  Future<void> finishQuiz(String userId, String subjectTitle) async {
    String status = 'Needs Work';
    double percentage = _questions.isEmpty ? 0 : _score / _questions.length;
    if (percentage >= 0.8) {
      status = 'Excellent';
    } else if (percentage >= 0.6) {
      status = 'Good';
    }

    _quizHistory.insert(0, {
      'title': subjectTitle,
      'date': DateTime.now().toString().substring(0, 10),
      'score': _score.toString(),
      'total': _questions.length.toString(),
      'status': status,
      'questions': List<QuestionModel>.from(_questions),
      'userAnswers': List<int?>.from(_userAnswers),
    });
    notifyListeners();

    try {
      await _quizService.saveQuizResult(userId, subjectTitle, _score, _questions.length);
    } catch (e) {
      debugPrint('Firebase save error: $e');
    }
  }

  void clearHistory() {
    _quizHistory.clear();
    notifyListeners();
  }

  int get totalXP {
    int total = 0;
    for (var quiz in _quizHistory) {
      total += int.parse(quiz['score'] ?? '0') * 10;
    }
    return total;
  }

  int get currentLevel => (totalXP / 100).floor() + 1;
  double get levelProgress => (totalXP % 100) / 100;

  String get userRank {
    int xp = totalXP;
    if (xp >= 2000) return 'Diamond';
    if (xp >= 1000) return 'Platinum';
    if (xp >= 500) return 'Gold';
    if (xp >= 200) return 'Silver';
    return 'Bronze';
  }

  int get totalQuizzesTaken => _quizHistory.length;

  double get averageAccuracy {
    if (_quizHistory.isEmpty) return 0.0;
    double totalPercentage = 0;
    for (var quiz in _quizHistory) {
      int score = int.parse(quiz['score'] ?? '0');
      int total = int.parse(quiz['total'] ?? '1');
      totalPercentage += score / total;
    }
    return totalPercentage / _quizHistory.length;
  }
}
