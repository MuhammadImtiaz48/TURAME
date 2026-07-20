import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../models/message_model.dart';
import '../../shared/chat_screen_component/chat_components.dart';

class AiChatScreen extends StatelessWidget {
  final ConversationModel conversation;
  const AiChatScreen({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppTheme.spacingLG),
              children: [
                AiWelcomeMessage(),
                SizedBox(height: AppTheme.spacingLG),
                ChatMessageBubble(
                  text: "I've been having headaches and feeling dizzy for 2 days",
                  isMe: true,
                ),
                SizedBox(height: AppTheme.spacingMD),
                AiAnalysisBox(
                  title: 'AI Analysis',
                  content: 'Headache with dizziness for 2+ days may suggest dehydration, hypertension, or low blood sugar.',
                ),
              ],
            ),
          ),
          ChatInputArea(hintText: "Describe your symptoms..."),
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
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4.h,
            left: AppTheme.spacingSM,
            right: AppTheme.spacingLG,
            bottom: 14.h,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16.r,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacingSM),
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: 22.r,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppTheme.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TURAME AI',
                      style: AppTextStyles.h3.copyWith(color: Colors.white, height: 1.2),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Health Assistant — Always Available',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
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
