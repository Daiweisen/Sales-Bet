// lib/views/Betting/betting_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_bets/core/utils/app_theme.dart';
import 'package:sales_bets/models/bet_model.dart';
import 'package:sales_bets/models/even_model.dart';
import 'package:sales_bets/models/team_model.dart';
import 'package:sales_bets/providers/auth_provider.dart' show AuthProvider;
import 'package:sales_bets/providers/betting_provider.dart';
import 'package:sales_bets/providers/event_provider.dart';
import 'package:sales_bets/providers/team_provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:sales_bets/views/win/win_screen.dart';
import 'package:sales_bets/providers/user_provider.dart';
import 'package:sales_bets/widgets/odds_slider.dart';

class BettingScreen extends StatefulWidget {
  final String eventId;

  const BettingScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  String? _selectedTeamId;
  double _betAmount = 0.0;
  
  // Member variables to hold the Future objects
  late Future<Event?> _eventFuture;
  late Future<List<Team?>> _teamsFuture;
  
  @override
  void initState() {
    super.initState();
    // Initialize the futures here so they are only called once
    _eventFuture = Provider.of<EventsProvider>(context, listen: false).getEventById(widget.eventId);
  }

  // A helper method to fetch the teams once the event is loaded
  Future<List<Team?>> _fetchTeams(Event event) {
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
    return Future.wait<Team?>(
      event.participatingTeams.map((teamId) => teamsProvider.getTeamById(teamId)),
    );
  }

  void _placeBet() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bettingProvider = Provider.of<BettingProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final userId = authProvider.currentUserId;
    final betAmount = _betAmount;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to place a bet.')),
      );
      return;
    }

    if (_selectedTeamId == null || betAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a team and a bet amount.')),
      );
      return;
    }

    try {
      final bet = Bet(
        id: '',
        userId: userId,
        eventId: widget.eventId,
        teamId: _selectedTeamId!,
        amount: betAmount.toInt(),
        placedAt: DateTime.now(),
        status: 'pending',
        odds: 1.0,
        winAmount: 0.0,
      );

      final betId = await bettingProvider.placeBet(bet: bet);
      final bool didWin = Random().nextBool();
      final double winAmount = didWin ? betAmount * 1.5 : 0.0;
      
      await bettingProvider.updateBet(
        betId: betId,
        userId: userId,
        betAmount: betAmount,
        status: didWin ? 'won' : 'lost',
        winAmount: winAmount,
      );

      if (didWin) {
        await userProvider.updateUserCredits(userId, winAmount, isWin: true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WinScreen(amountWon: winAmount),
          ),
        );
      } else {
        await userProvider.updateUserCredits(userId, -betAmount, isWin: false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your bet was placed. You lost this time. Better luck next time!'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e, stacktrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place bet: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Your Bet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Event?>(
        future: _eventFuture,
        builder: (context, eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (eventSnapshot.hasError || !eventSnapshot.hasData || eventSnapshot.data == null) {
            return const Center(child: Text('Event not found.'));
          }

          final event = eventSnapshot.data!;

          // Chain the next FutureBuilder to fetch teams after the event is available
          return FutureBuilder<List<Team?>>(
            future: _fetchTeams(event),
            builder: (context, teamsSnapshot) {
              if (teamsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (teamsSnapshot.hasError) {
                return Center(child: Text('Error: ${teamsSnapshot.error}'));
              }
              
              final participatingTeams = (teamsSnapshot.data ?? []).whereType<Team>().toList();
              if (participatingTeams.isEmpty) {
                return const Center(child: Text('No participating teams found.'));
              }

              final double teamOdds = 1.5;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Pot: \$${NumberFormat('#,##0').format(event.totalPot)}',
                      style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Choose Your Team',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: participatingTeams.map((team) {
                        final isSelected = _selectedTeamId == team.id;
                        return ChoiceChip(
                          label: Text(team.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTeamId = selected ? team.id : null;
                            });
                          },
                          selectedColor: AppTheme.primaryColor,
                          backgroundColor: AppTheme.darkCard,
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.darkText : AppTheme.lightText,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Stake Your Credits',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    OddsSlider(
                      currentOdds: teamOdds,
                      initialBetAmount: _betAmount,
                      onBetAmountChanged: (amount) {
                        setState(() {
                          _betAmount = amount.toDouble();
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _placeBet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: AppTheme.darkText,
                        minimumSize: const Size(double.infinity, 56),
                        elevation: 4,
                      ),
                      child: const Text('Place No-Loss Bet'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}