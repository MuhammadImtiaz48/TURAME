// Collection: users/{userId}/conversations/{conversationId}/messages/{messageId}

enum MessageType { text, image, file, ai, call }

enum MessageStatus { sent, delivered, read }

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? fileUrl;
  final String? fileName;
  final int? fileSizeKb;
  /// Call invite bubble fields (when [type] == [MessageType.call]).
  final String? callId;
  final String? roomId;
  final String? callType; // 'video' | 'audio'
  final String? callStatus; // 'active' | 'ended'

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.fileUrl,
    this.fileName,
    this.fileSizeKb,
    this.callId,
    this.roomId,
    this.callType,
    this.callStatus,
  });

  bool get isCallInvite => type == MessageType.call && (roomId ?? '').isNotEmpty;

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      fileSizeKb: map['fileSizeKb'],
      callId: map['callId'],
      roomId: map['roomId'],
      callType: map['callType'],
      callStatus: map['callStatus'],
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'content': content,
        'type': type.name,
        'status': status.name,
        'timestamp': timestamp.millisecondsSinceEpoch,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (fileName != null) 'fileName': fileName,
        if (fileSizeKb != null) 'fileSizeKb': fileSizeKb,
        if (callId != null) 'callId': callId,
        if (roomId != null) 'roomId': roomId,
        if (callType != null) 'callType': callType,
        if (callStatus != null) 'callStatus': callStatus,
      };
}

enum ConversationType { doctor, caregiver, ai }

class ConversationModel {
  final String id;
  final String participantId;
  final String participantName;
  final String participantSpecialty;
  final ConversationType type;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? imageUrl;

  const ConversationModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantSpecialty,
    required this.type,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.imageUrl,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversationModel(
      id: id,
      participantId: map['participantId'] ?? '',
      participantName: map['participantName'] ?? '',
      participantSpecialty: map['participantSpecialty'] ?? '',
      type: ConversationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ConversationType.doctor,
      ),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
          : DateTime.now(),
      unreadCount: map['unreadCount'] ?? 0,
      isOnline: map['isOnline'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
        'participantId': participantId,
        'participantName': participantName,
        'participantSpecialty': participantSpecialty,
        'type': type.name,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
        'unreadCount': unreadCount,
        'isOnline': isOnline,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}
