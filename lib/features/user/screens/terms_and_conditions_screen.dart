import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    context,
                    title: 'Welcome to Quiz Master',
                    content: 'By using our app, you agree to the following terms and conditions. Please read them carefully to ensure a seamless experience on our academic platform.',
                    icon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('1. ACCEPTANCE OF TERMS'),
                  _buildContentText('By accessing and using this app, you accept and agree to be bound by the terms and provision of this agreement. Use of the service implies full acceptance of all terms listed here.'),
                  const SizedBox(height: 24),
                  _buildSectionHeader('2. USER ACCOUNTS'),
                  _buildContentText('To use certain features, you must register for an account. You agree to provide accurate, current, and complete information and maintain the security of your account credentials.'),
                  const SizedBox(height: 24),
                  _buildSectionHeader('3. USAGE DATA'),
                  _buildContentText('We may collect information on how the app is accessed and used to improve our services and provide a personalized learning experience for every student.'),
                  const SizedBox(height: 24),
                  _buildSectionHeader('4. ACADEMIC INTEGRITY'),
                  _buildContentText('Quiz Master is intended for study and preparation purposes. Users are expected to maintain academic integrity while using AI-generated content.'),
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
                  'TERMS & CONDITIONS',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 24),
          const Icon(Icons.gavel_rounded, size: 60, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required String content, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: AppColors.textGrey, fontWeight: FontWeight.w500, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildContentText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03), // Subtle background for list items
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: AppColors.textGrey, fontWeight: FontWeight.w500, height: 1.6),
      ),
    );
  }
}
