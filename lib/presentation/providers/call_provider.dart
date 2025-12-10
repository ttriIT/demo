import 'package:flutter/foundation.dart';
import '../../data/services/call_service.dart';
import '../../data/models/user_model.dart';

/// Provider for managing video call state
class CallProvider with ChangeNotifier {
  final CallService _callService = CallService();
  
  bool _isInCall = false;
  bool _isInitialized = false;
  String? _currentCallId;
  UserModel? _callPartner;

  bool get isInCall => _isInCall;
  bool get isInitialized => _isInitialized;
  String? get currentCallId => _currentCallId;
  UserModel? get callPartner => _callPartner;

  /// Initialize call service
  Future<void> initialize({
    required String userId,
    required String userName,
  }) async {
    if (_isInitialized) return;
    
    try {
      await _callService.initialize(
        userId: userId,
        userName: userName,
      );
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to initialize call service: ${e.toString()}');
    }
  }

  /// Send call invitation
  Future<void> sendCallInvitation({
    required UserModel targetUser,
    required String callId,
    required bool isVideoCall,
  }) async {
    try {
      await _callService.sendCallInvitation(
        targetUserId: targetUser.id,
        targetUserName: targetUser.name,
        callId: callId,
        isVideoCall: isVideoCall,
      );
      
      _isInCall = true;
      _currentCallId = callId;
      _callPartner = targetUser;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to send call invitation: ${e.toString()}');
    }
  }

  /// End call
  void endCall() {
    _isInCall = false;
    _currentCallId = null;
    _callPartner = null;
    notifyListeners();
  }

  /// Uninitialize call service
  Future<void> uninitialize() async {
    if (!_isInitialized) return;
    
    await _callService.uninitialize();
    _isInitialized = false;
    notifyListeners();
  }
}

