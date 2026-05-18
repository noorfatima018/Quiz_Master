import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../quiz/screens/quiz_start_screen.dart';
import '../../tutor/screens/ai_tutor_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../user/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _userService.updateStreak();
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
            debugPrint('Dashboard Stream Update: User=${user?.uid}, photoURL=${user?.photoURL}');
            return Stack(
              children: [
                // Background Mesh Gradients
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withValues(alpha: 0.1),
                    ),
                    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container()),
                  ),
                ),

                SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, user),
                      const SizedBox(height: 24),
                      _buildCreationHub(context),
                      const SizedBox(height: 36),
                      _buildLeaderboardBanner(context),
                      const SizedBox(height: 36),
                      _buildSectionHeader(context, 'Quick Subjects'),
                      const SizedBox(height: 24),
                      _buildQuickSubjects(context),
                      const SizedBox(height: 48),
                      _buildAITutorCard(context),
                      const SizedBox(height: 48),
                      _buildDailyChallenge(context),
                    ],
                  ),
                ),
              ],
            );
          }
      ),
    );
  }

  String _getInitials(String name) {
    String cleanName = name.trim();
    if (cleanName.isEmpty) return '?';
    List<String> parts = cleanName.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Widget _buildHeader(BuildContext context, User? user) {
    String fullName = user?.displayName ?? 'Student';
    String firstName = fullName.split(' ')[0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGreeting(), style: const TextStyle(color: AppColors.textGrey, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              firstName,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? Text(
              _getInitials(fullName),
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            )
                : null,
          ),
        )
      ],
    );
  }

  Widget _buildCreationHub(BuildContext context) {
    return Column(
      children: [
        _buildMainToolCard(
          context,
          title: 'Topic Generator',
          description: 'Type any topic and let AI build your perfect quiz in seconds.',
          icon: Icons.psychology_rounded,
          color: AppColors.primary,
          mode: 'Topic',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmallToolCard(
                context,
                title: 'Document Lab',
                subtitle: 'Upload PDF/TXT',
                icon: Icons.upload_file_rounded,
                color: AppColors.primary,
                mode: 'File',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSmallToolCard(
                context,
                title: 'Daily Spark',
                subtitle: 'AI Random Topic',
                icon: Icons.auto_awesome_rounded,
                color: AppColors.primary,
                mode: 'Topic',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainToolCard(BuildContext context, {required String title, required String description, required IconData icon, required Color color, required String mode}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToStart(context, 'AI Genius', icon, color, mode),
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(description, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, height: 1.4, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Icon(icon, color: Colors.white, size: 36),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallToolCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required String mode}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToStart(context, title, icon, color, mode),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: 16),
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSubjects(BuildContext context) {
    final subjects = [
      {'name': 'Algorithms', 'icon': Icons.analytics_rounded, 'color': const Color(0xFF3B82F6)},
      {'name': 'Mobile Dev', 'icon': Icons.phone_android_rounded, 'color': const Color(0xFF8B5CF6)},
      {'name': 'ML', 'icon': Icons.psychology_rounded, 'color': const Color(0xFF10B981)},
      {'name': 'Compilers', 'icon': Icons.code_rounded, 'color': const Color(0xFFF59E0B)},
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final s = subjects[index];
          return GestureDetector(
            onTap: () => _navigateToStart(context, s['name'] as String, s['icon'] as IconData, s['color'] as Color, 'Subject'),
            child: Container(
              width: 100,
              decoration: AppTheme.glassDecoration(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(s['icon'] as IconData, color: s['color'] as Color, size: 30),
                  const SizedBox(height: 12),
                  Text(s['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAITutorCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD946EF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AITutorScreen())),
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Study Tutor', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text('Get instant help, explanations, and study tips from your personal AI assistant.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, height: 1.4, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(Icons.forum_rounded, color: Colors.white, size: 36),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallenge(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, color: AppColors.primary, size: 40),
          const SizedBox(height: 12),
          const Text('SURPRISE CHALLENGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, color: AppColors.secondary)),
          const SizedBox(height: 8),
          const Text('AI will pick a random topic for you to test your knowledge!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _navigateToStart(context, 'Surprise!', Icons.auto_awesome_rounded, AppColors.primary, 'Topic'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('I\'M FEELING LUCKY', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _navigateToStart(BuildContext context, String title, IconData icon, Color color, String mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizStartScreen(
          subjectTitle: title,
          subjectIcon: icon,
          subjectColor: color,
          initialMode: mode,
        ),
      ),
    );
  }

  Widget _buildLeaderboardBanner(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          int streak = 0;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            streak = data['currentStreak'] ?? 0;
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: AppTheme.glassDecoration(context),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Streak: $streak Days',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Theme.of(context).primaryColor),
                      ),
                      Text(
                        streak > 0 ? 'Keep it up! You\'re on fire! 🔥' : 'Start your learning journey today!',
                        style: const TextStyle(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textGrey),
              ],
            ),
          );
        }
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color, letterSpacing: -0.5),
        ),
      ],
    );
  }
}
