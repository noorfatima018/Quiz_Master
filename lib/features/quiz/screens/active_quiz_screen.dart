import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/quiz_provider.dart';
import 'quiz_result_screen.dart';

class ActiveQuizScreen extends StatefulWidget {
  final String subjectTitle;
  final Color subjectColor;

  const ActiveQuizScreen({
    super.key,
    required this.subjectTitle,
    required this.subjectColor,
  });

  @override
  State<ActiveQuizScreen> createState() => _ActiveQuizScreenState();
}

class _ActiveQuizScreenState extends State<ActiveQuizScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 30;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      _secondsRemaining = quizProvider.settings.timePerQuestion;
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    if (!quizProvider.isAnswered) {
      quizProvider.submitAnswer();
    }
    _goToNext();
  }

  void _handleGoToNext() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    if (quizProvider.isLastQuestion) {
      _finishQuiz();
    } else {
      quizProvider.nextQuestion();
      setState(() {
        _secondsRemaining = quizProvider.settings.timePerQuestion;
      });
      _startTimer();
    }
  }

  void _goToNext() {
    _handleGoToNext();
  }

  void _finishQuiz() {
    _timer?.cancel();
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    quizProvider.finishQuiz(user?.uid ?? 'anonymous', widget.subjectTitle);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          score: quizProvider.score,
          total: quizProvider.questions.length,
          subjectColor: widget.subjectColor,
          subjectTitle: widget.subjectTitle,
          questions: List.from(quizProvider.questions),
          userAnswers: List.from(quizProvider.userAnswers),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [

          Consumer<QuizProvider>(
            builder: (context, quizProvider, child) {
              if (quizProvider.isLoading) return const Center(child: CircularProgressIndicator());
              if (quizProvider.questions.isEmpty) return const Center(child: Text("No questions available."));

              final question = quizProvider.currentQuestion;
              final progress = (quizProvider.currentIndex + 1) / quizProvider.questions.length;

              return Column(
                children: [
                  _buildTopBar(context, quizProvider),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProgressSection(context, progress, quizProvider),
                          const SizedBox(height: 40),

                          // Question Card
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              key: ValueKey(quizProvider.currentIndex),
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: widget.subjectColor.withValues(alpha: 0.1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'QUESTION ${quizProvider.currentIndex + 1}',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : widget.subjectColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    question.text,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Options List
                          ...List.generate(question.options.length, (index) {
                            return _buildOptionTile(context, index, question, quizProvider);
                          }),

                          // AI Explanation Section
                          if (quizProvider.isAnswered) ...[
                            const SizedBox(height: 24),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 20),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'PROFESSOR\'S TIP',
                                          style: TextStyle(
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      question.explanation,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  _buildBottomNavigation(context, quizProvider),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, QuizProvider quizProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, size: 28, color: Colors.white),
            ),
            Expanded(
              child: Text(
                widget.subjectTitle.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, color: Colors.white),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Text(
                '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, double progress, QuizProvider quizProvider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PROGRESS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textGrey.withValues(alpha: 0.6), letterSpacing: 1),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: widget.subjectColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: widget.subjectColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(widget.subjectColor),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(BuildContext context, int index, question, QuizProvider quizProvider) {
    final isSelected = quizProvider.selectedOptionIndex == index;
    final isCorrect = question.correctOptionIndex == index;
    final isAnswered = quizProvider.isAnswered;

    Color tileColor = Colors.transparent;
    Color borderColor = Colors.grey.withValues(alpha: 0.2);

    if (isSelected) {
      tileColor = widget.subjectColor.withValues(alpha: 0.1);
      borderColor = widget.subjectColor;
    }

    if (isAnswered) {
      if (isCorrect) {
        tileColor = AppColors.correctGreen.withValues(alpha: 0.1);
        borderColor = AppColors.correctGreen;
      } else if (isSelected) {
        tileColor = AppColors.wrongRed.withValues(alpha: 0.1);
        borderColor = AppColors.wrongRed;
      }
    }

    return GestureDetector(
      onTap: isAnswered ? null : () => quizProvider.selectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: tileColor == Colors.transparent ? Theme.of(context).cardColor.withValues(alpha: 0.5) : tileColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isSelected || (isAnswered && isCorrect) ? 2 : 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(color: borderColor, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                question.options[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : AppColors.textGrey,
                ),
              ),
            ),
            if (isAnswered && isCorrect)
              const Icon(Icons.check_circle_rounded, color: AppColors.correctGreen)
            else if (isAnswered && isSelected && !isCorrect)
              const Icon(Icons.cancel_rounded, color: AppColors.wrongRed),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, QuizProvider quizProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          if (quizProvider.settings.allowBack && quizProvider.currentIndex > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  quizProvider.previousQuestion();
                  _timer?.cancel();
                  setState(() => _secondsRemaining = quizProvider.settings.timePerQuestion);
                  _startTimer();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.subjectColor.withValues(alpha: 0.5), width: 2),
                ),
                child: const Text('BACK'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: quizProvider.selectedOptionIndex == null
                  ? null
                  : () {
                if (!quizProvider.isAnswered) {
                  quizProvider.submitAnswer();
                  _timer?.cancel();
                } else {
                  _goToNext();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.subjectColor,
                shadowColor: widget.subjectColor.withValues(alpha: 0.4),
              ),
              child: Text(
                !quizProvider.isAnswered
                    ? 'SUBMIT ANSWER'
                    : (quizProvider.isLastQuestion ? 'SEE RESULTS' : 'NEXT QUESTION'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
