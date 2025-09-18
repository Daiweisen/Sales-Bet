import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_bets/core/utils/app_theme.dart';
import 'package:sales_bets/models/User_model.dart';
import 'package:sales_bets/models/bet_model.dart';
import 'package:sales_bets/providers/auth_provider.dart';
import 'package:sales_bets/core/services/betting_service.dart';
import 'package:sales_bets/providers/user_provider.dart'; // Import the UserProvider

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final bettingService = Provider.of<BettingService>(context);

    if (authProvider.user == null) {
      return const Center(
        child: Text('Please log in to view your profile.'),
      );
    }

    final userId = authProvider.user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile and Wallet Card
            StreamBuilder<UserProfile?>(
              stream: userProvider.getUserStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return const Text('User data not found.');
                }

                final user = snapshot.data!;
                return Card(
                  color: AppTheme.darkCard,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_circle,
                          size: 60,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome ${user.displayName ?? 'User'}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.lightText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Credits: \$${user.wallet.credits.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Bet History Section
            Text(
              'Your Bet History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Bet>>(
              future: bettingService.getBetsByUserId(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading bets: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('You have not placed any bets yet.'));
                }

                final bets = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bets.length,
                  itemBuilder: (context, index) {
                    final bet = bets[index];
                    return Card(
                      color: AppTheme.darkCard,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.sports_soccer, color: AppTheme.primaryColor),
                        title: Text('Team: ${bet.teamId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Staked: \$${bet.amount}\n'
                          'Status: ${bet.status}',
                          style: TextStyle(color: AppTheme.lightText.withOpacity(0.7)),
                        ),
                        trailing: Text(
                          bet.winAmount > 0
                              ? '+${bet.winAmount.toStringAsFixed(2)}'
                              : '-\$${bet.amount}',
                          style: TextStyle(
                            color: bet.winAmount > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}