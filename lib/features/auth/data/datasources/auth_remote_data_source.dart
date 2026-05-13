import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      log('Sign-in failed: ${e.code} — ${e.message}');
      throw _mapFirebaseException(e);
    }
  }

  Future<User> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      log('Sign-up failed: ${e.code} — ${e.message}');
      throw _mapFirebaseException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      log('Password reset failed: ${e.code} — ${e.message}');
      throw _mapFirebaseException(e);
    }
  }

  Exception _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No account found for that email.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'invalid-credential':
        return Exception('Invalid email or password.');
      case 'email-already-in-use':
        return Exception('An account already exists for that email.');
      case 'weak-password':
        return Exception('Password must be at least 6 characters.');
      case 'invalid-email':
        return Exception('Please enter a valid email address.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      default:
        return Exception(e.message ?? 'Authentication failed.');
    }
  }
}
