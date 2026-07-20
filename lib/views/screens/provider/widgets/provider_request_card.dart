// ============================================================
// FILE: lib/views/screens/provider/widgets/provider_request_card.dart
// Pending appointment request card with accept / decline actions.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';
import 'package:rambaa/models/provider_appointment_model.dart';

class ProviderRequestCard extends StatelessWidget {
  final ProviderAppointmentModel appointment;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ProviderRequestCard({
    super.key,
    required this.appointment,
    required this.onAccept,
    required this.onDecline,
  });

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.warningLighter),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLighter,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(appointment.avatarEmoji,
                      style: TextStyle(fontSize: 20.sp)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.patientName, style: AppTextStyles.h3),
                    SizedBox(height: 2.h),
                    Text(appointment.reason, style: AppTextStyles.bodySmall),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 13, color: AppColors.textTertiary),
                        SizedBox(width: 4.w),
                        Text(
                          '${_formatTime(appointment.dateTime)} · ${appointment.typeLabel}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.warningLighter,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'pending'.tr,
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.warning,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.providerColor,
                    minimumSize: Size(double.infinity, 40.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: Text('accept'.tr, style: AppTextStyles.buttonMedium),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: Size(double.infinity, 40.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: Text('decline'.tr,
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColors.textSecondary,
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
