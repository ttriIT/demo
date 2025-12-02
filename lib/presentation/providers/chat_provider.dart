import 'package:flutter/foundation.dart';
import '../../data/models/message_model.dart';
import '../../data/services/database_service.dart';
import 'dart:async';

/// Chat state provider
class ChatProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  final Map<String, List<MessageModel>> _conversations = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get messages for a conversation
  List<MessageModel> getConversationMessages(String userId, String friendId) {
    final conversationId = MessageModel.getConversationId(userId, friendId);
    return _conversations[conversationId] ?? [];
  }

  /// Load messages for a conversation
  Future<void> loadMessages(String userId, String friendId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final messages = await _databaseService.getMessages(userId, friendId);
      final conversationId = MessageModel.getConversationId(userId, friendId);
      _conversations[conversationId] = messages;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send a message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    try {
      final message = await _databaseService.sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        text: text,
      );

      final conversationId = MessageModel.getConversationId(senderId, receiverId);
      if (_conversations[conversationId] == null) {
        _conversations[conversationId] = [];
      }
      _conversations[conversationId]!.add(message);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Subscribe to real-time messages
  void subscribeToConversation(String userId, String friendId) {
    final conversationId = MessageModel.getConversationId(userId, friendId);
    
    // Cancel existing subscription if any
    _subscriptions[conversationId]?.cancel();

    // Subscribe to new messages
    _subscriptions[conversationId] = _databaseService
        .subscribeToMessages(userId, friendId)
        .listen((message) {
      if (_conversations[conversationId] == null) {
        _conversations[conversationId] = [];
      }
      
      // Add message if not already in list
      final exists = _conversations[conversationId]!
          .any((m) => m.id == message.id);
      
      if (!exists) {
        _conversations[conversationId]!.add(message);
        notifyListeners();
      }
    });
  }

  /// Unsubscribe from conversation
  void unsubscribeFromConversation(String userId, String friendId) {
    final conversationId = MessageModel.getConversationId(userId, friendId);
    _subscriptions[conversationId]?.cancel();
    _subscriptions.remove(conversationId);
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
