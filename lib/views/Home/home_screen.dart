import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_bets/models/even_model.dart';
import 'package:sales_bets/models/team_model.dart';
import 'package:sales_bets/providers/event_provider.dart';
import 'package:sales_bets/providers/team_provider.dart';
import 'package:sales_bets/providers/theme_provider.dart'; // Import the ThemeProvider
import 'package:sales_bets/views/Events/event_screen.dart';
import 'package:sales_bets/views/LeaderBoard/leaderBoard_Screen.dart';
import 'package:sales_bets/views/LiveStream/livestream_screen.dart';
import 'package:sales_bets/views/Profile/Profile_Screen.dart';
import 'package:sales_bets/views/Team/team_screen.dart';
import 'package:sales_bets/widgets/eventsCard_widget.dart';
import 'package:sales_bets/widgets/teamCard_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ongoing Challenges',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildOngoingChallengesList(),
            const SizedBox(height: 32),
            Text(
              'Trending Teams',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildTrendingTeamsList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildOngoingChallengesList() {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        return StreamBuilder<List<Event>>(
          stream: eventsProvider.events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final events = snapshot.data ?? [];
            if (events.isEmpty) {
              return const Center(child: Text('No ongoing events.'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: events[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventScreen(eventId: events[index].id),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTrendingTeamsList() {
    return Consumer<TeamsProvider>(
      builder: (context, teamsProvider, child) {
        return StreamBuilder<List<Team>>(
          stream: teamsProvider.trendingTeams,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final teams = snapshot.data ?? [];
            if (teams.isEmpty) {
              return const Center(child: Text('No trending teams.'));
            }
            return SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  return TeamCard(
                    team: teams[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamScreen(
                            teamId: teams[index].id,
                            eventId: '', // We can't get an eventId here, so we will pass an empty string
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Consumer2<EventsProvider, TeamsProvider>(
      builder: (context, eventsProvider, teamsProvider, child) {
        return BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Teams',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.live_tv),
              label: 'Live',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: (index) async {
            switch (index) {
              case 0:
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                );
                break;
              case 2:
                _navigateToLiveStream(context, eventsProvider);
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _navigateToLiveStream(BuildContext context, EventsProvider eventsProvider) async {
    try {
      final events = await eventsProvider.events.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => <Event>[],
      );
      
      if (context.mounted) {
        if (events.isNotEmpty) {
          final event = events.first;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LiveStreamScreen(
                streamUrl: event.streamUrl ?? '',
                eventTitle: event.title ?? 'Live Stream',
                eventId: event.id,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LiveStreamScreen(
                streamUrl: '',
                eventTitle: 'Live Stream',
                eventId: '',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LiveStreamScreen(
              streamUrl: '',
              eventId: '',
              eventTitle: 'Live Stream',
            ),
          ),
        );
      }
    }
  }
}