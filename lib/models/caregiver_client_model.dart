import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum CaregiverClientStatus { active, pending, inactive }

class CaregiverClientModel {
  final String id;
  final String name;
  final String careType;
  final String location;
  final String since;
  final CaregiverClientStatus status;
  final String avatarEmoji;
  final String? imageUrl;
  final int age;
  final String phone;
  final String emergencyContact;
  final List<String> careNeeds;
  final List<String> medications;
  final String? requestNote;
  final String? nextShift;
  final String dailyRate;
  final String hours;

  const CaregiverClientModel({
    required this.id,
    required this.name,
    required this.careType,
    required this.location,
    required this.since,
    required this.status,
    required this.avatarEmoji,
    this.imageUrl,
    required this.age,
    required this.phone,
    required this.emergencyContact,
    this.careNeeds = const [],
    this.medications = const [],
    this.requestNote,
    this.nextShift,
    this.dailyRate = '',
    this.hours = '',
  });

  String get statusLabel {
    switch (status) {
      case CaregiverClientStatus.active:
        return 'Active';
      case CaregiverClientStatus.pending:
        return 'New Request';
      case CaregiverClientStatus.inactive:
        return 'Inactive';
    }
  }

  Color get statusColor {
    switch (status) {
      case CaregiverClientStatus.active:
        return AppColors.healthGreen;
      case CaregiverClientStatus.pending:
        return AppColors.warning;
      case CaregiverClientStatus.inactive:
        return AppColors.textTertiary;
    }
  }

  Color get statusBg {
    switch (status) {
      case CaregiverClientStatus.active:
        return AppColors.healthGreenLighter;
      case CaregiverClientStatus.pending:
        return AppColors.warningLighter;
      case CaregiverClientStatus.inactive:
        return AppColors.borderLight;
    }
  }

  CaregiverClientModel copyWith({CaregiverClientStatus? status}) {
    return CaregiverClientModel(
      id: id,
      name: name,
      careType: careType,
      location: location,
      since: since,
      status: status ?? this.status,
      avatarEmoji: avatarEmoji,
      imageUrl: imageUrl,
      age: age,
      phone: phone,
      emergencyContact: emergencyContact,
      careNeeds: careNeeds,
      medications: medications,
      requestNote: requestNote,
      nextShift: nextShift,
      dailyRate: dailyRate,
      hours: hours,
    );
  }

}

