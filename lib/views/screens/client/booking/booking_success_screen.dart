import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../routes/app_routes.dart';
import '../../../widgets/app_button.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final provider = (args['provider'] as Map<String, dynamic>?) ?? {};
    final date = args['date'];
    final time = (args['time'] as String?) ?? '09:00 AM';
    final total = (args['total'] as num?)?.toInt() ?? 5500;
    final bookingId = (args['bookingId'] as String?) ?? '#RMB-20250623-0900';

    final providerName = provider['name'] ?? '';
    final specialty = provider['specialty'] ?? 'Cardiology';
    final avatarEmoji = provider['avatarEmoji'] ?? '👩‍⚕️';
    final imageUrl = (provider['imageUrl']?.toString().isNotEmpty ?? false)
        ? provider['imageUrl'] as String
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            children: [
              const Spacer(flex: 2),

              _SuccessIcon(),

              SizedBox(height: 32.h),

              Text(
                'booking_confirmed'.tr,
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              Text(
                'booking_confirmed_sub'.tr,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 36.h),

              _AppointmentCard(
                providerName: providerName,
                specialty: specialty,
                avatarEmoji: avatarEmoji,
                imageUrl: imageUrl,
                date: date != null ? '${date.day} Jun 2025' : 'Mon, 23 Jun 2025',
                time: time,
                bookingId: bookingId,
                total: total,
              ),

              const Spacer(flex: 2),

              AppButton(
                label: 'view_appointment'.tr,
                onTap: () => Get.offAllNamed(AppRoutes.appointments),
              ),

              SizedBox(height: 12.h),

              AppButton.outline(
                label: 'back_to_home'.tr,
                onTap: () => Get.offAllNamed(AppRoutes.patientDashboard),
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        color: AppColors.successLighter,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            color: AppColors.textOnDark,
            size: 44.sp,
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String providerName;
  final String specialty;
  final String avatarEmoji;
  final String? imageUrl;
  final String date;
  final String time;
  final String bookingId;
  final int total;

  const _AppointmentCard({
    required this.providerName,
    required this.specialty,
    required this.avatarEmoji,
    this.imageUrl,
    required this.date,
    required this.time,
    required this.bookingId,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null
                    ? Center(
                        child: Text(
                          avatarEmoji,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textOnDark,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(providerName, style: AppTextStyles.h3),
                  Text(specialty, style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),
          Container(height: 1, color: AppColors.borderLight),
          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'date'.tr,
                  value: date,
                ),
              ),
              Container(width: 1, height: 40.h, color: AppColors.borderLight),
              Expanded(
                child: _InfoItem(
                  icon: Icons.access_time_outlined,
                  label: 'time'.tr,
                  value: time,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),
          Container(height: 1, color: AppColors.borderLight),
          SizedBox(height: 16.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('booking_id'.tr, style: AppTextStyles.bodySmall),
              Text(
                bookingId,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.successLighter,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  'confirmed'.tr,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.success,
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

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary),
        SizedBox(height: 6.h),
        Text(label, style: AppTextStyles.caption),
        SizedBox(height: 2.h),
        Text(value, style: AppTextStyles.labelLarge),
      ],
    );
  }
}
