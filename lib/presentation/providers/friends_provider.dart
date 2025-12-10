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

  List<UserModel> get friends => _friends;
  List<FriendRequestModel> get pendingRequests => _pendingRequests;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  List<FriendRequestModel> _sentRequests = [];
  List<FriendRequestModel> get sentRequests => _sentRequests;

  /// Load pending friend requests
  Future<void> loadPendingRequests(String userId) async {
    try {
      // Load initial requests
      _pendingRequests = await _databaseService.getPendingRequests(userId);
      notifyListeners();

      // Subscribe to realtime updates
      _requestSubscription?.cancel();
      _requestSubscription = _databaseService.subscribeToFriendRequests(userId).listen(
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

  /// Load requests sent BY current user
  Future<void> loadSentRequests(String userId) async {
    try {
      _sentRequests = await _databaseService.getSentPendingRequests(userId);
      notifyListeners();
    } catch (e) {
      print('Failed to load sent requests: $e');
    }
  }

  /// Search users by email
  Future<void> searchUsers(String email, {String? currentUserId}) async {
    if (email.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _databaseService.searchUsersByEmail(email);
      // Reload sent requests to ensure UI is up to date if we searched and found
      // someone we already sent a request to.
      if (currentUserId != null) {
        await loadSentRequests(currentUserId);
      }
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
      // Add to local list or reload
      await loadSentRequests(fromUserId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cancel friend request
  Future<bool> cancelFriendRequest(String requestId, String userId) async {
     try {
       await _databaseService.deleteFriendRequest(requestId);
       // Remove from local list
       _sentRequests.removeWhere((r) => r.id == requestId);
       notifyListeners();
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
    String friendId, {
    Function()? onSuccess,
  }) async {
    try {
      await _databaseService.acceptFriendRequest(requestId, userId, friendId);
      // Refresh lists
      await loadFriends(userId);
      await loadPendingRequests(userId);
      // Call onSuccess callback to refresh user data in AuthProvider
      onSuccess?.call();
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
      // Remove from list
      _pendingRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove friend
  Future<bool> removeFriend(
    String userId,
    String friendId, {
    Function()? onSuccess,
  }) async {
    try {
      await _databaseService.removeFriend(userId, friendId);
      // Remove from friends list
      _friends.removeWhere((f) => f.id == friendId);
      // Refresh friends list
      await loadFriends(userId);
      // Call onSuccess callback to refresh user data in AuthProvider
      onSuccess?.call();
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
