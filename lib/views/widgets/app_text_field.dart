import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

enum AppTextFieldType { text, password, email, phone, search }

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final AppTextFieldType type;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool isSearchStyle;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.type = AppTextFieldType.text,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.textInputAction,
    this.focusNode,
    this.isSearchStyle = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  bool get _isPassword => widget.type == AppTextFieldType.password;

  TextInputType get _keyboardType => switch (widget.type) {
    AppTextFieldType.email => TextInputType.emailAddress,
    AppTextFieldType.phone => TextInputType.phone,
    AppTextFieldType.search => TextInputType.text,
    _ => TextInputType.text,
  };

  @override
  Widget build(BuildContext context) {
    final isSearch =
        widget.type == AppTextFieldType.search || widget.isSearchStyle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: AppTextStyles.labelLarge.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 4.h),
        // Field
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _isPassword && _obscure,
          keyboardType: _keyboardType,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: isSearch,
            fillColor: isSearch ? Colors.white.withValues(alpha: 0.15) : null,
            border: isSearch
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  )
                : null,
            enabledBorder: isSearch
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  )
                : null,
            prefixIcon: (widget.prefixIcon != null || isSearch)
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child:
                        widget.prefixIcon ??
                        Icon(Icons.search_rounded, color: Colors.white),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIcon: _isPassword
                ? GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : widget.suffixIcon,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),
        ),
      ],
    );
  }
}
