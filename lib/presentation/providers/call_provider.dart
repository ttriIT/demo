import 'package:flutter/material.dart';
import '../../data/services/call_service.dart';

/// Provider for managing video call state
class CallProvider with ChangeNotifier {
  final CallService _callService = CallService();

  /// Initialize call service
  Future<void> initialize({
    required String userId,
    required String userName,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    try {
      await _callService.initialize(
        userId: userId,
        userName: userName,
        navigatorKey: navigatorKey,
      );
    } catch (e) {
      debugPrint('CallProvider Init Error: $e');
    }
  }

  /// Uninitialize call service
  Future<void> uninitialize() async {
    await _callService.uninitialize();
  }

  /// Send call invitation
  Future<void> sendCallInvitation({
    required String targetUserId,
    required String targetUserName,
    required String callId,
    required bool isVideoCall,
  }) async {
    await _callService.sendCallInvitation(
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      callId: callId,
      isVideoCall: isVideoCall,
    );
  }
}
