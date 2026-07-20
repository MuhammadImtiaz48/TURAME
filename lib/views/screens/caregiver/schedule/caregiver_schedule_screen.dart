import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';
import '../../../../controllers/caregiver_controllers/caregiver_dashboard_controller.dart';
import '../../../../models/appointment_model.dart';
import '../../../../models/caregiver_schedule_model.dart';
import '../../../../models/message_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/firebase_service.dart';

class CaregiverScheduleScreen extends StatelessWidget {
  const CaregiverScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CaregiverDashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(ctrl: ctrl),
          _WeekPicker(ctrl: ctrl),
          _TabBar(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              final list = ctrl.currentScheduleList;
              if (list.isEmpty) return const _EmptyState();
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemCount: list.length,
                itemBuilder: (_, i) => _ScheduleCard(
                  shift: list[i],
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
  final CaregiverDashboardController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.caregiverGradient),
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
                    Text('nav_schedule'.tr, style: AppTextStyles.onDarkTitle),
                    SizedBox(height: 4.h),
                    Obx(() => Text(
                          '${ctrl.todaySchedule.length} today · ${ctrl.upcomingSchedule.length} upcoming',
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
                child: const Icon(Icons.calendar_today_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekPicker extends StatelessWidget {
  final CaregiverDashboardController ctrl;
  const _WeekPicker({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
      child: Obx(() {
        final days = ctrl.weekDays;
        return Row(
          children: List.generate(days.length, (i) {
            final day = days[i];
            final selected = ctrl.selectedDayIndex.value == i;
            final count = day['appointmentCount'] as int;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ctrl.selectDay(i);
                  ctrl.changeScheduleTab(0);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.caregiverColor
                        : (day['isToday'] as bool
                            ? AppColors.accentLighter
                            : AppColors.background),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: selected
                          ? AppColors.caregiverColor
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day['label'] as String,
                        style: AppTextStyles.caption.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${day['date']}',
                        style: AppTextStyles.h3.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 16.sp,
                        ),
                      ),
                      if (count > 0) ...[
                        SizedBox(height: 4.h),
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : AppColors.caregiverColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

class _TabBar extends StatelessWidget {
  final CaregiverDashboardController ctrl;
  const _TabBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tabs = ['Day View', 'Upcoming', 'Completed', 'Cancelled'];
    return Container(
      color: AppColors.surface,
      child: Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final count = switch (i) {
                  0 => ctrl.selectedDayAppointments.length,
                  1 => ctrl.upcomingSchedule.length,
                  2 => ctrl.completedSchedule.length,
                  _ => ctrl.cancelledSchedule.length,
                };
                return _TabChip(
                  label: tabs[i],
                  count: count,
                  selected: ctrl.scheduleTab.value == i,
                  onTap: () => ctrl.changeScheduleTab(i),
                );
              }),
            ),
          )),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.caregiverColor : AppColors.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.caregiverColor : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 6.w),
              Text(
                '$count',
                style: AppTextStyles.badge.copyWith(
                  color: selected ? Colors.white : AppColors.caregiverColor,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final CaregiverScheduleModel shift;
  final CaregiverDashboardController ctrl;

  const _ScheduleCard({required this.shift, required this.ctrl});

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $ampm';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    return '${weekdays[(dt.weekday - 1) % 7]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isActionable = shift.status == AppointmentStatus.confirmed ||
        shift.status == AppointmentStatus.pending;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                _ScheduleClientAvatar(
                  imageUrl: shift.imageUrl,
                  clientId: shift.clientId,
                  fallbackEmoji: shift.avatarEmoji,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shift.clientName, style: AppTextStyles.h3),
                      SizedBox(height: 2.h),
                      Text(shift.careType, style: AppTextStyles.bodySmall),
                      SizedBox(height: 4.h),
                      Text(
                        _formatDate(shift.dateTime),
                        style: AppTextStyles.caption,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${_formatTime(shift.dateTime)} · ${shift.hours}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: shift.status),
              ],
            ),
          ),
          if (isActionable)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ctrl.cancelShift(shift.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: Size(double.infinity, 40.h),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                      ),
                      child: Text('cancel'.tr,
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.textSecondary,
                          )),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (shift.status == AppointmentStatus.pending) {
                          ctrl.confirmShift(shift.id);
                        } else {
                          final currentUserId = Get.find<AuthController>().user.value?.id ?? '';
                          final ids = [currentUserId, shift.clientId]..sort();
                          final convId = 'conv_${ids.join('_')}';
                          Get.toNamed(
                            AppRoutes.chat,
                            arguments: ConversationModel(
                              id: convId,
                              participantId: shift.clientId,
                              participantName: shift.clientName,
                              participantSpecialty: shift.careType,
                              type: ConversationType.caregiver,
                              lastMessage: '',
                              lastMessageTime: DateTime.now(),
                              isOnline: true,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caregiverColor,
                        minimumSize: Size(double.infinity, 40.h),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                      ),
                      child: Text(
                        shift.status == AppointmentStatus.pending
                            ? 'confirm'.tr
                            : 'start'.tr,
                        style: AppTextStyles.buttonMedium,
                      ),
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

class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case AppointmentStatus.confirmed:
        color = AppColors.caregiverColor;
        label = 'confirmed'.tr;
        break;
      case AppointmentStatus.pending:
        color = AppColors.warning;
        label = 'pending'.tr;
        break;
      case AppointmentStatus.completed:
        color = AppColors.success;
        label = 'completed'.tr;
        break;
      case AppointmentStatus.cancelled:
        color = AppColors.danger;
        label = 'cancelled'.tr;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: color, fontSize: 10.sp),
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
          Text('📅', style: TextStyle(fontSize: 52.sp)),
          SizedBox(height: 16.h),
          Text('no_appointments'.tr, style: AppTextStyles.h3),
          SizedBox(height: 6.h),
          Text(
            'no_appointments_sub'.tr,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Schedule Client Avatar (resolves real uploaded image) ────────────────────
class _ScheduleClientAvatar extends StatefulWidget {
  final String? imageUrl;
  final String clientId;
  final String fallbackEmoji;

  const _ScheduleClientAvatar({
    required this.imageUrl,
    required this.clientId,
    required this.fallbackEmoji,
  });

  @override
  State<_ScheduleClientAvatar> createState() => _ScheduleClientAvatarState();
}

class _ScheduleClientAvatarState extends State<_ScheduleClientAvatar> {
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _ScheduleClientAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.clientId != widget.clientId) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      if (mounted) setState(() => _resolvedUrl = widget.imageUrl);
      return;
    }
    if (widget.clientId.isEmpty) return;
    final fetched = await FirebaseService.getUserImageUrl(widget.clientId);
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
        color: AppColors.accentLighter,
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
