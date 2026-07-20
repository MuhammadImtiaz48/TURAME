import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum PatientStatus { active, pending, inactive }

extension PatientStatusX on PatientStatus {
  String get statusLabel {
    switch (this) {
      case PatientStatus.active:
        return 'Active';
      case PatientStatus.pending:
        return 'Pending';
      case PatientStatus.inactive:
        return 'Inactive';
    }
  }

  Color get statusColor {
    switch (this) {
      case PatientStatus.active:
        return AppColors.healthGreen;
      case PatientStatus.pending:
        return AppColors.warning;
      case PatientStatus.inactive:
        return AppColors.textTertiary;
    }
  }
}

class PatientModel {
  final String id;
  final String name;
  final int age;
  final String condition;
  final String location;
  final String lastVisit;
  final PatientStatus status;
  final String bloodType;
  final String phone;
  final String avatarEmoji;
  final String? imageUrl;
  final String? nextAppointment;
  final List<String> medicalHistory;
  final List<String> medications;
  final String? requestNote;
  final DateTime? registeredAt;

  // ── Vitals entered by the provider ──────────────────────────
  final String? heartRate;
  final String? oxygen;
  final String? bloodPressure;
  final String? bloodSugar;

  PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.location,
    required this.lastVisit,
    required this.status,
    required this.bloodType,
    required this.phone,
    required this.avatarEmoji,
    this.imageUrl,
    this.nextAppointment,
    this.medicalHistory = const [],
    this.medications = const [],
    this.requestNote,
    this.registeredAt,
    this.heartRate,
    this.oxygen,
    this.bloodPressure,
    this.bloodSugar,
  });

  String get statusLabel {
    switch (status) {
      case PatientStatus.active:
        return 'Active';
      case PatientStatus.pending:
        return 'New Request';
      case PatientStatus.inactive:
        return 'Inactive';
    }
  }

  Color get statusColor {
    switch (status) {
      case PatientStatus.active:
        return AppColors.healthGreen;
      case PatientStatus.pending:
        return AppColors.warning;
      case PatientStatus.inactive:
        return AppColors.textTertiary;
    }
  }

  Color get statusBg {
    switch (status) {
      case PatientStatus.active:
        return AppColors.healthGreenLighter;
      case PatientStatus.pending:
        return AppColors.warningLighter;
      case PatientStatus.inactive:
        return AppColors.borderLight;
    }
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedRegisteredAt;
    if (map['registeredAt'] != null) {
      if (map['registeredAt'] is Timestamp) {
        parsedRegisteredAt = (map['registeredAt'] as Timestamp).toDate();
      } else if (map['registeredAt'] is String) {
        parsedRegisteredAt = DateTime.tryParse(map['registeredAt'] as String);
      }
    } else if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedRegisteredAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedRegisteredAt = DateTime.tryParse(map['createdAt'] as String);
      }
    }

    List<String> parseList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return PatientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      condition: map['condition'] ?? '',
      location: map['location'] ?? '',
      lastVisit: map['lastVisit'] ?? '',
      status: PatientStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'active'),
        orElse: () => PatientStatus.active,
      ),
      bloodType: map['bloodType'] ?? '',
      phone: map['phone'] ?? '',
      avatarEmoji: map['avatarEmoji'] ?? '👤',
      imageUrl: map['imageUrl'],
      nextAppointment: map['nextAppointment'],
      medicalHistory: parseList(map['medicalHistory']),
      medications: parseList(map['medications']),
      requestNote: map['requestNote'],
      registeredAt: parsedRegisteredAt,
      heartRate: map['heartRate']?.toString(),
      oxygen: map['oxygen']?.toString(),
      bloodPressure: map['bloodPressure']?.toString(),
      bloodSugar: map['bloodSugar']?.toString(),
    );
  }

  PatientModel copyWith({
    String? name,
    int? age,
    String? condition,
    String? location,
    String? lastVisit,
    PatientStatus? status,
    String? bloodType,
    String? phone,
    String? avatarEmoji,
    String? imageUrl,
    String? nextAppointment,
    List<String>? medicalHistory,
    List<String>? medications,
    String? requestNote,
    DateTime? registeredAt,
    String? heartRate,
    String? oxygen,
    String? bloodPressure,
    String? bloodSugar,
  }) {
    return PatientModel(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      lastVisit: lastVisit ?? this.lastVisit,
      status: status ?? this.status,
      bloodType: bloodType ?? this.bloodType,
      phone: phone ?? this.phone,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      imageUrl: imageUrl ?? this.imageUrl,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      medications: medications ?? this.medications,
      requestNote: requestNote ?? this.requestNote,
      registeredAt: registeredAt ?? this.registeredAt,
      heartRate: heartRate ?? this.heartRate,
      oxygen: oxygen ?? this.oxygen,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      bloodSugar: bloodSugar ?? this.bloodSugar,
    );
  }

  String get registeredLabel {
    final dt = registeredAt;
    if (dt == null) return 'Registration date unknown';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return 'Registered ${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$minute $ampm';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'condition': condition,
      'location': location,
      'lastVisit': lastVisit,
      'status': status.name,
      'bloodType': bloodType,
      'phone': phone,
      'avatarEmoji': avatarEmoji,
      'imageUrl': imageUrl,
      'nextAppointment': nextAppointment,
      'medicalHistory': medicalHistory,
      'medications': medications,
      'requestNote': requestNote,
      'heartRate': heartRate,
      'oxygen': oxygen,
      'bloodPressure': bloodPressure,
      'bloodSugar': bloodSugar,
      'registeredAt':
          registeredAt != null ? Timestamp.fromDate(registeredAt!) : null,
    };
  }

}

