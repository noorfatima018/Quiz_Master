import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/question_model.dart';
import '../providers/quiz_provider.dart';
import 'quiz_result_screen.dart';

class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({super.key});

  void _clearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.wrongRed),
            SizedBox(width: 12),
            Text('Clear History', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear all your quiz history? This action cannot be undone.',
          style: TextStyle(fontWeight: FontWeight.w500, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<QuizProvider>().clearHistory();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Quiz history cleared successfully.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.wrongRed,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('CLEAR ALL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<QuizProvider>(
              builder: (context, provider, child) {
                final history = provider.quizHistory;

                if (history.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final score = int.parse(item['score']!);
                    final total = int.parse(item['total']!);
                    final double percentage = total > 0 ? score / total : 0;

                    Color statusColor;
                    if (percentage >= 0.8) {
                      statusColor = AppColors.correctGreen;
                    } else if (percentage >= 0.6) {
                      statusColor = AppColors.accent;
                    } else {
                      statusColor = AppColors.wrongRed;
                    }

                    return _buildHistoryCard(context, item, score, total, percentage, statusColor, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'ASSESSMENT HISTORY',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
              Consumer<QuizProvider>(
                builder: (context, provider, child) {
                  if (provider.quizHistory.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
                      onPressed: () => _clearHistory(context),
                    );
                  }
                  return const SizedBox(width: 48);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Icon(Icons.history_edu_rounded, size: 60, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, dynamic item, int score, int total, double percentage, Color statusColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizResultScreen(
                score: score,
                total: total,
                subjectTitle: item['title'],
                subjectColor: AppColors.primary,
                questions: item['questions'] != null ? List<QuestionModel>.from(item['questions']) : null,
                userAnswers: item['userAnswers'] != null ? List<int?>.from(item['userAnswers']) : null,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 6,
                      backgroundColor: statusColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toInt()}%',
                    style: TextStyle(fontWeight: FontWeight.w900, color: statusColor, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textGrey.withValues(alpha: 0.7)),
                        const SizedBox(width: 6),
                        Text(
                          item['date'],
                          style: TextStyle(fontSize: 13, color: AppColors.textGrey.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textGrey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_toggle_off_rounded, size: 100, color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          const SizedBox(height: 32),
          const Text(
            'NO HISTORY YET',
            style: TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Complete your first assessment to start tracking your academic progress.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 15, fontWeight: FontWeight.w500, height: 1.5),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('TAKE A QUIZ', style: TextStyle(letterSpacing: 1.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}
