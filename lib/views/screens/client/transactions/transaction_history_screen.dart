import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/payment_controller.dart';
import '../../../../models/payment_model.dart';
import '../../../../routes/app_routes.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PaymentController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _AppBar(),
      body: Column(
        children: [
          _SummaryHeader(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              final grouped = ctrl.groupedTransactions;
              if (grouped.isEmpty) {
                return _EmptyState();
              }
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemCount: grouped.length,
                itemBuilder: (_, i) {
                  final entry = grouped.entries.elementAt(i);
                  return _TransactionGroup(
                    month: entry.key,
                    transactions: entry.value,
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

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22.r),
      ),
      title: Text('transactions'.tr, style: AppTextStyles.h2),
      centerTitle: true,
    );
  }
}

// ─── Summary Header ───────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  final PaymentController ctrl;
  const _SummaryHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Filter chip
          GestureDetector(
            onTap: ctrl.toggleFilter,
            child: Container(
              padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      color: Colors.white, size: 14.r),
                  SizedBox(width: 6.w),
                  Text(ctrl.selectedFilter.value,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ctrl.totalTransactions.toString(),
                style: AppTextStyles.h1
                    .copyWith(color: Colors.white, fontSize: 28.sp),
              ),
              Text(
                'total_rwf'.tr,
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
                ctrl.totalAmount,
                style: AppTextStyles.h2
                    .copyWith(color: Colors.white, fontSize: 20.sp),
              ),
              Text(
                'total_amount'.tr,
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

// ─── Transaction Group ────────────────────────────────────────────────────────

class _TransactionGroup extends StatelessWidget {
  final String month;
  final List<TransactionModel> transactions;

  const _TransactionGroup({
    required this.month,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text(month,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 0.8,
              )),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.border),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            children: List.generate(transactions.length, (i) {
              final tx = transactions[i];
              final isLast = i == transactions.length - 1;
              return Column(
                children: [
                  _TransactionTile(transaction: tx),
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

// ─── Transaction Tile ─────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.invoice),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            // Brand Badge
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: transaction.brandColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: transaction.status == TransactionStatus.failed
                    ? Icon(Icons.close_rounded,
                    color: Colors.white, size: 18.r)
                    : Text(
                  transaction.brandLabel,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: transaction.labelColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.providerName,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 3.h),
                  Text(
                    '${transaction.date} · ${transaction.methodName}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Amount + Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.formattedAmount,
                  style: AppTextStyles.h3.copyWith(
                    color: transaction.amountColor,
                  ),
                ),
                SizedBox(height: 3.h),
                if (transaction.status == TransactionStatus.failed)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'refunded'.tr,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.danger),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

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
          Text('no_transactions_sub'.tr,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}