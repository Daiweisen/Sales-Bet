import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_bets/models/user_model.dart';
import 'package:sales_bets/providers/leaderboard_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: Provider.of<LeaderboardProvider>(context).leaderboardStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users on the leaderboard yet.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(user.displayName),
                trailing: Text('\$${user.wallet.credits.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
}