import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This service now focuses on managing user data in Firestore
  // Image uploading has been removed as per user request.

  Future<void> updateUserData(String displayName) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': displayName,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await user.reload();
    }
  }

  Future<void> updateStreak() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (!userDoc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'currentStreak': 1,
        'lastActivityDate': Timestamp.fromDate(today),
        'longestStreak': 1,
        'displayName': user.displayName ?? 'Student',
      }, SetOptions(merge: true));
      return;
    }

    final data = userDoc.data() as Map<String, dynamic>;
    final lastActivityTimestamp = data['lastActivityDate'] as Timestamp?;
    int currentStreak = data['currentStreak'] ?? 0;
    int longestStreak = data['longestStreak'] ?? 0;

    if (lastActivityTimestamp == null) {
      currentStreak = 1;
    } else {
      final lastActivityDate = lastActivityTimestamp.toDate();
      final lastDate = DateTime(lastActivityDate.year, lastActivityDate.month, lastActivityDate.day);
      final difference = today.difference(lastDate).inDays;

      if (difference == 0) {
        // Already updated today
        return;
      } else if (difference == 1) {
        // Consecutive day
        currentStreak++;
      } else {
        // Streak broken
        currentStreak = 1;
      }
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    await _firestore.collection('users').doc(user.uid).update({
      'currentStreak': currentStreak,
      'lastActivityDate': Timestamp.fromDate(today),
      'longestStreak': longestStreak,
    });
  }
}
