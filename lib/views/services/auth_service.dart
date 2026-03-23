// ============================================================
// FILE: lib/services/auth_service.dart
// PURPOSE: Login, Register, Logout using Firebase Auth
//          Also saves user info to Firestore "users" collection
//
// Firestore path: users/{uid}
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Get the Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get the currently logged-in user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  // Stream that tells us when login state changes
  // Used in main.dart to show login or home screen
  Stream<User?> get authChanges => _auth.authStateChanges();

  // ----------------------------------------------------------
  // REGISTER - Create a new account
  // ----------------------------------------------------------
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // Step 1: Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Save extra info (name, phone) to Firestore
      // Firebase Auth only stores email/password, so we save more in Firestore
      await _db.collection('users').doc(result.user!.uid).set({
        'name':  name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // null means success (no error)

    } on FirebaseAuthException catch (e) {
      // Return a user-friendly error message
      if (e.code == 'email-already-in-use') return 'This email is already registered.';
      if (e.code == 'weak-password')        return 'Password must be at least 6 characters.';
      if (e.code == 'invalid-email')        return 'Please enter a valid email.';
      return 'Registration failed. Please try again.';
    }
  }

  // ----------------------------------------------------------
  // LOGIN - Sign in with existing account
  // ----------------------------------------------------------
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // null means success

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'No account found for this email.';
      if (e.code == 'wrong-password') return 'Incorrect password.';
      if (e.code == 'invalid-email')  return 'Please enter a valid email.';
      return 'Login failed. Please try again.';
    }
  }

  // ----------------------------------------------------------
  // LOGOUT - Sign out
  // ----------------------------------------------------------
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ----------------------------------------------------------
  // GET USER NAME from Firestore
  // ----------------------------------------------------------
  Future<String> getUserName() async {
    if (currentUser == null) return 'Guest';
    try {
      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists) {
        return doc['name'] ?? 'User';
      }
      return 'User';
    } catch (e) {
      return 'User';
    }
  }
}