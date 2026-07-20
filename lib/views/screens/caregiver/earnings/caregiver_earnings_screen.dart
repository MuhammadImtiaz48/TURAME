import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/views/widgets/finance_components.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/caregiver_controllers/caregiver_dashboard_controller.dart';
import '../../../../routes/app_routes.dart';

class CaregiverEarningsScreen extends StatelessWidget {
  const CaregiverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CaregiverDashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(ctrl: ctrl),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EarningsSummaryCard(ctrl: ctrl),
                  SizedBox(height: 20.h),
                   SectionHeader(
                     title: 'Recent Earnings',
                     actionLabel: 'See All',
                     onAction: () =>
                         Get.toNamed(AppRoutes.caregiverEarningsHistory),
                     actionColor: AppColors.caregiverColor,
                   ),
                  SizedBox(height: 12.h),
                  Obx(() {
                    final recent = ctrl.filteredEarnings.take(4).toList();
                     if (recent.isEmpty) return const EmptyTransactions();
                    return Column(
                       children: recent
                           .map((e) => EarningTile(
                             iconEmoji: '💰',
                             title: e.clientName,
                             subtitle: '${e.date} · ${e.serviceType}',
                             amount: e.formattedAmount,
                             amountColor: e.amountColor,
                             iconBgColor: AppColors.accentLighter,
                           ))
                           .toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CaregiverDashboardController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.caregiverGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('nav_revenue'.tr, style: AppTextStyles.onDarkTitle),
                    SizedBox(height: 4.h),
                    Obx(() => Text(
                          'Available: ${ctrl.formattedBalance}',
                          style: AppTextStyles.onDarkBody,
                        )),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.caregiverWithdraw),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 6.w),
                      Text(
                        'withdraw_earnings'.tr,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
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

class _EarningsSummaryCard extends StatelessWidget {
  final CaregiverDashboardController ctrl;
  const _EarningsSummaryCard({required this.ctrl});

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
              Obx(() => Container(
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
                       ctrl.earningsGrowth.value,
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.healthGreen,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(() => Text(
            ctrl.formattedMonthlyEarnings,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.caregiverColor,
              fontSize: 28.sp,
            ),
          )),
          SizedBox(height: 16.h),
          Obx(() => SizedBox(
            height: 60.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: () {
                if (ctrl.barData.isEmpty) return <Widget>[];
                final maxValue =
                    ctrl.barData.reduce((a, b) => a > b ? a : b);
                return ctrl.barData.asMap().entries.map((e) {
                  final isLast = e.key == ctrl.barData.length - 1;
                  final h = maxValue > 0 ? 60.h * (e.value / maxValue) : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Container(
                        height: h,
                        decoration: BoxDecoration(
                          color: isLast
                              ? AppColors.caregiverColor
                              : AppColors.accentLighter,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  );
                }).toList();
              }(),
            ),
          )),
          SizedBox(height: 16.h),
          Obx(() => Row(
                children: [
                   Expanded(
                     child: StatTile(
                       label: 'Remaining',
                       value: ctrl.formattedRemainingBalance,
                     ),
                   ),
                   SizedBox(width: 10.w),
                   Expanded(
                     child: StatTile(
                       label: 'Withdrawn',
                       value: ctrl.formattedWithdrawn,
                     ),
                   ),
                ],
              )),
          SizedBox(height: 10.h),
          Obx(() => Row(
                children: [
                   Expanded(
                     child: StatTile(
                       label: 'Available',
                       value: ctrl.formattedBalance,
                     ),
                   ),
                   SizedBox(width: 10.w),
                   Expanded(
                     child: StatTile(
                       label: 'Transactions',
                       value: '${ctrl.totalEarningTransactions}',
                     ),
                   ),
                ],
              )),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Get.toNamed(AppRoutes.caregiverWithdraw),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.caregiverColor,
                side: const BorderSide(color: AppColors.caregiverColor),
                minimumSize: Size(double.infinity, 44.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: Text(
                'withdraw_earnings'.tr,
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.caregiverColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
