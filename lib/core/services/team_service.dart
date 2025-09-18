import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sales_bets/models/team_model.dart';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // A stream to get all teams in real-time.
  Stream<List<Team>> getTeamsStream() {
    return _firestore.collection('teams').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Team.fromMap(doc.data())).toList();
    });
  }

  // A stream to get a limited list of trending teams.
  Stream<List<Team>> getTrendingTeamsStream() {
    // Queries for the top 5 teams based on 'followerCount'
    return _firestore
        .collection('teams')
        .orderBy('stats.followerCount', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Team.fromMap(doc.data())).toList();
    });
  }

  // A future to get a single team's data.
  Future<Team?> getTeamById(String teamId) async {
    try {
      final doc = await _firestore.collection('teams').doc(teamId).get();
      if (doc.exists) {
        return Team.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      // Handle error gracefully
      return null;
    }
  }

  // Method to add a new team.
  Future<void> addTeam(Team team) async {
    await _firestore.collection('teams').doc(team.id).set(team.toMap());
  }

  // Method to update a team (e.g., when someone follows them).
  Future<void> updateTeam(String teamId, Map<String, dynamic> data) async {
    await _firestore.collection('teams').doc(teamId).update(data);
  }
}