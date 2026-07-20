import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_theme.dart';

enum AppButtonType { primary, outline, ghost, danger, white }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonType type;
  final AppButtonSize size;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool loading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.large,
    this.prefixIcon,
    this.suffixIcon,
    this.loading = false,
    this.fullWidth = true,
  });

  // ── Convenience constructors ──────────────────────────────────
  const AppButton.outline({
    super.key,
    required this.label,
    this.onTap,
    this.size = AppButtonSize.large,
    this.prefixIcon,
    this.suffixIcon,
    this.loading = false,
    this.fullWidth = true,
  }) : type = AppButtonType.outline;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onTap,
    this.size = AppButtonSize.large,
    this.prefixIcon,
    this.suffixIcon,
    this.loading = false,
    this.fullWidth = true,
  }) : type = AppButtonType.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onTap,
    this.size = AppButtonSize.large,
    this.prefixIcon,
    this.suffixIcon,
    this.loading = false,
    this.fullWidth = true,
  }) : type = AppButtonType.danger;

  const AppButton.white({
    super.key,
    required this.label,
    this.onTap,
    this.size = AppButtonSize.large,
    this.prefixIcon,
    this.suffixIcon,
    this.loading = false,
    this.fullWidth = true,
  }) : type = AppButtonType.white;

  // ── Styles ────────────────────────────────────────────────────
  double get _height => switch (size) {
    AppButtonSize.small => 38,
    AppButtonSize.medium => 46,
    AppButtonSize.large => 54,
  };

  double get _fontSize => switch (size) {
    AppButtonSize.small => 13,
    AppButtonSize.medium => 14,
    AppButtonSize.large => 16,
  };

  EdgeInsets get _padding => switch (size) {
    AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 16),
    AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 20),
    AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 24),
  };

  Color get _bgColor => switch (type) {
    AppButtonType.primary => AppColors.primary,
    AppButtonType.outline => Colors.transparent,
    AppButtonType.ghost => AppColors.surface2,
    AppButtonType.danger => AppColors.danger,
    AppButtonType.white => AppColors.surface,
  };

  Color get _textColor => switch (type) {
    AppButtonType.primary => AppColors.textOnDark,
    AppButtonType.outline => AppColors.primary,
    AppButtonType.ghost => AppColors.textSecondary,
    AppButtonType.danger => AppColors.textOnDark,
    AppButtonType.white => AppColors.primary,
  };

  Border? get _border => switch (type) {
    AppButtonType.outline =>
        Border.all(color: AppColors.primary, width: 1.5),
    AppButtonType.ghost => Border.all(color: AppColors.border, width: 1),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _height,
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: _padding,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: _border,
            boxShadow: type == AppButtonType.primary ? AppTheme.shadowSm : null,
          ),
          child: Center(
            child: loading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _textColor,
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: _textColor,
                    fontSize: _fontSize,
                  ),
                ),
                if (suffixIcon != null) ...[
                  const SizedBox(width: 8),
                  suffixIcon!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}