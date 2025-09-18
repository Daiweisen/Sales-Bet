// lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sales_bets/core/services/acheivement_service.dart';
import 'package:sales_bets/models/User_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AchievementService _achievementService = AchievementService();

  // Internal state to hold the current user's profile data
  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  // Method to get the user ID for other providers
  String? get currentUserId => _currentUser?.uid;

  // Method to fetch the user profile and listen for updates
  void fetchAndListenToUser(String userId) {
    _firestore.collection('users').doc(userId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _currentUser = UserProfile.fromMap(snapshot.data()!);
        notifyListeners();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // New method to check if the user is following a specific team
  bool isFollowingTeam(String teamId) {
    return _currentUser?.following?.contains(teamId) ?? false;
  }

  // New method to add a team to the user's followedTeams list
  Future<void> followTeam(String userId, String teamId) async {
    final userRef = _firestore.collection('users').doc(userId);
    try {
      await userRef.update({
        'followedTeams': FieldValue.arrayUnion([teamId]),
      });
      // Award the badge for following the first team
      await _achievementService.awardBadge(userId, 'first_follow_badge');
    } catch (e) {
      debugPrint('Error following team: $e');
      rethrow;
    }
  }

  // New method to remove a team from the user's followedTeams list
  Future<void> unfollowTeam(String userId, String teamId) async {
    final userRef = _firestore.collection('users').doc(userId);
    try {
      await userRef.update({
        'followedTeams': FieldValue.arrayRemove([teamId]),
      });
    } catch (e) {
      debugPrint('Error unfollowing team: $e');
      rethrow;
    }
  }

  // updateUserCredits method with an isWin flag for clarity
  Future<void> updateUserCredits(String userId, double amount, {required bool isWin}) async {
    final userRef = _firestore.collection('users').doc(userId);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }

      final userData = userSnapshot.data() as Map<String, dynamic>;
      final walletData = userData['wallet'] as Map<String, dynamic>?;

      if (walletData == null) {
        throw Exception("User wallet not found!");
      }

      double currentCredits = (walletData['credits'] ?? 0).toDouble();
      double newCredits;

      if (isWin) {
        newCredits = currentCredits + amount;
      } else {
        newCredits = currentCredits - amount;
        if (newCredits < 0) {
          throw Exception("Insufficient funds to complete this transaction.");
        }
      }

      transaction.update(userRef, {
        'wallet.credits': newCredits,
      });
    });
  }

  // New method to update user statistics
  Future<void> updateUserStats({
    required String userId,
    int totalBets = 0,
    int totalWins = 0,
    int totalLosses = 0,
    double totalStaked = 0.0,
    double totalEarnings = 0.0,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);

    // Use a transaction for atomic updates to prevent race conditions
    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }

      Map<String, dynamic> updates = {};
      
      // We use FieldValue.increment() to atomically update the numbers
      if (totalBets != 0) {
        updates['stats.totalBets'] = FieldValue.increment(totalBets);
      }
      if (totalWins != 0) {
        updates['stats.totalWins'] = FieldValue.increment(totalWins);
      }
      if (totalLosses != 0) {
        updates['stats.totalLosses'] = FieldValue.increment(totalLosses);
      }
      if (totalStaked != 0.0) {
        updates['stats.totalStaked'] = FieldValue.increment(totalStaked);
      }
      if (totalEarnings != 0.0) {
        updates['stats.totalEarnings'] = FieldValue.increment(totalEarnings);
      }

      if (updates.isNotEmpty) {
        transaction.update(userRef, updates);
      }
    });
  }

  // Corrected method to get a real-time stream of the user's data
  Stream<UserProfile?> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      
      return UserProfile.fromMap(snapshot.data()!);
    });
  }
}