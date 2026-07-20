import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/provider_controller/provider_controller.dart';
import '../../../../controllers/caregiver_controllers/caregiver_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../widgets/provider_card.dart';
import '../../../widgets/caregiver_card.dart';

class BookNowScreen extends StatelessWidget {
  const BookNowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22.r),
          ),
          title: Text('book_appointment'.tr, style: AppTextStyles.h2),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                labelColor: AppColors.textOnDark,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
                unselectedLabelStyle: AppTextStyles.labelMedium,
                tabs: [
                  Tab(text: 'Providers'),
                  Tab(text: 'Caregivers'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _ProviderBookList(),
            _CaregiverBookList(),
          ],
        ),
      ),
    );
  }
}

class _ProviderBookList extends StatelessWidget {
  const _ProviderBookList();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProviderController>();

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      final list = ctrl.filteredProviders;

      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingXXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, size: 48.r, color: AppColors.textTertiary),
                SizedBox(height: 16.h),
                Text('No providers found', style: AppTextStyles.h3),
                SizedBox(height: 8.h),
                Text(
                  'Try adjusting your search or filters',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppTheme.spacingLG),
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        itemCount: list.length,
        itemBuilder: (context, i) {
          final provider = list[i];
          return ProviderCard(
            provider: provider,
            onTap: () {
              Get.toNamed(AppRoutes.providerProfile, arguments: provider);
            },
            onBookTap: provider.isAvailable
                ? () {
                    Get.toNamed(AppRoutes.booking, arguments: {
                      'provider': {
                        'id': provider.id,
                        'name': provider.name,
                        'avatarEmoji': '👩‍⚕️',
                        'specialty': provider.specialty,
                      },
                    });
                  }
                : null,
          );
        },
      );
    });
  }
}

class _CaregiverBookList extends StatelessWidget {
  const _CaregiverBookList();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CaregiverController>();

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.caregiverColor));
      }

      final list = ctrl.filteredCaregivers;

      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingXXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, size: 48.r, color: AppColors.textTertiary),
                SizedBox(height: 16.h),
                Text('No caregivers found', style: AppTextStyles.h3),
                SizedBox(height: 8.h),
                Text(
                  'Try adjusting your search or filters',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppTheme.spacingLG),
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        itemCount: list.length,
        itemBuilder: (context, i) {
          final caregiver = list[i];
          return CaregiverCard(
            caregiver: caregiver,
            onTap: () {
              // TODO: navigate to caregiver profile when route exists
            },
            onBookTap: caregiver.isAvailable
                ? () {
                    Get.toNamed(AppRoutes.booking, arguments: {
                      'provider': {
                        'id': caregiver.id,
                        'name': caregiver.name,
                        'avatarEmoji': '👩‍⚕️',
                        'serviceType': caregiver.serviceType,
                        'role': 'caregiver',
                      },
                    });
                  }
                : null,
          );
        },
      );
    });
  }
}
