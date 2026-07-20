import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/provider_controller/provider_profile_controller.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';
import '../../../../models/provider_model.dart';
import '../../../../services/cloudinary_service.dart';
import '../../../widgets/app_text_field.dart';

class ProviderEditProfileScreen extends StatefulWidget {
  const ProviderEditProfileScreen({super.key});

  @override
  State<ProviderEditProfileScreen> createState() =>
      _ProviderEditProfileScreenState();
}

class _ProviderEditProfileScreenState extends State<ProviderEditProfileScreen> {
  final _fullNameCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _picker = ImagePicker();
  String? _imageUrl;

  bool _monFriEnabled = true;
  bool _satEnabled = false;
  bool _isUploading = false;

  final _formKey = GlobalKey<FormState>();
  late final ProviderProfileController _profileCtrl;
  String _selectedLocation = 'Clinic';
  final List<String> _locationOptions = ['Clinic', 'Home', 'Both'];

  @override
  void initState() {
    super.initState();
    _profileCtrl = Get.isRegistered<ProviderProfileController>()
        ? Get.find<ProviderProfileController>()
        : Get.put(ProviderProfileController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _profileCtrl.loadProfile();
    });
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _specialtyCtrl.dispose();
    _experienceCtrl.dispose();
    _licenseCtrl.dispose();
    _feeCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _populateFields(ProviderModel p) {
    _fullNameCtrl.text = p.name;
    _specialtyCtrl.text = p.specialty;
    _experienceCtrl.text = '${p.experienceYears}';
    _licenseCtrl.text = p.licenseNumber;
    _feeCtrl.text = p.consultationFee.toStringAsFixed(0);
    _bioCtrl.text = p.bio;
    _selectedLocation = p.providerLocation;
    _imageUrl = p.imageUrl.isNotEmpty ? p.imageUrl : null;

    for (final slot in p.availability) {
      final days = slot['days']?.toString() ?? '';
      final enabled = slot['enabled'] == true;
      if (days.contains('Monday') || days.contains('Mon')) {
        _monFriEnabled = enabled;
      } else if (days.contains('Saturday') || days.contains('Sat')) {
        _satEnabled = enabled;
      }
    }
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
          backgroundColor: AppColors.danger,
          colorText: AppColors.textOnDark,
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
          backgroundColor: AppColors.danger,
          colorText: AppColors.textOnDark,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final experience = int.tryParse(_experienceCtrl.text.trim()) ?? 0;
      final fee = double.tryParse(_feeCtrl.text.trim().replaceAll(',', '')) ?? 0.0;

      final updated = ProviderModel(
        id: _profileCtrl.profile.value?.id ?? Get.find<AuthController>().user.value?.id ?? '',
        name: _fullNameCtrl.text.trim(),
        specialty: _specialtyCtrl.text.trim(),
        imageUrl: _imageUrl ?? _profileCtrl.profile.value?.imageUrl ?? '',
        rating: _profileCtrl.profile.value?.rating ?? 0.0,
        reviewCount: _profileCtrl.profile.value?.reviewCount ?? 0,
        consultationFee: fee,
        isAvailable: _profileCtrl.profile.value?.isAvailable ?? true,
        isVerified: _profileCtrl.profile.value?.isVerified ?? true,
        experienceYears: experience,
        distanceKm: _profileCtrl.profile.value?.distanceKm ?? 0.0,
        languages: _profileCtrl.profile.value?.languages ?? const [],
        services: _profileCtrl.profile.value?.services ?? const [],
        hospital: _profileCtrl.profile.value?.hospital ?? '',
        providerLocation: _selectedLocation,
        licenseNumber: _licenseCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        availability: [
          {'days': 'Monday – Friday', 'hours': '8:00 AM – 5:00 PM', 'enabled': _monFriEnabled},
          {'days': 'Saturday', 'hours': '9:00 AM – 1:00 PM', 'enabled': _satEnabled},
        ],
        education: _profileCtrl.profile.value?.education ?? const [],
      );

      final saved = await _profileCtrl.saveProfile(updated);
      if (saved && mounted) {
        _profileCtrl.loadProfile();
        Get.back();
        Get.snackbar(
          'Saved',
          'Profile updated successfully',
          backgroundColor: AppColors.healthGreenLighter,
          colorText: AppColors.success,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (mounted) {
        Get.snackbar(
          'Error',
          _profileCtrl.errorMessage.value.isNotEmpty
              ? _profileCtrl.errorMessage.value
              : 'Failed to save profile',
          backgroundColor: AppColors.danger,
          colorText: AppColors.textOnDark,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = _profileCtrl.isLoading.value;
      final profile = _profileCtrl.profile.value;

      if (profile != null && _fullNameCtrl.text.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _populateFields(profile);
        });
      }

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
              onPressed: loading ? null : _saveChanges,
              child: Text(
                'Save',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        body: loading && profile == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Form(
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
                                    color: AppColors.primaryLighter,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.3),
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
                                          child: Text('🧑‍⚕️', style: TextStyle(fontSize: 36.sp)),
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
                                        color: AppColors.primary,
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
                                  color: AppColors.primary,
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
                        label: 'Specialty',
                        hint: 'e.g. Cardiologist',
                        controller: _specialtyCtrl,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                        textInputAction: TextInputAction.next,
                      ),

                       SizedBox(height: 16.h),

                       Text('Practice Location', style: AppTextStyles.labelLarge.copyWith(fontSize: 14.sp)),
                       SizedBox(height: 8.h),
                       Container(
                         padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
                         decoration: BoxDecoration(
                           color: AppColors.surface2,
                           borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                           border: Border.all(color: AppColors.border),
                         ),
                         child: DropdownButtonHideUnderline(
                           child: DropdownButton<String>(
                             value: _selectedLocation,
                             isExpanded: true,
                             icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
                             style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
                             items: _locationOptions.map((loc) {
                               return DropdownMenuItem<String>(
                                 value: loc,
                                 child: Text(loc),
                               );
                             }).toList(),
                             onChanged: (val) {
                               if (val != null) {
                                 setState(() => _selectedLocation = val);
                               }
                             },
                           ),
                         ),
                       ),

                       SizedBox(height: 16.h),

                       AppTextField(
                         label: 'Years of Experience',
                        hint: 'e.g. 12',
                        type: AppTextFieldType.phone,
                        controller: _experienceCtrl,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                        textInputAction: TextInputAction.next,
                      ),

                      SizedBox(height: 16.h),

                      AppTextField(
                        label: 'License Number',
                        hint: 'e.g. RMC-2011-0234',
                        controller: _licenseCtrl,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                        textInputAction: TextInputAction.next,
                      ),

                      SizedBox(height: 16.h),

                      AppTextField(
                        label: 'Consultation Fee (RWF)',
                        hint: 'e.g. 15,000',
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
                        onPressed: loading ? null : _saveChanges,
                        child: Text('Save Changes', style: AppTextStyles.buttonLarge),
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}

// ─── Bio Field ────────────────────────────────────────────────────────────────
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

// ─── Availability Tile ────────────────────────────────────────────────────────
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
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryLight.withValues(alpha: 0.4),
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.borderLight,
          ),
        ],
      ),
    );
  }
}
