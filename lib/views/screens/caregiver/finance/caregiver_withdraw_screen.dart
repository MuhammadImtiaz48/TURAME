import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/caregiver_controllers/caregiver_dashboard_controller.dart';

class CaregiverWithdrawScreen extends StatefulWidget {
  const CaregiverWithdrawScreen({super.key});

  @override
  State<CaregiverWithdrawScreen> createState() =>
      _CaregiverWithdrawScreenState();
}

class _CaregiverWithdrawScreenState extends State<CaregiverWithdrawScreen> {
  final _amountCtrl = TextEditingController();
  String _selectedMethod = 'mtn';
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _withdraw(CaregiverDashboardController ctrl) async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Invalid Amount',
        'Please enter a valid withdrawal amount.',
        backgroundColor: AppColors.dangerLighter,
        colorText: AppColors.danger,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isProcessing = true);
    final success = await ctrl.withdrawEarnings(amount, _selectedMethod);
    setState(() => _isProcessing = false);

    if (success) {
      Get.back();
      Get.snackbar(
        'Withdrawal Successful',
        'RWF ${amount.toStringAsFixed(0)} has been sent to your account.',
        backgroundColor: AppColors.healthGreenLighter,
        colorText: AppColors.success,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Withdrawal Failed',
        'Amount exceeds available balance.',
        backgroundColor: AppColors.dangerLighter,
        colorText: AppColors.danger,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CaregiverDashboardController>();

    final methods = [
      ('mtn', 'MTN Mobile Money', '+250 078 XXX XXX', const Color(0xFFFFCC00)),
      ('airtel', 'Airtel Money', '+250 073 XXX XXX', const Color(0xFFE4002B)),
    ];

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
        title: Text('withdraw_earnings'.tr, style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    gradient: AppColors.caregiverGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Available Balance',
                          style: AppTextStyles.onDarkBody),
                      SizedBox(height: 6.h),
                      Text(ctrl.formattedBalance,
                          style: AppTextStyles.onDarkTitle.copyWith(
                            fontSize: 28.sp,
                          )),
                    ],
                  ),
                )),
            SizedBox(height: 24.h),
            Text('Withdrawal Amount', style: AppTextStyles.h3),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. 24,000',
                prefixText: 'RWF ',
                prefixStyle: AppTextStyles.h3
                    .copyWith(color: AppColors.caregiverColor),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: [24000, 48000].map((amount) {
                return GestureDetector(
                  onTap: () => _amountCtrl.text = '$amount',
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.accentLighter,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'RWF ${(amount / 1000).toStringAsFixed(0)}K',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.caregiverColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
            Text('Payout Method', style: AppTextStyles.h3),
            SizedBox(height: 12.h),
            ...methods.map((m) {
              final selected = _selectedMethod == m.$1;
              return GestureDetector(
                onTap: () => setState(() => _selectedMethod = m.$1),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: selected
                          ? AppColors.caregiverColor
                          : AppColors.borderLight,
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: m.$4,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Text(
                            m.$1 == 'mtn' ? 'MTN' : 'AIR',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: m.$1 == 'mtn'
                                  ? AppColors.textPrimary
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.$2, style: AppTextStyles.h3),
                            Text(m.$3, style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selected
                            ? AppColors.caregiverColor
                            : AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _withdraw(ctrl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.caregiverColor,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: _isProcessing
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Confirm Withdrawal',
                        style: AppTextStyles.buttonLarge),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Withdrawals are processed within 24 hours on business days.',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
