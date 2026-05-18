import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- REGISTER USER ---
  Future<String?> registerUser({required String email, required String password, required String name}) async {
    try {
      // 1. Create the User in Firebase
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Initialize Firestore Profile
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'totalXP': 0,
        'quizzesTaken': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Update Display Name and Send Verification
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.sendEmailVerification();

      await _auth.signOut();

      return null; // Success!
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'An account already exists for this email.';
      }
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    }
  }

  // --- LOGIN USER ---
  Future<String?> loginUser({required String email, required String password}) async {
    try {
      // 1. Sign In
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Check Verification Status
      if (credential.user != null && !credential.user!.emailVerified) {

        try { await credential.user?.sendEmailVerification(); } catch (_) {}

        await _auth.signOut();

        return 'Verification required! We just sent a new link to your inbox. Please click it before logging in.';
      }

      return null; // Success! Verified and Logged in.
    } on FirebaseAuthException catch (e) {

      if (e.code == 'invalid-credential' || e.code == 'wrong-password' || e.code == 'user-not-found') {
        return 'Incorrect email or password. Please double-check what you typed.';
      }
      return e.message ?? 'Unknown Firebase Error: ${e.code}';
    } catch (e) {
      return 'Unexpected Error: ${e.toString()}';
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
  }
}
