import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String category;
  final TeamStats stats;
  final List<String> members;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.category,
    required this.stats,
    required this.members,
    required this.createdAt,
  });

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      category: map['category'] ?? '',
      stats: TeamStats.fromMap(map['stats'] ?? {}),
      members: List<String>.from(map['members'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'category': category,
      'stats': stats.toMap(),
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class TeamStats {
  final int totalEarnings;
  final int followerCount;
  final double winRate;
  final int totalChallenges;

  TeamStats({
    required this.totalEarnings,
    required this.followerCount,
    required this.winRate,
    required this.totalChallenges,
  });

  factory TeamStats.fromMap(Map<String, dynamic> map) {
    return TeamStats(
      totalEarnings: map['totalEarnings'] ?? 0,
      followerCount: map['followerCount'] ?? 0,
      winRate: (map['winRate'] ?? 0).toDouble(),
      totalChallenges: map['totalChallenges'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalEarnings': totalEarnings,
      'followerCount': followerCount,
      'winRate': winRate,
      'totalChallenges': totalChallenges,
    };
  }
}
