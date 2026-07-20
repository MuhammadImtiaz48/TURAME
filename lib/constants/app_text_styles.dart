import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─── Display ──────────────────────────────────────────────────
  static TextStyle get displayLarge => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static TextStyle get displayMedium => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.25,
  );

  // ─── Headings ─────────────────────────────────────────────────
  static TextStyle get h1 => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get h2 => TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get h3 => TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ─── Body ─────────────────────────────────────────────────────
  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ─── Labels ───────────────────────────────────────────────────
  static TextStyle get labelLarge => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle get labelMedium => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static TextStyle get labelSmall => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.3,
  );

  // ─── Button ───────────────────────────────────────────────────
  static TextStyle get buttonLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
    letterSpacing: 0.3,
  );

  static TextStyle get buttonMedium => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
    letterSpacing: 0.2,
  );

  // ─── Special ──────────────────────────────────────────────────
  static TextStyle get metric => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: 'monospace',
    height: 1.1,
  );

  static TextStyle get metricSmall => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: 'monospace',
    height: 1.1,
  );

  static TextStyle get price => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    height: 1.2,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  static TextStyle get badge => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
    letterSpacing: 0.3,
  );

  // ─── On Dark ──────────────────────────────────────────────────
  static TextStyle get onDarkTitle => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
    height: 1.3,
  );

  static TextStyle get onDarkBody => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: Color(0xCCFFFFFF),
    height: 1.5,
  );
}