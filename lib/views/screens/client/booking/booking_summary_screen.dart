import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../routes/app_routes.dart';
import '../../../widgets/app_button.dart';

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key});

  static const Map<String, dynamic> _defaultProvider = {
    'id': '',
    'name': '',
    'avatarEmoji': '👩‍⚕️',
    'specialty': '',
  };

  static String _formatDate(dynamic dateItem) {
    try {
      final dt = (dateItem as dynamic).dateTime as DateTime?;
      if (dt != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
      }
    } catch (_) {}
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _goToPayment(Map<String, dynamic> args) {
    Get.toNamed(AppRoutes.payment, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final provider =
        (args['provider'] as Map<String, dynamic>?) ?? _defaultProvider;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.textPrimary),
          ),
        ),
        title: Text('booking_summary'.tr, style: AppTextStyles.h2),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppTheme.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),

                  // ── Provider info ──────────────────────────
                  _SectionCard(
                    title: 'provider'.tr,
                    child: Row(
                      children: [
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            image: (provider['imageUrl']?.toString().isNotEmpty ?? false)
                                ? DecorationImage(
                                    image: NetworkImage(provider['imageUrl']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (provider['imageUrl']?.toString().isNotEmpty ?? false)
                              ? null
                              : Center(
                                  child: Text(
                                      provider['avatarEmoji'] ?? '👩‍⚕️',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: AppColors.textOnDark,
                                      )),
                                ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider['name'] ?? '',
                                style: AppTextStyles.h3),
                            SizedBox(height: 2.h),
                            Text(provider['specialty'] ?? 'Cardiology',
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Appointment details ────────────────────
                  _SectionCard(
                    title: 'appointment_details'.tr,
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.medical_services_outlined,
                          label: 'service'.tr,
                          value: args['service']?.name ?? 'General Consultation',
                        ),
                        _Divider(),
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'date'.tr,
                          value: _formatDate(args['date']),
                        ),
                        _Divider(),
                        _DetailRow(
                          icon: Icons.access_time_outlined,
                          label: 'time'.tr,
                          value: args['time'] ?? '09:00 AM',
                        ),
                        _Divider(),
                        _DetailRow(
                          icon: Icons.timer_outlined,
                          label: 'duration'.tr,
                          value: args['service']?.duration ?? '30 min',
                        ),
                        _Divider(),
                        _DetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'location'.tr,
                          value: 'Kigali, Rwanda',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Payment breakdown ──────────────────────
                  _SectionCard(
                    title: 'payment_details'.tr,
                    child: Column(
                      children: [
                        _PayRow(
                          label: 'consultation_fee'.tr,
                          value: 'RWF ${args['service']?.price ?? 5000}',
                        ),
                        SizedBox(height: 8.h),
                        _PayRow(
                          label: 'service_fee'.tr,
                          value: 'RWF 500',
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          height: 1,
                          color: AppColors.borderLight,
                        ),
                        SizedBox(height: 12.h),
                        _PayRow(
                          label: 'total'.tr,
                          value: 'RWF ${((args['service']?.price ?? 5000) + 500).toString()}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Note ──────────────────────────────────
                  _SectionCard(
                    title: 'note'.tr,
                    child: Text(
                      'booking_note'.tr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // ── Bottom buttons ─────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                  top: BorderSide(color: AppColors.borderLight)),
              boxShadow: AppTheme.shadowMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  label: 'proceed_to_payment'.tr,
                  onTap: () => _goToPayment(args),
                ),
                SizedBox(height: 10.h),
                AppButton.outline(
                  label: 'cancel'.tr,
                  onTap: () => Get.back(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              )),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

// ── Detail Row ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 12.w),
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(value,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
              )),
        ],
      ),
    );
  }
}

// ── Payment Row ───────────────────────────────────────────────────────────────
class _PayRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _PayRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.h3
              : AppTextStyles.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.price
              : AppTextStyles.labelLarge,
        ),
      ],
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.borderLight);
  }
}
