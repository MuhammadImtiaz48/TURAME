// ============================================================
// FILE: lib/models/user_model.dart
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { patient, provider, caregiver, home }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? fcmToken;
  final DateTime? createdAt;
  final bool notificationsEnabled;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.fcmToken,
    this.createdAt,
    this.notificationsEnabled = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt'] as String);
      }
    }

    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == (map['role'] ?? 'patient'),
        orElse: () => UserRole.patient,
      ),
      fcmToken: map['fcmToken'],
      createdAt: parsedCreatedAt,
      notificationsEnabled: map['notificationsEnabled'] == true ||
          map['notificationsEnabled'] == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'fcmToken': fcmToken,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJsonMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'fcmToken': fcmToken,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? fcmToken,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}