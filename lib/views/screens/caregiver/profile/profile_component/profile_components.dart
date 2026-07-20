import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';



class DetailProfileCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String avatarEmoji;
  final String? imageUrl;
  final String badgeLabel;
  final Gradient gradient;

  const DetailProfileCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.avatarEmoji,
    this.imageUrl,
    required this.badgeLabel,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
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
                    child: Text(avatarEmoji, style: TextStyle(fontSize: 30.sp)),
                  )
                : null,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.onDarkTitle),
                SizedBox(height: 4.h),
                Text(subtitle, style: AppTextStyles.onDarkBody),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    badgeLabel,
                    style: AppTextStyles.badge.copyWith(fontSize: 10.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DetailInfoSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }
}

class DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const DetailInfoRow(this.icon, this.text, {super.key, this.iconColor = AppColors.providerColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          SizedBox(width: 10.w),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class BioField extends StatelessWidget {
  final TextEditingController controller;

  const BioField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 4.h),
        TextFormField(
          controller: controller,
          maxLines: 4,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Write a short bio...',
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textTertiary),
            suffixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_arrow_up_rounded,
                    size: 20, color: AppColors.textTertiary),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AvailabilityTile extends StatelessWidget {
  final String days;
  final String hours;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color activeTrackColor;

  const AvailabilityTile({
    super.key,
    required this.days,
    required this.hours,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.primary,  // ✅ Now works!
    this.activeTrackColor = AppColors.primaryLight,  // ✅ Now works!
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(days, style: AppTextStyles.h3),
              SizedBox(height: 2.h),
              Text(hours, style: AppTextStyles.bodySmall),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: activeColor,
            activeTrackColor: activeTrackColor.withValues(alpha: 0.4),
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.borderLight,
          ),
        ],
      ),
    );
  }
}