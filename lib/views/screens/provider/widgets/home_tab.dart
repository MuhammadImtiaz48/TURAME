// ============================================================
// FILE: lib/views/screens/provider/widgets/home_tab.dart
// Provider dashboard home tab — composes the dashboard widgets.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';
import 'package:rambaa/controllers/provider_controller/provider_dashboard_controller.dart';
import 'package:rambaa/controllers/provider_controller/provider_profile_controller.dart';
import 'package:rambaa/models/patient_model.dart';
import 'package:rambaa/routes/app_routes.dart';
import 'package:rambaa/views/screens/provider/widgets/provider_earnings_card.dart';
import 'package:rambaa/views/screens/provider/widgets/provider_header.dart';
import 'package:rambaa/views/screens/provider/widgets/provider_patient_card.dart';
import 'package:rambaa/views/screens/provider/widgets/provider_request_card.dart';
import 'package:rambaa/views/screens/provider/widgets/provider_section_header.dart';

class ProviderHomeTab extends StatelessWidget {
  final ProviderDashboardController ctrl;
  final VoidCallback onSeeAllPatients;
  final VoidCallback onWithdraw;

  const ProviderHomeTab({
    super.key,
    required this.ctrl,
    required this.onSeeAllPatients,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Obx(() {
            final profileCtrl = Get.isRegistered<ProviderProfileController>()
                ? Get.find<ProviderProfileController>()
                : null;
            return ProviderHeader(
              doctorName: ctrl.doctorName,
              greeting: ctrl.greeting,
              todayCount: ctrl.todayCount,
              thisWeekCount: ctrl.thisWeekCount,
              pendingCount: ctrl.pendingCount,
              notifCount: ctrl.notifCount.value,
              imageUrl: profileCtrl?.profile.value?.imageUrl,
            );
          }),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingMD,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Obx(() => ProviderEarningsCard(
                    monthlyEarnings: ctrl.formattedMonthlyEarnings,
                    earningsGrowth: ctrl.earningsGrowth.value,
                    barData: ctrl.barData,
                    remainingBalance: ctrl.formattedRemainingBalance,
                    withdrawnBalance: ctrl.formattedWithdrawn,
                    availableBalance: ctrl.formattedBalance,
                    transactionCount: ctrl.totalEarningTransactions,
                    onWithdraw: onWithdraw,
                  )),
              SizedBox(height: 20.h),
              ProviderSectionHeader(
                title: "todays_patients".tr,
                showSeeAll: true,
                onSeeAll: onSeeAllPatients,
              ),
              SizedBox(height: 12.h),
              Obx(() {
                final todayRegistered = ctrl.todaysPatients;
                if (todayRegistered.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'No patients yet.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return Column(
                  children: todayRegistered.map((p) {
                    return ProviderPatientCard(
                      name: p.name,
                      time: ctrl.patientTimeLabel(p),
                      type: p.condition,
                      specialty: p.location,
                      avatarEmoji: p.avatarEmoji,
                      imageUrl: p.imageUrl,
                      status: p.status == PatientStatus.active
                          ? 'Active'
                          : (p.status == PatientStatus.pending
                              ? 'New Request'
                              : null),
                      statusColor: p.status == PatientStatus.active
                          ? AppColors.healthGreen
                          : (p.status == PatientStatus.pending
                              ? AppColors.warning
                              : null),
                      statusBg: p.status == PatientStatus.active
                          ? AppColors.healthGreenLighter
                          : (p.status == PatientStatus.pending
                              ? AppColors.warningLighter
                              : null),
                      onTap: () => Get.toNamed(
                        AppRoutes.providerPatientDetail,
                        arguments: p,
                      ),
                    );
                  }).toList(),
                );
              }),
              SizedBox(height: 24.h),

              // ── Pending Appointment Requests ────────────────
              Obx(() {
                final requests = ctrl.pendingAppointments;
                if (requests.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProviderSectionHeader(
                      title: 'appointment_requests'.tr,
                      showSeeAll: true,
                      onSeeAll: () {},
                    ),
                    SizedBox(height: 12.h),
                    ...requests.map((a) => ProviderRequestCard(
                          appointment: a,
                          onAccept: () => ctrl.confirmAppointment(a.id),
                          onDecline: () => ctrl.cancelAppointment(a.id),
                        )),
                    SizedBox(height: 24.h),
                  ],
                );
              }),
            ]),
          ),
        ),
      ],
    );
  }
}
