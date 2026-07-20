// ============================================================
// FILE: lib/views/screens/client/dashboard/widgets/emergency_sos.dart
// Emergency SOS long-press card.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';

class EmergencySos extends StatelessWidget {
  final VoidCallback? onLongPress;

  const EmergencySos({super.key, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMD,
          vertical: 25.h,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.emergencyGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🚨', style: TextStyle(fontSize: 28)),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'emergency_sos'.tr,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Tap and hold to alert emergency services',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnDark.withValues(alpha: 0.85),
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
