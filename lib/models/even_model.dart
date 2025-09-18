import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participatingTeams;
  final int totalPot;
  final String? streamUrl;
  final bool isLive;
  final int viewerCount;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.participatingTeams,
    required this.totalPot,
    this.streamUrl,
    required this.isLive,
    required this.viewerCount,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participatingTeams: List<String>.from(map['participatingTeams'] ?? []),
      totalPot: map['totalPot'] ?? 0,
      streamUrl: map['streamUrl'],
      isLive: map['isLive'] ?? false,
      viewerCount: map['viewerCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'participatingTeams': participatingTeams,
      'totalPot': totalPot,
      'streamUrl': streamUrl,
      'isLive': isLive,
      'viewerCount': viewerCount,
    };
  }
}
