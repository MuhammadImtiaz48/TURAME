// ============================================================
// FILE: lib/views/screens/client/dashboard/widgets/service_category_row.dart
// Horizontal row of service category chips.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rambaa/constants/app_text_styles.dart';
import 'package:rambaa/views/screens/client/dashboard/widgets/dashboard_models.dart';

class ServiceCategoryRow extends StatelessWidget {
  final List<ServiceCategory> categories;
  final void Function(int index)? onTap;

  const ServiceCategoryRow({super.key, required this.categories, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (_, i) {
          final c = categories[i];
          return GestureDetector(
            onTap: onTap != null ? () => onTap!(i) : null,
            child: Column(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: c.bg,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Center(
                    child: Text(c.emoji, style: TextStyle(fontSize: 26.sp)),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  c.labelKey.tr,
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 10.sp),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
