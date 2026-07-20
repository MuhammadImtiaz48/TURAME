import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/payment_controller.dart';
import '../../../../models/payment_model.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OrderSummaryCard(ctrl: ctrl),
                  SizedBox(height: 24.h),
                  Text('select_payment_method'.tr, style: AppTextStyles.h2),
                  SizedBox(height: 12.h),
                  Obx(() => Column(
                    children: ctrl.methods.map((m) =>
                        _PaymentMethodCard(
                          method: m,
                          isSelected: ctrl.selectedMethodId.value == m.id,
                          onTap: () => ctrl.selectMethod(m.id),
                        ),
                    ).toList(),
                  )),
                ],
              ),
            ),
          ),
          _PayButton(ctrl: ctrl),
        ],
      ),
    );
  }
}

// ─── AppBar ──────────────────────────────────────────────────────────────────

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
      title: Text('payment'.tr, style: AppTextStyles.h2),
      centerTitle: true,
    );
  }
}

// ─── Order Summary Card ──────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  final PaymentController ctrl;
  const _OrderSummaryCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final order = ctrl.order.value;

      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.border),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('order_summary'.tr,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 0.8,
                )),
            SizedBox(height: 10.h),
            Text(order.providerName,
                style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
            SizedBox(height: 12.h),
            Divider(color: AppColors.borderLight, height: 1),
            SizedBox(height: 12.h),
            _SummaryRow(
              label: order.serviceType,
              value: order.formattedAmount(order.consultationFee),
            ),
            SizedBox(height: 8.h),
            _SummaryRow(
              label: 'service_fee'.tr,
              value: order.formattedAmount(order.serviceFee),
            ),
            SizedBox(height: 12.h),
            Divider(color: AppColors.borderLight, height: 1),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('total'.tr, style: AppTextStyles.h3),
                Text(
                  order.formattedTotal,
                  style: AppTextStyles.price,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}

// ─── Payment Method Card ─────────────────────────────────────────────────────

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethodModel method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            // Brand badge
            Container(
              width: 44.r,
              height: 30.r,
              decoration: BoxDecoration(
                color: method.brandColor,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text(
                  method.brandLabel,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: method.labelTextColor,
                    letterSpacing: 0.3,
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
                  Text(method.name, style: AppTextStyles.h3),
                  SizedBox(height: 2.h),
                  Text(method.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: method.isAddNew
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      )),
                ],
              ),
            ),
            // Radio or Plus
            if (method.isAddNew)
              Icon(Icons.add, color: AppColors.primary, size: 20.r)
            else
              Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 12.r)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Pay Button ──────────────────────────────────────────────────────────────

class _PayButton extends StatelessWidget {
  final PaymentController ctrl;
  const _PayButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Obx(() => GestureDetector(
        onTap: ctrl.isProcessing.value ? null : ctrl.processPayment,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: ctrl.isProcessing.value
              ? Center(
            child: SizedBox(
              width: 22.r,
              height: 22.r,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          )
              : Text(
            '${'pay'.tr} ${ctrl.order.value.formattedTotal}',
            textAlign: TextAlign.center,
            style: AppTextStyles.buttonLarge,
          ),
        ),
      )),
    );
  }
}