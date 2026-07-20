import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/payment_controller.dart';
import '../../../../routes/app_routes.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PaymentController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 48.h),

              // ── Success Animation ──
              _SuccessBadge(),
              SizedBox(height: 24.h),

              Text(
                'payment_successful'.tr,
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'payment_success_sub'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              // ── Transaction Details Card ──
              _TransactionCard(ctrl: ctrl),

              const Spacer(),

              // ── Buttons ──
              _BottomButtons(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Success Badge ────────────────────────────────────────────────────────────

class _SuccessBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.r,
      height: 100.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.success.withValues(alpha: 0.12),
      ),
      child: Center(
        child: Container(
          width: 72.r,
          height: 72.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withValues(alpha: 0.2),
          ),
          child: Center(
            child: Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 28.r,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Transaction Card ─────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final PaymentController ctrl;
  const _TransactionCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final order = ctrl.order.value;

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          _TxRow(
            label: 'transaction_id'.tr,
            value: '#TX8-2025-789456',
            valueStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          _Divider(),
          _TxRow(
            label: 'amount_paid'.tr,
            value: order.formattedTotal,
            valueStyle: AppTextStyles.h3.copyWith(color: AppColors.success),
          ),
          _Divider(),
          _TxRow(
            label: 'method'.tr,
            value: ctrl.selectedMethodName,
          ),
          _Divider(),
          _TxRow(
            label: 'date'.tr,
            value: ctrl.transactionDate,
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _TxRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          Text(value, style: valueStyle ?? AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(color: AppColors.borderLight, height: 1);
}

// ─── Bottom Buttons ───────────────────────────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Receipt Button
        Expanded(
          child: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.invoice),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppColors.primary),
              ),
              child: Text(
                'receipt'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.buttonMedium
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // View Appointment Button
        Expanded(
          child: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.appointments),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Text(
                'view_appointment'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.buttonMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}