import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ─── Radius ───────────────────────────────────────────────────
  static double get radiusSm => 10.r;
  static double get radiusMd => 16.r;
  static double get radiusLg => 24.r;
  static double get radiusXl => 32.r;

  // ─── Spacing ──────────────────────────────────────────────────
  static double get spacingXS  => 8.w;
  static double get spacingSM  => 12.w;
  static double get spacingMD  => 16.w;
  static double get spacingLG  => 20.w;
  static double get spacingXL  => 24.w;
  static double get spacingXXL => 32.w;

  // ─── Shadows ──────────────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: AppColors.shadowSm,
      blurRadius: 4.r,
      offset: Offset(0, 1.h),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: AppColors.shadowMd,
      blurRadius: 16.r,
      offset: Offset(0, 4.h),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: AppColors.shadowLg,
      blurRadius: 32.r,
      offset: Offset(0, 8.h),
    ),
  ];

  // ─── Light Theme ──────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnDark,
      primaryContainer: AppColors.primaryLighter,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnDark,
      secondaryContainer: AppColors.secondaryLighter,
      tertiary: AppColors.accent,
      onTertiary: AppColors.textOnDark,
      error: AppColors.danger,
      onError: AppColors.textOnDark,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),

    scaffoldBackgroundColor: AppColors.background,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: AppTextStyles.h2,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 22,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnDark,
        elevation: 0,
        minimumSize: Size(double.infinity, 52.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        textStyle: AppTextStyles.buttonLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        minimumSize: Size(double.infinity, 52.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        textStyle: AppTextStyles.buttonLarge.copyWith(color: AppColors.primary),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
      labelStyle: AppTextStyles.labelMedium,
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.danger),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
      space: 0,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primaryLighter,
      labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    ),

    iconTheme: const IconThemeData(
      color: AppColors.textSecondary,
      size: 22,
    ),

    textTheme: TextTheme(
      displayLarge:  AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      headlineSmall: AppTextStyles.h3,
      bodyLarge:     AppTextStyles.bodyLarge,
      bodyMedium:    AppTextStyles.bodyMedium,
      bodySmall:     AppTextStyles.bodySmall,
      labelLarge:    AppTextStyles.labelLarge,
      labelMedium:   AppTextStyles.labelMedium,
      labelSmall:    AppTextStyles.labelSmall,
    ),
  );
}