// ============================================================
// FILE: lib/views/widgets/provider_card.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_theme.dart';
import '../../models/provider_model.dart';

class ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback? onTap;
  final VoidCallback? onBookTap;

  const ProviderCard({
    super.key,
    required this.provider,
    this.onTap,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Avatar + Info + Availability ─────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProviderAvatar(provider: provider),
                  SizedBox(width: AppTheme.spacingSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Verified badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider.name,
                                style: AppTextStyles.h3,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (provider.isVerified)
                              Padding(
                                padding: EdgeInsets.only(left: 6.w),
                                child: Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.primary,
                                  size: 16.r,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        // Specialty
                        Text(
                          provider.specialty,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        // Hospital / Location
                        Row(
                          children: [
                            Icon(
                              provider.providerLocation == 'Home'
                                  ? Icons.home_outlined
                                  : Icons.local_hospital_outlined,
                              size: 12.r,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                provider.providerLocation == 'Home'
                                    ? 'Home Visits Only'
                                    : provider.hospital,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Availability chip
                  _AvailabilityBadge(isAvailable: provider.isAvailable),
                ],
              ),

              SizedBox(height: AppTheme.spacingSM),
              Divider(color: AppColors.borderLight, height: 1),
              SizedBox(height: AppTheme.spacingSM),

              // ── Stats Row ─────────────────────────────────────
              Row(
                children: [
                  _StatItem(
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFF57F17),
                    value: provider.rating.toStringAsFixed(1),
                    label: '(${provider.reviewCount})',
                  ),
                  _Divider(),
                  _StatItem(
                    icon: Icons.work_outline_rounded,
                    iconColor: AppColors.secondary,
                    value: '${provider.experienceYears}yr',
                    label: 'exp',
                  ),
                  _Divider(),
                  _StatItem(
                    icon: Icons.location_on_outlined,
                    iconColor: AppColors.accent,
                    value: '${provider.distanceKm}km',
                    label: 'away',
                  ),
                  _Divider(),
                  _StatItem(
                    icon: Icons.payments_outlined,
                    iconColor: AppColors.healthGreen,
                    value: '${(provider.consultationFee / 1000).toStringAsFixed(0)}k',
                    label: 'RWF',
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spacingSM),

              // ── Services Tags ─────────────────────────────────
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: provider.services
                    .map((s) => _ServiceTag(label: s))
                    .toList(),
              ),

              SizedBox(height: AppTheme.spacingMD),

              // ── Book Button ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: provider.isAvailable ? onBookTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.isAvailable
                        ? AppColors.primary
                        : AppColors.border,
                    foregroundColor: AppColors.textOnDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: Text(
                    provider.isAvailable ? 'Book Appointment' : 'Unavailable',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: provider.isAvailable
                          ? AppColors.textOnDark
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────

class _ProviderAvatar extends StatelessWidget {
  final ProviderModel provider;
  const _ProviderAvatar({required this.provider});

  // Generate consistent initials color from provider id
  Color get _avatarColor {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.healthGreen,
      AppColors.accent,
      AppColors.bloodPressure,
    ];
    return colors[provider.id.hashCode % colors.length];
  }

  String get _initials {
    final parts = provider.name.replaceAll('Dr.', '').replaceAll('Nurse', '').trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0][0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.r,
      height: 64.r,
      decoration: BoxDecoration(
        color: _avatarColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: _avatarColor.withValues(alpha: 0.25), width: 1.5),
        image: provider.imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(provider.imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: provider.imageUrl.isEmpty
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
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool isAvailable;
  const _AvailabilityBadge({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.successLighter : AppColors.dangerLighter,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAvailable ? AppColors.success : AppColors.danger,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            isAvailable ? 'Available' : 'Busy',
            style: AppTextStyles.labelSmall.copyWith(
              color: isAvailable ? AppColors.success : AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(fit: FlexFit.tight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14.r, color: iconColor),
          SizedBox(width: 2.w),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(fontSize: 12.sp),
          ),
          SizedBox(width: 1.w),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 14.h,
      color: AppColors.borderLight,
    );
  }
}

class _ServiceTag extends StatelessWidget {
  final String label;
  const _ServiceTag({required this.label});

  IconData get _icon => switch (label) {
    'Video' => Icons.videocam_outlined,
    'Home Visit' => Icons.home_outlined,
    _ => Icons.local_hospital_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 11.r, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}