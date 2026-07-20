import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:rambaa/controllers/message_controller.dart';
import 'package:rambaa/controllers/auth_controllers/auth_controller.dart';
import 'package:rambaa/controllers/appointment_controller.dart';
import 'package:rambaa/models/message_model.dart';
import 'package:rambaa/models/appointment_model.dart';
import 'package:rambaa/services/call_service.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../widgets/app_text_field.dart';
import '../../../../services/firebase_service.dart';
import '../../shared/chat_screen.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MessagesController>()) {
      Get.put(MessagesController(), permanent: false);
    }
    final ctrl = Get.find<MessagesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(),
          _SearchBar(ctrl: ctrl),
          Expanded(child: _ConversationList(ctrl: ctrl)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.welcomeGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppTheme.spacingLG,
            right: AppTheme.spacingLG,
            top: AppTheme.spacingMD,
            bottom: AppTheme.spacingXL,
          ),
          child: Row(
            children: [
              SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Messages', style: AppTextStyles.onDarkTitle),
                    SizedBox(height: 2.h),
                    Text(
                      'Your conversations',
                      style: AppTextStyles.onDarkBody.copyWith(fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18.r,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final MessagesController ctrl;
  const _SearchBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLG,
        vertical: AppTheme.spacingMD,
      ),
      child: AppTextField(
        label: '',
        hint: 'Search conversations...',
        type: AppTextFieldType.search,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 18.r,
          color: AppColors.textTertiary,
        ),
        onChanged: ctrl.onSearch,
      ),
    );
  }
}

// ─── Avatar (resolves real uploaded image) ─────────────────────────────────────

class _ConversationAvatar extends StatefulWidget {
  final String? imageUrl;
  final String participantId;
  final String initials;
  final Color color;

  const _ConversationAvatar({
    required this.imageUrl,
    required this.participantId,
    required this.initials,
    required this.color,
  });

  @override
  State<_ConversationAvatar> createState() => _ConversationAvatarState();
}

class _ConversationAvatarState extends State<_ConversationAvatar> {
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _ConversationAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.participantId != widget.participantId) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      if (mounted) setState(() => _resolvedUrl = widget.imageUrl);
      return;
    }
    final fetched = await FirebaseService.getUserImageUrl(widget.participantId);
    if (mounted) setState(() => _resolvedUrl = fetched);
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    final showImage = url != null && url.isNotEmpty;
    final avatarImage = showImage ? url : null;
    return Container(
      width: 50.r,
      height: 50.r,
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.25),
          width: 1.5,
        ),
        image: avatarImage != null
            ? DecorationImage(
                image: NetworkImage(avatarImage),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: showImage
          ? null
          : Center(
              child: Text(
                widget.initials,
                style: AppTextStyles.h3.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  final MessagesController ctrl;
  const _ConversationList({required this.ctrl});

  AppointmentType? _allowedCallType(String providerId) {
    if (!Get.isRegistered<AppointmentController>()) return null;
    final apptCtrl = Get.find<AppointmentController>();
    return apptCtrl.callTypeForProvider(providerId);
  }

  bool _canCall(String providerId) {
    if (!Get.isRegistered<AppointmentController>()) return false;
    final apptCtrl = Get.find<AppointmentController>();
    return apptCtrl.canCallProvider(providerId);
  }

  Future<void> _startCall(
    BuildContext context,
    ConversationModel conversation,
    String type,
  ) async {
    final allowed = _allowedCallType(conversation.participantId);
    if (allowed == null) {
      Get.snackbar(
        'Call Unavailable',
        'Please book an appointment first to call this provider.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.textOnDark,
      );
      return;
    }
    if (type != allowed.name) {
      Get.snackbar(
        'Call Unavailable',
        'Only ${allowed == AppointmentType.video ? 'Video' : 'Audio'} calls are allowed for this appointment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.textOnDark,
      );
      return;
    }
    if (!_canCall(conversation.participantId)) {
      Get.snackbar(
        'Call Not Available',
        'You can call only within 15 minutes before to 30 minutes after your appointment time.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.textOnDark,
      );
      return;
    }

    final auth = Get.find<AuthController>();
    final callerId = auth.user.value?.id ?? '';
    final callerName = auth.user.value?.name ?? 'User';
    final calleeId = conversation.participantId;
    final calleeName = conversation.participantName;

    if (callerId.isEmpty || calleeId.isEmpty) {
      if (context.mounted) {
        Get.snackbar(
          'Call Error',
          'Unable to start call. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: AppColors.textOnDark,
        );
      }
      return;
    }

    try {
      if (!Get.isRegistered<CallService>()) {
        Get.put(CallService(), permanent: true);
      }
      final appointmentId = Get.find<AppointmentController>()
          .getActiveAppointmentForProvider(calleeId)
          ?.id;
      await CallService.to.startCall(
        callerId: callerId,
        callerName: callerName,
        calleeId: calleeId,
        calleeName: calleeName,
        type: type,
        appointmentId: appointmentId,
      );
    } catch (e) {
      if (context.mounted) {
        Get.snackbar(
          'Call Failed',
          e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: AppColors.textOnDark,
        );
      }
    }
  }

  /*
  String? _appointmentId(String providerId) {
    if (!Get.isRegistered<AppointmentController>()) return null;
    final apptCtrl = Get.find<AppointmentController>();
    final appt = apptCtrl.getActiveAppointmentForProvider(providerId);
    return appt?.id;
  }
  */

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      final list = ctrl.filtered;

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 36.r,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'No conversations yet',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Book an appointment to start chatting',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.fromLTRB(
          AppTheme.spacingLG,
          0,
          AppTheme.spacingLG,
          AppTheme.spacingXXL,
        ),
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        itemCount: list.length,
        separatorBuilder: (_, _) => SizedBox(height: AppTheme.spacingSM),
        itemBuilder: (context, i) {
          final conv = list[i];
          final allowed = _allowedCallType(conv.participantId);
          final showAudio =
              allowed == AppointmentType.audio && _canCall(conv.participantId);
          final showVideo =
              allowed == AppointmentType.video && _canCall(conv.participantId);
          return _ConversationCard(
            conversation: conv,
            formattedTime: DateFormat('h:mm a').format(conv.lastMessageTime),
            onTap: () {
              Get.to(() => ChatScreen(conversation: conv));
            },
            onAudioCallTap: showAudio
                ? () => _startCall(context, conv, 'audio')
                : null,
            onVideoCallTap: showVideo
                ? () => _startCall(context, conv, 'video')
                : null,
          );
        },
      );
    });
  }
}

