import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/call_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../routes/app_routes.dart';
import 'firebase_service.dart';
import 'push_notification.dart';
import 'zego_service.dart';

class CallService extends GetxService {
  static CallService get to => Get.find<CallService>();

  static const String statusCalling = 'calling';
  static const String statusAccepted = 'accepted';
  static const String statusRejected = 'rejected';
  static const String statusEnded = 'ended';
  static const String statusMissed = 'missed';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _calls => _db.collection('calls');

  /// Creates a Firestore call, posts a joinable chat bubble to both users,
  /// notifies the callee, then opens the call screen for the caller.
  Future<void> startCall({
    required String callerId,
    required String callerName,
    required String calleeId,
    required String calleeName,
    required String type,
    String? appointmentId,
  }) async {
    if (callerId.isEmpty || calleeId.isEmpty) {
      throw Exception('Missing caller or callee');
    }

    final isVideo = type.toLowerCase() == 'video';
    final zego = Get.find<ZegoService>();
    if (!zego.isInitialized) {
      await zego.init(userID: callerId, userName: callerName);
    }
    final ok = await zego.ensureCallPermissions(video: isVideo);
    if (!ok) {
      throw Exception('Camera/microphone permission required');
    }

    final callRef = _calls.doc();
    final callId = callRef.id;
    final roomId = 'room_$callId';
    final callType = isVideo ? 'video' : 'audio';
    final now = DateTime.now();

    final call = CallModel(
      id: callId,
      roomId: roomId,
      type: callType,
      callerId: callerId,
      callerName: callerName,
      calleeId: calleeId,
      calleeName: calleeName,
      status: statusCalling,
      createdAt: now,
    );
    await callRef.set({
      ...call.toMap(),
      'appointmentId': ?appointmentId,
    });

    final conversationId =
        FirebaseService.conversationIdFor(callerId, calleeId);
    final label = isVideo ? 'Video Call' : 'Audio Call';
    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: callerId,
      content: '$label started — tap Join to connect',
      type: MessageType.call,
      status: MessageStatus.sent,
      timestamp: now,
      callId: callId,
      roomId: roomId,
      callType: callType,
      callStatus: 'active',
    );

    await FirebaseService.sendMessage(
      conversationId,
      callerId,
      calleeId,
      message,
      senderName: callerName,
      receiverName: calleeName,
    );

    final enabled = await FirebaseService.isNotificationsEnabled(calleeId);
    if (enabled) {
      await FirebaseService.createNotification(
        userId: calleeId,
        title: isVideo ? 'Incoming Video Call' : 'Incoming Audio Call',
        message: '$callerName started a $callType call. Open chat to join.',
        type: NotificationType.call,
        category: 'Calls',
        data: {
          'callId': callId,
          'roomId': roomId,
          'callType': callType,
          'conversationId': conversationId,
          'participantId': callerId,
          'participantName': callerName,
        },
      );

      PushNotificationService.sendPushNotification(
        userID: calleeId,
        type: 'call',
        title: isVideo ? 'Video Call' : 'Audio Call',
        body: '$callerName started a call. Tap to join.',
        data: {
          'callId': callId,
          'roomId': roomId,
          'callType': callType,
          'conversationId': conversationId,
          'participantId': callerId,
          'participantName': callerName,
          'remoteUserId': callerId,
          'remoteUserName': callerName,
        },
      );
    }

    joinCall(
      roomId: roomId,
      userId: callerId,
      userName: callerName,
      remoteUserId: calleeId,
      calleeName: calleeName,
      callType: callType,
      appointmentId: appointmentId,
      isIncoming: false,
    );
  }

  Future<void> joinCall({
    required String roomId,
    required String userId,
    required String userName,
    required String remoteUserId,
    required String callType,
    String? calleeName,
    String? appointmentId,
    bool isIncoming = true,
  }) async {
    final isVideo = callType.toLowerCase() == 'video';
    final zego = Get.find<ZegoService>();
    if (!zego.isInitialized) {
      await zego.init(userID: userId, userName: userName);
    }
    final ok = await zego.ensureCallPermissions(video: isVideo);
    if (!ok) {
      throw Exception('Camera/microphone permission required');
    }

    final route = isVideo ? AppRoutes.videoCall : AppRoutes.audioCall;
    Get.toNamed(
      route,
      arguments: {
        'roomId': roomId,
        'userId': userId,
        'userName': userName,
        'remoteUserId': remoteUserId,
        'calleeName': calleeName,
        'isIncoming': isIncoming,
        'appointmentId': appointmentId,
      },
    );
  }

  Future<void> logCall({
    required String callerId,
    required String callerName,
    required String calleeId,
    required String calleeName,
    required String type,
    required String status,
  }) async {
    try {
      final id = _calls.doc().id;
      final call = CallModel(
        id: id,
        roomId: id,
        type: type.toLowerCase(),
        callerId: callerId,
        callerName: callerName,
        calleeId: calleeId,
        calleeName: calleeName,
        status: status,
        createdAt: DateTime.now(),
      );
      await _calls.doc(id).set(call.toMap());
    } catch (e) {
      debugPrint('Log call failed: $e');
    }
  }

  Future<void> updateCallStatus(String callId, String status) async {
    if (callId.isEmpty) return;
    try {
      await _calls.doc(callId).update({'status': status});
    } catch (e) {
      debugPrint('Update call status failed: $e');
    }
  }

  Future<void> endCall(String callId) async {
    if (callId.isEmpty) return;
    try {
      await _calls.doc(callId).update({'status': statusEnded});
    } catch (e) {
      debugPrint('End call failed: $e');
    }
  }
}
