import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppTheme.spacingLG),
        children: [
          _buildSectionTitle('General'),
          SizedBox(height: 12.h),
          _buildInfoTile(
            Icons.notifications_outlined,
            'Notifications',
            'Manage notification preferences',
            () {},
          ),
          _buildInfoTile(
            Icons.language_outlined,
            'Language',
            'English',
            () {},
          ),
          _buildInfoTile(
            Icons.dark_mode_outlined,
            'Dark Mode',
            'Appearance settings',
            () {},
          ),
          SizedBox(height: 24.h),
          _buildSectionTitle('Account'),
          SizedBox(height: 12.h),
          _buildInfoTile(
            Icons.person_outline_outlined,
            'Edit Profile',
            'Update your personal information',
            () {},
          ),
          _buildInfoTile(
            Icons.logout_outlined,
            'Sign Out',
            'Log out of your account',
            () {
              Get.dialog(
                AlertDialog(
                  title: Text('Sign Out', style: AppTextStyles.h3),
                  content: Text(
                    'Are you sure you want to sign out?',
                    style: AppTextStyles.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel', style: AppTextStyles.bodyMedium),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        final authCtrl = Get.find<AuthController>();
                        authCtrl.signOut();
                      },
                      child: Text(
                        'Sign Out',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
