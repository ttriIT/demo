import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../core/constants/app_constants.dart';

/// Video call screen using ZegoCloud UIKit
class VideoCallScreen extends StatelessWidget {
  final String callId;
  final String currentUserId;
  final String currentUserName;

  const VideoCallScreen({
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
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..onOnlySelfInRoom = (context) {
          // Auto navigate back when user is alone
          Navigator.of(context).pop();
        },
    );
  }
}
