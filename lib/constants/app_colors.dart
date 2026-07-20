import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary (Blue — logo hand left) ─────────────────────────
  static const Color primary        = Color(0xFF5270FF);
  static const Color primaryLight   = Color(0xCC5270FF);      // ← Changed
  static const Color primaryLighter = Color(0xFFE3F2FD);

  // ─── Secondary (Rose/Pink — logo hand right) ──────────────────
  static const Color secondary        = Color(0xFF0499AD);
  static  Color secondaryLight   = Color(0xFF0499AD).withValues(alpha: 0.8);
  static const Color secondaryLighter = Color(0xFFFCE4EC);

  // ─── Health Green (leaves in logo) ────────────────────────────
  static const Color healthGreen        = Color(0xFF43A047);
  static const Color healthGreenLight   = Color(0xFF66BB6A);
  static const Color healthGreenLighter = Color(0xFFE8F5E9);

  // ─── Accent (Caregiver Orange) ────────────────────────────────
  static const Color accent        = Color(0xFFFF6D00);
  static const Color accentLight   = Color(0xFFFF9E40);
  static const Color accentLighter = Color(0xFFFFF3E0);

  // ─── Status ───────────────────────────────────────────────────
  static const Color success        = Color(0xFF2E7D32);
  static const Color successLight   = Color(0xFF43A047);
  static const Color successLighter = Color(0xFFE8F5E9);

  static const Color danger        = Color(0xFFC62828);
  static const Color dangerLight   = Color(0xFFEF5350);
  static const Color dangerLighter = Color(0xFFFFEBEE);

  static const Color warning        = Color(0xFFF57F17);
  static const Color warningLighter = Color(0xFFFFFDE7);

  // ─── Background & Surface ─────────────────────────────────────
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color surface2   = Color(0xFFF8FAFF);

  // ─── Text ─────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF455A64);
  static const Color textTertiary  = Color(0xFF90A4AE);
  static const Color textOnDark    = Color(0xFFFFFFFF);

  // ─── Border ───────────────────────────────────────────────────
  static const Color border      = Color(0xFFE0E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // ─── Health Metric Colors ─────────────────────────────────────
  static const Color heartRate     = Color(0xFFC62828);
  static const Color oxygen        = Color(0xFF1565C0);
  static const Color bloodPressure = Color(0xFF6A1B9A);
  static const Color bloodSugar    = Color(0xFFF57F17);

  // ─── Role Identity ────────────────────────────────────────────
  static const Color patientColor   = Color(0xFF1565C0);
  static const Color providerColor  = Color(0xFF43A047);
  static const Color caregiverColor = Color(0xFFE91E8C);
  static const Color homeColor        = Color(0xFF7B1FA2);

  // ─── Shadows ──────────────────────────────────────────────────
  static const Color shadowSm = Color(0x141565C0);
  static const Color shadowMd = Color(0x1F1565C0);
  static const Color shadowLg = Color(0x291565C0);

  // ─── Gradients ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Welcome screen gradient — blue to pink (logo colors)
  static const LinearGradient welcomeGradient = LinearGradient(
    colors: [Color(0xFF5270FF), Color(0xFF0499AD), Color(0xFF0499AD)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient healthGradient = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFC62828), Color(0xFFEF5350)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient caregiverGradient = LinearGradient(
    colors: [Color(0xFFE91E8C), Color(0xFFF48FB1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}