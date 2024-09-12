class Request {
  final String id;
  final String senderId;
  final String type; // 'donor' or 'recipient'
  String status; // Change to non-final
  String? volunteerId; // Change to non-final
  final Map<String, String> details;
  String? username; // Add username field
  final String? chatId; // Add chatId field

  Request({
    required this.id,
    required this.senderId,
    required this.type,
    this.status = 'pending', // Default to 'pending'
    this.volunteerId,
    required this.details,
    this.username, // Initialize this field
    this.chatId, // Initialize this field
  });

  // Convert a Request instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'type': type,
      'status': status,
      'volunteerId': volunteerId,
      'details': details,
      'username': username,
      'chatId': chatId, // Include this field
    };
  }

  // Convert a Map to a Request instance
  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'] as String,
      senderId: map['senderId'] as String,
      type: map['type'] as String,
      status: map['status'] as String,
      volunteerId: map['volunteerId'] as String?,
      details: Map<String, String>.from(map['details'] as Map),
      username: map['username'] as String?,
      chatId: map['chatId'] as String?, // Initialize this field
    );
  }

  // Method to copy the request with a new username and chatId
  Request copyWith({String? username, String? chatId}) {
    return Request(
      id: id,
      senderId: senderId,
      type: type,
      status: status,
      volunteerId: volunteerId,
      details: details,
      username: username ?? this.username,
      chatId: chatId ?? this.chatId, // Allow updating chatId
    );
  }
}
