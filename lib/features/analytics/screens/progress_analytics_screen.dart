import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../quiz/providers/quiz_provider.dart';

class ProgressAnalyticsScreen extends StatelessWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: quizProvider.quizHistory.isEmpty
                ? _buildEmptyState(context)
                : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryStats(context, quizProvider),
                  const SizedBox(height: 36),
                  _buildSectionHeader('SUBJECT MASTERY'),
                  const SizedBox(height: 20),
                  _buildSubjectMastery(context, quizProvider),
                  const SizedBox(height: 36),
                  _buildSectionHeader('RECENT TRENDS'),
                  const SizedBox(height: 20),
                  _buildRecentTrends(context, quizProvider),
                  const SizedBox(height: 40),
                ],
              ),
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
      child: const Column(
        children: [
          Text(
            'PERFORMANCE ANALYTICS',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          SizedBox(height: 20),
          Icon(Icons.analytics_rounded, size: 60, color: Colors.white),
        ],
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
            child: Icon(Icons.analytics_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          const SizedBox(height: 24),
          const Text(
            'NO DATA YET',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Complete some quizzes to see your personalized performance analytics and subject mastery.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context, QuizProvider quizProvider) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, 'Quizzes', quizProvider.totalQuizzesTaken.toString(), Icons.assignment_turned_in_rounded, AppColors.primary)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, 'Total XP', quizProvider.totalXP.toString(), Icons.bolt_rounded, AppColors.secondary)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, 'Accuracy', '${(quizProvider.averageAccuracy * 100).toInt()}%', Icons.track_changes_rounded, AppColors.accent)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.5),
    );
  }

  Widget _buildSubjectMastery(BuildContext context, QuizProvider quizProvider) {
    Map<String, List<double>> subjectData = {};
    for (var quiz in quizProvider.quizHistory) {
      String title = quiz['title'] ?? 'Other';
      double accuracy = (int.parse(quiz['score']) / int.parse(quiz['total']));
      subjectData.putIfAbsent(title, () => []).add(accuracy);
    }

    return Column(
      children: subjectData.entries.map((entry) {
        double avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('${(avg * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: avg,
                  minHeight: 10,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentTrends(BuildContext context, QuizProvider quizProvider) {
    final recent = quizProvider.quizHistory.take(5).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.length,
      itemBuilder: (context, index) {
        final quiz = recent[index];
        double accuracy = (int.parse(quiz['score']) / int.parse(quiz['total']));

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (accuracy >= 0.8 ? AppColors.correctGreen : (accuracy >= 0.6 ? AppColors.accent : AppColors.wrongRed)).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  accuracy >= 0.8 ? Icons.trending_up_rounded : (accuracy >= 0.6 ? Icons.trending_flat_rounded : Icons.trending_down_rounded),
                  color: accuracy >= 0.8 ? AppColors.correctGreen : (accuracy >= 0.6 ? AppColors.accent : AppColors.wrongRed),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quiz['title'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(quiz['date'], style: const TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${quiz['score']}/${quiz['total']}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const Text('SCORE', style: TextStyle(color: AppColors.textGrey, fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
