import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../quiz/providers/quiz_provider.dart';
import '../../quiz/services/quiz_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final QuizService _quizService = QuizService();
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _quizService.getLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.wrongRed)));
          }

          final rankings = snapshot.data ?? [];
          if (rankings.isEmpty) {
            return _buildEmptyState(context);
          }

          final top3 = rankings.length >= 3 ? rankings.sublist(0, 3) : rankings;
          final others = rankings.length > 3 ? rankings.sublist(3) : [];

          return Column(
            children: [
              _buildHeader(context, top3),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: others.isEmpty
                      ? const Center(child: Text('No more rankings available.', style: TextStyle(color: AppColors.textGrey)))
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    itemCount: others.length,
                    itemBuilder: (context, index) {
                      final rankData = others[index];
                      return _buildRankItem(context, rankData, index + 4, currentUserId);
                    },
                  ),
                ),
              ),
              _buildMyRankBanner(context, quizProvider, rankings, currentUserId),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context, []),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, size: 80, color: AppColors.textGrey.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text('No rankings yet. Be the first!', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, List<Map<String, dynamic>> top3) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
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
                  'GLOBAL RANKINGS',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 24),
          if (top3.isNotEmpty) _buildPodium(context, top3),
        ],
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<Map<String, dynamic>> top3) {
    List<Map<String, dynamic>> orderedPodium = [];
    if (top3.length >= 2) orderedPodium.add(top3[1]); // 2nd
    if (top3.isNotEmpty) orderedPodium.add(top3[0]); // 1st
    if (top3.length >= 3) orderedPodium.add(top3[2]); // 3rd

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(orderedPodium.length, (index) {
        final data = orderedPodium[index];
        final rank = top3.indexOf(data) + 1;

        double pedestalHeight = 60;
        double avatarSize = 30;
        Color medalColor = const Color(0xFFCD7F32); // Bronze
        IconData medalIcon = Icons.military_tech_rounded;

        if (rank == 1) {
          pedestalHeight = 100;
          avatarSize = 40;
          medalColor = const Color(0xFFFFD700); // Gold
          medalIcon = Icons.emoji_events_rounded;
        } else if (rank == 2) {
          pedestalHeight = 80;
          avatarSize = 34;
          medalColor = const Color(0xFFC0C0C0); // Silver
          medalIcon = Icons.workspace_premium_rounded;
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildPodiumSpot(context, data, rank,
                pedestalHeight: pedestalHeight,
                avatarSize: avatarSize,
                medalColor: medalColor,
                medalIcon: medalIcon
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPodiumSpot(BuildContext context, Map<String, dynamic> data, int rank, {
    required double pedestalHeight,
    required double avatarSize,
    required Color medalColor,
    required IconData medalIcon
  }) {
    String initials = (data['name'] ?? '?')[0].toUpperCase();
    String? photoUrl = data['photoURL'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: medalColor, width: rank == 1 ? 4 : 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: CircleAvatar(
                  radius: avatarSize,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Text(initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: avatarSize * 0.8))
                      : null,
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(medalIcon, color: medalColor, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          data['name'] ?? 'Unknown',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
        ),
        Text(
          '${data['totalXP'] ?? 0} XP',
          style: TextStyle(fontWeight: FontWeight.w900, color: medalColor, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Container(
          height: pedestalHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: rank == 1 ? 0.25 : 0.15),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: rank == 1 ? 28 : 22),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankItem(BuildContext context, Map<String, dynamic> data, int rank, String? currentUserId) {
    bool isMe = data['uid'] == currentUserId;
    final theme = Theme.of(context);
    String initials = (data['name'] ?? '?')[0].toUpperCase();
    String? photoUrl = data['photoURL'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isMe ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textGrey, fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'Anonymous',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${data['quizzesTaken'] ?? 0} Quizzes Completed',
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            '${data['totalXP'] ?? 0}',
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 18),
          ),
          const SizedBox(width: 4),
          const Text('XP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _buildMyRankBanner(BuildContext context, QuizProvider provider, List<Map<String, dynamic>> rankings, String? currentUserId) {
    final myRankIndex = rankings.indexWhere((element) => element['uid'] == currentUserId);
    final myRank = myRankIndex != -1 ? myRankIndex + 1 : 0;
    final myData = myRankIndex != -1 ? rankings[myRankIndex] : null;
    String? myPhotoUrl = FirebaseAuth.instance.currentUser?.photoURL;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Text(
                myRank != 0 ? '#$myRank' : '-',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              backgroundImage: myPhotoUrl != null ? NetworkImage(myPhotoUrl) : null,
              child: myPhotoUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your Rank',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  Text(
                    myRank != 0 ? 'Keep up the momentum!' : 'Take a quiz to see your rank!',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${myData?['totalXP'] ?? 0}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
                ),
                const Text('TOTAL XP', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
