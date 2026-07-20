import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../controllers/auth_controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _phoneInputCtrl = TextEditingController();
  bool _loading = false;
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _phoneInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      Get.snackbar(
        'Terms Required',
        'Please accept terms and privacy policy',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: AppColors.textOnDark,
      );
      return;
    }
    setState(() => _loading = true);
    final authCtrl = Get.find<AuthController>();
    try {
      final success = await authCtrl.signUp(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneInputCtrl.text.trim(),
        password: _passCtrl.text,
        role: UserRole.patient,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (success) {
        Get.offNamed(AppRoutes.roleSelection);
      } else {
        Get.snackbar(
          'Registration Failed',
          authCtrl.errorMessage.value.isNotEmpty
              ? authCtrl.errorMessage.value
              : 'An error occurred during registration',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: AppColors.textOnDark,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      Get.snackbar(
        'Registration Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: AppColors.textOnDark,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLG,
            vertical: AppTheme.spacingXL,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8.w,
                          bottom: 8.w,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Create Account'.tr,
                      style: AppTextStyles.displayMedium,
                    ),
                  ],
                ),
                SizedBox(height: 28.h),

                AppTextField(
                  label: 'full_name'.tr,
                  hint: 'full_name_hint'.tr,
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'name_required'.tr;
                    }
                    if (v.trim().length < 3) return 'name_min'.tr;
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                AppTextField(
                  label: 'email'.tr,
                  hint: 'email_hint'.tr,
                  type: AppTextFieldType.email,
                  controller: _emailCtrl,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'email_required'.tr;
                    }
                    if (!RegExp(
                      r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$',
                    ).hasMatch(v.trim())) {
                      return 'email_invalid'.tr;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                AppTextField(
                  label: 'phone'.tr,
                  hint: 'phone_hint'.tr,
                  type: AppTextFieldType.phone,
                  controller: _phoneInputCtrl,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'phone_required'.tr;
                    }
                    final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                AppTextField(
                  label: 'password'.tr,
                  hint: 'password_hint'.tr,
                  type: AppTextFieldType.password,
                  controller: _passCtrl,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'password_required'.tr;
                    if (v.length < 6) return 'password_min'.tr;
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                AppTextField(
                  label: 'confirm_password'.tr,
                  hint: 'password_hint'.tr,
                  type: AppTextFieldType.password,
                  controller: _confirmPassCtrl,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'password_required'.tr;
                    if (v != _passCtrl.text) return 'password_mismatch'.tr;
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                _TermsRow(
                  agreed: _agreed,
                  onChanged: (val) => setState(() => _agreed = val ?? false),
                ),

                SizedBox(height: 24.h),

                AppButton(
                  label: 'sign_up'.tr,
                  onTap: _onSignup,
                  loading: _loading,
                ),

                SizedBox(height: 20.h),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${'have_account'.tr} ',
                        style: AppTextStyles.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.login),
                        child: Text(
                          'sign_in'.tr,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool?> onChanged;

  const _TermsRow({required this.agreed, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24.w,
          height: 24.w,
          child: Checkbox(
            value: agreed,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodySmall,
              children: [
                TextSpan(text: '${'agree_to'.tr} '),
                TextSpan(
                  text: 'terms_of_service'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: ' ${'and'.tr} '),
                TextSpan(
                  text: 'privacy_policy'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
