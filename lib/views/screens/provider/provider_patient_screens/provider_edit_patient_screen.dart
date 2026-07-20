import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/provider_controller/provider_dashboard_controller.dart';
import '../../../../models/patient_model.dart';
import '../../../widgets/app_button.dart';

class ProviderEditPatientScreen extends StatefulWidget {
  const ProviderEditPatientScreen({super.key});

  @override
  State<ProviderEditPatientScreen> createState() =>
      _ProviderEditPatientScreenState();
}

class _ProviderEditPatientScreenState extends State<ProviderEditPatientScreen> {
  late final PatientModel _patient;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _conditionCtrl;
  late final TextEditingController _bloodTypeCtrl;
  late final TextEditingController _lastVisitCtrl;
  late final TextEditingController _nextAppointmentCtrl;
  late final TextEditingController _medicationsCtrl;
  late final TextEditingController _historyCtrl;
  late final TextEditingController _heartRateCtrl;
  late final TextEditingController _oxygenCtrl;
  late final TextEditingController _bloodPressureCtrl;
  late final TextEditingController _bloodSugarCtrl;

  late PatientStatus _status;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _patient = Get.arguments as PatientModel;
    _status = _patient.status;
    _nameCtrl = TextEditingController(text: _patient.name);
    _ageCtrl = TextEditingController(text: _patient.age.toString());
    _phoneCtrl = TextEditingController(text: _patient.phone);
    _locationCtrl = TextEditingController(text: _patient.location);
    _conditionCtrl = TextEditingController(text: _patient.condition);
    _bloodTypeCtrl = TextEditingController(text: _patient.bloodType);
    _lastVisitCtrl = TextEditingController(text: _patient.lastVisit);
    _nextAppointmentCtrl = TextEditingController(text: _patient.nextAppointment);
    _medicationsCtrl =
        TextEditingController(text: _patient.medications.join('\n'));
    _historyCtrl =
        TextEditingController(text: _patient.medicalHistory.join('\n'));
    _heartRateCtrl = TextEditingController(text: _patient.heartRate ?? '');
    _oxygenCtrl = TextEditingController(text: _patient.oxygen ?? '');
    _bloodPressureCtrl =
        TextEditingController(text: _patient.bloodPressure ?? '');
    _bloodSugarCtrl = TextEditingController(text: _patient.bloodSugar ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _conditionCtrl.dispose();
    _bloodTypeCtrl.dispose();
    _lastVisitCtrl.dispose();
    _nextAppointmentCtrl.dispose();
    _medicationsCtrl.dispose();
    _historyCtrl.dispose();
    _heartRateCtrl.dispose();
    _oxygenCtrl.dispose();
    _bloodPressureCtrl.dispose();
    _bloodSugarCtrl.dispose();
    super.dispose();
  }

  List<String> _splitLines(String value) => value
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = _patient.copyWith(
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()) ?? _patient.age,
      phone: _phoneCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      condition: _conditionCtrl.text.trim(),
      bloodType: _bloodTypeCtrl.text.trim(),
      lastVisit: _lastVisitCtrl.text.trim(),
      nextAppointment:
          _nextAppointmentCtrl.text.trim().isEmpty ? null : _nextAppointmentCtrl.text.trim(),
      medications: _splitLines(_medicationsCtrl.text),
      medicalHistory: _splitLines(_historyCtrl.text),
      status: _status,
      heartRate: _heartRateCtrl.text.trim().isEmpty
          ? null
          : _heartRateCtrl.text.trim(),
      oxygen: _oxygenCtrl.text.trim().isEmpty ? null : _oxygenCtrl.text.trim(),
      bloodPressure: _bloodPressureCtrl.text.trim().isEmpty
          ? null
          : _bloodPressureCtrl.text.trim(),
      bloodSugar: _bloodSugarCtrl.text.trim().isEmpty
          ? null
          : _bloodSugarCtrl.text.trim(),
    );

    final ctrl = Get.find<ProviderDashboardController>();
    final success = await ctrl.updatePatient(updated);
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      Get.back(result: updated);
      Get.snackbar(
        'Updated',
        'Patient details saved to profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.textOnDark,
      );
    } else {
      Get.snackbar(
        'Error',
        'Could not save patient details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: AppColors.textOnDark,
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Edit Patient', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingMD),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel('Full Name'),
              _TextField(
                controller: _nameCtrl,
                hint: 'Patient name',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 14.h),
              _FieldLabel('Age'),
              _TextField(
                controller: _ageCtrl,
                hint: 'Age',
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 14.h),
              _FieldLabel('Phone'),
              _TextField(controller: _phoneCtrl, hint: 'Phone number'),
              SizedBox(height: 14.h),
              _FieldLabel('Location'),
              _TextField(controller: _locationCtrl, hint: 'Location'),
              SizedBox(height: 14.h),
              _FieldLabel('Condition'),
              _TextField(controller: _conditionCtrl, hint: 'Condition'),
              SizedBox(height: 14.h),
              _FieldLabel('Blood Type'),
              _TextField(controller: _bloodTypeCtrl, hint: 'e.g. A+'),
              SizedBox(height: 14.h),
              _FieldLabel('Status'),
              Row(
                children: PatientStatus.values.map((s) {
                  final selected = _status == s;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: s != PatientStatus.values.last ? 8.w : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _status = s),
                        child: Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: selected ? s.statusColor : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: selected
                                  ? s.statusColor
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              s.statusLabel,
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: selected
                                    ? AppColors.textOnDark
                                    : AppColors.textSecondary,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 14.h),
              _FieldLabel('Last Visit'),
              _TextField(controller: _lastVisitCtrl, hint: 'e.g. Jun 18, 2025'),
              SizedBox(height: 14.h),
              _FieldLabel('Next Appointment'),
              _TextField(
                controller: _nextAppointmentCtrl,
                hint: 'e.g. Today · 10:00 AM',
              ),
              SizedBox(height: 14.h),
              _FieldLabel('Heart Rate (bpm)'),
              _TextField(
                controller: _heartRateCtrl,
                hint: 'e.g. 72',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 14.h),
              _FieldLabel('Oxygen (SpO₂ %)'),
              _TextField(
                controller: _oxygenCtrl,
                hint: 'e.g. 98',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 14.h),
              _FieldLabel('Blood Pressure (mmHg)'),
              _TextField(
                controller: _bloodPressureCtrl,
                hint: 'e.g. 120/80',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 14.h),
              _FieldLabel('Blood Sugar (mg/dL)'),
              _TextField(
                controller: _bloodSugarCtrl,
                hint: 'e.g. 95',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 14.h),
              _FieldLabel('Medications (one per line)'),
              _TextField(
                controller: _medicationsCtrl,
                hint: 'Amlodipine 5mg\nLisinopril 10mg',
                maxLines: 3,
              ),
              SizedBox(height: 14.h),
              _FieldLabel('Medical History (one per line)'),
              _TextField(
                controller: _historyCtrl,
                hint: 'Hypertension (2020)',
                maxLines: 3,
              ),
              SizedBox(height: 24.h),
              AppButton(
                label: 'Save Changes',
                onTap: _saving ? null : _onSave,
                loading: _saving,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 6.h, left: 2.w),
        child: Text(
          text,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.providerColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      style: AppTextStyles.bodyLarge,
    );
  }
}
