import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/appointment_controller.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';
import '../../../../models/appointment_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/call_service.dart';
import '../../../../services/firebase_service.dart';

class AppointmentScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const AppointmentScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AppointmentController>()) {
      Get.lazyPut<AppointmentController>(() => AppointmentController());
    }
    final ctrl = Get.find<AppointmentController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _AppBar(onBack: onBack),
      body: Column(
        children: [
          _TabBar(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              final list = ctrl.currentList;
              if (list.isEmpty) return const _EmptyState();
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemCount: list.length,
                itemBuilder: (_, i) => _AppointmentCard(appointment: list[i]),
              );
            }),
          ),
        ],
      ),
      //  bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ─── AppBar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;

  const _AppBar({this.onBack});

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          if (onBack != null) {
            onBack!();
          } else if (Navigator.of(context).canPop()) {
            Get.back();
          } else {
            Get.toNamed(AppRoutes.patientDashboard);
          }
        },
        child: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22.r),
      ),
      title: Text('appointments'.tr, style: AppTextStyles.h2),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.booking),
          child: Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(Icons.add, color: AppColors.primary, size: 20.r),
          ),
        ),
      ],
    );
  }
}

// ─── Tab Bar ─────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final AppointmentController ctrl;
  const _TabBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Obx(
        () => Row(
          children: [
            _TabItem(
              label: 'Upcoming',
              count: ctrl.upcoming.length,
              selected: ctrl.selectedTab.value == 0,
              onTap: () => ctrl.changeTab(0),
            ),
            _TabItem(
              label: 'Completed',
              count: ctrl.completed.length,
              selected: ctrl.selectedTab.value == 1,
              onTap: () => ctrl.changeTab(1),
            ),
            _TabItem(
              label: 'Cancelled',
              count: ctrl.cancelled.length,
              selected: ctrl.selectedTab.value == 2,
              onTap: () => ctrl.changeTab(2),
            ),
          ],
        ),
      ),
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
                color: selected ? AppColors.primary : Colors.transparent,
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
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
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

// ─── Appointment Card ─────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: appointment.borderColor),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          _CardHeader(appointment: appointment),
          Divider(height: 1, color: AppColors.borderLight),
          _CardBody(appointment: appointment),
          if (appointment.status == AppointmentStatus.confirmed ||
              appointment.status == AppointmentStatus.pending)
            _CardActions(appointment: appointment),
        ],
      ),
    );
  }
}

