import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';



class StatTile extends StatelessWidget {
  final String label;
  final String value;

  const StatTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          SizedBox(height: 4.h),
          Text(value, style: AppTextStyles.h3.copyWith(fontSize: 14.sp)),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final Color? actionColor;

  const SectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h3),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: AppTextStyles.labelLarge.copyWith(
              color: actionColor ?? AppColors.providerColor,
              fontSize: 13.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class EarningTile extends StatelessWidget {
  final String iconEmoji;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final Color iconBgColor;

  const EarningTile({
    super.key,
    required this.iconEmoji,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(child: Text(iconEmoji, style: TextStyle(fontSize: 20.sp))),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.h3.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }
}

class EmptyTransactions extends StatelessWidget {
  const EmptyTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        'No earnings yet this month.',
        style: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class EmptyEarningsCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const EmptyEarningsCard({
    super.key,
    this.emoji = '📊',
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 52.sp)),
          SizedBox(height: 16.h),
          Text(title, style: AppTextStyles.h3),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
