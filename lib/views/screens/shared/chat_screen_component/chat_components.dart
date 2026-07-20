import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../constants/app_colors.dart';

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const ChatMessageBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 8.h),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft: isMe ? Radius.circular(14.r) : Radius.circular(4.r),
            bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(14.r),
          ),
          boxShadow: isMe
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : AppTheme.shadowSm,
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isMe ? AppColors.textOnDark : AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class ChatInputArea extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onImageSelected;
  final bool isBusy;

  const ChatInputArea({
    super.key,
    this.hintText = 'Type a message...',
    this.onSubmitted,
    this.onImageSelected,
    this.isBusy = false,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  static const _emojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
    '🙂', '😉', '😊', '😇', '🥰', '😍', '🤩', '😘',
    '😗', '😚', '😋', '😛', '😜', '🤪', '😝', '🤑',
    '🤗', '🤭', '🤫', '🤔', '🤐', '🤨', '😐', '😑',
    '😶', '😏', '😒', '🙄', '😬', '😌', '😔', '😪',
    '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮', '🥵',
    '🥶', '🥴', '😵', '🤯', '🤠', '🥳', '😎', '🤓',
    '🧐', '😕', '😟', '🙁', '😮', '😯', '😲', '😳',
    '🥺', '😦', '😧', '😨', '😰', '😥', '😢', '😭',
    '😱', '😖', '😣', '😞', '😓', '😩', '😫', '🥱',
    '😤', '😡', '😠', '🤬', '👋', '🤚', '🖐', '✋',
    '🖖', '👌', '🤌', '🤏', '✌️', '🤞', '🤟', '🤘',
    '🤙', '👈', '👉', '👆', '👇', '☝️', '👍', '👎',
    '✊', '👊', '🤛', '🤜', '👏', '🙌', '👐', '🤲',
    '🤝', '🙏', '💪', '🦾', '❤️', '🧡', '💛', '💚',
    '💙', '💜', '🖤', '🤍', '🤎', '💔', '❣️', '💕',
    '💞', '💓', '💗', '💖', '💘', '💝', '💟', '☮️',
    '✨', '⭐', '🌟', '💫', '🔥', '💯', '✅', '❌',
    '🎉', '🎊', '🎈', '🎁', '🏆', '🥇', '💊', '🩺',
    '🏥', '🚑', '☀️', '🌙', '☕', '🍵', '🍎', '🥗',
  ];

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showEmojiPicker = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.isBusy) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmitted?.call(text);
    _controller.clear();
  }

  void _insertEmoji(String emoji) {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final next = text.replaceRange(start, end, emoji);
    final cursor = start + emoji.length;
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  void _toggleEmojiPicker() {
    if (widget.isBusy) return;
    setState(() => _showEmojiPicker = !_showEmojiPicker);
    if (_showEmojiPicker) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.isBusy;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            AppTheme.spacingMD,
            AppTheme.spacingSM,
            AppTheme.spacingMD,
            AppTheme.spacingSM +
                (_showEmojiPicker
                    ? 0
                    : MediaQuery.of(context).padding.bottom),
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.borderLight, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSm,
                blurRadius: 12,
                offset: Offset(0, -2.h),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: !_showEmojiPicker,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !busy,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 13.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMD,
                          vertical: 10.h,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      onTap: () {
                        if (_showEmojiPicker) {
                          setState(() => _showEmojiPicker = false);
                        }
                      },
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spacingXS),
                Opacity(
                  opacity: busy ? 0.45 : 1,
                  child: _InputIcon(
                    icon: _showEmojiPicker
                        ? Icons.keyboard_rounded
                        : Icons.emoji_emotions_outlined,
                    onTap: busy ? () {} : _toggleEmojiPicker,
                  ),
                ),
                SizedBox(width: AppTheme.spacingXS),
                Opacity(
                  opacity: busy ? 0.45 : 1,
                  child: GestureDetector(
                    onTap: busy ? null : _submit,
                    child: Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: 19.r,
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showEmojiPicker)
          Container(
            height: 260.h,
            width: double.infinity,
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(
              8.w,
              4.h,
              8.w,
              MediaQuery.of(context).padding.bottom + 8.h,
            ),
            child: GridView.builder(
              itemCount: _emojis.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 4.h,
                crossAxisSpacing: 4.w,
              ),
              itemBuilder: (context, index) {
                final emoji = _emojis[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: () => _insertEmoji(emoji),
                  child: Center(
                    child: Text(emoji, style: TextStyle(fontSize: 24.sp)),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _InputIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _InputIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(icon, size: 20.r, color: AppColors.textSecondary),
      ),
    );
  }
}

class AiWelcomeMessage extends StatelessWidget {
  final String text;

  const AiWelcomeMessage({
    super.key,
    this.text = "Hello! I'm your personal health assistant...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              size: 18.r,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppTheme.spacingSM),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AiAnalysisBox extends StatelessWidget {
  final String title;
  final String content;

  const AiAnalysisBox({
    super.key,
    this.title = 'AI Analysis',
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm / 2),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 16.r,
                ),
              ),
              SizedBox(width: AppTheme.spacingSM),
              Text(
                title,
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingSM),
          Text(
            content,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
