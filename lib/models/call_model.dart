// ============================================================
// FILE: lib/models/call_model.dart
// ============================================================

// Represents a realtime call invitation stored in Firestore so the
// remote (callee) device can be notified of an incoming call.
//
// Collection: calls/{callId}
class CallModel {
  final String id;
  final String roomId; // Zego room the call connects through
  final String type; // 'video' | 'audio'
  final String callerId;
  final String callerName;
  final String calleeId;
  final String calleeName;
  final String status; // 'calling' | 'accepted' | 'rejected' | 'ended' | 'missed'
  final DateTime createdAt;

  const CallModel({
    required this.id,
    required this.roomId,
    required this.type,
    required this.callerId,
    required this.callerName,
    required this.calleeId,
    required this.calleeName,
    required this.status,
    required this.createdAt,
  });

  factory CallModel.fromMap(Map<String, dynamic> map, String id) {
    return CallModel(
      id: id,
      roomId: map['roomId'] ?? id,
      type: map['type'] ?? 'video',
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      calleeId: map['calleeId'] ?? '',
      calleeName: map['calleeName'] ?? '',
      status: map['status'] ?? 'calling',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'roomId': roomId,
        'type': type,
        'callerId': callerId,
        'callerName': callerName,
        'calleeId': calleeId,
        'calleeName': calleeName,
        'status': status,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}
