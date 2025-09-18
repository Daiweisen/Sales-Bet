import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user profile in Firestore
        await _createUserProfile(credential.user!, fullName);
        
        // Update display name
        await credential.user!.updateDisplayName(fullName);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(User user, String fullName) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': fullName,
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'wallet': {
        'credits': 1000, // Starting credits
        'totalEarnings': 0,
        'totalBets': 0,
      },
      'stats': {
        'winRate': 0.0,
        'totalWins': 0,
        'followingCount': 0,
        'achievementsCount': 0,
      },
      'preferences': {
        'notifications': true,
        'darkMode': true,
        'language': 'en',
      },
      'achievements': [], // Array of achievement IDs
      'following': [], // Array of team IDs
    });

    // Create initial wallet document
    await _firestore.collection('wallets').doc(user.uid).set({
      'userId': user.uid,
      'credits': 1000,
      'totalEarnings': 0,
      'transactions': [],
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'user-not-found':
        return 'No user found with that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}