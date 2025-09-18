class Wallet {
  final int credits;
  final int totalEarnings;
  final int totalBets;

  Wallet({
    required this.credits,
    required this.totalEarnings,
    required this.totalBets,
  });

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      credits: map['credits'] ?? 0,
      totalEarnings: map['totalEarnings'] ?? 0,
      totalBets: map['totalBets'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'credits': credits,
      'totalEarnings': totalEarnings,
      'totalBets': totalBets,
    };
  }
}
