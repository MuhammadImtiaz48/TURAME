// Collection: users/{userId}/notifications/{notificationId}

enum NotificationType { health, payment, appointment, message, call, general }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String category;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, String> data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.createdAt,
    this.isRead = false,
    this.data = const {},
  });

  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) {
      final h = createdAt.hour > 12
          ? createdAt.hour - 12
          : (createdAt.hour == 0 ? 12 : createdAt.hour);
      final period = createdAt.hour >= 12 ? 'PM' : 'AM';
      final min = createdAt.minute.toString().padLeft(2, '0');
      return '$h:$min $period';
    }
    if (diff.inDays == 1) return 'Yesterday';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.general,
      ),
      category: map['category']?.toString() ?? 'General',
      isRead: map['isRead'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'] is int
                  ? map['createdAt'] as int
                  : int.tryParse(map['createdAt'].toString()) ?? 0,
            )
          : DateTime.now(),
      data: Map<String, String>.from(
        (map['data'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v.toString()),
            ) ??
            {},
      ),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'message': message,
        'type': type.name,
        'category': category,
        'isRead': isRead,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'data': data,
      };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        message: message,
        type: type,
        category: category,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        data: data,
      );
}
