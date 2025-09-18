// lib/views/Team/team_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_bets/core/utils/app_theme.dart';
import 'package:sales_bets/models/team_model.dart';
import 'package:intl/intl.dart';
import 'package:sales_bets/providers/team_provider.dart';
import 'package:sales_bets/providers/user_provider.dart';
import 'package:sales_bets/views/Betting/betting_screen.dart';

class TeamScreen extends StatefulWidget {
  final String teamId;
  final String eventId;

  const TeamScreen({Key? key, required this.teamId, required this.eventId}) : super(key: key);

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  // Local state to manage the button's text
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teamsProvider = context.read<TeamsProvider>();
    
    // QUICK FIX FOR PRESENTATION: AVOID LOGIN CHECK
    final userId = 'dummy_user_id'; 

    return Scaffold(
      body: FutureBuilder<Team?>(
        future: teamsProvider.getTeamById(widget.teamId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Team not found.'));
          }

          final team = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTeamHeader(context, theme, team, userId),
                _buildTeamStats(theme, team.stats),
                _buildSectionTitle(theme, 'Team Members'),
                _buildMembersList(theme, team.members),
                _buildSectionTitle(theme, 'Achievements'),
                _buildEmptyState(theme, 'No achievements yet.'),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BettingScreen(
                            eventId: widget.eventId,
                          ),
                        ),
                      );
                    },
                    child: const Text('Place a Bet'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamHeader(BuildContext context, ThemeData theme, Team team, String userId) {
    return Stack(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://picsum.photos/800/600?random=${team.id.hashCode}'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.lightSurface,
                backgroundImage: NetworkImage(team.logoUrl),
              ),
              const SizedBox(height: 16),
              Text(
                team.name,
                style: theme.textTheme.displaySmall?.copyWith(color: AppTheme.lightText, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                team.description,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // DUMMY FIX: Immediately change local state
                  setState(() {
                    _isFollowing = !_isFollowing;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_isFollowing ? 'You are now following this team.' : 'You have unfollowed this team.')),
                  );
                },
                icon: Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
                label: Text(_isFollowing ? 'Following' : 'Follow'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing ? AppTheme.greyText : AppTheme.primaryColor,
                  foregroundColor: AppTheme.lightText,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamStats(ThemeData theme, TeamStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(theme, 'Win Rate', '${(stats.winRate * 100).toStringAsFixed(0)}%'),
          _buildStatCard(theme, 'Total Earnings', '\$${NumberFormat('#,##0').format(stats.totalEarnings)}'),
          _buildStatCard(theme, 'Challenges', stats.totalChallenges.toString()),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.displayMedium?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMembersList(ThemeData theme, List<String> members) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: members.map((memberId) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '- $memberId',
                style: theme.textTheme.bodyMedium,
              ),
            )).toList(),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedText, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}