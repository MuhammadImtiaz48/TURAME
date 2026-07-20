import 'appointment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class CaregiverScheduleModel {
  final String id;
  final String clientId;
  final String clientName;
  final String avatarEmoji;
  final String? imageUrl;
  final String careType;
  final DateTime dateTime;
  final String hours;
  final AppointmentStatus status;

  const CaregiverScheduleModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.avatarEmoji,
    this.imageUrl,
    required this.careType,
    required this.dateTime,
    required this.hours,
    required this.status,
  });

  CaregiverScheduleModel copyWith({AppointmentStatus? status, DateTime? dateTime}) {
    return CaregiverScheduleModel(
      id: id,
      clientId: clientId,
      clientName: clientName,
      avatarEmoji: avatarEmoji,
      imageUrl: imageUrl,
      careType: careType,
      dateTime: dateTime ?? this.dateTime,
      hours: hours,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
      'avatarEmoji': avatarEmoji,
      'imageUrl': imageUrl,
      'careType': careType,
        'dateTime': dateTime,
        'hours': hours,
        'status': status.name,
      };

  factory CaregiverScheduleModel.fromMap(Map<String, dynamic> map) {
    AppointmentStatus parseStatus(dynamic v) =>
        AppointmentStatus.values.firstWhere((e) => e.name == (v ?? 'pending'),
            orElse: () => AppointmentStatus.pending);
    DateTime parseDt(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) {
        final parsed = DateTime.tryParse(v);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return CaregiverScheduleModel(
      id: map['id'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      avatarEmoji: map['avatarEmoji'] ?? '👤',
      imageUrl: map['imageUrl'],
      careType: map['careType'] ?? '',
      dateTime: parseDt(map['dateTime']),
      hours: map['hours'] ?? '',
      status: parseStatus(map['status']),
    );
  }
}
