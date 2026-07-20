// ============================================================
// FILE: lib/views/screens/client/dashboard/widgets/health_summary_card.dart
// Today's health metrics summary card.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';

class HealthSummaryCard extends StatelessWidget {
  final String heartRate;
  final String oxygen;
  final String bloodPressure;

  const HealthSummaryCard({
    super.key,
    required this.heartRate,
    required this.oxygen,
    required this.bloodPressure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLighter, AppColors.healthGreenLighter],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('todays_health'.tr, style: AppTextStyles.h3),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'All Normal',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Metrics row
          IntrinsicHeight(
            child: Row(
              children: [
                HealthMetricItem(
                  label: 'HEART RATE',
                  value: heartRate,
                  unit: 'bpm',
                  color: AppColors.heartRate,
                ),
                VerticalDivider(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
                HealthMetricItem(
                  label: 'OXYGEN',
                  value: oxygen,
                  unit: 'SpO₂',
                  color: AppColors.oxygen,
                ),
                VerticalDivider(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
                HealthMetricItem(
                  label: 'BLOOD P.',
                  value: bloodPressure,
                  unit: 'mmHg',
                  color: AppColors.bloodPressure,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HealthMetricItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const HealthMetricItem({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(fontSize: 9.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(value, style: AppTextStyles.metricSmall.copyWith(color: color)),
          Text(unit, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
