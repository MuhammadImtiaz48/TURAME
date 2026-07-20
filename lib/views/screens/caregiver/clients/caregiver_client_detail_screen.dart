import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/views/screens/caregiver/profile/profile_component/profile_components.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';
import '../../../../controllers/caregiver_controllers/caregiver_dashboard_controller.dart';
import '../../../../models/appointment_model.dart';
import '../../../../models/caregiver_client_model.dart';
import '../../../../models/message_model.dart';
import '../../../../routes/app_routes.dart';

class CaregiverClientDetailScreen extends StatelessWidget {
  const CaregiverClientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Get.arguments as CaregiverClientModel;
    final ctrl = Get.find<CaregiverDashboardController>();

    final shifts = ctrl.schedule
        .where((s) => s.clientId == client.id && s.dateTime != null)
        .toList()
      ..sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

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
        title: Text('Client Details', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.caregiverColor),
            onPressed: () {
              final currentUserId = Get.find<AuthController>().user.value?.id ?? '';
              final ids = [currentUserId, client.id]..sort();
              final convId = 'conv_${ids.join('_')}';
              Get.toNamed(
                AppRoutes.chat,
                arguments: ConversationModel(
                  id: convId,
                  participantId: client.id,
                  participantName: client.name,
                  participantSpecialty: client.careType,
                  type: ConversationType.caregiver,
                  lastMessage: '',
                  lastMessageTime: DateTime.now(),
                  isOnline: true,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
DetailProfileCard(
               name: client.name,
               subtitle: client.careType,
               avatarEmoji: client.avatarEmoji,
               imageUrl: client.imageUrl,
               badgeLabel: client.statusLabel,
               gradient: AppColors.caregiverGradient,
             ),
             SizedBox(height: 16.h),
             DetailInfoSection(
               title: 'CONTACT',
               children: [
                 DetailInfoRow(Icons.phone_rounded, client.phone, iconColor: AppColors.caregiverColor),
                 DetailInfoRow(Icons.location_on_rounded, client.location, iconColor: AppColors.caregiverColor),
                 DetailInfoRow(Icons.cake_rounded, '${client.age} years old', iconColor: AppColors.caregiverColor),
                 DetailInfoRow(Icons.emergency_rounded, client.emergencyContact, iconColor: AppColors.caregiverColor),
               ],
             ),
             SizedBox(height: 16.h),
             DetailInfoSection(
               title: 'CARE DETAILS',
               children: [
                 if (client.dailyRate.isNotEmpty)
                   DetailInfoRow(Icons.payments_rounded, client.dailyRate, iconColor: AppColors.caregiverColor),
                 if (client.hours.isNotEmpty)
                   DetailInfoRow(Icons.access_time_rounded, client.hours, iconColor: AppColors.caregiverColor),
                 DetailInfoRow(Icons.calendar_today_rounded, client.since, iconColor: AppColors.caregiverColor),
               ],
             ),
             if (client.requestNote != null) ...[
               SizedBox(height: 16.h),
               DetailInfoSection(
                 title: 'REQUEST NOTE',
                 children: [
                   Text(client.requestNote!, style: AppTextStyles.bodyMedium),
                 ],
               ),
             ],
             if (client.careNeeds.isNotEmpty) ...[
               SizedBox(height: 16.h),
               DetailInfoSection(
                 title: 'CARE NEEDS',
                 children: client.careNeeds
                     .map((n) => DetailInfoRow(Icons.check_circle_outline_rounded, n, iconColor: AppColors.caregiverColor))
                     .toList(),
               ),
             ],
             if (client.medications.isNotEmpty) ...[
               SizedBox(height: 16.h),
               DetailInfoSection(
                 title: 'MEDICATIONS',
                 children: client.medications
                     .map((m) => DetailInfoRow(Icons.medication_rounded, m, iconColor: AppColors.caregiverColor))
                     .toList(),
               ),
             ],
            SizedBox(height: 16.h),
            Text('Schedule', style: AppTextStyles.h3),
            SizedBox(height: 12.h),
            if (shifts.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  'No shifts scheduled.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...shifts.map((s) => _ShiftTile(shift: s)),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final CaregiverClientModel client;
  const _ProfileCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        gradient: AppColors.caregiverGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  Text(client.avatarEmoji, style: TextStyle(fontSize: 30.sp)),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: AppTextStyles.onDarkTitle),
                SizedBox(height: 4.h),
                Text(client.careType, style: AppTextStyles.onDarkBody),
                SizedBox(height: 8.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    client.statusLabel,
                    style: AppTextStyles.badge.copyWith(fontSize: 10.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.caregiverColor),
          SizedBox(width: 10.w),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _ShiftTile extends StatelessWidget {
  final dynamic shift;
  const _ShiftTile({required this.shift});

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
        return AppColors.caregiverColor;
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
                 Text(
                   shift.dateTime != null ? _formatDate(shift.dateTime!) : '—',
                   style: AppTextStyles.bodySmall),
                SizedBox(height: 4.h),
                Text(shift.careType, style: AppTextStyles.h3),
                Text(shift.hours, style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: _statusColor(shift.status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _statusLabel(shift.status),
              style: AppTextStyles.badge.copyWith(
                color: _statusColor(shift.status),
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
