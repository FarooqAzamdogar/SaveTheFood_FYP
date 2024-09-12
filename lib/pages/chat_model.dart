import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  // Convert from Firestore Document to ChatMessage
  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    return ChatMessage(
      senderId: doc['senderId'],
      receiverId: doc['receiverId'],
      message: doc['message'],
      timestamp: doc['timestamp'],
    );
  }

  // Convert ChatMessage to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
