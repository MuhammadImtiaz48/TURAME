import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../../services/zego_service.dart';

class VideoCallScreen extends StatelessWidget {
  final String roomId;
  final String userId;
  final String userName;
  final String? calleeName;
  final String remoteUserId;
  final bool isIncoming;
  final String? appointmentId;

  const VideoCallScreen({
    super.key,
    required this.roomId,
    required this.userId,
    required this.userName,
    this.calleeName,
    required this.remoteUserId,
    this.isIncoming = false,
    this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    if (roomId.isEmpty || userId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Invalid call session')),
      );
    }

    return ZegoUIKitPrebuiltCall(
      appID: ZegoService.appId,
      appSign: ZegoService.appSign,
      callID: roomId,
      userID: userId,
      userName: userName.isEmpty ? 'User' : userName,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}
