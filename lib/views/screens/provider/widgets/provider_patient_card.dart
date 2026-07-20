// ============================================================
// FILE: lib/views/screens/provider/widgets/provider_patient_card.dart
// Patient card used on the provider dashboard home tab.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';

class ProviderPatientCard extends StatelessWidget {
  final String name;
  final String time;
  final String type;
  final String specialty;
  final String? avatarEmoji;
  final String? imageUrl;
  final String? status;
  final Color? statusColor;
  final Color? statusBg;
  final VoidCallback? onTap;

  const ProviderPatientCard({
    super.key,
    required this.name,
    required this.time,
    required this.type,
    required this.specialty,
    this.avatarEmoji,
    this.imageUrl,
    this.status,
    this.statusColor,
    this.statusBg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null || imageUrl!.isEmpty
                  ? Center(
                      child: avatarEmoji != null
                          ? Text(avatarEmoji!, style: TextStyle(fontSize: 20.sp))
                          : const Icon(Icons.person_rounded,
                              color: AppColors.primary, size: 22),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.h3),
                  SizedBox(height: 3.h),
                  Text(
                    '$time · $type',
                    style: AppTextStyles.bodySmall,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 13, color: AppColors.textTertiary),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          specialty,
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (status != null) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        status!,
                        style: AppTextStyles.badge.copyWith(
                          color: statusColor,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
