import 'package:appwrite/models.dart' as models;

/// Message types
enum MessageType {
  text,
  image,
  call,
}

/// Message model for chat messages
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
  });

  /// Create MessageModel from Appwrite Document
  factory MessageModel.fromDocument(models.Document doc) {
    return MessageModel(
      id: doc.$id,
      senderId: doc.data['senderId'] as String,
      receiverId: doc.data['receiverId'] as String,
      text: doc.data['text'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == (doc.data['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(doc.data['timestamp'] as String),
      isRead: doc.data['isRead'] as bool? ?? false,
    );
  }

  /// Convert to Map for Appwrite Document
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  /// Create conversation ID from two user IDs (consistent ordering)
  static String getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Create a copy with updated fields
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? text,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
