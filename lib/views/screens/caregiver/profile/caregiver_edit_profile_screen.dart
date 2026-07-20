import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';
import '../../../../controllers/caregiver_profile_controller.dart';
import '../../../../models/caregiver_profile_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/cloudinary_service.dart';
import '../../../../services/firebase_service.dart';
import '../../../../utils/loading_utils.dart';
import '../../../widgets/app_text_field.dart';

class CaregiverEditProfileScreen extends StatefulWidget {
  const CaregiverEditProfileScreen({super.key});

  @override
  State<CaregiverEditProfileScreen> createState() =>
      _CaregiverEditProfileScreenState();
}

class _CaregiverEditProfileScreenState
    extends State<CaregiverEditProfileScreen> {
  final _fullNameCtrl = TextEditingController();
  final _serviceTypeCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _picker = ImagePicker();
  String? _imageUrl;

  bool _monFriEnabled = true;
  bool _satEnabled = false;
  bool _isSaving = false;
  bool _isUploading = false;

  final _formKey = GlobalKey<FormState>();

  CaregiverProfileController get _profileCtrl =>
      Get.isRegistered<CaregiverProfileController>()
          ? Get.find<CaregiverProfileController>()
          : Get.put(CaregiverProfileController());

  @override
  void initState() {
    super.initState();
    final profile = _profileCtrl.profile.value;
    if (profile != null) {
      _fullNameCtrl.text = profile.name;
      _serviceTypeCtrl.text = profile.serviceType;
      _experienceCtrl.text = profile.experienceYears.toString();
      _feeCtrl.text = profile.dailyRate.toStringAsFixed(0);
      _bioCtrl.text = profile.bio;
      _imageUrl = profile.imageUrl.isNotEmpty ? profile.imageUrl : null;
      if (profile.availability.isNotEmpty) {
        for (final a in profile.availability) {
          final days = (a['days'] ?? '').toString();
          if (days.contains('Monday') && days.contains('Friday')) {
            _monFriEnabled = a['enabled'] ?? true;
          } else if (days == 'Saturday') {
            _satEnabled = a['enabled'] ?? false;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _serviceTypeCtrl.dispose();
    _experienceCtrl.dispose();
    _licenseCtrl.dispose();
    _feeCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null) return;

      setState(() {
        _isUploading = true;
      });

      final fileBytes = await picked.readAsBytes();
      final fileName = picked.name;
      final url = await CloudinaryService.uploadImageToFolder(
        path: picked.path,
        fileBytes: fileBytes,
        folder: 'level_plus/profile_images',
        fileName: fileName,
      );

      if (url != null && mounted) {
        setState(() {
          _imageUrl = url;
          _isUploading = false;
        });
        Get.snackbar(
          'Success',
          'Profile photo uploaded',
          backgroundColor: AppColors.healthGreenLighter,
          colorText: AppColors.success,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (mounted) {
        setState(() {
          _isUploading = false;
        });
        Get.snackbar(
          'Error',
          'Failed to upload image',
          backgroundColor: AppColors.danger.withValues(alpha: 0.1),
          colorText: AppColors.danger,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: AppColors.danger.withValues(alpha: 0.1),
          colorText: AppColors.danger,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);
    LoadingUtils.show(message: 'Saving profile...');

    try {
      final auth = Get.find<AuthController>();
      final current = _profileCtrl.profile.value;
      final base = current ??
          CaregiverProfileModel(
            id: auth.user.value?.id ?? '',
            name: '',
            serviceType: 'Caregiver',
            imageUrl: '',
            rating: 0,
            reviewCount: 0,
            dailyRate: 0,
            isAvailable: true,
            isVerified: false,
            experienceYears: 0,
            distanceKm: 0,
            languages: const [],
            skills: const [],
            location: 'Kigali, Rwanda',
          );

      final updated = base.copyWith(
        name: _fullNameCtrl.text.trim(),
        serviceType: _serviceTypeCtrl.text.trim(),
        imageUrl: _imageUrl ?? base.imageUrl,
        experienceYears: int.tryParse(_experienceCtrl.text.trim()) ?? 0,
        dailyRate:
            double.tryParse(_feeCtrl.text.replaceAll(',', '').trim()) ?? 0,
        bio: _bioCtrl.text.trim(),
        availability: [
          {
            'days': 'Monday – Friday',
            'hours': '8:00 AM – 5:00 PM',
            'enabled': _monFriEnabled,
          },
          {
            'days': 'Saturday',
            'hours': '9:00 AM – 1:00 PM',
            'enabled': _satEnabled,
          },
        ],
      );

      final success = await _profileCtrl.saveProfile(updated);

      if (success) {
        final userId = auth.user.value?.id ?? updated.id;
        if (userId.isNotEmpty) {
          await FirebaseService.updateUser(UserModel(
            id: userId,
            name: updated.name,
            email: auth.user.value?.email ?? '',
            phone: auth.user.value?.phone ?? '',
            role: auth.user.value?.role ?? UserRole.caregiver,
          ));
          await auth.refreshUserData();
        }
      }

      LoadingUtils.hide();
      setState(() => _isSaving = false);

      if (success) {
        Get.back();
        Get.snackbar(
          'Saved',
          'Profile updated successfully',
          backgroundColor: AppColors.healthGreenLighter,
          colorText: AppColors.success,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          _profileCtrl.errorMessage.value.isNotEmpty
              ? _profileCtrl.errorMessage.value
              : 'Could not save profile. Try again.',
          backgroundColor: AppColors.danger.withValues(alpha: 0.1),
          colorText: AppColors.danger,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      LoadingUtils.hide();
      setState(() => _isSaving = false);
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.danger.withValues(alpha: 0.1),
        colorText: AppColors.danger,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('My Profile', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              'Save',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.caregiverColor,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingMD,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 88.w,
                          height: 88.w,
                          decoration: BoxDecoration(
                            color: AppColors.accentLighter,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.caregiverColor
                                  .withValues(alpha: 0.3),
                              width: 2,
                            ),
                            image: _imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _imageUrl == null
                              ? Center(
                                  child: Text('😊', style: TextStyle(fontSize: 36.sp)),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploading ? null : _pickAndUploadImage,
                            child: Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: BoxDecoration(
                                color: AppColors.caregiverColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.surface, width: 2),
                              ),
                              child: _isUploading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.surface,
                                      ),
                                    )
                                  : const Icon(Icons.camera_alt_rounded,
                                      color: AppColors.surface, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: _isUploading ? null : _pickAndUploadImage,
                      child: Text(
                        _isUploading ? 'Uploading...' : 'Change Photo',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.caregiverColor,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              AppTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _fullNameCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16.h),
              AppTextField(
                label: 'Service Type',
                hint: 'e.g. Elderly Care',
                controller: _serviceTypeCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16.h),
              AppTextField(
                label: 'Years of Experience',
                hint: 'e.g. 5',
                type: AppTextFieldType.phone,
                controller: _experienceCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16.h),
              AppTextField(
                label: 'Certification Number',
                hint: 'e.g. CG-2024-0089',
                controller: _licenseCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16.h),
              AppTextField(
                label: 'Daily Rate (RWF)',
                hint: 'e.g. 8,000',
                type: AppTextFieldType.phone,
                controller: _feeCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16.h),
              _BioField(controller: _bioCtrl),
              SizedBox(height: 24.h),
              Text('Availability Schedule', style: AppTextStyles.h3),
              SizedBox(height: 12.h),
              _AvailabilityTile(
                days: 'Monday – Friday',
                hours: '8:00 AM – 5:00 PM',
                value: _monFriEnabled,
                onChanged: (v) => setState(() => _monFriEnabled = v),
              ),
              SizedBox(height: 10.h),
              _AvailabilityTile(
                days: 'Saturday',
                hours: '9:00 AM – 1:00 PM',
                value: _satEnabled,
                onChanged: (v) => setState(() => _satEnabled = v),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.caregiverColor,
                ),
                child: Text('Save Changes', style: AppTextStyles.buttonLarge),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _BioField extends StatelessWidget {
  final TextEditingController controller;

  const _BioField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 4.h),
        TextFormField(
          controller: controller,
          maxLines: 4,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Write a short bio...',
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textTertiary),
            suffixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_arrow_up_rounded,
                    size: 20, color: AppColors.textTertiary),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AvailabilityTile extends StatelessWidget {
  final String days;
  final String hours;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AvailabilityTile({
    required this.days,
    required this.hours,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(days, style: AppTextStyles.h3),
              SizedBox(height: 2.h),
              Text(hours, style: AppTextStyles.bodySmall),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.caregiverColor,
            activeTrackColor: AppColors.accentLight.withValues(alpha: 0.4),
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.borderLight,
          ),
        ],
      ),
    );
  }
}
