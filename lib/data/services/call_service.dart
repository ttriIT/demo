import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../../core/constants/app_constants.dart';

/// Service for managing video calls using ZegoCloud
class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  bool _isInitialized = false;

  /// Initialize ZegoUIKit with signaling plugin
  Future<void> initialize({
    required String userId,
    required String userName,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_isInitialized) return;

    try {
      // Initialize ZegoUIKit with signaling plugin
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: AppConstants.zegoAppId,
        appSign: AppConstants.zegoAppSign,
        userID: userId,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
      );
      
      // Set navigator key for overlay support
      ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize ZegoUIKit: ${e.toString()}');
    }
  }

  /// Send call invitation to a user
  Future<void> sendCallInvitation({
    required String targetUserId,
    required String targetUserName,
    required String callId,
    required bool isVideoCall,
  }) async {
    try {
      await ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [
          ZegoCallUser(targetUserId, targetUserName),
        ],
        isVideoCall: isVideoCall,
        callID: callId,
      );
    } catch (e) {
      throw Exception('Failed to send call invitation: ${e.toString()}');
    }
  }

  /// Uninitialize ZegoUIKit
  Future<void> uninitialize() async {
    if (!_isInitialized) return;

    try {
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
      _isInitialized = false;
    } catch (e) {
      print('Failed to uninitialize ZegoUIKit: ${e.toString()}');
    }
  }

  bool get isInitialized => _isInitialized;
}
