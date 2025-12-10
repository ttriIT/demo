import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/models/friend_request_model.dart';
import '../../data/services/database_service.dart';

/// Friends state provider
class FriendsProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<UserModel> _friends = [];
  List<FriendRequestModel> _pendingRequests = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<FriendRequestModel>? _requestSubscription;
  List<FriendRequestModel> _sentRequests = [];

  List<UserModel> get friends => _friends;
  List<FriendRequestModel> get pendingRequests => _pendingRequests;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<FriendRequestModel> get sentRequests => _sentRequests;

  @override
  void dispose() {
    _requestSubscription?.cancel();
    super.dispose();
  }

  /// Load user's friends
  Future<void> loadFriends(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _friends = await _databaseService.getUserFriends(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load pending friend requests
  Future<void> loadPendingRequests(String userId) async {
    try {
      // Load initial requests
      _pendingRequests = await _databaseService.getPendingRequests(userId);
      notifyListeners();

      // Subscribe to realtime updates
      _requestSubscription?.cancel();
      _requestSubscription =
          _databaseService.subscribeToFriendRequests(userId).listen(
        (request) {
          if (!_pendingRequests.any((r) => r.id == request.id)) {
            _pendingRequests.insert(0, request);
            notifyListeners();
          }
        },
        onError: (e) {
          print('Friend request subscription error: $e');
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Search users by email
  Future<void> searchUsers(String email) async {
    if (email.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _databaseService.searchUsersByEmail(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send friend request
  Future<bool> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      await _databaseService.sendFriendRequest(
        fromUserId: fromUserId,
        toUserId: toUserId,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(
    String requestId,
    String userId,
    String friendId,
  ) async {
    try {
      await _databaseService.acceptFriendRequest(requestId, userId, friendId);

      // Remove from pending requests
      _pendingRequests.removeWhere((r) => r.id == requestId);

      // Force reload friends list to ensure new friend appears
      await loadFriends(userId);

      // Reload pending requests to ensure UI updates
      await loadPendingRequests(userId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Decline friend request
  Future<bool> declineFriendRequest(String requestId) async {
    try {
      await _databaseService.declineFriendRequest(requestId);

      // Immediately remove from both lists for instant UI update
      _pendingRequests.removeWhere((r) => r.id == requestId);
      _sentRequests.removeWhere((r) => r.id == requestId);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Load friend requests sent by current user
  Future<void> loadSentRequests(String userId) async {
    try {
      _sentRequests = await _databaseService.getSentRequests(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Cancel (decline) a sent friend request
  Future<bool> cancelFriendRequest(String requestId, String userId) async {
    try {
      await _databaseService.declineFriendRequest(requestId);
      _sentRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
      // Optionally reload sent requests for full sync:
      await loadSentRequests(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove friend
  Future<bool> removeFriend(String currentUserId, String friendId) async {
    try {
      await _databaseService.removeFriend(currentUserId, friendId);

      // Remove from local friends list
      _friends.removeWhere((friend) => friend.id == friendId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get friend by ID
  UserModel? getFriendById(String friendId) {
    try {
      return _friends.firstWhere((f) => f.id == friendId);
    } catch (e) {
      return null;
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
