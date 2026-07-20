import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_theme.dart';
import '../../../controllers/language_controller.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/app_button.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final _langCtrl = Get.find<LanguageController>();
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = _langCtrl.currentCode;
  }

  void _onContinue() {
    _langCtrl.changeLanguage(_selected);
    Get.toNamed(AppRoutes.intro);
  }

  String get _logoAsset {
    switch (_selected) {
      case 'fr':
        return 'assets/francais.jpeg';
      case 'rw':
        return 'assets/Kinyarwanda.jpeg';
      default:
        return 'assets/english.jpeg';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_logoAsset),
                    fit: BoxFit.cover,
                  ),
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),

              Text('select_language'.tr, style: AppTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text('choose_language'.tr, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 36),

              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _langCtrl.languages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final lang = _langCtrl.languages[i];
                    final isSelected = _selected == lang['code'];
                    return _LangTile(
                      flag: lang['flag']!,
                      name: lang['name']!,
                      native: lang['native']!,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selected = lang['code']!),
                    );
                  },
                ),
              ),

              AppButton(
                label: 'continue_btn'.tr,
                onTap: _onContinue,
                suffixIcon: const Icon(
                  Icons.arrow_forward,
                  color: AppColors.textOnDark,
                  size: 18,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String flag;
  final String name;
  final String native;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangTile({
    required this.flag,
    required this.name,
    required this.native,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLighter : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.h3.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(native, style: AppTextStyles.bodySmall),
              ],
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: AppColors.textOnDark, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}