// ============================================================
// FILE: lib/views/screens/provider/widgets/provider_header.dart
// Provider dashboard gradient header with stats.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';
import 'package:rambaa/routes/app_routes.dart';

class ProviderHeader extends StatelessWidget {
  final String doctorName;
  final String greeting;
  final int todayCount;
  final int thisWeekCount;
  final int pendingCount;
  final int notifCount;
  final String? imageUrl;

  const ProviderHeader({
    super.key,
    required this.doctorName,
    required this.greeting,
    required this.todayCount,
    required this.thisWeekCount,
    required this.pendingCount,
    this.notifCount = 0,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.healthGradient,
      ),
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingMD,
        MediaQuery.of(context).padding.top + 16.h,
        AppTheme.spacingMD,
        AppTheme.spacingXXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting, style: AppTextStyles.onDarkBody),
                    SizedBox(height: 2.h),
                    Text(doctorName, style: AppTextStyles.onDarkTitle),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Healthcare Provider',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: () => Get.toNamed(AppRoutes.notification),
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textOnDark,
                            size: 22,
                          ),
                        ),
                      ),
                      if (notifCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 18.w,
                            height: 18.w,
                            decoration: BoxDecoration(
                              color: AppColors.dangerLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.textOnDark,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$notifCount',
                                style: AppTextStyles.badge.copyWith(fontSize: 9.sp),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      image: imageUrl != null && imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl == null || imageUrl!.isEmpty
                        ? Center(
                            child: Text('🩺', style: TextStyle(fontSize: 24.sp)),
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: ProviderStatBox(
                  value: '$todayCount',
                  label: 'Today',
                  icon: Icons.calendar_today_rounded,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ProviderStatBox(
                  value: '$thisWeekCount',
                  label: 'This Week',
                  icon: Icons.date_range_rounded,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ProviderStatBox(
                  value: '$pendingCount',
                  label: 'Pending',
                  icon: Icons.pending_actions_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProviderStatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const ProviderStatBox({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: AppTextStyles.onDarkTitle.copyWith(fontSize: 18.sp),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textOnDark.withValues(alpha: 0.75),
              fontSize: 9.sp,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
