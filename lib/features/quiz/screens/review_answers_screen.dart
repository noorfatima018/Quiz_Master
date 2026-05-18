import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/question_model.dart';

class ReviewAnswersScreen extends StatelessWidget {
  final String subjectTitle;
  final List<QuestionModel> questions;
  final List<int?> userAnswers;

  const ReviewAnswersScreen({
    super.key,
    required this.subjectTitle,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Review Answers'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final userAnswerIndex = index < userAnswers.length ? userAnswers[index] : null;
          final isCorrect = userAnswerIndex == question.correctOptionIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCorrect
                    ? AppColors.correctGreen.withValues(alpha: 0.3)
                    : AppColors.wrongRed.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: isDark ? null : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppColors.correctGreen.withValues(alpha: 0.1)
                            : AppColors.wrongRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCorrect ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                        color: isCorrect ? AppColors.correctGreen : AppColors.wrongRed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Question ${index + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(question.options.length, (optIndex) {
                  final isSelected = userAnswerIndex == optIndex;
                  final isActuallyCorrect = question.correctOptionIndex == optIndex;

                  Color bgColor = Colors.transparent;
                  Color borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1);
                  Color textColor = isDark ? AppColors.textOffWhite : AppColors.textNearBlack;
                  IconData? trailingIcon;
                  Color? iconColor;

                  if (isActuallyCorrect) {
                    bgColor = AppColors.correctGreen.withValues(alpha: 0.1);
                    borderColor = AppColors.correctGreen;
                    textColor = AppColors.correctGreen;
                    trailingIcon = Icons.check_circle_rounded;
                    iconColor = AppColors.correctGreen;
                  } else if (isSelected && !isActuallyCorrect) {
                    bgColor = AppColors.wrongRed.withValues(alpha: 0.1);
                    borderColor = AppColors.wrongRed;
                    textColor = AppColors.wrongRed;
                    trailingIcon = Icons.cancel_rounded;
                    iconColor = AppColors.wrongRed;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(color: borderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            question.options[optIndex],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected || isActuallyCorrect ? FontWeight.bold : FontWeight.normal,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) Icon(trailingIcon, color: iconColor, size: 20),
                      ],
                    ),
                  );
                }),
                
                // AI Explanation
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.1), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Explanation',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              question.explanation,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
