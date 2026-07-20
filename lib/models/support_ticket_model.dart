import 'package:cloud_firestore/cloud_firestore.dart';

enum SupportTicketStatus { open, inProgress, resolved, closed }

enum SupportTicketCategory { technical, billing, account, appointment, general }

class SupportTicketResponse {
  final String text;
  final String senderRole;
  final DateTime createdAt;

  const SupportTicketResponse({
    required this.text,
    required this.senderRole,
    required this.createdAt,
  });

  factory SupportTicketResponse.fromMap(Map<String, dynamic> map) {
    return SupportTicketResponse(
      text: map['text']?.toString() ?? '',
      senderRole: map['senderRole']?.toString() ?? 'user',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderRole': senderRole,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

class SupportTicketModel {
  final String id;
  final String userId;
  final String subject;
  final String description;
  final SupportTicketCategory category;
  final SupportTicketStatus status;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SupportTicketResponse> responses;

  const SupportTicketModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.category,
    this.status = SupportTicketStatus.open,
    this.priority = 'medium',
    required this.createdAt,
    required this.updatedAt,
    this.responses = const [],
  });

  factory SupportTicketModel.fromMap(Map<String, dynamic> map, String id) {
    return SupportTicketModel(
      id: id,
      userId: map['userId']?.toString() ?? '',
      subject: map['subject']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: SupportTicketCategory.values.firstWhere(
        (e) => e.name == (map['category'] ?? 'general'),
        orElse: () => SupportTicketCategory.general,
      ),
      status: SupportTicketStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'open'),
        orElse: () => SupportTicketStatus.open,
      ),
      priority: map['priority']?.toString() ?? 'medium',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      responses: (map['responses'] as List?)
              ?.map((r) => SupportTicketResponse.fromMap(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'subject': subject,
      'description': description,
      'category': category.name,
      'status': status.name,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'responses': responses.map((r) => r.toMap()).toList(),
    };
  }

  SupportTicketModel copyWith({
    String? id,
    String? userId,
    String? subject,
    String? description,
    SupportTicketCategory? category,
    SupportTicketStatus? status,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SupportTicketResponse>? responses,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      responses: responses ?? this.responses,
    );
  }
}
