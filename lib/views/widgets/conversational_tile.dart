// FILE: lib/views/widgets/messages/conversation_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_theme.dart';
import '../../../models/message_model.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final String formattedTime;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.formattedTime,
    required this.onTap,
  });

  // Avatar colors per participant
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
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLG,
          vertical: AppTheme.spacingMD,
        ),
        color: Colors.transparent,
        child: Row(
          children: [
            // ── Avatar ───────────────────────────────────────
            Stack(
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: _avatarColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                        color: _avatarColor.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      _initials.toUpperCase(),
                      style: AppTextStyles.h3.copyWith(
                        color: _avatarColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                // Online dot
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
                            color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: AppTheme.spacingMD),

            // ── Name + Last message ───────────────────────────
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
                          conversation.lastMessage,
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
          ],
        ),
      ),
    );
  }
}