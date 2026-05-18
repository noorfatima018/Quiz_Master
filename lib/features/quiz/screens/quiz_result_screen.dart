import 'dart:ui';
import 'package:flutter/material.dart';
import '../../dashboard/screens/main_wrapper.dart';
import '../../../core/theme/app_theme.dart';
import '../models/question_model.dart';
import 'review_answers_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final Color subjectColor;
  final String subjectTitle;
  final List<QuestionModel>? questions;
  final List<int?>? userAnswers;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.subjectColor,
    required this.subjectTitle,
    this.questions,
    this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? score / total : 0;

    String feedbackTitle = '';
    String feedbackSubtitle = '';
    IconData trophyIcon;
    Color statusColor;

    if (percentage >= 0.8) {
      feedbackTitle = 'EXCELLENT!';
      feedbackSubtitle = 'You\'ve mastered this topic perfectly.';
      trophyIcon = Icons.emoji_events_rounded;
      statusColor = AppColors.correctGreen;
    } else if (percentage >= 0.6) {
      feedbackTitle = 'WELL DONE!';
      feedbackSubtitle = 'Great effort! Just a few bits to polish.';
      trophyIcon = Icons.stars_rounded;
      statusColor = AppColors.primary;
    } else {
      feedbackTitle = 'KEEP IT UP!';
      feedbackSubtitle = 'Reviewing the material will help you improve.';
      trophyIcon = Icons.psychology_rounded;
      statusColor = AppColors.wrongRed;
    }

    return Scaffold(
      body: Stack(
        children: [

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'ASSESSMENT COMPLETE',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 48),

                  // Trophy Reveal
                  _buildTrophyReveal(context, trophyIcon, statusColor),

                  const SizedBox(height: 32),
                  Text(
                    feedbackTitle,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: -1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedbackSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGrey, fontSize: 15),
                  ),

                  const SizedBox(height: 48),

                  // Score Gauge
                  _buildScoreGauge(context, percentage, statusColor),

                  const SizedBox(height: 48),

                  // Stats Grid
                  _buildStatsGrid(context),

                  const SizedBox(height: 48),

                  // Actions
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyReveal(BuildContext context, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Icon(icon, size: 80, color: color),
    );
  }

  Widget _buildScoreGauge(BuildContext context, double percentage, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ACCURACY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: AppColors.textGrey)),
              Text('${(percentage * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(context, 'CORRECT', score.toString(), AppColors.correctGreen),
        const SizedBox(width: 16),
        _buildStatCard(context, 'WRONG', (total - score).toString(), AppColors.wrongRed),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, color: color)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            if (questions == null || userAnswers == null) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewAnswersScreen(
                  subjectTitle: subjectTitle,
                  questions: questions!,
                  userAnswers: userAnswers!,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('REVIEW ANSWERS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainWrapper()),
                  (route) => false,
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 64),
            side: const BorderSide(color: AppColors.textGrey, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('BACK TO HOME', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, color: AppColors.textGrey)),
        ),
      ],
    );
  }
}
