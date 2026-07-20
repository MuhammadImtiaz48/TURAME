import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/caregiver_controllers/caregiver_dashboard_controller.dart';
import '../../../../models/caregiver_earning_model.dart';
import '../../../../models/payment_model.dart';

class CaregiverEarningsHistoryScreen extends StatelessWidget {
  const CaregiverEarningsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CaregiverDashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Earnings History', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _SummaryHeader(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              final grouped = ctrl.groupedEarnings;
              if (grouped.isEmpty) return _EmptyState();
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemCount: grouped.length,
                itemBuilder: (_, i) {
                  final entry = grouped.entries.elementAt(i);
                  return _EarningGroup(
                    month: entry.key,
                    earnings: entry.value,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final CaregiverDashboardController ctrl;
  const _SummaryHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          margin: EdgeInsets.all(16.r),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: AppColors.caregiverGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: ctrl.toggleEarningsFilter,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Colors.white, size: 14),
                      SizedBox(width: 6.w),
                      Text(
                        ctrl.earningsFilter.value,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${ctrl.totalEarningTransactions}',
                    style: AppTextStyles.h1
                        .copyWith(color: Colors.white, fontSize: 28.sp),
                  ),
                  Text(
                    'Transactions',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ctrl.totalEarningsAmount,
                    style: AppTextStyles.h2
                        .copyWith(color: Colors.white, fontSize: 18.sp),
                  ),
                  Text(
                    'Total Earned',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

class _EarningGroup extends StatelessWidget {
  final String month;
  final List<CaregiverEarningModel> earnings;

  const _EarningGroup({required this.month, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text(
            month,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.border),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            children: List.generate(earnings.length, (i) {
              final earning = earnings[i];
              final isLast = i == earnings.length - 1;
              return Column(
                children: [
                  _EarningTile(earning: earning),
                  if (!isLast)
                    Divider(
                      color: AppColors.borderLight,
                      height: 1,
                      indent: 56.w,
                    ),
                ],
              );
            }),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class _EarningTile extends StatelessWidget {
  final CaregiverEarningModel earning;
  const _EarningTile({required this.earning});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: earning.status == TransactionStatus.failed
                  ? AppColors.danger
                  : AppColors.accentLighter,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(
                earning.status == TransactionStatus.failed
                    ? Icons.close_rounded
                    : Icons.payments_rounded,
                color: earning.status == TransactionStatus.failed
                    ? Colors.white
                    : AppColors.caregiverColor,
                size: 18,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(earning.clientName,
                    style: AppTextStyles.h3, maxLines: 1),
                SizedBox(height: 3.h),
                Text(
                  '${earning.date} · ${earning.methodName}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                earning.formattedAmount,
                style: AppTextStyles.h3.copyWith(color: earning.amountColor),
              ),
              if (earning.status == TransactionStatus.pending)
                Container(
                  margin: EdgeInsets.only(top: 3.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.warningLighter,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'pending'.tr,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.warning),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64.r, color: AppColors.textTertiary),
          SizedBox(height: 16.h),
          Text('no_transactions'.tr, style: AppTextStyles.h3),
          SizedBox(height: 6.h),
          Text(
            'no_transactions_sub'.tr,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
