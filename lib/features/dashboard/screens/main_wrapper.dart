import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import 'dashboard_screen.dart';
import '../../user/screens/leaderboard_screen.dart';
import '../../analytics/screens/progress_analytics_screen.dart';
import '../../user/screens/profile_screen.dart';
import '../../user/screens/settings_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../main.dart';
import '../../quiz/screens/quiz_history_screen.dart';
import '../../quiz/providers/quiz_provider.dart';
import '../../user/screens/badges_screen.dart';
import '../../tutor/screens/ai_tutor_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const LeaderboardScreen(),
    const ProgressAnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Premium Global AppBar
      appBar: AppBar(
        title: const Text(
          'QUIZ MASTER',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, themeMode, child) {
              final isDark = themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                onPressed: () {
                  themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
        ],
      ),

      // Professional Drawer for advanced settings and features
      drawer: _buildDrawer(context),

      // Body Content
      body: _pages[_currentIndex],

      // Elegant Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: AppColors.textGrey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: 'Ranks'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Progress'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
                final fullName = user?.displayName ?? 'Student';

                String getInitials(String name) {
                  String cleanName = name.trim();
                  if (cleanName.isEmpty) return '?';
                  List<String> parts = cleanName.split(' ').where((s) => s.isNotEmpty).toList();
                  if (parts.isEmpty) return '?';
                  if (parts.length > 1) {
                    return (parts[0][0] + parts[1][0]).toUpperCase();
                  }
                  return parts[0][0].toUpperCase();
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    setState(() => _currentIndex = 3); // Switch to Profile tab
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? Text(
                            getInitials(fullName),
                            style: const TextStyle(color: AppColors.secondary, fontSize: 24, fontWeight: FontWeight.bold),
                          )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          fullName,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level ${quizProvider.currentLevel} Scholar • ${quizProvider.userRank}',
                          style: const TextStyle(color: AppColors.primarySoftBlue, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _drawerItem(
                  icon: Icons.forum_rounded,
                  title: 'AI Study Tutor',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AITutorScreen()));
                  },
                ),
                _drawerItem(
                  icon: Icons.history_rounded,
                  title: 'Quiz History',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizHistoryScreen()));
                  },
                ),
                _drawerItem(
                    icon: Icons.shield_rounded,
                    title: 'Badges & Rewards',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BadgesScreen()));
                    }
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Divider(color: Color(0xFFE0E0E0)),
                ),
                _drawerItem(
                  icon: Icons.settings_rounded,
                  title: 'App Settings',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
              ],
            ),
          ),

          // Secure Logout logic
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.wrongRed,
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String title, required VoidCallback onTap, bool isToggle = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: AppColors.secondary, size: 26),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 15)),
      trailing: isToggle
          ? Switch(value: true, onChanged: (v){}, activeThumbColor: AppColors.secondary, activeTrackColor: AppColors.secondary.withValues(alpha: 0.5))
          : Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textGrey.withValues(alpha: 0.5)),
      onTap: onTap,
    );
  }
}
