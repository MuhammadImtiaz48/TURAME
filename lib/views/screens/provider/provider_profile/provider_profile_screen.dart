import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';
import '../../../../controllers/provider_controller/provider_profile_controller.dart';
import '../../../../controllers/provider_controller/provider_dashboard_controller.dart';
import '../../../../routes/app_routes.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen>
    with WidgetsBindingObserver {
  late final ProviderProfileController _profileCtrl;

  @override
  void initState() {
    super.initState();
    _profileCtrl = Get.isRegistered<ProviderProfileController>()
        ? Get.find<ProviderProfileController>()
        : Get.put(ProviderProfileController());
    WidgetsBinding.instance.addObserver(this);
    _profileCtrl.loadProfile();

    final dashCtrl = Get.find<ProviderDashboardController>();
    dashCtrl.currentTab.listen((index) {
      if (index == 5) _profileCtrl.loadProfile();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _profileCtrl.loadProfile();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileCtrl = _profileCtrl;
    final dashCtrl = Get.find<ProviderDashboardController>();
    final authCtrl = Get.find<AuthController>();

    return Obx(() {
      final profile = profileCtrl.profile.value;
      final isLoading = profileCtrl.isLoading.value;

      if (isLoading && profile == null) {
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }

      final doctorName = profile?.name ?? dashCtrl.doctorName;
      final specialty = profile?.specialty ?? dashCtrl.specialty;
      final rating = profile?.rating ?? 0.0;
      final experienceYears = profile?.experienceYears ?? 0;
      final memberSince = _memberSince();
      final totalPatients = dashCtrl.allPatients.length;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(
                doctorName: doctorName,
                specialty: specialty,
                rating: rating,
                experienceYears: experienceYears,
                memberSince: memberSince,
                imageUrl: profile?.imageUrl,
              ),
              Padding(
                padding: EdgeInsets.all(AppTheme.spacingLG),
                child: Column(
                  children: [
                    _StatsCard(
                      totalPatients: totalPatients,
                      rating: rating,
                      pendingCount: dashCtrl.pendingCount,
                    ),
                    SizedBox(height: 20.h),
                    _buildOptionTile(
                      Icons.person_outline_rounded,
                      'Edit Profile',
                      () => Get.toNamed(AppRoutes.providerEditProfile),
                    ),
                    _buildOptionTile(
                      Icons.schedule_rounded,
                      'Availability Schedule',
                      () => Get.toNamed(AppRoutes.providerEditProfile),
                    ),
                    _buildOptionTile(
                      Icons.account_balance_wallet_outlined,
                      'Earnings & Withdrawals',
                      () => Get.toNamed(AppRoutes.providerWithdraw),
                    ),
                    _buildOptionTile(
                      Icons.receipt_long_outlined,
                      'Earnings History',
                      () => Get.toNamed(AppRoutes.providerEarningsHistory),
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
                         onPressed: () => authCtrl.signOut(),
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

  String _memberSince() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[now.month - 1]} ${now.year}';
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
        leading: Icon(icon, color: AppColors.providerColor),
        title: Text(title, style: AppTextStyles.bodyLarge),
        trailing: isSwitch
            ? Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeThumbColor: AppColors.providerColor,
              )
            : Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final double rating;
  final int experienceYears;
  final String memberSince;
  final String? imageUrl;

  const _ProfileHeader({
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.experienceYears,
    required this.memberSince,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 60.h, 16.w, 24.h),
      decoration: const BoxDecoration(gradient: AppColors.healthGradient),
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
                    child: Text('🧑‍⚕️', style: TextStyle(fontSize: 36.sp)),
                  )
                : null,
          ),
          SizedBox(height: 12.h),
          Text(doctorName, style: AppTextStyles.onDarkTitle),
          SizedBox(height: 4.h),
          Text(
            specialty,
            style: AppTextStyles.onDarkBody,
          ),
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
  final int totalPatients;
  final double rating;
  final int pendingCount;

  const _StatsCard({
    required this.totalPatients,
    required this.rating,
    required this.pendingCount,
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
          _statItem('Patients', '$totalPatients'),
          _divider(),
          _statItem('Rating', '$rating'),
          _divider(),
          _statItem('Pending', '$pendingCount'),
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

