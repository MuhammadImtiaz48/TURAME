import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/app_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;
  static const int _resendSeconds = 60;

  final TextEditingController _otpController = TextEditingController();

  bool _loading = false;
  bool _hasError = false;
  int _countdown = _resendSeconds;
  Timer? _timer;

  String get _phone {
    final args = Get.arguments as Map<String, dynamic>?;
    return args?['phone'] as String? ?? '+250 078 XXX XXX';
  }

  bool get _isComplete => _otpController.text.length == _otpLength;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _countdown = _resendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  Future<void> _onVerify() async {
    if (!_isComplete) return;
    setState(() {
      _loading = true;
      _hasError = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (_otpController.text == '000000') {
      setState(() {
        _loading = false;
        _hasError = true;
      });
      _shakeAndClear();
    } else {
      setState(() => _loading = false);
      Get.toNamed(AppRoutes.roleSelection);
    }
  }

  void _onResend() {
    if (_countdown > 0) return;
    _startTimer();
    _clearAll();
    Get.snackbar(
      'otp_resent_title'.tr,
      '${'otp_resent_body'.tr} $_phone',
      backgroundColor: AppColors.successLighter,
      colorText: AppColors.success,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(AppTheme.spacingMD),
      borderRadius: AppTheme.radiusMd,
      duration: const Duration(seconds: 3),
    );
  }

  void _clearAll() {
    _otpController.clear();
    setState(() => _hasError = false);
  }

  void _shakeAndClear() {
    Future.delayed(const Duration(milliseconds: 600), _clearAll);
  }

  PinTheme _pinTheme({
    Color borderColor = AppColors.border,
    Color fillColor = AppColors.surface,
    Color textColor = AppColors.primary,
  }) {
    return PinTheme(
      width: 48.w,
      height: 58.h,
      textStyle: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: textColor,
        fontFamily: 'monospace',
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: borderColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultTheme = _pinTheme();
    final focusedTheme = _pinTheme(
      borderColor: AppColors.primary,
      fillColor: AppColors.primaryLighter,
    );
    final submittedTheme = _pinTheme(
      borderColor: AppColors.primary,
      fillColor: AppColors.primaryLighter,
    );
    final errorTheme = _pinTheme(
      borderColor: AppColors.danger,
      fillColor: AppColors.dangerLighter,
      textColor: AppColors.danger,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingXL,
            vertical: AppTheme.spacingXL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              SizedBox(height: 32.h),
              Text('📱', style: TextStyle(fontSize: 64.sp)),
              SizedBox(height: 20.h),
              Text(
                'otp_title'.tr,
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  children: [
                    TextSpan(text: '${'otp_subtitle'.tr}\n'),
                    TextSpan(
                      text: _phone,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36.h),

              // OTP input via pinput package
              Pinput(
                length: _otpLength,
                controller: _otpController,
                defaultPinTheme: defaultTheme,
                focusedPinTheme: focusedTheme,
                submittedPinTheme: submittedTheme,
                errorPinTheme: errorTheme,
                forceErrorState: _hasError,
                keyboardType: TextInputType.number,
                mainAxisAlignment: MainAxisAlignment.center,
                onChanged: (_) => setState(() => _hasError = false),
                onCompleted: (_) => _onVerify(),
              ),

              if (_hasError) ...[
                SizedBox(height: 8.h),
                Text(
                  'otp_wrong'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              SizedBox(height: 32.h),
              AppButton(
                label: 'otp_verify_btn'.tr,
                onTap: _isComplete ? _onVerify : null,
                loading: _loading,
              ),
              SizedBox(height: 24.h),
              _ResendRow(
                countdown: _countdown,
                onResend: _onResend,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  final int countdown;
  final VoidCallback onResend;

  const _ResendRow({required this.countdown, required this.onResend});

  @override
  Widget build(BuildContext context) {
    final canResend = countdown == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${'otp_no_code'.tr} ',
          style: AppTextStyles.bodyMedium,
        ),
        GestureDetector(
          onTap: canResend ? onResend : null,
          child: Text(
            canResend
                ? 'otp_resend'.tr
                : '${'otp_resend'.tr} (${countdown}s)',
            style: AppTextStyles.bodyMedium.copyWith(
              color: canResend ? AppColors.primary : AppColors.textTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}