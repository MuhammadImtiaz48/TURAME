// ============================================================
// FILE: lib/views/screens/patient/caregiver_list_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/caregiver_controllers/caregiver_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/caregiver_card.dart';

class CaregiverListScreen extends StatelessWidget {
  const CaregiverListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CaregiverController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _TopBar(ctrl: ctrl),
          _CategoryChips(ctrl: ctrl),
          _LocationChips(ctrl: ctrl),
          Expanded(child: _CaregiverList(ctrl: ctrl)),
        ],
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ── 1. Top Bar with Search ──────────────────────────────────

class _TopBar extends StatelessWidget {
  final CaregiverController ctrl;
  const _TopBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: AppTheme.spacingLG,
        right: AppTheme.spacingLG,
        bottom: AppTheme.spacingMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + Title + Filter icon
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22.r,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Text('Find Caregivers', style: AppTextStyles.h2),
              ),
              // Sort/filter button
              Obx(() => GestureDetector(
                onTap: () => _showSortSheet(context, ctrl),
                child: Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: ctrl.hasActiveFilters
                        ? AppColors.primaryLighter
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: ctrl.hasActiveFilters
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 18.r,
                    color: ctrl.hasActiveFilters
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              )),
            ],
          ),
          SizedBox(height: AppTheme.spacingMD),

          // Search — AppTextField
          Obx(() => AppTextField(
            label: '',
            hint: 'Service type, name...',
            type: AppTextFieldType.search,
            onChanged: ctrl.setSearch,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 20.r,
            ),
            suffixIcon: ctrl.searchQuery.value.isNotEmpty
                ? GestureDetector(
              onTap: () => ctrl.setSearch(''),
              child: Icon(
                Icons.close_rounded,
                size: 18.r,
                color: AppColors.textTertiary,
              ),
            )
                : null,
          )),
        ],
      ),
    );
  }
}

// ── 2. Category Chips ───────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final CaregiverController ctrl;
  const _CategoryChips({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLG,
          vertical: 8.h,
        ),
        itemCount: ctrl.categories.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final cat = ctrl.categories[i];
          return Obx(() {
            final isSelected = ctrl.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => ctrl.setCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.textOnDark
                          : AppColors.textSecondary,
                      fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _LocationChips extends StatelessWidget {
  final CaregiverController ctrl;
  const _LocationChips({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLG,
          vertical: 6.h,
        ),
        itemCount: ctrl.locations.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final loc = ctrl.locations[i];
          return Obx(() {
            final isSelected = ctrl.selectedLocation.value == loc;
            return GestureDetector(
              onTap: () => ctrl.setLocation(loc),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.homeColor : AppColors.background,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColors.homeColor : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    loc,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.textOnDark
                          : AppColors.textSecondary,
                      fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

// ── 3. Caregiver List ───────────────────────────────────────

class _CaregiverList extends StatelessWidget {
  final CaregiverController ctrl;
  const _CaregiverList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.caregiverColor),
        );
      }

      if (ctrl.filteredCaregivers.isEmpty) {
        return _EmptyState(onClear: ctrl.clearFilters);
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppTheme.spacingLG),
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        itemCount: ctrl.filteredCaregivers.length,
        itemBuilder: (context, i) {
          final caregiver = ctrl.filteredCaregivers[i];
          return CaregiverCard(
            caregiver: caregiver,
            onTap: () {
              // TODO: Navigate to caregiver profile
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

// ── 4. Empty State ──────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;
  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: AppColors.secondaryLighter,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 36.r,
                color: AppColors.caregiverColor,
              ),
            ),
            SizedBox(height: AppTheme.spacingLG),
            Text('No caregivers found', style: AppTextStyles.h2),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your search or filters\nto find the right caregiver.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacingXL),
            SizedBox(
              width: 180.w,
              height: 46.h,
              child: OutlinedButton(
                onPressed: onClear,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.caregiverColor),
                ),
                child: Text(
                  'Clear Filters',
                  style: AppTextStyles.buttonMedium
                      .copyWith(color: AppColors.caregiverColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 5. Bottom Navigation ────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    // Search tab is active (index 2)
    return BottomNavigationBar(
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      selectedLabelStyle: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
      ),
      elevation: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_rounded),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ],
      onTap: (i) {
        // TODO: handle nav
      },
    );
  }
}

// ── 6. Sort Bottom Sheet ────────────────────────────────────

void _showSortSheet(BuildContext context, CaregiverController ctrl) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusLg),
      ),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingLG),
            Text('Sort By', style: AppTextStyles.h2),
            SizedBox(height: AppTheme.spacingMD),
            ...[
              (CaregiverSortOption.rating, 'Highest Rated', Icons.star_rounded),
              (CaregiverSortOption.distance, 'Nearest First', Icons.location_on_rounded),
              (CaregiverSortOption.fee, 'Lowest Daily Rate', Icons.payments_rounded),
              (CaregiverSortOption.experience, 'Most Experienced', Icons.work_rounded),
            ].map((item) {
              final (opt, label, icon) = item;
              return Obx(() {
                final isSelected = ctrl.sortOption.value == opt;
                return GestureDetector(
                  onTap: () {
                    ctrl.setSortOption(opt);
                    Get.back();
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: AppTheme.spacingSM),
                    padding: EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLighter
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(icon,
                            size: 20.r,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary),
                        SizedBox(width: AppTheme.spacingMD),
                        Expanded(
                          child: Text(
                            label,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              size: 20.r, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              });
            }),
            SizedBox(height: AppTheme.spacingMD),
          ],
        ),
      );
    },
  );
}