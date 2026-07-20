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
import '../../widgets/role_card.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selected = UserRole.patient;
  bool _loading = false;

  Future<void> _onContinue() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    final authCtrl = Get.find<AuthController>();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final success = await authCtrl.signUp(
        name: args['name'] as String,
        email: args['email'] as String,
        phone: args['phone'] as String,
        password: args['password'] as String,
        role: _selected!,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (!success) {
        Get.snackbar(
          'Error',
          authCtrl.errorMessage.value.isNotEmpty
              ? authCtrl.errorMessage.value
              : 'An error occurred during registration',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: AppColors.textOnDark,
        );
        return;
      }
    } else {
      await authCtrl.updateUserRole(_selected!);
      if (!mounted) return;
      setState(() => _loading = false);
      if (authCtrl.errorMessage.value.isNotEmpty) {
        Get.snackbar(
          'Error',
          authCtrl.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: AppColors.textOnDark,
        );
        return;
      }
    }
    switch (_selected!) {
      case UserRole.provider:
        Get.offAllNamed(AppRoutes.providerDashboard);
        break;
      case UserRole.caregiver:
        Get.offAllNamed(AppRoutes.caregiverDashboard);
        break;
      default:
        Get.offAllNamed(AppRoutes.patientDashboard);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'ROLE SELECTION',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              SizedBox(height: 32.h),

              Text(
                'who_are_you'.tr,
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Select your role to personalize your experience',
                style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40.h),

              RoleCard(
                emoji: '👤',
                emojiColor: AppColors.patientColor,
                title: 'patient'.tr,
                subtitle: 'Find and book healthcare providers & caregivers',
                isSelected: _selected == UserRole.patient,
                selectedColor: AppColors.patientColor,
                onTap: () => setState(() => _selected = UserRole.patient),
              ),

              SizedBox(height: 12.h),

              RoleCard(
                emoji: '🩺',
                emojiColor: AppColors.providerColor,
                title: 'provider'.tr,
                subtitle: 'Doctors, Nurses, Physiotherapists, Laboratory Technicians for home sample collection, and Pyschologists. — home visits only',
                isSelected: _selected == UserRole.provider,
                selectedColor: AppColors.providerColor,
                onTap: () => setState(() => _selected = UserRole.provider),
              ),


              SizedBox(height: 12.h),

              RoleCard(
                emoji: '🤲',
                emojiColor: AppColors.caregiverColor,
                title: 'caregiver'.tr,
                subtitle: 'Home or hospital support, elderly care, personal assistance',
                isSelected: _selected == UserRole.caregiver,
                selectedColor: AppColors.caregiverColor,
                onTap: () => setState(() => _selected = UserRole.caregiver),
              ),

              SizedBox(height: 24.h),

              AppButton(
                label: 'Continue →',
                onTap: (_selected != null && !_loading) ? _onContinue : null,
                loading: _loading,
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