// ─── Card Header ─────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final AppointmentModel appointment;
  const _CardHeader({required this.appointment});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[dt.weekday - 1];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$dayName, ${dt.day} ${months[dt.month - 1]}  ·  $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 13.r,
            color: AppColors.textTertiary,
          ),
          SizedBox(width: 6.w),
          Text(
            _formatDate(appointment.dateTime),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '  ·  ${appointment.durationMins} mins',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          _StatusBadge(appointment: appointment),
        ],
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final AppointmentModel appointment;
  const _StatusBadge({required this.appointment});

  String get _label {
    if (appointment.isInactive) return 'Inactive';
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        return 'confirmed'.tr;
      case AppointmentStatus.pending:
        return 'pending'.tr;
      case AppointmentStatus.completed:
        return 'completed'.tr;
      case AppointmentStatus.cancelled:
        return 'cancelled'.tr;
    }
  }

  Color get _badgeColor {
    if (appointment.isInactive) return AppColors.textTertiary;
    switch (appointment.status) {
      case AppointmentStatus.confirmed: return AppColors.primary;
      case AppointmentStatus.pending:   return AppColors.warning;
      case AppointmentStatus.completed: return AppColors.success;
      case AppointmentStatus.cancelled: return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _label,
        style: AppTextStyles.labelSmall.copyWith(
          color: _badgeColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Card Body ───────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  final AppointmentModel appointment;
  const _CardBody({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          // Avatar
          _AppointmentAvatar(appointment: appointment),
          SizedBox(width: 12.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.providerName, style: AppTextStyles.h3),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(appointment.specialty, style: AppTextStyles.bodySmall),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text(
                        '·',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Text(
                      appointment.typeIcon,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    SizedBox(width: 3.w),
                    Text(appointment.typeLabel, style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20.r),
        ],
      ),
    );
  }
}

// ─── Card Actions ────────────────────────────────────────────────────────────

class _CardActions extends StatelessWidget {
  final AppointmentModel appointment;
  const _CardActions({required this.appointment});

  Future<void> _joinCall(BuildContext context) async {
    final auth = Get.find<AuthController>();
    final callerId = auth.user.value?.id ?? '';
    final callerName = auth.user.value?.name ?? 'User';
    if (callerId.isEmpty) return;

    try {
      if (!Get.isRegistered<CallService>()) {
        Get.put(CallService(), permanent: true);
      }
      await CallService.to.startCall(
        callerId: callerId,
        callerName: callerName,
        calleeId: appointment.providerId,
        calleeName: appointment.providerName,
        type: appointment.type.name,
        appointmentId: appointment.id,
      );
    } catch (e) {
      Get.snackbar(
        'Call Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: AppColors.textOnDark,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AppointmentController>()) {
      Get.lazyPut<AppointmentController>(() => AppointmentController());
    }
    final ctrl = Get.find<AppointmentController>();
    final isConfirmed = appointment.status == AppointmentStatus.confirmed;
    final isCallWindow = !appointment.isWithinCallWindow;

    String buttonLabel;
    VoidCallback? onPressed;
    if (appointment.callCompleted) {
      buttonLabel = 'call_done'.tr;
      onPressed = null;
    } else if (!isConfirmed) {
      buttonLabel = 'confirm'.tr;
      onPressed = () => ctrl.confirmAppointment(appointment.id);
    } else if (!isCallWindow) {
      buttonLabel = 'join_call'.tr;
      onPressed = () {
        final diff = appointment.dateTime.difference(DateTime.now());
        final msg = diff.isNegative
            ? 'This call window has passed.'
            : 'Call will be available ${diff.inMinutes} minutes before your appointment.';
        Get.snackbar(
          'Call Not Available',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnDark,
        );
      };
    } else {
      buttonLabel = 'join_call'.tr;
      onPressed = () => _joinCall(context);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => isConfirmed
                  ? {} // reschedule logic
                  : ctrl.cancelAppointment(appointment.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                minimumSize: Size.zero,
              ),
              child: Text(
                isConfirmed ? 'reschedule'.tr : 'cancel'.tr,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: appointment.callCompleted
                    ? AppColors.border
                    : AppColors.primary,
                foregroundColor: AppColors.textOnDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                minimumSize: Size.zero,
              ),
              child: Text(
                buttonLabel,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar (resolves real uploaded image) ─────────────────────────────────────

class _AppointmentAvatar extends StatefulWidget {
  final AppointmentModel appointment;
  const _AppointmentAvatar({required this.appointment});

  @override
  State<_AppointmentAvatar> createState() => _AppointmentAvatarState();
}

class _AppointmentAvatarState extends State<_AppointmentAvatar> {
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _AppointmentAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appointment.imageUrl != widget.appointment.imageUrl ||
        oldWidget.appointment.providerId != widget.appointment.providerId) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final stored = widget.appointment.imageUrl;
    if (stored != null && stored.isNotEmpty) {
      if (mounted) setState(() => _resolvedUrl = stored);
      return;
    }
    final fetched = await FirebaseService.getUserImageUrl(
      widget.appointment.providerId,
    );
    if (mounted) {
      setState(() {
        _resolvedUrl = fetched;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    final showImage = url != null && url.isNotEmpty;
    final imageUrl = showImage ? url : null;
    return Container(
      width: 46.r,
      height: 46.r,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.border),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: showImage
          ? null
          : Center(
              child: Text(
                widget.appointment.avatarEmoji,
                style: TextStyle(fontSize: 22.sp),
              ),
            ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

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
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.bookAppointment),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnDark,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              minimumSize: Size.zero,
            ),
            child: Text('book_now'.tr, style: AppTextStyles.buttonMedium),
          ),
        ],
      ),
    );
  }
}

// // ─── Bottom Nav ──────────────────────────────────────────────────────────────
//
// class _BottomNav extends StatelessWidget {
//   const _BottomNav();
//
//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       {'icon': Icons.home_outlined,           'label': 'home',         'route': AppRoutes.patientDashboard},
//       {'icon': Icons.calendar_month_outlined, 'label': 'appointments', 'route': AppRoutes.appointments},
//       {'icon': Icons.favorite_outline,        'label': 'health',       'route': AppRoutes.healthMonitor},
//       {'icon': Icons.chat_bubble_outline,     'label': 'messages',     'route': AppRoutes.chat},
//       {'icon': Icons.person_outline,          'label': 'profile',      'route': AppRoutes.profile},
//     ];
//
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         border: Border(top: BorderSide(color: AppColors.borderLight)),
//         boxShadow: AppTheme.shadowSm,
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 8.h),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: items.map((item) {
//               final isActive = item['route'] == AppRoutes.appointments;
//               return GestureDetector(
//                 onTap: () => Get.toNamed(item['route'] as String),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       item['icon'] as IconData,
//                       color: isActive ? AppColors.primary : AppColors.textTertiary,
//                       size: 22.r,
//                     ),
//                     SizedBox(height: 3.h),
//                     Text(
//                       (item['label'] as String).tr,
//                       style: AppTextStyles.labelSmall.copyWith(
//                         color: isActive ? AppColors.primary : AppColors.textTertiary,
//                         fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
//                       ),
//                     ),
//                     SizedBox(height: 3.h),
//                     Container(
//                       width: 4.r,
//                       height: 4.r,
//                       decoration: BoxDecoration(
//                         color: isActive ? AppColors.primary : Colors.transparent,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }
