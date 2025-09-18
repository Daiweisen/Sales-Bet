// lib/models/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sales_bets/models/user-stats_model.dart';
import 'package:sales_bets/models/user_preference.dart';
import 'package:sales_bets/models/wallet_model.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final Wallet wallet;
  final UserStats stats;
  final UserPreferences preferences;
  final List<String> achievements;
  final List<String> following;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.wallet,
    required this.stats,
    required this.preferences,
    required this.achievements,
    required this.following,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wallet: Wallet.fromMap(map['wallet'] ?? {}),
      stats: UserStats.fromMap(map['stats'] ?? {}),
      preferences: UserPreferences.fromMap(map['preferences'] ?? {}),
      achievements: List<String>.from(map['achievements'] ?? []),
      following: List<String>.from(map['following'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'wallet': wallet.toMap(),
      'stats': stats.toMap(),
      'preferences': preferences.toMap(),
      'achievements': achievements,
      'following': following,
    };
  }
}
