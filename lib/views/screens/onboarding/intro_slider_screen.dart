import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/app_button.dart';

class IntroSliderScreen extends StatefulWidget {
  const IntroSliderScreen({super.key});

  @override
  State<IntroSliderScreen> createState() => _IntroSliderScreenState();
}

class _IntroSliderScreenState extends State<IntroSliderScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  List<_SlideData> get _slides => [
    _SlideData(
      emoji: '🏥',
      bgColors: [AppColors.primaryLighter, AppColors.healthGreenLighter],
      title: 'slide1_title'.tr,
      subtitle: 'slide1_sub'.tr,
    ),
    _SlideData(
      emoji: '💳',
      bgColors: [AppColors.accentLighter, AppColors.primaryLighter],
      title: 'slide3_title'.tr,
      subtitle: 'slide3_sub'.tr,
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.toNamed(AppRoutes.signup);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) => _SlideItem(slide: _slides[i]),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                          (i) => _Dot(isActive: i == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Next / Get Started
                  AppButton(
                    label: _currentPage == _slides.length - 1
                        ? 'get_started'.tr
                        : 'next'.tr,
                    onTap: _next,
                    suffixIcon: const Icon(
                      Icons.arrow_forward,
                      color: AppColors.textOnDark,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Skip
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.signup),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'skip'.tr,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
    );
  }
}

class _SlideItem extends StatelessWidget {
  final _SlideData slide;
  const _SlideItem({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 300.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: slide.bgColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppTheme.radiusLg),
              bottomRight: Radius.circular(AppTheme.radiusLg),
            ),
          ),
          child: Center(
            child: Text(slide.emoji, style: const TextStyle(fontSize: 90)),
          ),
        ),
        SizedBox(height: 28.h),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(slide.title, style: AppTextStyles.displayMedium),
              const SizedBox(height: 12),
              Text(
                slide.subtitle,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;
  const _Dot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _SlideData {
  final String emoji;
  final List<Color> bgColors;
  final String title;
  final String subtitle;

  const _SlideData({
    required this.emoji,
    required this.bgColors,
    required this.title,
    required this.subtitle,
  });
}
