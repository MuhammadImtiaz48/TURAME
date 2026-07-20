import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum AppointmentStatus { confirmed, pending, completed, cancelled }

enum AppointmentType { video, audio, home, clinic }

class AppointmentModel {
  final String id;
  final String patientId;
  final String providerId;
  final String providerName;
  final String specialty;
  final String avatarEmoji;
  final String? imageUrl;
  final AppointmentType type;
  final DateTime dateTime;
  final int durationMins;
  final AppointmentStatus status;
  final bool callCompleted;

  const AppointmentModel({
    required this.id,
    this.patientId = '',
    this.providerId = '',
    required this.providerName,
    required this.specialty,
    required this.avatarEmoji,
    this.imageUrl,
    required this.type,
    required this.dateTime,
    required this.durationMins,
    required this.status,
    this.callCompleted = false,
  });

  String get typeLabel {
    switch (type) {
      case AppointmentType.video:  return 'Video Call';
      case AppointmentType.audio:  return 'Audio Call';
      case AppointmentType.home:   return 'Home Visit';
      case AppointmentType.clinic: return 'Clinic';
    }
  }

  String get typeIcon {
    switch (type) {
      case AppointmentType.video:  return '📹';
      case AppointmentType.audio:  return '🎧';
      case AppointmentType.home:   return '🏠';
      case AppointmentType.clinic: return '🏥';
    }
  }

  Color get statusColor {
    switch (status) {
      case AppointmentStatus.confirmed: return AppColors.primary;
      case AppointmentStatus.pending:   return AppColors.warning;
      case AppointmentStatus.completed: return AppColors.success;
      case AppointmentStatus.cancelled: return AppColors.danger;
    }
  }

  Color get borderColor {
    switch (status) {
      case AppointmentStatus.confirmed: return AppColors.primaryLighter;
      case AppointmentStatus.pending:   return AppColors.warningLighter;
      case AppointmentStatus.completed: return AppColors.successLighter;
      case AppointmentStatus.cancelled: return AppColors.dangerLighter;
    }
  }

  AppointmentModel copyWith({
    AppointmentStatus? status,
    bool? callCompleted,
  }) {
    return AppointmentModel(
      id: id,
      patientId: patientId,
      providerId: providerId,
      providerName: providerName,
      specialty: specialty,
      avatarEmoji: avatarEmoji,
      imageUrl: imageUrl,
      type: type,
      dateTime: dateTime,
      durationMins: durationMins,
      status: status ?? this.status,
      callCompleted: callCompleted ?? this.callCompleted,
    );
  }

  bool get isWithinCallWindow {
    final now = DateTime.now();
    final start = dateTime.subtract(const Duration(minutes: 15));
    final end = dateTime.add(const Duration(minutes: 30));
    return now.isAfter(start) && now.isBefore(end);
  }

  bool get isInactive => status == AppointmentStatus.completed;

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
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

    return AppointmentModel(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      specialty: map['specialty'] ?? map['reason'] ?? '',
      avatarEmoji: map['avatarEmoji'] ?? '👩‍⚕️',
      imageUrl: map['imageUrl'],
      type: parseType(map['type']),
      dateTime: parseDt(map['dateTime']),
      durationMins: map['durationMins'] ?? 30,
      status: parseStatus(map['status']),
      callCompleted: map['callCompleted'] == true || map['callCompleted'] == 'true',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'providerId': providerId,
        'providerName': providerName,
        'specialty': specialty,
        'reason': specialty,
        'avatarEmoji': avatarEmoji,
        'imageUrl': imageUrl,
        'type': type.name,
        'dateTime': Timestamp.fromDate(dateTime),
        'durationMins': durationMins,
        'status': status.name,
        'callCompleted': callCompleted,
      };

}
