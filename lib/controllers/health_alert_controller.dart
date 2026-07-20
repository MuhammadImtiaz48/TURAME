import 'package:get/get.dart';
import '../models/health_alert_model.dart';

class HealthAlertController extends GetxController {
  // In real app — passed via Get.arguments or fetched from Firebase
  final alert = HealthAlertModel(
    id: 'ALT001',
    metricName: 'High Heart Rate',
    metricEmoji: '❤️',
    description: 'Above normal resting range',
    detectedValue: 142,
    unit: 'bpm',
    normalRange: '60–100 bpm',
    severity: AlertSeverity.critical,
    detectedAt: DateTime(2025, 6, 24, 9, 38),
    aiRecommendation:
    'Your heart rate is significantly elevated. Rest immediately, avoid physical activity. '
        'If this persists for more than 10 minutes or you experience chest pain, '
        'seek emergency care immediately.',
  );

  String get formattedTime {
    final h = alert.detectedAt.hour > 12
        ? alert.detectedAt.hour - 12
        : alert.detectedAt.hour;
    final ampm = alert.detectedAt.hour >= 12 ? 'PM' : 'AM';
    final m = alert.detectedAt.minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }

  void notifyDoctor() {
    Get.snackbar(
      '✅ Doctor Notified',
      'Your doctor has been alerted about this reading.',
      snackPosition: SnackPosition.TOP,
    );
  }

  void notifyFamily() {
    Get.snackbar(
      '✅ Family Notified',
      'Your family has been alerted about this reading.',
      snackPosition: SnackPosition.TOP,
    );
  }

  void callEmergency() {
    Get.snackbar(
      '🚨 Emergency SOS',
      'Calling emergency services...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
    );
  }
}