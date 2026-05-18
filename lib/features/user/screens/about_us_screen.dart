import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
                  _buildSectionHeader('MEET THE DEVELOPERS'),
                  const SizedBox(height: 20),
                  _buildDeveloperCard(
                    context,
                    name: 'Areeba Arif',
                    rollNo: '23021519-068',
                    role: 'Lead Developer',
                    icon: Icons.code_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildDeveloperCard(
                    context,
                    name: 'Noor Fatima',
                    rollNo: '23021519-007',
                    role: 'UI/UX Designer & Developer',
                    icon: Icons.design_services_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildDeveloperCard(
                    context,
                    name: 'Imtishal Abid',
                    rollNo: '23021519-176',
                    role: 'Backend Developer',
                    icon: Icons.dns_rounded,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('PROJECT INFO'),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    title: 'Version',
                    value: '1.0.0 (Stable)',
                    icon: Icons.info_outline_rounded,
                  ),
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
                  'ABOUT US',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 24),
          const Icon(Icons.school_rounded, size: 70, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'UNIVERSITY OF GUJRAT',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'BS Computer Science | Batch \'23',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context, {required String name, required String rollNo, required String role, required IconData icon}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Roll No: $rollNo', style: const TextStyle(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(role, style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String value, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
        ],
      ),
    );
  }
}
