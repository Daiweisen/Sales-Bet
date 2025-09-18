import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sales_bets/models/bet_model.dart';

class BettingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new bet document in Firestore and returns its ID.
  Future<String> createBet({required Bet bet}) async {
    try {
      final docRef = _firestore.collection('bets').doc();
      final betWithId = bet.copyWith(id: docRef.id);
      await docRef.set(betWithId.toMap());
      print('Bet created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating bet: $e');
      rethrow;
    }
  }

  /// Updates a specific bet's status and win amount.
  Future<void> updateBet({
    required String betId,
    required String status,
    required double winAmount,
  }) async {
    try {
      await _firestore.collection('bets').doc(betId).update({
        'status': status,
        'winAmount': winAmount,
      });
      print('Bet ID: $betId updated to status: $status with winnings: $winAmount');
    } catch (e) {
      print('Error updating bet: $e');
      rethrow;
    }
  }

  /// Retrieves a stream of bets for a specific user.
  Stream<List<Bet>> getBetsStreamByUserId(String userId) {
    return _firestore
        .collection('bets')
        .where('userId', isEqualTo: userId)
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Bet.fromMap(doc.data()))
            .toList());
  }

  /// Retrieves a one-time list of bets for a specific user.
  Future<List<Bet>> getBetsByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('bets')
          .where('userId', isEqualTo: userId)
          .orderBy('placedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Bet.fromMap(doc.data());
      }).toList();
    } catch (e) {
      print('Error getting bets for user: $e');
      rethrow;
    }
  }
}