class _ConversationCard extends StatelessWidget {
  final ConversationModel conversation;
  final String formattedTime;
  final VoidCallback onTap;
  final VoidCallback? onAudioCallTap;
  final VoidCallback? onVideoCallTap;

  const _ConversationCard({
    required this.conversation,
    required this.formattedTime,
    required this.onTap,
    this.onAudioCallTap,
    this.onVideoCallTap,
  });

  Color get _avatarColor {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.healthGreen,
      AppColors.accent,
    ];
    return colors[conversation.participantId.hashCode % colors.length];
  }

  String get _initials {
    final name = conversation.participantName
        .replaceAll('Dr.', '')
        .replaceAll('Nurse', '')
        .trim();
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0][0];
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingMD),
          child: Row(
            children: [
              Stack(
                children: [
                  _ConversationAvatar(
                    imageUrl: conversation.imageUrl,
                    participantId: conversation.participantId,
                    initials: _initials.toUpperCase(),
                    color: _avatarColor,
                  ),
                  if (conversation.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 13.r,
                        height: 13.r,
                        decoration: BoxDecoration(
                          color: AppColors.healthGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.participantName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          formattedTime,
                          style: AppTextStyles.caption.copyWith(
                            color: hasUnread
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage.isEmpty
                                ? (conversation.type == ConversationType.doctor
                                      ? 'Start a conversation'
                                      : 'Say hello!')
                                : conversation.lastMessage,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: hasUnread
                                  ? AppColors.textSecondary
                                  : AppColors.textTertiary,
                              fontWeight: hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          SizedBox(width: 8.w),
                          Container(
                            width: 20.r,
                            height: 20.r,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${conversation.unreadCount}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textOnDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppTheme.spacingSM),
              /*
              if (onAudioCallTap != null)
                GestureDetector(
                  onTap: onAudioCallTap,
                  child: Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Icon(Icons.call_rounded, size: 18.r, color: AppColors.primary),
                  ),
                ),
              if (onAudioCallTap != null && onVideoCallTap != null)
                SizedBox(width: 6.w),
              if (onVideoCallTap != null)
                GestureDetector(
                  onTap: onVideoCallTap,
                  child: Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Icon(Icons.videocam_rounded, size: 18.r, color: AppColors.primary),
                  ),
                ),
              SizedBox(width: 6.w),
              */
              Icon(
                Icons.chevron_right_rounded,
                size: 20.r,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
