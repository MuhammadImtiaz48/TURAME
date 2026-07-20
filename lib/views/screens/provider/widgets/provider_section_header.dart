// ============================================================
// FILE: lib/views/screens/provider/widgets/provider_section_header.dart
// Reusable section header with optional "See all" action.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_colors.dart';
import 'package:rambaa/constants/app_text_styles.dart';

class ProviderSectionHeader extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAll;

  const ProviderSectionHeader({
    super.key,
    required this.title,
    this.showSeeAll = false,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h3),
        if (showSeeAll)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'see_all'.tr,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.providerColor,
                fontSize: 13.sp,
              ),
            ),
          ),
      ],
    );
  }
}
