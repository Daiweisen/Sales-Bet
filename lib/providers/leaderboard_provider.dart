import 'package:flutter/material.dart';
import 'package:sales_bets/core/services/leaderboard_service.dart';
import 'package:sales_bets/models/user_model.dart';

class LeaderboardProvider with ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();

  Stream<List<UserProfile>> get leaderboardStream => _leaderboardService.getLeaderboard();
}