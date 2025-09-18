import 'package:cloud_firestore/cloud_firestore.dart';

class Bet {
  final String id;
  final String userId;
  final String eventId;
  final String teamId;
  final int amount;
  final double odds;
  final String status;
  final DateTime placedAt;
  final DateTime? resolvedAt;
  final double winAmount;

  Bet({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.teamId,
    required this.amount,
    required this.odds,
    required this.status,
    required this.placedAt,
    this.resolvedAt,
    this.winAmount = 0.0,
  });

  factory Bet.fromMap(Map<String, dynamic> map) {
    return Bet(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      teamId: map['teamId'] ?? '',
      amount: map['amount'] ?? 0,
      odds: (map['odds'] ?? 0.0).toDouble(), 
      status: map['status'] ?? '',
      placedAt: (map['placedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
      winAmount: (map['winAmount'] ?? 0.0).toDouble(), 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'teamId': teamId,
      'amount': amount,
      'odds': odds,
      'status': status,
      'placedAt': Timestamp.fromDate(placedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'winAmount': winAmount,
    };
  }

  Bet copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? teamId,
    int? amount,
    double? odds,
    String? status,
    DateTime? placedAt,
    DateTime? resolvedAt,
    double? winAmount,
  }) {
    return Bet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      teamId: teamId ?? this.teamId,
      amount: amount ?? this.amount,
      odds: odds ?? this.odds,
      status: status ?? this.status,
      placedAt: placedAt ?? this.placedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      winAmount: winAmount ?? this.winAmount,
    );
  }
}