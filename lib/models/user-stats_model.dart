class UserStats {
  final double winRate;
  final int totalWins;
  final int followingCount;
  final int achievementsCount;

  UserStats({
    required this.winRate,
    required this.totalWins,
    required this.followingCount,
    required this.achievementsCount,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      winRate: (map['winRate'] ?? 0).toDouble(),
      totalWins: map['totalWins'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      achievementsCount: map['achievementsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'winRate': winRate,
      'totalWins': totalWins,
      'followingCount': followingCount,
      'achievementsCount': achievementsCount,
    };
  }
}
