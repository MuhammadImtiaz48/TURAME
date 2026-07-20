import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment_model.dart';

class ProviderAppointmentModel {
  final String id;
  final String providerId;
  final String patientId;
  final String patientName;
  final String avatarEmoji;
  final String reason;
  final AppointmentType type;
  final DateTime dateTime;
  final int durationMins;
  final AppointmentStatus status;

  const ProviderAppointmentModel({
    required this.id,
    this.providerId = '',
    required this.patientId,
    required this.patientName,
    required this.avatarEmoji,
    required this.reason,
    required this.type,
    required this.dateTime,
    required this.durationMins,
    required this.status,
  });

  String get typeLabel {
    switch (type) {
      case AppointmentType.video:
        return 'Video Call';
      case AppointmentType.audio:
        return 'Audio Call';
      case AppointmentType.home:
        return 'In-Person';
      case AppointmentType.clinic:
        return 'Clinic';
    }
  }

  ProviderAppointmentModel copyWith({AppointmentStatus? status}) {
    return ProviderAppointmentModel(
      id: id,
      providerId: providerId,
      patientId: patientId,
      patientName: patientName,
      avatarEmoji: avatarEmoji,
      reason: reason,
      type: type,
      dateTime: dateTime,
      durationMins: durationMins,
      status: status ?? this.status,
    );
  }

  factory ProviderAppointmentModel.fromMap(Map<String, dynamic> map) {
    AppointmentType parseType(dynamic v) =>
        AppointmentType.values.firstWhere((e) => e.name == (v ?? 'video'),
            orElse: () => AppointmentType.video);
    AppointmentStatus parseStatus(dynamic v) =>
        AppointmentStatus.values.firstWhere((e) => e.name == (v ?? 'pending'),
            orElse: () => AppointmentStatus.pending);
    DateTime parseDt(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return ProviderAppointmentModel(
      id: map['id'] ?? '',
      providerId: map['providerId'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      avatarEmoji: map['avatarEmoji'] ?? '🧑',
      reason: map['reason'] ?? map['specialty'] ?? '',
      type: parseType(map['type']),
      dateTime: parseDt(map['dateTime']),
      durationMins: map['durationMins'] ?? 30,
      status: parseStatus(map['status']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'providerId': providerId,
        'patientId': patientId,
        'patientName': patientName,
        'avatarEmoji': avatarEmoji,
        'reason': reason,
        'specialty': reason,
        'type': type.name,
        'dateTime': Timestamp.fromDate(dateTime),
        'durationMins': durationMins,
        'status': status.name,
      };

}

