import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'],
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}