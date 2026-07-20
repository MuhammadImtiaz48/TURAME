import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/controllers/auth_controllers/auth_controller.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final authCtrl = Get.find<AuthController>();
    await authCtrl.sendPasswordReset(email: _emailCtrl.text.trim());
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'FORGOT PASSWORD',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontSize: 13.sp,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: EdgeInsets.only(left: AppTheme.spacingMD),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingXL,
            vertical: AppTheme.spacingXXL,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),

                // ── Key Emoji ─────────────────────────────────────────
                Text(
                  '🔑',
                  style: TextStyle(fontSize: 72.sp),
                ),

                SizedBox(height: 24.h),

                // ── Title ─────────────────────────────────────────────
                Text(
                  'Forgot Password?',
                  style: AppTextStyles.displayMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 10.h),

                // ── Subtitle ──────────────────────────────────────────
                Text(
                  "No worries. Enter your email and we'll send\nreset instructions.",
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                // ── Email Field ───────────────────────────────────────
                AppTextField(
                  label: 'email'.tr,
                  hint: 'email_hint'.tr,
                  type: AppTextFieldType.email,
                  controller: _emailCtrl,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'email_required'.tr;
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                        .hasMatch(v.trim())) {
                      return 'email_invalid'.tr;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 28.h),

                // ── Send Reset Link Button ────────────────────────────
                AppButton(
                  label: 'Send Reset Link',
                  onTap: _onSend,
                  loading: _loading,
                ),

                SizedBox(height: 20.h),

                // ── Back to Sign In ───────────────────────────────────
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.arrow_back,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Back to Sign In',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

 