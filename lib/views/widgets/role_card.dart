import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_theme.dart';

/// Reusable Role Card — used in RoleSelectionScreen.
/// Can also be reused anywhere a selectable card with icon + title + subtitle is needed.
class RoleCard extends StatelessWidget {
  final String emoji;
  final Color emojiColor;
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.emoji,
    required this.emojiColor,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(minHeight: 150.h),
        width: double.infinity,
        padding: EdgeInsets.all(AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? AppTheme.shadowSm : null,
        ),
        child:// Row(
         // crossAxisAlignment: CrossAxisAlignment.start,
          // children: [
            // ── Emoji Icon ───────────────────────────────────────────


           // SizedBox(width: 14.w),

            // ── Title + Subtitle ─────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withValues(alpha: 0.12)
                        : AppColors.surface2,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    color: isSelected ? selectedColor : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.5,fontSize: 14.sp),
                ),
              ],
            ),
      //    ],
        //),
      ),
    );
  }
}