import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/views/screens/caregiver/profile/profile_component/profile_components.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/provider_controller/provider_dashboard_controller.dart';
import '../../../../models/appointment_model.dart';
import '../../../../models/message_model.dart';
import '../../../../models/patient_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';

class ProviderPatientDetailScreen extends StatelessWidget {
  const ProviderPatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final initialPatient = Get.arguments as PatientModel;
    final ctrl = Get.find<ProviderDashboardController>();

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
        title: Text('Patient Details', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.providerColor),
            onPressed: () => Get.toNamed(
              AppRoutes.providerEditPatient,
              arguments: initialPatient,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.providerColor),
            onPressed: () {
              final patient = ctrl.patientById(initialPatient.id) ?? initialPatient;
              final currentUserId = Get.find<AuthController>().user.value?.id ?? '';
              final ids = [currentUserId, patient.id]..sort();
              final convId = 'conv_${ids.join('_')}';
              Get.toNamed(
                AppRoutes.chat,
                arguments: ConversationModel(
                  id: convId,
                  participantId: patient.id,
                  participantName: patient.name,
                  participantSpecialty: patient.condition,
                  type: ConversationType.doctor,
                  lastMessage: '',
                  lastMessageTime: DateTime.now(),
                  isOnline: true,
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final patient = ctrl.patientById(initialPatient.id) ?? initialPatient;
        final appointments = ctrl.schedule
            .where((a) => a.patientId == patient.id)
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailProfileCard(
                name: patient.name,
                subtitle: patient.condition,
                avatarEmoji: patient.avatarEmoji,
                imageUrl: patient.imageUrl,
                badgeLabel: patient.statusLabel,
                gradient: AppColors.healthGradient,
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 14, color: AppColors.textTertiary),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        patient.registeredLabel,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16.h),
            DetailInfoSection(
              title: 'CONTACT',
              children: [
                DetailInfoRow(Icons.phone_rounded, patient.phone),
                DetailInfoRow(Icons.location_on_rounded, patient.location),
                DetailInfoRow(Icons.cake_rounded, '${patient.age} years old'),
              ],
            ),
            SizedBox(height: 16.h),
            DetailInfoSection(
              title: 'MEDICAL INFO',
              children: [
                DetailInfoRow(Icons.bloodtype_rounded, 'Blood Type: ${patient.bloodType}'),
                DetailInfoRow(Icons.medical_information_rounded, patient.condition),
                if (patient.lastVisit != 'Never')
                  DetailInfoRow(Icons.history_rounded, 'Last visit: ${patient.lastVisit}'),
              ],
            ),
            if (patient.requestNote != null) ...[
              SizedBox(height: 16.h),
              DetailInfoSection(
                title: 'REQUEST NOTE',
                children: [
                  Text(patient.requestNote!, style: AppTextStyles.bodyMedium),
                ],
              ),
            ],
            if (patient.medications.isNotEmpty) ...[
              SizedBox(height: 16.h),
              DetailInfoSection(
                title: 'MEDICATIONS',
                children: patient.medications
                    .map((m) => DetailInfoRow(Icons.medication_rounded, m))
                    .toList(),
              ),
            ],
            if (patient.medicalHistory.isNotEmpty) ...[
              SizedBox(height: 16.h),
              DetailInfoSection(
                title: 'MEDICAL HISTORY',
                children: patient.medicalHistory
                    .map((h) => DetailInfoRow(Icons.check_circle_outline_rounded, h))
                    .toList(),
              ),
            ],
            SizedBox(height: 16.h),
            Text('Appointments', style: AppTextStyles.h3),
            SizedBox(height: 12.h),
            if (appointments.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  'No appointments scheduled.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...appointments.map((a) => _AppointmentTile(appointment: a)),
            SizedBox(height: 24.h),
          ],
        ),
      );
      }),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final dynamic appointment;
  const _AppointmentTile({required this.appointment});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day} · $hour:$minute $ampm';
  }

  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return AppColors.providerColor;
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.danger;
    }
  }

  String _statusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(appointment.dateTime),
                    style: AppTextStyles.bodySmall),
                SizedBox(height: 4.h),
                Text(appointment.reason, style: AppTextStyles.h3),
                Text(appointment.typeLabel, style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: _statusColor(appointment.status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _statusLabel(appointment.status),
              style: AppTextStyles.badge.copyWith(
                color: _statusColor(appointment.status),
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}