// ============================================================
// FILE: lib/views/screens/client/dashboard/widgets/home_tab.dart
// Patient dashboard home tab — composes the dashboard widgets.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';
import 'package:rambaa/controllers/appointment_controller.dart';
import 'package:rambaa/controllers/caregiver_controllers/caregiver_controller.dart';
import 'package:rambaa/controllers/provider_controller/provider_controller.dart';
import 'package:rambaa/models/caregiver_model.dart';
import 'package:rambaa/models/provider_model.dart';
import 'package:rambaa/routes/app_routes.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/dashboard_header.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/dashboard_models.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/dashboard_provider_card.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/emergency_sos.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/health_summary_card.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/section_header.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/service_category_row.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/upcoming_appointment_card.dart';
import 'package:rambaa/views/widgets/caregiver_card.dart';

class PatientHomeTab extends StatelessWidget {
  final String patientName;
  final String greeting;
  final int notifCount;
  final String heartRate;
  final String oxygen;
  final String bloodPressure;
  final List<ServiceCategory> categories;
  final ProviderController providerCtrl;
  final CaregiverController caregiverCtrl;
  final AppointmentController appointmentCtrl;
  final void Function(ProviderModel) onBookProvider;
  final void Function(CaregiverModel) onBookCaregiver;
  final void Function(int index)? onCategoryTap;

  const PatientHomeTab({
    super.key,
    required this.patientName,
    required this.greeting,
    required this.notifCount,
    required this.heartRate,
    required this.oxygen,
    required this.bloodPressure,
    required this.categories,
    required this.providerCtrl,
    required this.caregiverCtrl,
    required this.appointmentCtrl,
    required this.onBookProvider,
    required this.onBookCaregiver,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Gradient Header ────────────────────────────────────────
        SliverToBoxAdapter(
          child: DashboardHeader(
            name: patientName,
            greeting: greeting,
            notifCount: notifCount,
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingMD,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Health Summary Card ──────────────────────────────
              HealthSummaryCard(
                heartRate: heartRate,
                oxygen: oxygen,
                bloodPressure: bloodPressure,
              ),

              SizedBox(height: 16.h),

              // ── Emergency SOS ────────────────────────────────────
              EmergencySos(),

              SizedBox(height: 20.h),

              // ── Services ─────────────────────────────────────────
              const DashboardSectionHeader(title: 'Services'),
              SizedBox(height: 12.h),
              ServiceCategoryRow(categories: categories, onTap: onCategoryTap),

              SizedBox(height: 20.h),

              // ── Featured Providers ───────────────────────────────
              DashboardSectionHeader(
                title: 'find_providers'.tr,
                showSeeAll: providerCtrl.filteredProviders.length > 4,
                onSeeAll: () => Get.toNamed(AppRoutes.providerList),
              ),
              SizedBox(height: 12.h),
              Obx(() {
                if (providerCtrl.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (providerCtrl.filteredProviders.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'no_providers'.tr,
                      style: AppTextStyles.bodyMedium,
                    ),
                  );
                }
                final displayProviders = providerCtrl.filteredProviders.take(4).toList();
                return Column(
                  children: displayProviders
                      .map((p) => DashboardProviderCard(
                            data: DashboardProviderData.fromModel(p),
                            provider: p,
                            onBook: () => onBookProvider(p),
                          ))
                      .toList(),
                );
              }),

              SizedBox(height: 20.h),

              // ── Featured Caregivers ─────────────────────────────
              DashboardSectionHeader(
                title: 'find_caregivers'.tr,
                showSeeAll: caregiverCtrl.filteredCaregivers.length > 4,
                onSeeAll: () => Get.toNamed('/caregiver-list'),
              ),
              SizedBox(height: 12.h),
              Obx(() {
                if (caregiverCtrl.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (caregiverCtrl.filteredCaregivers.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'no_caregivers'.tr,
                      style: AppTextStyles.bodyMedium,
                    ),
                  );
                }
                final displayCaregivers = caregiverCtrl.filteredCaregivers.take(3).toList();
                return Column(
                  children: displayCaregivers
                      .map((c) => CaregiverCard(
                            caregiver: c,
                            onBookTap: () => onBookCaregiver(c),
                          ))
                      .toList(),
                );
              }),

              // ── Upcoming Appointment ─────────────────────────────
              SizedBox(height: 4.h),
              DashboardSectionHeader(
                title: 'upcoming_appointments'.tr,
                showSeeAll: true,
                onSeeAll: () => Get.toNamed(AppRoutes.appointments),
              ),
              SizedBox(height: 12.h),
              Obx(() => UpcomingAppointmentCard(
                  appointment: appointmentCtrl.nextAppointment)),

              SizedBox(height: 24.h),
            ]),
          ),
        ),
      ],
    );
  }
}
