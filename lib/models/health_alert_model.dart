import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum AlertSeverity { warning, critical }

class HealthAlertModel {
  final String id;
  final String metricName;
  final String metricEmoji;
  final String description;
  final double detectedValue;
  final String unit;
  final String normalRange;
  final AlertSeverity severity;
  final DateTime detectedAt;
  final String aiRecommendation;

  const HealthAlertModel({
    required this.id,
    required this.metricName,
    required this.metricEmoji,
    required this.description,
    required this.detectedValue,
    required this.unit,
    required this.normalRange,
    required this.severity,
    required this.detectedAt,
    required this.aiRecommendation,
  });

  Color get severityColor {
    switch (severity) {
      case AlertSeverity.warning:  return AppColors.warning;
      case AlertSeverity.critical: return AppColors.danger;
    }
  }

  Color get cardBgColor {
    switch (severity) {
      case AlertSeverity.warning:  return AppColors.warningLighter;
      case AlertSeverity.critical: return AppColors.dangerLighter;
    }
  }
}