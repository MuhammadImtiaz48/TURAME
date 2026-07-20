import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';

class LoadingUtils {
  static bool _isShowing = false;

  static void show({String message = 'Please wait...'}) {
    if (_isShowing) return;
    _isShowing = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Container(
          color: Colors.black.withValues(alpha: 0.45),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.caregiverColor),
                  SizedBox(height: 16.h),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (_isShowing) {
      _isShowing = false;
      if (Get.isDialogOpen == true) Get.back();
    }
  }
}
