// ============================================================
// FILE: lib/views/screens/provider/widgets/provider_earnings_card.dart
// Monthly earnings summary card with a withdraw action.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';

class ProviderEarningsCard extends StatelessWidget {
  final String monthlyEarnings;
  final String earningsGrowth;
  final List<double> barData;
  final String remainingBalance;
  final String withdrawnBalance;
  final String availableBalance;
  final int transactionCount;
  final VoidCallback onWithdraw;

  const ProviderEarningsCard({
    super.key,
    required this.monthlyEarnings,
    required this.earningsGrowth,
    required this.barData,
    required this.remainingBalance,
    required this.withdrawnBalance,
    required this.availableBalance,
    required this.transactionCount,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('this_month_earnings'.tr, style: AppTextStyles.h3),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.healthGreenLighter,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded,
                        size: 10, color: AppColors.healthGreen),
                    SizedBox(width: 2.w),
                    Text(
                      earningsGrowth,
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.healthGreen,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            monthlyEarnings,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.providerColor,
              fontSize: 28.sp,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 60.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: () {
                if (barData.isEmpty) return <Widget>[];
                final maxValue =
                    barData.reduce((a, b) => a > b ? a : b);
                return barData.asMap().entries.map((e) {
                  final isLast = e.key == barData.length - 1;
                  final h = maxValue > 0 ? 60.h * (e.value / maxValue) : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Container(
                        height: h,
                        decoration: BoxDecoration(
                          color: isLast
                              ? AppColors.providerColor
                              : AppColors.healthGreenLighter,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  );
                }).toList();
              }(),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _MiniStat(label: 'Remaining', value: remainingBalance),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MiniStat(label: 'Withdrawn', value: withdrawnBalance),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _MiniStat(label: 'Available', value: availableBalance),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MiniStat(
                  label: 'Transactions',
                  value: '$transactionCount',
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onWithdraw,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.providerColor,
                side: const BorderSide(color: AppColors.providerColor),
                minimumSize: Size(double.infinity, 44.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: Text(
                'withdraw_earnings'.tr,
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.providerColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          SizedBox(height: 2.h),
          Text(value, style: AppTextStyles.h3.copyWith(fontSize: 12.sp)),
        ],
      ),
    );
  }
}
