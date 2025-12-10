import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../models/friend_request_model.dart';

/// Database service for Appwrite operations
class DatabaseService {
  final _appwrite = AppwriteService();

  // ==================== USER OPERATIONS ====================

  /// Get user by ID
  Future<UserModel> getUserById(String userId) async {
    try {
      final doc = await _appwrite.databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: userId,
      );
      return UserModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  /// Search users by email
  Future<List<UserModel>> searchUsersByEmail(String email) async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        queries: [
          Query.search('email', email),
        ],
      );
      return response.documents.map((doc) => UserModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }

  /// Update user status
  Future<void> updateUserStatus(String userId, {bool? isOnline, DateTime? lastSeen}) async {
    try {
      final data = <String, dynamic>{};
      if (isOnline != null) data['isOnline'] = isOnline;
      if (lastSeen != null) data['lastSeen'] = lastSeen.toIso8601String();

      await _appwrite.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: userId,
        data: data,
      );
    } catch (e) {
      // Silently fail for status updates
      print('Failed to update user status: ${e.toString()}');
    }
  }

  /// Get user's friends
  Future<List<UserModel>> getUserFriends(String userId) async {
    try {
      final userDoc = await _appwrite.databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: userId,
      );

      final friendIds = List<String>.from(userDoc.data['friends'] as List? ?? []);
      
      if (friendIds.isEmpty) return [];

      // Fetch all friends
      final friends = <UserModel>[];
      for (final friendId in friendIds) {
        try {
          final friend = await getUserById(friendId);
          friends.add(friend);
        } catch (e) {
          // Skip if friend not found
          continue;
        }
      }
      
      return friends;
    } catch (e) {
      throw Exception('Failed to get friends: ${e.toString()}');
    }
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Send a message
  Future<MessageModel> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
    MessageType type = MessageType.text,
  }) async {
    try {
      final message = MessageModel(
        id: ID.unique(),
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        type: type,
        timestamp: DateTime.now(),
      );

      final doc = await _appwrite.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.messagesCollectionId,
        documentId: message.id,
        data: message.toMap(),
      );

      return MessageModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  /// Get messages for a conversation
  Future<List<MessageModel>> getMessages(String userId, String friendId) async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.messagesCollectionId,
        queries: [
          Query.or([
            Query.and([
              Query.equal('senderId', userId),
              Query.equal('receiverId', friendId),
            ]),
            Query.and([
              Query.equal('senderId', friendId),
              Query.equal('receiverId', userId),
            ]),
          ]),
          Query.orderDesc('timestamp'),
          Query.limit(AppConstants.messagesPageSize),
        ],
      );

      return response.documents
          .map((doc) => MessageModel.fromDocument(doc))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw Exception('Failed to get messages: ${e.toString()}');
    }
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _appwrite.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.messagesCollectionId,
        documentId: messageId,
        data: {'isRead': true},
      );
    } catch (e) {
      // Silently fail - non-critical
      print('Failed to mark message as read: ${e.toString()}');
    }
  }

  // ==================== FRIEND REQUEST OPERATIONS ====================

  /// Send friend request
  Future<FriendRequestModel> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      final request = FriendRequestModel(
        id: ID.unique(),
        fromUserId: fromUserId,
        toUserId: toUserId,
        timestamp: DateTime.now(),
      );

      final doc = await _appwrite.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.friendRequestsCollectionId,
        documentId: request.id,
        data: request.toMap(),
      );

      return FriendRequestModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to send friend request: ${e.toString()}');
    }
  }

  /// Get pending friend requests for a user
  Future<List<FriendRequestModel>> getPendingRequests(String userId) async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.friendRequestsCollectionId,
        queries: [
          Query.equal('toUserId', userId),
          Query.equal('status', 'pending'),
          Query.orderDesc('timestamp'),
        ],
      );

      return response.documents
          .map((doc) => FriendRequestModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get requests: ${e.toString()}');
    }
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String requestId, String userId, String friendId) async {
    try {
      // Update request status
      await _appwrite.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.friendRequestsCollectionId,
        documentId: requestId,
        data: {'status': 'accepted'},
      );

      // Add to both users' friends lists
      final userDoc = await getUserById(userId);
      final friendDoc = await getUserById(friendId);

      await _appwrite.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: userId,
        data: {'friends': [...userDoc.friends, friendId]},
      );

      await _appwrite.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: friendId,
        data: {'friends': [...friendDoc.friends, userId]},
      );
    } catch (e) {
      throw Exception('Failed to accept request: ${e.toString()}');
    }
  }

  /// Decline friend request
  Future<void> declineFriendRequest(String requestId) async {
    try {
      await _appwrite.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.friendRequestsCollectionId,
        documentId: requestId,
        data: {'status': 'declined'},
      );
    } catch (e) {
      throw Exception('Failed to decline request: ${e.toString()}');
    }
  }

  /// Delete (Cancel) friend request
  Future<void> deleteFriendRequest(String requestId) async {
    try {
      await _appwrite.databases.deleteDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.friendRequestsCollectionId,
        documentId: requestId,
      );
    } catch (e) {
      throw Exception('Failed to delete request: ${e.toString()}');
    }
  }

  /// Get pending friend requests sent BY a user
  Future<List<FriendRequestModel>> getSentPendingRequests(String userId) async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.friendRequestsCollectionId,
        queries: [
          Query.equal('fromUserId', userId),
          Query.equal('status', 'pending'),
          Query.orderDesc('timestamp'),
        ],
      );

      return response.documents
          .map((doc) => FriendRequestModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sent requests: ${e.toString()}');
    }
  }

  /// Remove friend from both users' friends lists
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      // Get both users' documents
      final userDoc = await getUserById(userId);
      final friendDoc = await getUserById(friendId);

      // Remove friend from user's friends list
      final updatedUserFriends = List<String>.from(userDoc.friends)
        ..remove(friendId);
      
      // Remove user from friend's friends list
      final updatedFriendFriends = List<String>.from(friendDoc.friends)
        ..remove(userId);

      // Update both users' documents
      await _appwrite.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: userId,
        data: {'friends': updatedUserFriends},
      );

      await _appwrite.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: friendId,
        data: {'friends': updatedFriendFriends},
      );
    } catch (e) {
      throw Exception('Failed to remove friend: ${e.toString()}');
    }
  }

  /// Subscribe to real-time messages
  Stream<MessageModel> subscribeToMessages(String userId, String friendId) {
    final subscription = _appwrite.realtime.subscribe([
      'databases.${AppConstants.databaseId}.collections.${AppConstants.messagesCollectionId}.documents'
    ]);

    return subscription.stream.map((event) {
      final doc = event.payload;
      return MessageModel.fromDocument(doc as dynamic);
    }).where((message) {
      // Filter for current conversation only
      return (message.senderId == userId && message.receiverId == friendId) ||
             (message.senderId == friendId && message.receiverId == userId);
    });
  }

  /// Subscribe to real-time friend requests
  Stream<FriendRequestModel> subscribeToFriendRequests(String userId) {
    final subscription = _appwrite.realtime.subscribe([
      'databases.${AppConstants.databaseId}.collections.${AppConstants.friendRequestsCollectionId}.documents'
    ]);

    return subscription.stream.map((event) {
      final doc = event.payload;
      return FriendRequestModel.fromDocument(doc as dynamic);
    }).where((request) {
      // Filter for requests sent to current user
      return request.toUserId == userId && request.status == FriendRequestStatus.pending;
    });
  }
}
