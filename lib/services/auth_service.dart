import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proverbs/screens/auth/login_screen.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();

      // Navigate to login screen and clear navigation history
      // This ensures the user can't go back to protected screens
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false, // This removes all previous routes
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      String uid = currentUser!.uid;
      await _firestore.collection('users').doc(uid).delete();
      await currentUser!.delete();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user details from Firestore
  Future<UserModel?> getUserDetails() async {
    try {
      if (currentUser == null) return null;

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }

  // Handle Firebase Auth exceptions with user-friendly messages
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'The email address is already in use.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'requires-recent-login':
          return 'Please log in again before deleting your account.';
        default:
          return 'Authentication error: ${e.message}';
      }
    }
    return 'An error occurred. Please try again.';
  }
}
