import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/constants/app_theme.dart';
import 'package:rambaa/controllers/auth_controllers/auth_controller.dart';
import 'package:rambaa/controllers/appointment_controller.dart';
import 'package:rambaa/models/message_model.dart';
import 'package:rambaa/models/appointment_model.dart';
import 'package:rambaa/models/user_model.dart';
import 'package:rambaa/services/call_service.dart';
import 'package:rambaa/services/cloudinary_service.dart';
import 'package:rambaa/services/firebase_service.dart';
import 'package:rambaa/services/push_notification.dart';

import 'chat_screen_component/chat_components.dart';

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late final String _userId;
  late final UserRole? _userRole;
  final AuthController _authCtrl = Get.find<AuthController>();
  bool _isSendingImage = false;

  @override
  void initState() {
    super.initState();
    _userId = _authCtrl.user.value?.id ?? '';
    _userRole = _authCtrl.user.value?.role;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendTextMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _userId.isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _userId,
      content: trimmed,
      type: MessageType.text,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
    );

    try {
      await FirebaseService.sendMessage(
        widget.conversation.id,
        _userId,
        widget.conversation.participantId,
        newMessage,
      );
      _notifyRecipient(trimmed);
      _scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'Send Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: AppColors.textOnDark,
      );
    }
  }

  Future<void> _sendImageMessage(String localPath) async {
    if (_isSendingImage || _userId.isEmpty || localPath.isEmpty) return;

    setState(() => _isSendingImage = true);
    try {
      final file = File(localPath);
      final fileBytes = await file.readAsBytes();
      final rawExt = localPath.split('.').last.toLowerCase();
      const allowed = {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'};
      final ext = allowed.contains(rawExt) ? rawExt : 'jpg';
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$_userId.$ext';

      final downloadUrl = await CloudinaryService.uploadImageToFolder(
        path: localPath,
        fileBytes: fileBytes,
        folder: 'chat_images/${widget.conversation.id}',
        fileName: fileName,
      );

      final originalFileName = localPath.split(RegExp(r'[/\\]')).last;
      final newMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _userId,
        content: '📷 Photo',
        type: MessageType.image,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
        fileUrl: downloadUrl,
        fileName: originalFileName,
      );

      await FirebaseService.sendMessage(
        widget.conversation.id,
        _userId,
        widget.conversation.participantId,
        newMessage,
      );
      _notifyRecipient('📷 Photo');
      _scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'Photo Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: AppColors.textOnDark,
      );
    } finally {
      if (mounted) setState(() => _isSendingImage = false);
    }
  }

  // Push a notification to the chat partner (no Cloud Function needed).
  Future<void> _notifyRecipient(String text) async {
    try {
      final recipientId = widget.conversation.participantId;
      final enabled = await FirebaseService.isNotificationsEnabled(recipientId);
      if (!enabled) return;

      final senderName = _authCtrl.user.value?.name ?? 'User';
      await PushNotificationService.sendPushNotification(
        userID: recipientId,
        type: 'chat',
        title: senderName,
        body: text,
        data: {
          'conversationId': widget.conversation.id,
          'participantId': recipientId,
          'participantName': widget.conversation.participantName,
        },
      );
    } catch (_) {
      // Notification is best-effort; never block the chat UI.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_userRole == UserRole.patient &&
        widget.conversation.type != ConversationType.doctor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          'Access Denied',
          'Patients can only message providers.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: AppColors.textOnDark,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_userRole == UserRole.provider &&
        widget.conversation.type != ConversationType.doctor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          'Access Denied',
          'Providers can only message patients.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: AppColors.textOnDark,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_userRole == UserRole.caregiver &&
        widget.conversation.type != ConversationType.caregiver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          'Access Denied',
          'Caregivers can only message clients.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: AppColors.textOnDark,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return StreamBuilder<List<MessageModel>>(
      stream: FirebaseService.getMessagesStream(
        widget.conversation.id,
        _userId,
      ),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _ChatHeader(conversation: widget.conversation),
              Expanded(
                child: messages.isEmpty
                    ? _EmptyState(conversation: widget.conversation)
                    : _MessageList(
                        messages: messages,
                        userId: _userId,
                        userName: _authCtrl.user.value?.name ?? 'User',
                        conversation: widget.conversation,
                        scrollController: _scrollController,
                      ),
              ),
              ChatInputArea(
                hintText: 'Type a message...',
                isBusy: _isSendingImage,
                onSubmitted: _sendTextMessage,
                onImageSelected: _sendImageMessage,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final ConversationModel conversation;
  const _ChatHeader({required this.conversation});

  String get _initials {
    final clean = conversation.participantName
        .replaceAll('Dr.', '')
        .replaceAll('Nurse', '')
        .trim();
    final parts = clean.split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  AppointmentType? _allowedCallType() {
    if (!Get.isRegistered<AppointmentController>()) return null;
    final ctrl = Get.find<AppointmentController>();
    final role = Get.find<AuthController>().user.value?.role;
    // Providers call patients — window check still uses appointments by patient side.
    if (role == UserRole.provider || role == UserRole.home) {
      return AppointmentType.video; // refined below via appointment list
    }
    return ctrl.callTypeForProvider(conversation.participantId);
  }

  bool _canCall() {
    if (!Get.isRegistered<AppointmentController>()) return false;
    final role = Get.find<AuthController>().user.value?.role;
    if (role == UserRole.provider || role == UserRole.home) {
      return true;
    }
    return Get.find<AppointmentController>().canCallProvider(
      conversation.participantId,
    );
  }

  Future<void> _startCall(String type) async {
    final role = Get.find<AuthController>().user.value?.role;
    final isPatient = role == UserRole.patient;

    if (isPatient) {
      final allowed = _allowedCallType();
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
      if (!_canCall()) {
        Get.snackbar(
          'Call Not Available',
          'You can call only within 15 minutes before to 30 minutes after your appointment time.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnDark,
        );
        return;
      }
    }

    final auth = Get.find<AuthController>();
    final callerId = auth.user.value?.id ?? '';
    final callerName = auth.user.value?.name ?? 'User';
    final calleeId = conversation.participantId;
    final calleeName = conversation.participantName;

    if (callerId.isEmpty || calleeId.isEmpty) return;

    try {
      if (!Get.isRegistered<CallService>()) {
        Get.put(CallService(), permanent: true);
      }
      String? appointmentId;
      if (Get.isRegistered<AppointmentController>()) {
        appointmentId = Get.find<AppointmentController>()
            .getActiveAppointmentForProvider(calleeId)
            ?.id;
      }
      await CallService.to.startCall(
        callerId: callerId,
        callerName: callerName,
        calleeId: calleeId,
        calleeName: calleeName,
        type: type,
        appointmentId: appointmentId,
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
    final bool isOnline = conversation.isOnline;
    final role = Get.find<AuthController>().user.value?.role;
    final isPatient = role == UserRole.patient;
    final canCall = _canCall();
    final allowedType = _allowedCallType();
    final showAudio =
        canCall && (!isPatient || allowedType == AppointmentType.audio);
    final showVideo =
        canCall &&
        (!isPatient ||
            allowedType == AppointmentType.video ||
            allowedType == null);

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.welcomeGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMd,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: 10.h,
          ),
          child: Row(
            children: [
              _CircleIcon(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Get.back(),
              ),
              SizedBox(width: AppTheme.spacingSM),
              Stack(
                children: [
                  _ChatAvatar(
                    imageUrl: conversation.imageUrl,
                    participantId: conversation.participantId,
                    initials: _initials,
                    size: 44.r,
                    radius: AppTheme.radiusSm,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    borderColor: Colors.white.withValues(alpha: 0.35),
                    textStyle: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 13.r,
                        height: 13.r,
                        decoration: BoxDecoration(
                          color: AppColors.healthGreenLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.welcomeGradient.colors.last,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppTheme.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.participantName,
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        if (isOnline)
                          Container(
                            width: 7.r,
                            height: 7.r,
                            decoration: const BoxDecoration(
                              color: AppColors.healthGreenLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (isOnline) SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            isOnline
                                ? (conversation.participantSpecialty.isNotEmpty
                                      ? conversation.participantSpecialty
                                      : 'Online')
                                : (conversation.participantSpecialty.isNotEmpty
                                      ? conversation.participantSpecialty
                                      : 'Offline'),
                            style: AppTextStyles.caption.copyWith(
                              color: isOnline
                                  ? AppColors.healthGreenLight
                                  : Colors.white70,
                              fontSize: 11.sp,
                              fontWeight: isOnline
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showAudio) ...[
                _CircleIcon(
                  icon: Icons.call_rounded,
                  onTap: () => _startCall('audio'),
                ),
                SizedBox(width: 8.w),
              ],
              if (showVideo) ...[
                _CircleIcon(
                  icon: Icons.videocam_rounded,
                  onTap: () => _startCall('video'),
                ),
                SizedBox(width: 8.w),
              ],
              _CircleIcon(icon: Icons.more_vert_rounded, onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(icon, size: 18.r, color: Colors.white),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ConversationModel conversation;
  const _EmptyState({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96.r,
            height: 96.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLighter,
                  AppColors.primary.withValues(alpha: 0.18),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_rounded,
              size: 42.r,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No messages yet',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXXL),
            child: Text(
              'Say hello to ${conversation.participantName.split(' ').first} to start the conversation.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatefulWidget {
  final List<MessageModel> messages;
  final String userId;
  final String userName;
  final ConversationModel conversation;
  final ScrollController scrollController;

  const _MessageList({
    required this.messages,
    required this.userId,
    required this.userName,
    required this.conversation,
    required this.scrollController,
  });

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  bool _didInitialScroll = false;
  List<DateTime> _sortedDates = const [];
  Map<DateTime, List<MessageModel>> _grouped = const {};

  void _scrollToBottom({bool animate = false}) {
    final sc = widget.scrollController;
    if (!sc.hasClients) return;
    if (sc.position.maxScrollExtent <= 0) return;
    if (animate) {
      sc.animateTo(
        sc.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      sc.jumpTo(sc.position.maxScrollExtent);
    }
  }

  void _computeGroups() {
    final grouped = <DateTime, List<MessageModel>>{};
    for (final msg in widget.messages) {
      final date = DateTime(
        msg.timestamp.year,
        msg.timestamp.month,
        msg.timestamp.day,
      );
      grouped.putIfAbsent(date, () => []).add(msg);
    }
    final sortedDates = grouped.keys.toList()..sort((a, b) => a.compareTo(b));
    _grouped = grouped;
    _sortedDates = sortedDates;
  }

  @override
  void didUpdateWidget(covariant _MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages != oldWidget.messages) {
      _computeGroups();
    }
    if (widget.messages.length > oldWidget.messages.length) {
      final sc = widget.scrollController;
      final atBottom =
          sc.hasClients &&
          sc.position.pixels >= sc.position.maxScrollExtent - 120;
      if (atBottom) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(animate: true),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _computeGroups();
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = _sortedDates;
    final grouped = _grouped;

    if (sortedDates.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (!_didInitialScroll && widget.messages.isNotEmpty) {
      _didInitialScroll = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingMD,
      ),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        final date = sortedDates[dateIndex];
        // Within a day, oldest first so the newest is at the bottom.
        final dayMessages = grouped[date]!.reversed.toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DateSeparator(date: date),
            SizedBox(height: AppTheme.spacingSM),
            ...dayMessages.map((msg) {
              final isMe = msg.senderId == widget.userId;
              return _MessageRow(
                message: msg,
                isMe: isMe,
                showAvatar: !isMe,
                userId: widget.userId,
                userName: widget.userName,
                conversation: widget.conversation,
              );
            }),
            SizedBox(height: AppTheme.spacingSM),
          ],
        );
      },
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
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
      label = '${months[date.month - 1]} ${date.day}, ${date.year}';
    }

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppTheme.spacingXS),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
          ),
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final String userId;
  final String userName;
  final ConversationModel conversation;

  const _MessageRow({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.userId,
    required this.userName,
    required this.conversation,
  });

  String get _time {
    final h = message.timestamp.hour > 12
        ? message.timestamp.hour - 12
        : (message.timestamp.hour == 0 ? 12 : message.timestamp.hour);
    final period = message.timestamp.hour >= 12 ? 'PM' : 'AM';
    final min = message.timestamp.minute.toString().padLeft(2, '0');
    return '$h:$min $period';
  }

  Widget _statusIcon() {
    switch (message.status) {
      case MessageStatus.read:
        return Icon(Icons.done_all_rounded, size: 15.r, color: Colors.white70);
      case MessageStatus.delivered:
        return Icon(Icons.done_all_rounded, size: 15.r, color: Colors.white54);
      case MessageStatus.sent:
        return Icon(Icons.done_rounded, size: 15.r, color: Colors.white54);
    }
  }

  Future<void> _joinCallBubble() async {
    if (!message.isCallInvite) return;
    try {
      if (!Get.isRegistered<CallService>()) {
        Get.put(CallService(), permanent: true);
      }
      await CallService.to.joinCall(
        roomId: message.roomId!,
        userId: userId,
        userName: userName,
        remoteUserId: conversation.participantId,
        calleeName: conversation.participantName,
        callType: message.callType ?? 'video',
        isIncoming: !isMe,
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

  void _openFullImage(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white70,
                        size: 48.r,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 28.r,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _callBubble(BuildContext context) {
    final isVideo = (message.callType ?? 'video').toLowerCase() == 'video';
    final ended = message.callStatus == 'ended';

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: isMe ? null : AppColors.surface,
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0xFF5C7CFF), Color(0xFF3D5AFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
          bottomLeft: Radius.circular(isMe ? 18.r : 5.r),
          bottomRight: Radius.circular(isMe ? 5.r : 18.r),
        ),
        border: isMe ? null : Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                size: 20.r,
                color: isMe ? Colors.white : AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                isVideo ? 'Video Call' : 'Audio Call',
                style: AppTextStyles.h3.copyWith(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            ended ? 'Call ended' : message.content,
            style: AppTextStyles.bodySmall.copyWith(
              color: isMe ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10.h),
          if (!ended)
            GestureDetector(
              onTap: _joinCallBubble,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  'Join Call',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isMe ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          SizedBox(height: 6.h),
          Text(
            _time,
            style: AppTextStyles.caption.copyWith(
              color: isMe ? Colors.white70 : AppColors.textTertiary,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageBubble(BuildContext context) {
    final url = message.fileUrl ?? '';
    final maxW = MediaQuery.of(context).size.width * 0.68;

    return Container(
      constraints: BoxConstraints(maxWidth: maxW),
      decoration: BoxDecoration(
        color: isMe ? null : AppColors.surface,
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0xFF5C7CFF), Color(0xFF3D5AFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
          bottomLeft: Radius.circular(isMe ? 18.r : 5.r),
          bottomRight: Radius.circular(isMe ? 5.r : 18.r),
        ),
        border: isMe ? null : Border.all(color: AppColors.borderLight),
        boxShadow: isMe
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: Offset(0, 4.h),
                ),
              ]
            : AppTheme.shadowSm,
      ),
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: url.isEmpty ? null : () => _openFullImage(context, url),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: url.isEmpty
                  ? _imagePlaceholder(maxW)
                  : Image.network(
                      url,
                      width: maxW,
                      height: 220.h,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          width: maxW,
                          height: 220.h,
                          child: Center(
                            child: SizedBox(
                              width: 28.r,
                              height: 28.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: isMe ? Colors.white : AppColors.primary,
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _imagePlaceholder(maxW),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 4.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _time,
                  style: AppTextStyles.caption.copyWith(
                    color: isMe ? Colors.white70 : AppColors.textTertiary,
                    fontSize: 10.sp,
                  ),
                ),
                if (isMe) ...[SizedBox(width: 4.w), _statusIcon()],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(double maxW) {
    return Container(
      width: maxW,
      height: 180.h,
      color: isMe ? Colors.white.withValues(alpha: 0.15) : AppColors.background,
      child: Icon(
        Icons.broken_image_outlined,
        size: 40.r,
        color: isMe ? Colors.white70 : AppColors.textTertiary,
      ),
    );
  }

  Widget _textBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isMe ? null : AppColors.surface,
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0xFF5C7CFF), Color(0xFF3D5AFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
          bottomLeft: Radius.circular(isMe ? 18.r : 5.r),
          bottomRight: Radius.circular(isMe ? 5.r : 18.r),
        ),
        border: isMe ? null : Border.all(color: AppColors.borderLight),
        boxShadow: isMe
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: Offset(0, 4.h),
                ),
              ]
            : AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isMe ? AppColors.textOnDark : AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _time,
                style: AppTextStyles.caption.copyWith(
                  color: isMe ? Colors.white70 : AppColors.textTertiary,
                  fontSize: 10.sp,
                ),
              ),
              if (isMe) ...[SizedBox(width: 4.w), _statusIcon()],
            ],
          ),
        ],
      ),
    );
  }

  Widget _leadingAvatar() {
    if (isMe) return const SizedBox.shrink();
    if (!showAvatar) return SizedBox(width: 34.r);

    if (message.type == MessageType.call) {
      return Padding(
        padding: EdgeInsets.only(right: 6.w),
        child: Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm / 2),
          ),
          child: Icon(Icons.call_rounded, size: 14.r, color: AppColors.primary),
        ),
      );
    }

    final clean = conversation.participantName
        .replaceAll('Dr.', '')
        .replaceAll('Nurse', '')
        .trim();
    final parts = clean.isEmpty ? <String>[] : clean.split(' ');
    String initials;
    if (parts.isEmpty) {
      initials = '?';
    } else if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      initials = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }

    return Padding(
      padding: EdgeInsets.only(right: 6.w),
      child: _ChatAvatar(
        imageUrl: conversation.imageUrl,
        participantId: conversation.participantId,
        initials: initials,
        size: 28.r,
        radius: AppTheme.radiusSm / 2,
        backgroundColor: AppColors.primaryLighter,
        borderColor: Colors.transparent,
        textStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 9.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget bubble;
    switch (message.type) {
      case MessageType.call:
        bubble = _callBubble(context);
      case MessageType.image:
        bubble = _imageBubble(context);
      case MessageType.text:
      case MessageType.file:
      case MessageType.ai:
        bubble = _textBubble(context);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _leadingAvatar(),
          Expanded(
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: bubble,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat avatar (resolves real uploaded image) ────────────────────────────────

class _ChatAvatar extends StatefulWidget {
  final String? imageUrl;
  final String participantId;
  final String initials;
  final double size;
  final double radius;
  final Color backgroundColor;
  final Color borderColor;
  final TextStyle textStyle;

  const _ChatAvatar({
    required this.imageUrl,
    required this.participantId,
    required this.initials,
    required this.size,
    required this.radius,
    required this.backgroundColor,
    required this.borderColor,
    required this.textStyle,
  });

  @override
  State<_ChatAvatar> createState() => _ChatAvatarState();
}

class _ChatAvatarState extends State<_ChatAvatar> {
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _ChatAvatar oldWidget) {
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
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: widget.borderColor, width: 1.5),
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
              child: Text(widget.initials, style: widget.textStyle),
            ),
    );
  }
}
