// ============================================================
// FILE: lib/views/widgets/caregiver_card.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_theme.dart';
import '../../models/caregiver_model.dart';

class CaregiverCard extends StatelessWidget {
  final CaregiverModel caregiver;
  final VoidCallback? onTap;
  final VoidCallback? onBookTap;

  const CaregiverCard({
    super.key,
    required this.caregiver,
    this.onTap,
    this.onBookTap,
  });

  // Consistent color per caregiver
  Color get _avatarColor {
    final colors = [
      AppColors.caregiverColor,   // pink
      AppColors.accent,           // orange
      AppColors.healthGreen,      // green
      AppColors.primary,          // blue
      AppColors.bloodPressure,    // purple
    ];
    return colors[caregiver.id.hashCode % colors.length];
  }

  String get _initials {
    final parts = caregiver.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0][0];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppTheme.spacingMD),
        padding: EdgeInsets.all(AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──────────────────────────────────────
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: _avatarColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _avatarColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                image: caregiver.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(caregiver.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: caregiver.imageUrl.isEmpty
                  ? Center(
                      child: Text(
                        _initials.toUpperCase(),
                        style: AppTextStyles.h2.copyWith(
                          color: _avatarColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: AppTheme.spacingMD),

            // ── Info ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Verified
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          caregiver.name,
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (caregiver.isVerified)
                        Icon(
                          Icons.verified_rounded,
                          size: 14.r,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                   // Service · Experience
                   Text(
                     '${caregiver.serviceType} · ${caregiver.experienceYears} yrs exp',
                     style: AppTextStyles.bodySmall.copyWith(
                       color: AppColors.textSecondary,
                     ),
                   ),
                   SizedBox(height: 4.h),

                   // Location
                   Row(
                     children: [
                       Icon(Icons.location_on_outlined, size: 12.r, color: AppColors.textTertiary),
                       SizedBox(width: 4.w),
                       Text(
                         caregiver.location,
                         style: AppTextStyles.caption.copyWith(
                           color: AppColors.textSecondary,
                         ),
                       ),
                     ],
                   ),
                   SizedBox(height: 6.h),

                   // Rating
                  Row(
                    children: [
                      Text('⭐', style: TextStyle(fontSize: 13.sp)),
                      SizedBox(width: 4.w),
                      Text(
                        caregiver.rating.toStringAsFixed(1),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        ' (${caregiver.reviewCount} reviews)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Distance · Rate
                  Row(
                    children: [
                      Text('📍', style: TextStyle(fontSize: 12.sp)),
                      SizedBox(width: 3.w),
                      Text(
                        '${caregiver.distanceKm} km',
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        '  ·  ',
                        style: AppTextStyles.caption,
                      ),
                      Text('🔥', style: TextStyle(fontSize: 12.sp)),
                      SizedBox(width: 3.w),
                      Text(
                        '${_formatRate(caregiver.dailyRate)} RWF/day',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                   // Skill tags
                   Wrap(
                     spacing: 6.w,
                     runSpacing: 6.h,
                     children: caregiver.skills
                         .map((s) => _SkillTag(label: s))
                         .toList(),
                   ),
                   SizedBox(height: 8.h),

                    // Book Button
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: onBookTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.caregiverColor,
                          foregroundColor: AppColors.textOnDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                        ),
                        child: Text(
                          'Book Appointment',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.textOnDark,
                          ),
                        ),
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

  String _formatRate(double rate) {
    if (rate >= 1000) {
      return '${(rate / 1000).toStringAsFixed(0)},000';
    }
    return rate.toStringAsFixed(0);
  }
}

// ── Skill Tag ───────────────────────────────────────────────

class _SkillTag extends StatelessWidget {
  final String label;
  const _SkillTag({required this.label});

  // Different colors for different skill types
  Color get _bg => switch (label.toLowerCase()) {
    'elderly' || 'elderly care' => const Color(0xFFFFF3E0),
    'medication'                 => const Color(0xFFE3F2FD),
    'child care' || 'tutoring'   => const Color(0xFFFCE4EC),
    'cooking' || 'cleaning'      => const Color(0xFFE8F5E9),
    'home support'               => const Color(0xFFE0F2F1),
    'disability'                 => const Color(0xFFF3E5F5),
    _                            => const Color(0xFFF5F5F5),
  };

  Color get _fg => switch (label.toLowerCase()) {
    'elderly' || 'elderly care' => const Color(0xFFE65100),
    'medication'                 => const Color(0xFF1565C0),
    'child care' || 'tutoring'   => const Color(0xFFAD1457),
    'cooking' || 'cleaning'      => const Color(0xFF2E7D32),
    'home support'               => const Color(0xFF00695C),
    'disability'                 => const Color(0xFF6A1B9A),
    _                            => const Color(0xFF455A64),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: _fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}