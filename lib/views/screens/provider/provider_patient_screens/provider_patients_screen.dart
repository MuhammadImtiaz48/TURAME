import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/provider_controller/provider_dashboard_controller.dart';
import '../../../../models/patient_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/firebase_service.dart';

class ProviderPatientsScreen extends StatelessWidget {
  const ProviderPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProviderDashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(ctrl: ctrl),
          _TabBar(ctrl: ctrl),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: CupertinoSearchTextField(
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textPrimary),
              placeholder: 'Search patients...',
              onChanged: ctrl.setPatientSearch,
            ),
          ),
          Expanded(
            child: Obx(() {
              final list = ctrl.filteredPatients;
              if (list.isEmpty) return const _EmptyState();
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemCount: list.length,
                itemBuilder: (_, i) => _PatientCard(
                  patient: list[i],
                  ctrl: ctrl,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ProviderDashboardController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.healthGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('nav_patients'.tr, style: AppTextStyles.onDarkTitle),
                    SizedBox(height: 4.h),
                    Obx(() => Text(
                          '${ctrl.allPatients.length} total · ${ctrl.pendingPatients.length} pending',
                          style: AppTextStyles.onDarkBody,
                        )),
                  ],
                ),
              ),
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final ProviderDashboardController ctrl;
  const _TabBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tabs = ['All', 'Requests', 'Active'];
    return Container(
      color: AppColors.surface,
      child: Obx(() => Row(
            children: List.generate(tabs.length, (i) {
              final count = switch (i) {
                1 => ctrl.pendingPatients.length,
                2 => ctrl.activePatients.length,
                _ => ctrl.allPatients.length,
              };
              return _TabItem(
                label: tabs[i],
                count: count,
                selected: ctrl.patientsTab.value == i,
                onTap: () => ctrl.changePatientsTab(i),
              );
            }),
          )),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.providerColor : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: selected
                      ? AppColors.providerColor
                      : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: 4.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.providerColor
                        : AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.badge.copyWith(fontSize: 10.sp),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final PatientModel patient;
  final ProviderDashboardController ctrl;

  const _PatientCard({required this.patient, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isPending = patient.status == PatientStatus.pending;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.providerPatientDetail,
        arguments: patient,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
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
            Row(
              children: [
                _PatientAvatar(
                  imageUrl: patient.imageUrl,
                  patientId: patient.id,
                  fallbackEmoji: patient.avatarEmoji,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.name, style: AppTextStyles.h3),
                      SizedBox(height: 2.h),
                      Text(patient.condition, style: AppTextStyles.bodySmall),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 13, color: AppColors.textSecondary),
                          SizedBox(width: 3.w),
                          Text(patient.location, style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: patient.statusBg,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        patient.statusLabel,
                        style: AppTextStyles.badge.copyWith(
                          color: patient.statusColor,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        AppRoutes.providerEditPatient,
                        arguments: patient,
                      ),
                      child: Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            size: 16, color: AppColors.providerColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (patient.nextAppointment != null) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(Icons.event_rounded,
                      size: 13, color: AppColors.providerColor),
                  SizedBox(width: 6.w),
                  Text(
                    'Next: ${patient.nextAppointment}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.providerColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.calendar_month_outlined,
                    size: 13, color: AppColors.textTertiary),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    patient.registeredLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            if (isPending) ...[
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ctrl.acceptPatient(patient.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.providerColor,
                        minimumSize: Size(double.infinity, 40.h),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                      ),
                      child: Text('accept'.tr, style: AppTextStyles.buttonMedium),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ctrl.declinePatient(patient.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: Size(double.infinity, 40.h),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                      ),
                      child: Text('decline'.tr,
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.textSecondary,
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 56.sp, color: AppColors.textTertiary),
          SizedBox(height: 16.h),
          Text('No patients found', style: AppTextStyles.h3),
          SizedBox(height: 6.h),
          Text(
            'Patients will appear here once they book appointments.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Patient Avatar (resolves real uploaded image) ────────────────────────────
class _PatientAvatar extends StatefulWidget {
  final String? imageUrl;
  final String patientId;
  final String fallbackEmoji;

  const _PatientAvatar({
    required this.imageUrl,
    required this.patientId,
    required this.fallbackEmoji,
  });

  @override
  State<_PatientAvatar> createState() => _PatientAvatarState();
}

class _PatientAvatarState extends State<_PatientAvatar> {
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _PatientAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.patientId != widget.patientId) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      if (mounted) setState(() => _resolvedUrl = widget.imageUrl);
      return;
    }
    if (widget.patientId.isEmpty) return;
    final fetched = await FirebaseService.getUserImageUrl(widget.patientId);
    if (mounted) setState(() => _resolvedUrl = fetched);
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    final showImage = url != null && url.isNotEmpty;
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        shape: BoxShape.circle,
        image: showImage
            ? DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: showImage
          ? null
          : Center(
              child: Text(
                widget.fallbackEmoji,
                style: TextStyle(fontSize: 22.sp),
              ),
            ),
    );
  }
}
