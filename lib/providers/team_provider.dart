import 'package:flutter/material.dart';
import 'package:sales_bets/core/services/team_service.dart';
import 'package:sales_bets/models/team_model.dart';

class TeamsProvider extends ChangeNotifier {
  final TeamService _teamService;
  
  TeamsProvider(this._teamService);

  // Stream to get all teams, useful for a full Teams/Athletes page.
  Stream<List<Team>> get teams {
    return _teamService.getTeamsStream();
  }

  // Stream to get a limited list of trending teams for the home screen.
  Stream<List<Team>> get trendingTeams {
    return _teamService.getTrendingTeamsStream();
  }

  // A future to get a single team by its ID (for the detailed team screen).
  Future<Team?> getTeamById(String teamId) {
    return _teamService.getTeamById(teamId);
  }
}