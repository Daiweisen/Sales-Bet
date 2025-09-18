import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> awardBadge(String userId, String badgeId) async {
    final userRef = _firestore.collection('users').doc(userId);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }

      final userData = userSnapshot.data() as Map<String, dynamic>;
      List<String> currentAchievements = List<String>.from(userData['achievements'] ?? []);

      if (!currentAchievements.contains(badgeId)) {
        currentAchievements.add(badgeId);
        transaction.update(userRef, {'achievements': currentAchievements});
      }
    });
  }
}