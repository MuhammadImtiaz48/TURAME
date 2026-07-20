import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';
import '../../../../controllers/caregiver_controllers/caregiver_dashboard_controller.dart';
import '../../../../controllers/caregiver_profile_controller.dart';
import '../../../../models/user_model.dart';
import '../../../../routes/app_routes.dart';

class CaregiverProfileScreen extends StatelessWidget {
  const CaregiverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.isRegistered<CaregiverProfileController>()
        ? Get.find<CaregiverProfileController>()
        : Get.put(CaregiverProfileController());
    final dashCtrl = Get.find<CaregiverDashboardController>();
    final auth = Get.find<AuthController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileCtrl.loadProfile();
    });

    return Obx(() {
      final profile = profileCtrl.profile.value;
      final isLoading = profileCtrl.isLoading.value;

      if (isLoading && profile == null) {
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
              child: CircularProgressIndicator(color: AppColors.caregiverColor)),
        );
      }

      final name = profile?.name ?? auth.user.value?.name ?? 'Caregiver';
      final serviceType = profile?.serviceType ?? 'Caregiver';
      final rating = profile?.rating ?? 0.0;
      final experienceYears = profile?.experienceYears ?? 0;
      final isVerified = profile?.isVerified ?? false;
      final memberSince = _memberSince(auth.user.value);
      final totalClients = dashCtrl.clients.length;
      final activeClients = dashCtrl.activeClientsCount;
      final pendingClients = dashCtrl.pendingClients.length;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(
                name: name,
                serviceType: serviceType,
                rating: rating,
                experienceYears: experienceYears,
                isVerified: isVerified,
                memberSince: memberSince,
                contact: auth.user.value,
                imageUrl: profile?.imageUrl,
              ),
              Padding(
                padding: EdgeInsets.all(AppTheme.spacingLG),
                child: Column(
                  children: [
                    _StatsCard(
                      totalClients: totalClients,
                      activeClients: activeClients,
                      pendingClients: pendingClients,
                      rating: rating,
                    ),
                    SizedBox(height: 20.h),
                    _buildOptionTile(
                      Icons.person_outline_rounded,
                      'Edit Profile',
                      () => Get.toNamed(AppRoutes.caregiverEditProfile),
                    ),
                    _buildOptionTile(
                      Icons.schedule_rounded,
                      'Availability Schedule',
                      () => Get.toNamed(AppRoutes.caregiverEditProfile),
                    ),
                    _buildOptionTile(
                      Icons.account_balance_wallet_outlined,
                      'Earnings & Withdrawals',
                      () => Get.toNamed(AppRoutes.caregiverWithdraw),
                    ),
                    _buildOptionTile(
                      Icons.receipt_long_outlined,
                      'Earnings History',
                      () => Get.toNamed(AppRoutes.caregiverEarningsHistory),
                    ),
                    _buildOptionTile(
                      Icons.language_rounded,
                      'Language & Region',
                      () => _showLanguageDialog(),
                    ),
                    _buildOptionTile(
                      Icons.notifications_none_rounded,
                      'Notifications',
                      () {},
                      isSwitch: true,
                      switchValue: profileCtrl.notificationsEnabled.value,
                      onSwitchChanged: profileCtrl.toggleNotifications,
                    ),
                    _buildOptionTile(
                      Icons.lock_outline_rounded,
                      'Privacy & Security',
                      () => Get.toNamed(AppRoutes.privacySecurity),
                    ),
                    _buildOptionTile(
                      Icons.help_outline_rounded,
                      'Help & Support',
                      () => Get.toNamed(AppRoutes.helpSupport),
                    ),
                    SizedBox(height: 30.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                        ),
                        onPressed: () => auth.signOut(),
                        child: Text(
                          'Sign Out',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _memberSince(UserModel? user) {
    final created = user?.createdAt;
    if (created == null) return 'New';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[created.month - 1]} ${created.year}';
  }

  void _showLanguageDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('select_language'.tr, style: AppTextStyles.h3),
            ListTile(
              title: const Text('English'),
              onTap: () {
                Get.updateLocale(const Locale('en', 'US'));
                Get.back();
              },
            ),
            ListTile(
              title: const Text('Kinyarwanda'),
              onTap: () {
                Get.updateLocale(const Locale('rw', 'RW'));
                Get.back();
              },
            ),
            ListTile(
              title: const Text('Français'),
              onTap: () {
                Get.updateLocale(const Locale('fr', 'FR'));
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isSwitch = false,
    bool switchValue = true,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: Icon(icon, color: AppColors.caregiverColor),
        title: Text(title, style: AppTextStyles.bodyLarge),
        trailing: isSwitch
            ? Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeThumbColor: AppColors.caregiverColor,
              )
            : Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String serviceType;
  final double rating;
  final int experienceYears;
  final bool isVerified;
  final String memberSince;
  final UserModel? contact;
  final String? imageUrl;

  const _ProfileHeader({
    required this.name,
    required this.serviceType,
    required this.rating,
    required this.experienceYears,
    required this.isVerified,
    required this.memberSince,
    required this.contact,
    this.imageUrl,
  });

  String get _contactInfo {
    if (contact?.phone.isNotEmpty == true) return contact!.phone;
    if (contact?.email.isNotEmpty == true) return contact!.email;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 60.h, 16.w, 24.h),
      decoration: const BoxDecoration(gradient: AppColors.caregiverGradient),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
              image: imageUrl != null && imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null || imageUrl!.isEmpty
                ? Center(
                    child: Text('🧑‍🤝‍🧑', style: TextStyle(fontSize: 36.sp)),
                  )
                : null,
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  name,
                  style: AppTextStyles.onDarkTitle,
                  textAlign: TextAlign.center,
                ),
              ),
              if (isVerified) ...[
                SizedBox(width: 6.w),
                const Icon(Icons.verified_rounded,
                    color: Colors.white, size: 18),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            serviceType,
            style: AppTextStyles.onDarkBody,
          ),
          if (_contactInfo.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              _contactInfo,
              style: AppTextStyles.onDarkBody,
            ),
          ],
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              SizedBox(width: 4.w),
              Text(
                '$rating · $experienceYears yrs exp',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Member since $memberSince',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int totalClients;
  final int activeClients;
  final int pendingClients;
  final double rating;

  const _StatsCard({
    required this.totalClients,
    required this.activeClients,
    required this.pendingClients,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Clients', '$totalClients'),
          _divider(),
          _statItem('Active', '$activeClients'),
          _divider(),
          _statItem('Requests', '$pendingClients'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36.h,
        color: AppColors.borderLight,
      );

  Widget _statItem(String label, String value) => Column(
        children: [
          Text(value, style: AppTextStyles.h2.copyWith(fontSize: 18.sp)),
          SizedBox(height: 2.h),
          Text(label, style: AppTextStyles.caption),
        ],
      );
}
