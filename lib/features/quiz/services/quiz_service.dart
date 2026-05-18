import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Retrieve questions from Firestore
  Future<List<QuestionModel>> getQuestionsForSubject(String subjectTitle) async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .doc(subjectTitle.toLowerCase())
          .collection('questions')
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          return QuestionModel.fromMap(doc.data(), doc.id);
        }).toList();
      } else {
        // Fallback to mock data if Firestore has no questions for this subject yet
        return _getMockQuestions(subjectTitle);
      }
    } catch (e) {
      debugPrint('Error fetching questions from Firestore: $e');
      return _getMockQuestions(subjectTitle);
    }
  }

  // Retrieve top users for the leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('totalXP', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => {
        'uid': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      return [];
    }
  }

  // Save the result of the quiz to Firestore and update user XP
  Future<void> saveQuizResult(String userId, String subjectTitle, int score, int total) async {
    try {
      final batch = _firestore.batch();
      
      // 1. Add to quiz history
      final historyRef = _firestore.collection('users').doc(userId).collection('quiz_history').doc();
      batch.set(historyRef, {
        'subject': subjectTitle,
        'score': score,
        'total': total,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Update user's total XP and stats
      // Each correct answer gives 10 XP
      int xpGained = score * 10;
      final userRef = _firestore.collection('users').doc(userId);
      
      batch.set(userRef, {
        'totalXP': FieldValue.increment(xpGained),
        'quizzesTaken': FieldValue.increment(1),
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
    }
  }

  List<QuestionModel> _getMockQuestions(String subjectTitle) {
    return [
      QuestionModel(
        id: 'q1',
        text: 'What is a key concept of $subjectTitle?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctOptionIndex: 0,
      ),
      QuestionModel(
        id: 'q2',
        text: 'Which of the following is true about $subjectTitle?',
        options: ['Statement 1', 'Statement 2', 'Statement 3', 'Statement 4'],
        correctOptionIndex: 1,
      ),
      QuestionModel(
        id: 'q3',
        text: 'How does $subjectTitle impact modern applications?',
        options: ['Impact X', 'Impact Y', 'Impact Z', 'None of the above'],
        correctOptionIndex: 2,
      ),
      QuestionModel(
        id: 'q4',
        text: 'In $subjectTitle, what is the best practice?',
        options: ['Practice A', 'Practice B', 'Practice C', 'Practice D'],
        correctOptionIndex: 3,
      ),
      QuestionModel(
        id: 'q5',
        text: 'What is the primary goal of $subjectTitle?',
        options: ['Goal 1', 'Goal 2', 'Goal 3', 'Goal 4'],
        correctOptionIndex: 0,
      ),
    ];
  }
}
