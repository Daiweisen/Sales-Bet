// lib/services/leaderboard_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sales_bets/models/user_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a real-time stream of users ranked by total credits.
  Stream<List<UserProfile>> getLeaderboard() {
    return _firestore
        .collection('users')
        .orderBy('credits', descending: true) // Sort by credits
        .limit(50) // Limit to the top 50 users for performance
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromMap(doc.data()))
            .toList());
  }
}