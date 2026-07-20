// ============================================================
// FILE: lib/views/screens/client/dashboard/widgets/upcoming_appointment_card.dart
// Upcoming appointment card (or empty state) driven by an AppointmentModel.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';
import 'package:rambaa/models/appointment_model.dart';
import 'package:rambaa/routes/app_routes.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  final AppointmentModel? appointment;

  const UpcomingAppointmentCard({super.key, this.appointment});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _formatDate(DateTime dt) =>
      '${_days[dt.weekday - 1]}, ${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    if (appointment == null) {
      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.booking),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(AppTheme.spacingMD),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.calendar_today_outlined,
                      color: AppColors.primary, size: 20),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('no_upcoming'.tr, style: AppTextStyles.h3),
                    SizedBox(height: 2.h),
                    Text('book_appointment_sub'.tr,
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: AppColors.textTertiary, size: 20.r),
            ],
          ),
        ),
      );
    }

    final a = appointment!;
    final end = a.dateTime.add(Duration(minutes: a.durationMins));
    final statusLabel = switch (a.status) {
      AppointmentStatus.confirmed => 'confirmed'.tr,
      AppointmentStatus.pending => 'pending'.tr,
      AppointmentStatus.completed => a.isInactive ? 'Inactive' : 'completed'.tr,
      AppointmentStatus.cancelled => 'cancelled'.tr,
    };
    final statusColor = a.isInactive
        ? AppColors.textTertiary
        : switch (a.status) {
              AppointmentStatus.confirmed => AppColors.primary,
              AppointmentStatus.pending => AppColors.warning,
              AppointmentStatus.completed => AppColors.success,
              AppointmentStatus.cancelled => AppColors.danger,
            };

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.appointments),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppTheme.shadowSm,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMD,
                vertical: 12.h,
              ),
              color: AppColors.primaryLighter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(a.dateTime),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontSize: 13.sp,
                        ),
                      ),
                      Text(
                        '${_formatTime(a.dateTime)} – ${_formatTime(end)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: a.isInactive
                          ? AppColors.borderLight
                          : AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: a.isInactive
                            ? AppColors.border
                            : AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      statusLabel,
                      style: AppTextStyles.badge.copyWith(
                        color: statusColor,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingMD),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      shape: BoxShape.circle,
                      image: a.imageUrl != null && a.imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(a.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: a.imageUrl == null || a.imageUrl!.isEmpty
                        ? Center(
                            child: Text(a.avatarEmoji,
                                style: TextStyle(fontSize: 20.sp)),
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.providerName, style: AppTextStyles.h3),
                        SizedBox(height: 2.h),
                        Text(
                          '${a.specialty} · ${a.typeLabel} ${a.typeIcon}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
