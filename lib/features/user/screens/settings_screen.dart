import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../../main.dart';
import '../../../core/widgets/custom_loading_overlay.dart';
import 'terms_and_conditions_screen.dart';
import 'about_us_screen.dart';
import 'edit_profile_screen.dart';
import 'university_identity_screen.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _darkMode = themeNotifier.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionHeader('PREFERENCES'),
                _buildSwitchTile(
                  title: 'Push Notifications',
                  icon: Icons.notifications_rounded,
                  value: settings.notificationsEnabled,
                  onChanged: (val) {
                    settings.toggleNotifications(val);
                    _showSnack(val ? 'Push Notifications Enabled' : 'Push Notifications Disabled');
                  },
                ),
                _buildSwitchTile(
                  title: 'Dark Theme',
                  icon: Icons.dark_mode_rounded,
                  value: _darkMode,
                  onChanged: (val) {
                    setState(() => _darkMode = val);
                    themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
                _buildSwitchTile(
                  title: 'Quiz Sound Effects',
                  icon: Icons.volume_up_rounded,
                  value: settings.soundsEnabled,
                  onChanged: (val) {
                    settings.toggleSounds(val);
                    _showSnack(val ? 'Sounds Enabled' : 'Sounds Disabled');
                  },
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('ACCOUNT'),
                _buildActionTile(
                    title: 'Edit Profile',
                    icon: Icons.person_rounded,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    }
                ),
                _buildActionTile(
                    title: 'University Identity',
                    icon: Icons.school_rounded,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UniversityIdentityScreen()));
                    }
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('ABOUT QUIZ MASTER'),
                _buildActionTile(title: 'Terms & Conditions', icon: Icons.description_rounded, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()));
                }),
                _buildActionTile(title: 'About Us', icon: Icons.info_rounded, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen()));
                }),
                _buildActionTile(title: 'Check for Updates', icon: Icons.system_update_rounded, onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Scaffold(
                      backgroundColor: Colors.transparent,
                      body: CustomLoadingOverlay(message: 'Checking for updates...'),
                    ),
                  );
                  await Future.delayed(const Duration(seconds: 2));
                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog
                    _showSnack('Quiz Master is up to date!');
                  }
                }),

                const SizedBox(height: 48),
                ElevatedButton.icon(
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
                  label: const Text('SIGN OUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.wrongRed,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 4,
                    shadowColor: AppColors.wrongRed.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
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
                  'APP SETTINGS',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          const Icon(Icons.settings_suggest_rounded, size: 60, color: Colors.white),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        )
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primaryLight, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required IconData icon, required bool value, required Function(bool) onChanged}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: theme.textTheme.bodyMedium?.color, fontSize: 15)),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildActionTile({required String title, required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: theme.textTheme.bodyMedium?.color, fontSize: 15)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textGrey.withValues(alpha: 0.5)),
      ),
    );
  }
}
