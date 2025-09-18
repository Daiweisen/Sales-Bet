import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sales_bets/models/User_model.dart';
import 'package:sales_bets/models/bet_model.dart';
import 'package:sales_bets/models/chat_model.dart';
import 'package:sales_bets/models/even_model.dart';
import 'package:sales_bets/models/team_model.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  CollectionReference get usersCollection => _db.collection('users');
  CollectionReference get teamsCollection => _db.collection('teams');
  CollectionReference get eventsCollection => _db.collection('events');
  CollectionReference get betsCollection => _db.collection('bets');
  CollectionReference get walletsCollection => _db.collection('wallets');
  CollectionReference get messagesCollection => _db.collection('messages');


  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await usersCollection.doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }


  Stream<List<Team>> getTeams({int limit = 20}) {
    return teamsCollection
        .orderBy('stats.totalEarnings', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Team.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<Team>> getTrendingTeams({int limit = 10}) {
    return teamsCollection
        .orderBy('stats.followerCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Team.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<Team?> getTeam(String teamId) async {
    try {
      final doc = await teamsCollection.doc(teamId).get();
      if (doc.exists) {
        return Team.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get team: $e');
    }
  }

  Future<void> followTeam(String userId, String teamId) async {
    try {
      final batch = _db.batch();

      // Add to user's following list
      batch.update(usersCollection.doc(userId), {
        'following': FieldValue.arrayUnion([teamId]),
        'stats.followingCount': FieldValue.increment(1),
      });

      // Increment team's follower count
      batch.update(teamsCollection.doc(teamId), {
        'stats.followerCount': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to follow team: $e');
    }
  }

  Future<void> unfollowTeam(String userId, String teamId) async {
    try {
      final batch = _db.batch();

      // Remove from user's following list
      batch.update(usersCollection.doc(userId), {
        'following': FieldValue.arrayRemove([teamId]),
        'stats.followingCount': FieldValue.increment(-1),
      });

      // Decrement team's follower count
      batch.update(teamsCollection.doc(teamId), {
        'stats.followerCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to unfollow team: $e');
    }
  }

  // Event Operations
  Stream<List<Event>> getActiveEvents({int limit = 20}) {
    return eventsCollection
        .where('status', isEqualTo: 'active')
        .orderBy('startDate', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<Event>> getEventsForTeam(String teamId, {int limit = 10}) {
    return eventsCollection
        .where('participatingTeams', arrayContains: teamId)
        .orderBy('startDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<Event?> getEvent(String eventId) async {
    try {
      final doc = await eventsCollection.doc(eventId).get();
      if (doc.exists) {
        return Event.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  Future<String> placeBet({
    required String userId,
    required String eventId,
    required String teamId,
    required int credits,
    required double odds,
    required int amount,
  }) async {
    try {
      final batch = _db.batch();
      
      final betId = _db.collection('bets').doc().id;
      final bet = Bet(
        id: betId,
        userId: userId,
        eventId: eventId,
        teamId: teamId,
        odds: odds,
        status: 'pending',
        placedAt: DateTime.now(), amount: amount,
      );

      // Create bet document
      batch.set(betsCollection.doc(betId), bet.toMap());

      // Update user stats
      batch.update(usersCollection.doc(userId), {
        'wallet.totalBets': FieldValue.increment(1),
        'stats.totalBets': FieldValue.increment(1),
      });

      await batch.commit();
      return betId;
    } catch (e) {
      throw Exception('Failed to place bet: $e');
    }
  }

  Stream<List<Bet>> getUserBets(String userId, {int limit = 20}) {
    return betsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('placedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Bet.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> resolveBet(String betId, bool isWin, int winAmount) async {
    try {
      final batch = _db.batch();

      // Update bet status
      batch.update(betsCollection.doc(betId), {
        'status': isWin ? 'won' : 'lost',
        'winAmount': isWin ? winAmount : 0,
        'resolvedAt': FieldValue.serverTimestamp(),
      });

      if (isWin) {
        // Get bet details to update user wallet
        final betDoc = await betsCollection.doc(betId).get();
        final bet = Bet.fromMap(betDoc.data() as Map<String, dynamic>);

        // Update user wallet and stats
        batch.update(usersCollection.doc(bet.userId), {
          'wallet.credits': FieldValue.increment(winAmount),
          'wallet.totalEarnings': FieldValue.increment(winAmount),
          'stats.totalWins': FieldValue.increment(1),
        });

        // Update wallet document
        batch.update(walletsCollection.doc(bet.userId), {
          'credits': FieldValue.increment(winAmount),
          'totalEarnings': FieldValue.increment(winAmount),
          'transactions': FieldValue.arrayUnion([{
            'type': 'win',
            'amount': winAmount,
            'betId': betId,
            'timestamp': FieldValue.serverTimestamp(),
          }]),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to resolve bet: $e');
    }
  }

  // Chat Operations
  Future<void> sendMessage({
    required String eventId,
    required String userId,
    required String userName,
    required String message,
    String? userAvatar,
  }) async {
    try {
      final messageDoc = messagesCollection.doc();
      final chatMessage = ChatMessage(
        id: messageDoc.id,
        eventId: eventId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        message: message,
        timestamp: DateTime.now(),
      );

      await messageDoc.set(chatMessage.toMap());
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<ChatMessage>> getEventMessages(String eventId, {int limit = 100}) {
    return messagesCollection
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Wallet Operations
  Future<Map<String, dynamic>?> getWallet(String userId) async {
    try {
      final doc = await walletsCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  // Achievement Operations
  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      await usersCollection.doc(userId).update({
        'achievements': FieldValue.arrayUnion([achievementId]),
        'stats.achievementsCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to unlock achievement: $e');
    }
  }

  // Leaderboard Operations
  Stream<List<UserProfile>> getTopEarners({int limit = 10}) {
    return usersCollection
        .orderBy('wallet.totalEarnings', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<Team>> getTeamLeaderboard({int limit = 10}) {
    return teamsCollection
        .orderBy('stats.totalEarnings', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Team.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Seed demo data
  Future<void> seedDemoData() async {
    try {
      final batch = _db.batch();

      // Demo teams
      final demoTeams = [
        {
          'id': 'team_1',
          'name': 'Sales Sharks',
          'description': 'Aggressive sales team with proven track record',
          'logoUrl': 'https://example.com/logos/sharks.png',
          'category': 'Sales',
          'stats': {
            'totalEarnings': 125000,
            'followerCount': 1250,
            'winRate': 0.78,
            'totalChallenges': 45,
          },
          'members': ['John Smith', 'Sarah Johnson', 'Mike Chen'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'team_2',
          'name': 'Marketing Mavericks',
          'description': 'Creative marketing team disrupting the industry',
          'logoUrl': 'https://example.com/logos/mavericks.png',
          'category': 'Marketing',
          'stats': {
            'totalEarnings': 98000,
            'followerCount': 980,
            'winRate': 0.72,
            'totalChallenges': 38,
          },
          'members': ['Emma Davis', 'Alex Rodriguez', 'Lisa Wong'],
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (final team in demoTeams) {
        batch.set(teamsCollection.doc(team['id'] as String), team);
      }

      // Demo events
      final demoEvents = [
        {
          'id': 'event_1',
          'title': 'Q4 Sales Challenge',
          'description': 'Race to close the most deals in Q4',
          'category': 'Sales',
          'status': 'active',
          'startDate': DateTime.now(),
          'endDate': DateTime.now().add(const Duration(days: 30)),
          'participatingTeams': ['team_1', 'team_2'],
          'totalPot': 50000,
          'streamUrl': 'https://example.com/stream/q4-challenge',
          'isLive': true,
          'viewerCount': 245,
        },
      ];

      for (final event in demoEvents) {
        batch.set(eventsCollection.doc(event['id'] as String), event);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to seed demo data: $e');
    }
  }
}