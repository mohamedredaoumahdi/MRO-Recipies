import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moroccan_recipies_app/utils/admin_helper.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : 
    _auth = auth ?? FirebaseAuth.instance,
    _firestore = firestore ?? FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if this is the admin email (test@test.com)
      bool isAdmin = email.toLowerCase() == 'test@test.com';

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'username': username,
        'isAdmin': isAdmin,
        'uid': userCredential.user!.uid,
      });

      return userCredential;
    } catch (e) {
      throw 'Failed to sign up: $e';
    }
  }

  // Sign In with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Current auth state: ${_auth.currentUser}');
      await signOut();
      
      // Add platform check
      print('Running on: ${Platform.isIOS ? "iOS" : "Android"}');
      
      print('Attempting to sign in with email: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw 'Connection timeout',
      );
      
      print('Sign in successful: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
      throw 'Failed to sign in: ${e.message}';
    } catch (e) {
      print('General Error: $e');
      throw 'Failed to sign in: $e';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update User Profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Check if user is signed in
  bool get isUserSignedIn => currentUser != null;

  // Get user display name
  String? get userDisplayName {
    return _auth.currentUser?.displayName ?? 
           _auth.currentUser?.email?.split('@')[0];
  }

  // Get user email
  String? get userEmail => currentUser?.email;

  // Get user photo URL
  String? get userPhotoURL => currentUser?.photoURL;

  // Get user ID
  String? get userId => currentUser?.uid;

  // Update or add this method
  Future<void> register({
    required String email,
    required String password,
    required String fullName,  // Make sure this is passed from RegisterScreen
  }) async {
    try {
      // Create auth user
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save user data to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to register: ${e.toString()}';
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      final email = user?.email;
      
      if (user == null || email == null) {
        throw 'No user logged in';
      }

      // Reauthenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      
      // Change password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to change password: $e';
    }
  }

  // Add this method for anonymous sign in
  Future<UserCredential> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'isAnonymous': true,
        'createdAt': FieldValue.serverTimestamp(),
        'fullName': 'Guest User',
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Add this method to check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data()?['isAdmin'] ?? false;
  }

  // Add this method to check if a specific user is admin
  Future<bool> isUserAdmin(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc.data()?['isAdmin'] ?? false;
  }

  // Add method to get username from Firestore
  Future<String?> getCurrentUsername() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final doc = await _firestore.collection('users').doc(uid).get();
        return doc.data()?['username'];
      }
      return null;
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }

  Future<String?> getUsernameById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['username'] as String?;
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }
}