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

  List<UserModel> get friends => _friends;
  List<FriendRequestModel> get pendingRequests => _pendingRequests;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
      _pendingRequests = await _databaseService.getPendingRequests(userId);
      notifyListeners();
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
      // Refresh lists
      await loadFriends(userId);
      await loadPendingRequests(userId);
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
