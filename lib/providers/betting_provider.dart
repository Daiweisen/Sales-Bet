// lib/providers/betting_provider.dart

import 'package:flutter/material.dart';
import 'package:sales_bets/core/services/acheivement_service.dart';
import 'package:sales_bets/core/services/betting_service.dart';
import 'package:sales_bets/models/bet_model.dart';
import 'package:sales_bets/providers/user_provider.dart'; // To update user stats

class BettingProvider with ChangeNotifier {
  final BettingService _bettingService = BettingService();
  final UserProvider _userProvider; // Inject UserProvider
  final AchievementService _achievementService = AchievementService(); // Achievement service

  BettingProvider({required UserProvider userProvider}) : _userProvider = userProvider;

  Future<String> placeBet({required Bet bet}) async {
    try {
      // Create the bet in Firestore
      final betId = await _bettingService.createBet(bet: bet);

      // Update user stats after a successful bet
      await _userProvider.updateUserStats(
        userId: bet.userId,
        // Assuming your updateUserStats method can handle different stats
        // We will need to update the UserProvider to include this method
        totalBets: 1, 
        totalStaked: bet.amount.toDouble(),
      );

      // Award achievement for the first bet
      await _achievementService.awardBadge(bet.userId, 'first_bet_badge');

      return betId;
    } catch (e) {
      // Re-throw the error so it can be caught and handled in the UI
      rethrow;
    }
  }

  Future<void> updateBet({
    required String betId,
    required String status,
    required double winAmount,
    required String userId, // We need the userId to update stats
    required double betAmount, // We need the bet amount to update stats
  }) async {
    try {
      await _bettingService.updateBet(
        betId: betId,
        status: status,
        winAmount: winAmount,
      );

      // Update user credits and stats based on the outcome
      if (status == 'won') {
        // Update user credits and total earnings
        await _userProvider.updateUserCredits(userId, winAmount, isWin: true);
        await _userProvider.updateUserStats(
          userId: userId,
          totalWins: 1,
          totalEarnings: winAmount,
        );
        // Award badge for a win
        await _achievementService.awardBadge(userId, 'first_win_badge');
      } else if (status == 'lost') {
        // Update user credits for a loss
        await _userProvider.updateUserCredits(userId, -betAmount, isWin: false);
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Bet>> getUserBets(String userId) {
    return _bettingService.getBetsStreamByUserId(userId);
  }
}