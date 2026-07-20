import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_theme.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../controllers/auth_controllers/auth_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final ctrl = Get.find<AuthController>();
    final langCtrl = Get.find<LanguageController>();
    if (ctrl.isLoggedIn && ctrl.user.value != null) {
      Future.microtask(() {
        final role = ctrl.user.value!.role;
        if (role == UserRole.provider) {
          Get.offAllNamed(AppRoutes.providerDashboard);
        } else if (role == UserRole.caregiver) {
          Get.offAllNamed(AppRoutes.caregiverDashboard);
        } else if (role == UserRole.home) {
          Get.offAllNamed(AppRoutes.providerDashboard);
        } else {
          Get.offAllNamed(AppRoutes.patientDashboard);
        }
      });
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.welcomeGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
              
                const SizedBox(height: 24),
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    image: DecorationImage(
                      image: AssetImage(langCtrl.logoAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                 
                ),
               
                const SizedBox(height: 40),
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.textOnDark.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'app_subtitle'.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnDark.withValues(alpha: 0.85),
                    fontSize: 15,
                    height: 1.65,
                  ),
                ),
                const Spacer(flex: 2),
                AppButton.white(
                  label: 'get_started'.tr,
                  onTap: () => Get.toNamed(AppRoutes.language),
                ),
                const SizedBox(height: 14),
                const _SignInRow(),
                const SizedBox(height: 36),
                const _LanguageRow(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartIcon extends StatelessWidget {
  const _HeartIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.textOnDark.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('💙', style: TextStyle(fontSize: 46)),
      ),
    );
  }
}

class _SignInRow extends StatelessWidget {
  const _SignInRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${'already_account'.tr} ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textOnDark.withValues(alpha: 0.7),
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.login),
          child: Text(
            'sign_in'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LangItem(flag: '🇷🇼', label: 'Kinyarwanda', code: 'rw'),
        const _Pipe(),
        _LangItem(flag: '🇫🇷', label: 'Français', code: 'fr'),
        const _Pipe(),
        _LangItem(flag: '🇬🇧', label: 'English', code: 'en'),
      ],
    );
  }
}

class _LangItem extends StatelessWidget {
  final String flag;
  final String label;
  final String code;
  const _LangItem({required this.flag, required this.label, required this.code});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.language),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textOnDark.withValues(alpha: 0.55),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pipe extends StatelessWidget {
  const _Pipe();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '|',
        style: TextStyle(
          color: AppColors.textOnDark.withValues(alpha: 0.3),
          fontSize: 11,
        ),
      ),
    );
  }
}