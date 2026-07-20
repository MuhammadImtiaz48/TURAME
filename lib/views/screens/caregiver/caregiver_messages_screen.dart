// ============================================================
// FILE: lib/views/screens/caregiver/caregiver_messages_screen.dart
// Caregiver chat — lists patients who booked home visits with
// the caregiver, and opens a real-time chat with each of them.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_theme.dart';
import '../../../controllers/message_controller.dart';
import '../../../models/message_model.dart';
import '../../../services/firebase_service.dart';
import '../../widgets/app_text_field.dart';
import '../shared/chat_screen.dart';

class CaregiverMessagesScreen extends StatelessWidget {
  const CaregiverMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<MessagesController>()
        ? Get.find<MessagesController>()
        : Get.put(MessagesController());

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
            color: widget.color.withValues(alpha: 0.25), width: 1.5),
        image: avatarImage != null
            ? DecorationImage(
                image: NetworkImage(avatarImage),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatarImage == null
          ? Center(
              child: Text(
                widget.initials,
                style: AppTextStyles.h3.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Messages', style: AppTextStyles.onDarkTitle),
                    SizedBox(height: 2.h),
                    Text(
                      'Chat with your patients',
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
                  Icons.chat_bubble_rounded,
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
        hint: 'Search patients...',
        type: AppTextFieldType.search,
        prefixIcon: Icon(Icons.search_rounded, size: 18.r, color: AppColors.textTertiary),
        onChanged: ctrl.onSearch,
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  final MessagesController ctrl;
  const _ConversationList({required this.ctrl});

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
                'Patients who book home visits with you\nwill appear here.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
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
          return _ConversationCard(
            conversation: conv,
            formattedTime: DateFormat('h:mm a').format(conv.lastMessageTime),
            onTap: () {
              Get.to(() => ChatScreen(conversation: conv));
            },
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

  const _ConversationCard({
    required this.conversation,
    required this.formattedTime,
    required this.onTap,
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
    final name = conversation.participantName.trim();
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    if (parts.first.isNotEmpty) return parts[0][0];
    return '?';
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
                          border: Border.all(color: AppColors.surface, width: 2),
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
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
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
                            color: hasUnread ? AppColors.primary : AppColors.textTertiary,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
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
                                ? 'Say hello to your patient'
                                : conversation.lastMessage,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: hasUnread ? AppColors.textSecondary : AppColors.textTertiary,
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
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
                    if (conversation.participantSpecialty.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        conversation.participantSpecialty,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: AppTheme.spacingSM),
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
