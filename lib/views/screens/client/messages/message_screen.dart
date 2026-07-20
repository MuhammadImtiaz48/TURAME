// FILE: lib/views/screens/patient/messages_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/message_controller.dart';
import '../../../../models/message_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/conversational_tile.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MessagesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppTheme.spacingLG,
                AppTheme.spacingLG,
                AppTheme.spacingLG,
                AppTheme.spacingMD,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Messages', style: AppTextStyles.bodySmall),
                  ),
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Icon(Icons.edit_outlined,
                        size: 18.r, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            // ── Search bar (AppTextField) ─────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLG),
              child: AppTextField(
                label: '',
                hint: 'Search conversations...',
                type: AppTextFieldType.search,
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18.r, color: AppColors.textTertiary),
                onChanged: ctrl.onSearch,
              ),
            ),

            SizedBox(height: AppTheme.spacingMD),

            // ── List ──────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  );
                }

                final list = ctrl.filtered;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 48.r, color: AppColors.textTertiary),
                        SizedBox(height: 12.h),
                        Text(
                          'No conversations found',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  );
                }

                final aiConvs = list
                    .where((c) => c.type == ConversationType.ai)
                    .toList();
                final regularConvs = list
                    .where((c) => c.type != ConversationType.ai)
                    .toList();

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // ── AI Assistant card ──────────────────────
                    if (aiConvs.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingLG),
                        child: _AiAssistantCard(
                          onTap: () => Get.toNamed(AppRoutes.aiChat),
                        ),
                      ),
                      SizedBox(height: AppTheme.spacingMD),
                    ],

                    // ── Recent chats label ─────────────────────
                    if (regularConvs.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingLG),
                        child: Text(
                          'RECENT CHATS',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(height: 1, color: AppColors.borderLight),

                      ...regularConvs.map((conv) => Column(
                        children: [
                          ConversationTile(
                            conversation: conv,
                            formattedTime:
                            ctrl.formatTime(conv.lastMessageTime),
                            onTap: () => Get.toNamed(
                              AppRoutes.chat,
                              arguments: conv,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingLG),
                            child: Container(
                                height: 1,
                                color: AppColors.borderLight),
                          ),
                        ],
                      )),
                    ],

                    SizedBox(height: AppTheme.spacingXXL),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── AI Assistant Card ────────────────────────────────────────────────────────

class _AiAssistantCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AiAssistantCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingMD),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(Icons.smart_toy_rounded,
                  size: 26.r, color: Colors.white),
            ),
            SizedBox(width: AppTheme.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TURAME AI Assistant',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Ask me about your health...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4), width: 1),
              ),
              child: Text(
                'AI',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}