import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/patient_controllers/patient_profile_controller.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';
import '../../../../models/user_model.dart';
import '../../../../models/patient_model.dart';
import '../../../../services/cloudinary_service.dart';
import '../../../widgets/app_text_field.dart';

class PatientEditProfileScreen extends StatefulWidget {
  const PatientEditProfileScreen({super.key});

  @override
  State<PatientEditProfileScreen> createState() =>
      _PatientEditProfileScreenState();
}

class _PatientEditProfileScreenState extends State<PatientEditProfileScreen> {
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bloodTypeCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  final _oxygenCtrl = TextEditingController();
  final _bloodPressureCtrl = TextEditingController();
  final _picker = ImagePicker();
  String? _imageUrl;

  final _formKey = GlobalKey<FormState>();
  late final PatientProfileController _profileCtrl;
  bool _didPopulateFields = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _profileCtrl = Get.find<PatientProfileController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _profileCtrl.loadProfile();
    });
  }

  void _populateUserFields(UserModel u) {
    _fullNameCtrl.text = u.name;
    _phoneCtrl.text = u.phone;
  }

  void _populatePatientFields(PatientModel p) {
    _bloodTypeCtrl.text = p.bloodType;
    _ageCtrl.text = p.age > 0 ? '${p.age}' : '';
    _heartRateCtrl.text = p.heartRate ?? '';
    _oxygenCtrl.text = p.oxygen ?? '';
    _bloodPressureCtrl.text = p.bloodPressure ?? '';
    _imageUrl = p.imageUrl;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _bloodTypeCtrl.dispose();
    _ageCtrl.dispose();
    _heartRateCtrl.dispose();
    _oxygenCtrl.dispose();
    _bloodPressureCtrl.dispose();
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
      final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;

      final updatedUser = _profileCtrl.user.value?.copyWith(
            name: _fullNameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
          ) ??
          UserModel(
            id: _profileCtrl.user.value?.id ?? Get.find<AuthController>().user.value?.id ?? '',
            name: _fullNameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            email: _profileCtrl.user.value?.email ?? Get.find<AuthController>().user.value?.email ?? '',
            role: _profileCtrl.user.value?.role ?? Get.find<AuthController>().user.value?.role ?? UserRole.patient,
          );

      final updatedPatient = _profileCtrl.patient.value?.copyWith(
            bloodType: _bloodTypeCtrl.text.trim(),
            age: age,
            heartRate: _heartRateCtrl.text.trim(),
            oxygen: _oxygenCtrl.text.trim(),
            bloodPressure: _bloodPressureCtrl.text.trim(),
            imageUrl: _imageUrl ?? _profileCtrl.patient.value?.imageUrl,
          ) ??
          PatientModel(
            id: updatedUser.id,
            name: updatedUser.name,
            age: age,
            condition: _profileCtrl.patient.value?.condition ?? '',
            location: _profileCtrl.patient.value?.location ?? '',
            lastVisit: _profileCtrl.patient.value?.lastVisit ?? '',
            status: _profileCtrl.patient.value?.status ?? PatientStatus.active,
            bloodType: _bloodTypeCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            avatarEmoji: _profileCtrl.patient.value?.avatarEmoji ?? '👤',
            imageUrl: _imageUrl,
            heartRate: _heartRateCtrl.text.trim(),
            oxygen: _oxygenCtrl.text.trim(),
            bloodPressure: _bloodPressureCtrl.text.trim(),
          );

      final saved = await _profileCtrl.saveProfile(updatedUser, updatedPatient);
      if (saved && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            contentPadding: EdgeInsets.all(AppTheme.spacingXL),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: AppColors.healthGreenLighter,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 32.r,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: AppTheme.spacingLG),
                Text(
                  'Success',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacingSM),
                Text(
                  'Profile updated successfully',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacingXL),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Get.back();
                    },
                    child: Text('OK', style: AppTextStyles.buttonMedium),
                  ),
                ),
              ],
            ),
          ),
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
      final user = _profileCtrl.user.value;
      final patient = _profileCtrl.patient.value;

    if (user != null && patient != null && !_didPopulateFields) {
      _didPopulateFields = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateUserFields(user);
        _populatePatientFields(patient);
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
          title: Text('Edit Profile', style: AppTextStyles.h2),
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
        body: loading && user == null && patient == null
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
                                          child: Text('👤', style: TextStyle(fontSize: 36.sp)),
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

                      Text('Personal Details', style: AppTextStyles.h3),
                      SizedBox(height: 12.h),

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
                        label: 'Phone',
                        hint: 'Enter your phone number',
                        controller: _phoneCtrl,
                        type: AppTextFieldType.phone,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                        textInputAction: TextInputAction.next,
                      ),

                      SizedBox(height: 24.h),

                      Text('Medical Information', style: AppTextStyles.h3),
                      SizedBox(height: 12.h),

                      AppTextField(
                        label: 'Blood Type',
                        hint: 'e.g. A+',
                        controller: _bloodTypeCtrl,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                        textInputAction: TextInputAction.next,
                      ),

                      SizedBox(height: 16.h),

                      AppTextField(
                        label: 'Age',
                        hint: 'e.g. 30',
                        controller: _ageCtrl,
                        type: AppTextFieldType.phone,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                        textInputAction: TextInputAction.next,
                      ),

                      SizedBox(height: 16.h),

                      AppTextField(
                        label: 'Heart Rate (bpm)',
                        hint: 'e.g. 72',
                        controller: _heartRateCtrl,
                        type: AppTextFieldType.phone,
                        textInputAction: TextInputAction.next,
                      ),

                      SizedBox(height: 16.h),

                      AppTextField(
                        label: 'Oxygen Saturation (%)',
                        hint: 'e.g. 98',
                        controller: _oxygenCtrl,
                        type: AppTextFieldType.phone,
                        textInputAction: TextInputAction.next,
                      ),

                      SizedBox(height: 16.h),

                      AppTextField(
                        label: 'Blood Pressure',
                        hint: 'e.g. 120/80',
                        controller: _bloodPressureCtrl,
                        textInputAction: TextInputAction.done,
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
