import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';
import '../../../../controllers/patient_controllers/patient_profile_controller.dart';
import '../../../../models/user_model.dart';
import '../../../../models/patient_model.dart';
import '../../../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authCtrl = Get.find<AuthController>();
  final PatientProfileController profileCtrl = Get.find<PatientProfileController>();

  @override
  void initState() {
    super.initState();
    if (profileCtrl.patient.value == null && !profileCtrl.isLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) profileCtrl.loadProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = authCtrl.user.value;
      final patient = profileCtrl.patient.value;
      final isLoading = profileCtrl.isLoading.value;

      if (user == null && !isLoading) {
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(user: user, imageUrl: patient?.imageUrl),
              Padding(
                padding: EdgeInsets.all(AppTheme.spacingLG),
                child: Column(
                  children: [
                    _MedicalInfoCard(patient: patient, isLoading: isLoading),
                    SizedBox(height: 20.h),
                    _buildOptionTile(
                      Icons.person_outline,
                      'Personal Details',
                      () => Get.toNamed(AppRoutes.patientEditProfile),
                    ),
                    _buildOptionTile(
                      Icons.language,
                      'Language & Region',
                      () => _showLanguageDialog(),
                    ),
                     _buildOptionTile(
                       Icons.notifications_none,
                       'Notifications',
                       () {},
                       isSwitch: true,
                       switchValue: profileCtrl.notificationsEnabled.value,
                       onSwitchChanged: profileCtrl.toggleNotifications,
                     ),
                     _buildOptionTile(
                       Icons.lock_outline,
                       'Privacy & Security',
                       () => Get.toNamed(AppRoutes.privacySecurity),
                     ),
                     _buildOptionTile(
                       Icons.help_outline,
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
                         onPressed: () => _confirmLogout(authCtrl),
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
            Text("Select Language", style: AppTextStyles.h3),
            ListTile(
              title: Text("English"),
              onTap: () {
                Get.updateLocale(const Locale('en', 'US'));
                Get.back();
              },
            ),
            ListTile(
              title: Text("Kinyarwanda"),
              onTap: () {
                Get.updateLocale(const Locale('rw', 'RW'));
                Get.back();
              },
            ),
            ListTile(
              title: const Text("Français"),
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

  Future<void> _confirmLogout(AuthController authCtrl) async {
    await authCtrl.signOut();
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
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyLarge),
        trailing: isSwitch
            ? Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeThumbColor: AppColors.primary,
              )
            : Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel? user;
  final String? imageUrl;

  const _ProfileHeader({this.user, this.imageUrl});

  String _roleLabel(UserModel? user) {
    switch (user?.role) {
      case UserRole.caregiver:
        return 'Caregiver';
      case UserRole.provider:
        return 'Provider';
      case UserRole.home:
        return 'Home Healthcare Provider';
      default:
        return 'Patient';
    }
  }

  String _memberSince(UserModel? user) {
    final createdAt = user?.createdAt;
    if (createdAt == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const SizedBox.shrink();
    }
    final u = user!;
    final contact = (u.phone.isNotEmpty) ? u.phone : u.email;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 60.h, 16.w, 20.h),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundColor: Colors.white24,
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : null,
            child: imageUrl == null || imageUrl!.isEmpty
                ? Icon(Icons.person, size: 50.r, color: Colors.white)
                : null,
          ),
          SizedBox(height: 12.h),
          Text(u.name, style: AppTextStyles.onDarkTitle),
          Text(
            '${_roleLabel(u)} · $contact',
            style: AppTextStyles.onDarkBody,
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Member since ${_memberSince(u)}',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalInfoCard extends StatelessWidget {
  final PatientModel? patient;
  final bool isLoading;

  const _MedicalInfoCard({this.patient, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MEDICAL INFO',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (isLoading && patient == null)
                SizedBox(
                  width: 14.r,
                  height: 14.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          if (patient != null)
            Wrap(
              spacing: 12.w,
              runSpacing: 14.h,
              alignment: WrapAlignment.spaceBetween,
              children: [
                _infoItem(context, 'Blood Type', patient!.bloodType.isNotEmpty ? patient!.bloodType : '—'),
                _infoItem(context, 'Age', patient!.age > 0 ? '${patient!.age} yrs' : '—'),
                _infoItem(context, 'Heart Rate', patient!.heartRate?.isNotEmpty == true ? '${patient!.heartRate} bpm' : '--'),
                _infoItem(context, 'Oxygen', patient!.oxygen?.isNotEmpty == true ? '${patient!.oxygen}%' : '--'),
                _infoItem(context, 'Blood Pressure', patient!.bloodPressure?.isNotEmpty == true ? patient!.bloodPressure! : '--'),
              ],
            )
          else
            Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Text('No medical info available', style: AppTextStyles.bodyMedium),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoItem(BuildContext context, String label, String value) => SizedBox(
    width: (MediaQuery.of(context).size.width - AppTheme.spacingLG * 2 - 24.w) / 3,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.h3),
      ],
    ),
  );
}
