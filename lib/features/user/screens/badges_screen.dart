import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> badges = [
      {
        'title': 'Quick Starter',
        'description': 'Completed your first quiz!',
        'icon': Icons.flash_on_rounded,
        'color': Colors.orange,
        'unlocked': true,
      },
      {
        'title': 'Perfect 10',
        'description': 'Got a 100% score in any quiz.',
        'icon': Icons.star_rounded,
        'color': Colors.amber,
        'unlocked': true,
      },
      {
        'title': 'Night Owl',
        'description': 'Completed a quiz after midnight.',
        'icon': Icons.dark_mode_rounded,
        'color': Colors.indigo,
        'unlocked': false,
      },
      {
        'title': 'Subject Master',
        'description': 'Ace 5 quizzes in one subject.',
        'icon': Icons.workspace_premium_rounded,
        'color': Colors.purple,
        'unlocked': true,
      },
      {
        'title': 'Streak King',
        'description': 'Maintain a 7-day quiz streak.',
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.red,
        'unlocked': false,
      },
      {
        'title': 'AI Explorer',
        'description': 'Generated 10 quizzes using AI.',
        'icon': Icons.auto_awesome_rounded,
        'color': Colors.blue,
        'unlocked': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('BADGES & REWARDS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          final isUnlocked = badge['unlocked'] as bool;

          return Container(
            decoration: AppTheme.glassDecoration(context).copyWith(
              color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.05),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: (badge['color'] as Color).withValues(alpha: isUnlocked ? 0.2 : 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(
                      badge['icon'] as IconData,
                      size: 40,
                      color: isUnlocked ? (badge['color'] as Color) : Colors.grey.withValues(alpha: 0.4),
                    ),
                    if (!isUnlocked)
                      const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  badge['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    badge['description'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isUnlocked ? AppColors.textGrey : Colors.grey.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
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
