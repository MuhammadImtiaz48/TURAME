import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../controllers/auth_controllers/auth_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../models/user_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final authCtrl = Get.find<AuthController>();
    final success = await authCtrl.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      final role = authCtrl.user.value?.role;
      if (role == UserRole.provider) {
        Get.offAllNamed(AppRoutes.providerDashboard);
      } else if (role == UserRole.caregiver) {
        Get.offAllNamed(AppRoutes.caregiverDashboard);
      } else if (role == UserRole.home) {
        Get.offAllNamed(AppRoutes.providerDashboard);
      } else {
        Get.offAllNamed(AppRoutes.patientDashboard);
      }
    } else {
      Get.snackbar(
        'sign_in'.tr,
        authCtrl.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: AppColors.textOnDark,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = Get.find<LanguageController>();
    return Scaffold(
      backgroundColor: Colors.white,
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
                SizedBox(height: 24.h),

                Center(
                  child: Container(
                    width: 150.w,
                    height: 150.w,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(langCtrl.logoAsset),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Text(
                    'app_subtitle'.tr.split('\n').first,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),

                SizedBox(height: 28.h),

                Text('welcome_back'.tr, style: AppTextStyles.displayMedium),
                SizedBox(height: 4.h),
                Text('sign_in_continue'.tr, style: AppTextStyles.bodyMedium),

                SizedBox(height: 28.h),

                AppTextField(
                  label: 'email'.tr,
                  hint: 'email_hint'.tr,
                  type: AppTextFieldType.email,
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'email_required'.tr;
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v.trim())) {
                      return 'email_invalid'.tr;
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
                  focusNode: _passFocus,
                  textInputAction: TextInputAction.done,
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

                SizedBox(height: 8.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                    ),
                    child: Text(
                      'forgot_password'.tr,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                AppButton(
                  label: 'sign_in'.tr,
                  onTap: _onLogin,
                  loading: _loading,
                ),

                SizedBox(height: 16.h),

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or_continue_with'.tr, style: AppTextStyles.caption),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: _SocialBtn(
                        label: 'google'.tr,
                        icon: Icons.g_mobiledata_rounded,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SocialBtn(
                        label: 'apple'.tr,
                        icon: Icons.apple_rounded,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${'no_account'.tr} ', style: AppTextStyles.bodyMedium),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.signup),
                        child: Text(
                          'sign_up'.tr,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
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

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppColors.border),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.labelLarge),
          ],
        ),
      ),
    );
  }
}
