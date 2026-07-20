import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/auth_controllers/auth_controller.dart';
import '../../../../models/message_model.dart';
import '../../../../models/notification_model.dart';
import '../../../../models/user_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/call_service.dart';
import '../../../../services/firebase_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Get.find<AuthController>().user.value?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: uid.isEmpty
                ? null
                : () => FirebaseService.markAllNotificationsRead(uid),
            child: Text(
              'Mark all read',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
          if (uid.isNotEmpty)
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_sweep_outlined),
              color: AppColors.textSecondary,
              onPressed: () => _confirmClearAll(context, uid),
            ),
        ],
      ),
      body: uid.isEmpty
          ? const Center(child: Text('Sign in to see notifications'))
          : StreamBuilder<List<NotificationModel>>(
              stream: FirebaseService.notificationsStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No notifications yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                final grouped = <String, List<NotificationModel>>{};
                final now = DateTime.now();
                for (final n in items) {
                  final label = _sectionLabel(n.createdAt, now);
                  grouped.putIfAbsent(label, () => []).add(n);
                }

                return ListView(
                  padding: EdgeInsets.all(AppTheme.spacingLG),
                  children: [
                    for (final entry in grouped.entries) ...[
                      _buildSection(entry.key),
                      ...entry.value.map(
                        (n) => Dismissible(
                          key: ValueKey(n.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) =>
                              FirebaseService.deleteNotification(uid, n.id),
                          background: Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                          ),
                          child: _NotificationTile(
                            notification: n,
                            userId: uid,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Clear all notifications', style: AppTextStyles.h3),
        content: Text(
          'This will permanently delete all your notifications. This cannot be undone.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete all',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseService.deleteAllNotifications(uid);
    }
  }

  String _sectionLabel(DateTime dt, DateTime now) {
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'TODAY';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'YESTERDAY';
    }
    return DateFormat('MMM d, yyyy').format(dt).toUpperCase();
  }

  Widget _buildSection(String title) => Padding(
        padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
        child: Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
        ),
      );
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final String userId;

  const _NotificationTile({
    required this.notification,
    required this.userId,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.health:
        return Icons.favorite;
      case NotificationType.payment:
        return Icons.check_circle;
      case NotificationType.appointment:
        return Icons.event_available;
      case NotificationType.message:
        return Icons.chat_bubble;
      case NotificationType.call:
        return Icons.videocam;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color get _color {
    switch (notification.type) {
      case NotificationType.health:
        return Colors.redAccent;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.appointment:
        return AppColors.primary;
      case NotificationType.message:
        return Colors.blueAccent;
      case NotificationType.call:
        return const Color(0xFF5C7CFF);
      case NotificationType.general:
        return AppColors.textSecondary;
    }
  }

  Future<void> _onTap() async {
    await FirebaseService.markNotificationRead(userId, notification.id);
    final data = notification.data;

    if (notification.type == NotificationType.call &&
        (data['roomId'] ?? '').isNotEmpty) {
      final auth = Get.find<AuthController>().user.value;
      if (auth == null) return;
      if (!Get.isRegistered<CallService>()) {
        Get.put(CallService(), permanent: true);
      }
      await CallService.to.joinCall(
        roomId: data['roomId']!,
        userId: auth.id,
        userName: auth.name,
        remoteUserId: data['participantId'] ?? data['remoteUserId'] ?? '',
        calleeName: data['participantName'] ?? data['remoteUserName'],
        callType: data['callType'] ?? 'video',
      );
      return;
    }

    if (notification.type == NotificationType.appointment ||
        data['screen'] == 'appointments') {
      Get.toNamed(AppRoutes.appointments);
      return;
    }

    if (notification.type == NotificationType.message &&
        (data['conversationId'] ?? '').isNotEmpty) {
      final auth = Get.find<AuthController>().user.value;
      final role = auth?.role;
      final conversationType = role == UserRole.caregiver
          ? ConversationType.caregiver
          : ConversationType.doctor;
      Get.toNamed(
        AppRoutes.chat,
        arguments: ConversationModel(
          id: data['conversationId']!,
          participantId: data['participantId'] ?? '',
          participantName: data['participantName'] ?? '',
          participantSpecialty: '',
          type: conversationType,
          lastMessage: notification.message,
          lastMessageTime: notification.createdAt,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          leading: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _color, size: 20.r),
          ),
          title: Text(
            notification.title,
            style: AppTextStyles.h3.copyWith(fontSize: 14.sp),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Text(notification.message, style: AppTextStyles.bodySmall),
              SizedBox(height: 4.h),
              Text(
                '${notification.timeLabel} · ${notification.category}',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!notification.isRead)
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              IconButton(
                tooltip: 'Delete',
                icon: Icon(Icons.close_rounded,
                    size: 18.r, color: AppColors.textTertiary),
                onPressed: () =>
                    FirebaseService.deleteNotification(userId, notification.id),
              ),
            ],
          ),
          onTap: _onTap,
        ),
      ),
    );
  }
}
