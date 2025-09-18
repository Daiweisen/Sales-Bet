// lib/core/seed/data_seeder.dart

import 'package:sales_bets/core/services/event_service.dart';
import 'package:sales_bets/core/services/team_service.dart';
import 'package:sales_bets/models/even_model.dart';
import 'package:sales_bets/models/team_model.dart';

class DataSeeder {
  final EventService _eventService = EventService();
  final TeamService _teamService = TeamService();

  Future<void> seedDatabase() async {
    // Add dummy teams
    final team1 = Team(
      id: 'team_01',
      name: 'Alpha Squad',
      description: 'The best sales team in the industry.',
      logoUrl: 'https://cdn-icons-png.flaticon.com/512/3233/3233827.png',
      category: 'Software',
      stats: TeamStats(
        totalEarnings: 50000,
        followerCount: 1500,
        winRate: 0.85,
        totalChallenges: 20,
      ),
      members: ['user_A', 'user_B'],
      createdAt: DateTime.now(),
    );
    await _teamService.addTeam(team1);

    final team2 = Team(
      id: 'team_02',
      name: 'Beta Force',
      description: 'A rising star in the market.',
      logoUrl: 'https://cdn-icons-png.flaticon.com/512/2855/2855589.png',
      category: 'Hardware',
      stats: TeamStats(
        totalEarnings: 30000,
        followerCount: 900,
        winRate: 0.70,
        totalChallenges: 15,
      ),
      members: ['user_C', 'user_D'],
      createdAt: DateTime.now(),
    );
    await _teamService.addTeam(team2);

    final team3 = Team(
      id: 'team_03',
      name: 'Gamma Pioneers',
      description: 'Innovators on the cutting edge.',
      logoUrl: 'https://cdn-icons-png.flaticon.com/512/3592/3592237.png',
      category: 'Services',
      stats: TeamStats(
        totalEarnings: 75000,
        followerCount: 2100,
        winRate: 0.92,
        totalChallenges: 25,
      ),
      members: ['user_E', 'user_F'],
      createdAt: DateTime.now(),
    );
    await _teamService.addTeam(team3);

    final team4 = Team(
      id: 'team_04',
      name: 'Delta Hawks',
      description: 'Aggressive and results-driven.',
      logoUrl: 'https://cdn-icons-png.flaticon.com/512/3588/3588018.png',
      category: 'Consumer Goods',
      stats: TeamStats(
        totalEarnings: 45000,
        followerCount: 1200,
        winRate: 0.78,
        totalChallenges: 18,
      ),
      members: ['user_G', 'user_H'],
      createdAt: DateTime.now(),
    );
    await _teamService.addTeam(team4);

    // Add dummy events using the team IDs
    final event1 = Event(
      id: 'event_01',
      title: 'Q3 Sales Showdown',
      description: 'The final competition of the quarter.',
      category: 'Sales',
      status: 'Ongoing',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participatingTeams: ['team_01', 'team_02'],
      totalPot: 10000,
      isLive: true,
      viewerCount: 55,
      streamUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4' ,
    );
    await _eventService.addEvent(event1);

    final event2 = Event(
      id: 'event_02',
      title: 'Monthly Challenge',
      description: 'An internal monthly sales competition.',
      category: 'Internal',
      status: 'Upcoming',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 9)),
      participatingTeams: ['team_03', 'team_04'],
      totalPot: 5000,
      isLive: false,
      viewerCount: 0,
      streamUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4' ,
    );
    await _eventService.addEvent(event2);

    final event3 = Event(
      id: 'event_03',
      title: 'Industry-wide Tournament',
      description: 'Sales teams from across the industry compete.',
      category: 'Enterprise',
      status: 'Ongoing',
      startDate: DateTime.now().subtract(const Duration(hours: 12)),
      endDate: DateTime.now().add(const Duration(hours: 48)),
      participatingTeams: ['team_01', 'team_03'],
      totalPot: 25000,
      isLive: true,
      viewerCount: 120,
      streamUrl: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', // A different public stream URL
    );
    await _eventService.addEvent(event3);

    final event4 = Event(
      id: 'event_04',
      title: 'Rookie Rumble',
      description: 'A friendly competition for new sales reps.',
      category: 'Beginner',
      status: 'Completed',
      startDate: DateTime.now().subtract(const Duration(days: 14)),
      endDate: DateTime.now().subtract(const Duration(days: 10)),
      participatingTeams: ['team_02', 'team_04'],
      totalPot: 2000,
      isLive: false,
      viewerCount: 80,
      streamUrl: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    );
    await _eventService.addEvent(event4);

    print('Database seeded successfully!');
  }
}