import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';
import 'package:rambaa/controllers/auth_controllers/auth_controller.dart';
import 'package:rambaa/controllers/language_controller.dart';
import 'package:rambaa/models/user_model.dart';
import 'package:rambaa/routes/app_routes.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final authCtrl = Get.find<AuthController>();
    if (authCtrl.isLoggedIn && authCtrl.user.value != null) {
      final role = authCtrl.user.value!.role;
      switch (role) {
        case UserRole.provider:
          Get.offAllNamed(AppRoutes.providerDashboard);
          break;
        case UserRole.caregiver:
          Get.offAllNamed(AppRoutes.caregiverDashboard);
          break;
        case UserRole.home:
          Get.offAllNamed(AppRoutes.providerDashboard);
          break;
        default:
          Get.offAllNamed(AppRoutes.patientDashboard);
          break;
      }
    } else {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = Get.find<LanguageController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            SizedBox(height: 24.h),
            Text(
              'app_name'.tr,
              style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 8.h),
            Text(
              'app_tagline'.tr,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
