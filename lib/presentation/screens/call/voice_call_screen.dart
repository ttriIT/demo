import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../../core/constants/app_constants.dart';

/// Voice call screen using ZegoCloud UIKit
class VoiceCallScreen extends StatelessWidget {
  final String callId;
  final String currentUserId;
  final String currentUserName;

  const VoiceCallScreen({
    super.key,
    required this.callId,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: AppConstants.zegoAppId,
      appSign: AppConstants.zegoAppSign,
      userID: currentUserId,
      userName: currentUserName,
      callID: callId,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }
}
