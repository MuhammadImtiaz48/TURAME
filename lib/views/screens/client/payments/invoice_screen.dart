import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/payment_controller.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PaymentController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _AppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
              child: _InvoiceCard(ctrl: ctrl),
            ),
          ),
          _BottomActions(),
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
      title: Text('invoice'.tr, style: AppTextStyles.h2),
      centerTitle: true,
    );
  }
}

// ─── Invoice Card ─────────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  final PaymentController ctrl;
  const _InvoiceCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final order = ctrl.order.value;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    'R',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TURAME',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.primary)),
                  Text('Healthcare', style: AppTextStyles.bodySmall),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('invoice'.tr.toUpperCase(),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 1,
                      )),
                  SizedBox(height: 2.h),
                  Text('#1W-2025-0842',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primary)),
                ],
              ),
            ],
          ),

          SizedBox(height: 20.h),
          Divider(color: AppColors.borderLight),
          SizedBox(height: 16.h),

          // ── Meta Grid ──
          Row(
            children: [
              Expanded(
                child: _MetaBlock(
                  label: 'patient'.tr,
                  value: '',
                ),
              ),
              Expanded(
                child: _MetaBlock(
                  label: 'date'.tr,
                  value: ctrl.transactionDate,
                  crossAlign: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _MetaBlock(
                  label: 'provider'.tr,
                  value: order.providerName,
                ),
              ),
              Expanded(
                child: _MetaBlock(
                  label: 'status'.tr,
                  value: 'paid'.tr,
                  valueColor: AppColors.success,
                  crossAlign: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),
          Divider(color: AppColors.borderLight),
          SizedBox(height: 16.h),

          // ── Line Items ──
          _LineItem(
            label: order.serviceType,
            amount: order.formattedAmount(order.consultationFee),
          ),
          SizedBox(height: 10.h),
          _LineItem(
            label: 'service_fee'.tr,
            amount: order.formattedAmount(order.serviceFee),
          ),

          SizedBox(height: 16.h),
          Divider(color: AppColors.borderLight),
          SizedBox(height: 12.h),

          // ── Total ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('total'.tr.toUpperCase(),
                  style: AppTextStyles.h3.copyWith(letterSpacing: 0.5)),
              Text(order.formattedTotal, style: AppTextStyles.price),
            ],
          ),

          SizedBox(height: 20.h),

          // ── Status Chip ──
          Center(
            child: Container(
              padding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 16.r),
                  SizedBox(width: 6.w),
                  Text(
                    '${'paid_via'.tr} ${ctrl.selectedMethodName}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final CrossAxisAlignment crossAlign;

  const _MetaBlock({
    required this.label,
    required this.value,
    this.valueColor,
    this.crossAlign = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textTertiary)),
        SizedBox(height: 2.h),
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            )),
      ],
    );
  }
}

class _LineItem extends StatelessWidget {
  final String label;
  final String amount;
  const _LineItem({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(amount,
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Bottom Actions ───────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Download PDF
          GestureDetector(
            onTap: () {}, // PDF download logic
            child: Container(
              width: double.infinity,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded,
                      color: Colors.white, size: 18.r),
                  SizedBox(width: 8.w),
                  Text('download_pdf'.tr,
                      style: AppTextStyles.buttonMedium),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Share Receipt
          GestureDetector(
            onTap: () {}, // Share logic
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_outlined,
                      color: AppColors.textPrimary, size: 18.r),
                  SizedBox(width: 8.w),
                  Text('share_receipt'.tr,
                      style: AppTextStyles.buttonMedium
                          .copyWith(color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}