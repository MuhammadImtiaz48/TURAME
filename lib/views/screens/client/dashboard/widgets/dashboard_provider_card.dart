// ============================================================
// FILE: lib/views/screens/client/dashboard/widgets/dashboard_provider_card.dart
// Featured provider card with a Book action.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';
import 'package:rambaa/models/provider_model.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/dashboard_models.dart';

class DashboardProviderCard extends StatelessWidget {
  final DashboardProviderData data;
  final ProviderModel? provider;
  final VoidCallback? onBook;

  const DashboardProviderCard({
    super.key,
    required this.data,
    this.provider,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Avatar
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: data.bg,
              shape: BoxShape.circle,
              image: data.imageUrl != null && data.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(data.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: data.imageUrl == null || data.imageUrl!.isEmpty
                ? Center(
                    child: Text(data.emoji, style: TextStyle(fontSize: 22.sp)),
                  )
                : null,
          ),

          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name, style: AppTextStyles.h3),
                SizedBox(height: 2.h),
                Text(data.spec, style: AppTextStyles.bodySmall),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 3.w),
                    Text(
                      '${data.rating} ',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.warning,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text('(${data.reviews})', style: AppTextStyles.caption),
                    if (data.available) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.healthGreenLighter,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Available',
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.healthGreen,
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '📍 ${data.distance} · 💰 ${data.fee}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // Book button
          GestureDetector(
            onTap: onBook,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Text(
                'Book',
                style: AppTextStyles.buttonMedium.copyWith(fontSize: 12.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
