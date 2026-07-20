import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum HealthStatus { normal, warning, critical }

enum DeviceType { appleWatch, samsungHealth, fitbit, other }

class HealthMetricModel {
  final String id;
  final String emoji;
  final String value;
  final String unit;
  final String label;
  final HealthStatus status;
  final Color cardColor;
  final Color metricColor;
  final List<double> sparkline; // mini chart data

  const HealthMetricModel({
    required this.id,
    required this.emoji,
    required this.value,
    required this.unit,
    required this.label,
    required this.status,
    required this.cardColor,
    required this.metricColor,
    required this.sparkline,
  });

  String get statusLabel {
    switch (status) {
      case HealthStatus.normal:   return 'Normal';
      case HealthStatus.warning:  return 'Warning';
      case HealthStatus.critical: return 'Critical';
    }
  }

  Color get statusColor {
    switch (status) {
      case HealthStatus.normal:   return AppColors.healthGreen;
      case HealthStatus.warning:  return AppColors.warning;
      case HealthStatus.critical: return AppColors.danger;
    }
  }
}

class ConnectedDeviceModel {
  final String name;
  final String subtitle;
  final DeviceType type;
  final bool isConnected;
  final bool isAvailable;
  final int? batteryPercent;

  const ConnectedDeviceModel({
    required this.name,
    required this.subtitle,
    required this.type,
    required this.isConnected,
    this.isAvailable = true,
    this.batteryPercent,
  });

  ConnectedDeviceModel copyWith({
    String? name,
    String? subtitle,
    DeviceType? type,
    bool? isConnected,
    bool? isAvailable,
    int? batteryPercent,
    bool clearBattery = false,
  }) {
    return ConnectedDeviceModel(
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      isConnected: isConnected ?? this.isConnected,
      isAvailable: isAvailable ?? this.isAvailable,
      batteryPercent:
          clearBattery ? null : (batteryPercent ?? this.batteryPercent),
    );
  }

  String get deviceIcon {
    switch (type) {
      case DeviceType.appleWatch:    return '⌚';
      case DeviceType.samsungHealth: return '📱';
      case DeviceType.fitbit:        return '⌚';
      case DeviceType.other:         return '🔗';
    }
  }
}