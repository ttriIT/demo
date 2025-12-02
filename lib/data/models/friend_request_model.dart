import 'package:appwrite/models.dart' as models;

/// Friend request status
enum FriendRequestStatus {
  pending,
  accepted,
  declined,
}

/// Friend request model
class FriendRequestModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final FriendRequestStatus status;
  final DateTime timestamp;

  FriendRequestModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    this.status = FriendRequestStatus.pending,
    required this.timestamp,
  });

  /// Create FriendRequestModel from Appwrite Document
  factory FriendRequestModel.fromDocument(models.Document doc) {
    return FriendRequestModel(
      id: doc.$id,
      fromUserId: doc.data['fromUserId'] as String,
      toUserId: doc.data['toUserId'] as String,
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == (doc.data['status'] as String? ?? 'pending'),
        orElse: () => FriendRequestStatus.pending,
      ),
      timestamp: DateTime.parse(doc.data['timestamp'] as String),
    );
  }

  /// Convert to Map for Appwrite Document
  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  FriendRequestModel copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    FriendRequestStatus? status,
    DateTime? timestamp,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
