// ============================================================
// FILE: lib/views/screens/client/dashboard/widgets/dashboard_header.dart
// Gradient header with greeting, notification bell and search.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';
import 'package:rambaa/routes/app_routes.dart';
import 'package:rambaa/views/widgets/app_text_field.dart';

class DashboardHeader extends StatelessWidget {
  final String name;
  final String greeting;
  final int notifCount;

  const DashboardHeader({
    super.key,
    required this.name,
    required this.greeting,
    required this.notifCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingMD,
        MediaQuery.of(context).padding.top + 20.h,
        AppTheme.spacingMD,
        AppTheme.spacingXXL,
      ),
      child: Column(
        children: [
          // ── Top row ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$greeting 👋', style: AppTextStyles.onDarkBody),
                  SizedBox(height: 2.h),
                  Text(name, style: AppTextStyles.onDarkTitle),
                ],
              ),
              // Notification Bell
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
            ],
          ),

          SizedBox(height: 10.h),

          // ── Search bar ───────────────────────────────────────────
          AppTextField(
            label: "",
            hint: 'search'.tr,
            type: AppTextFieldType.search,
            isSearchStyle: true,
            prefixIcon: Icon(Icons.search_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
