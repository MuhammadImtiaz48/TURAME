
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../controllers/provider_controller/provider_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/provider_card.dart';

class ProviderListScreen extends StatelessWidget {
  const ProviderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProviderController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _TopBar(ctrl: ctrl),
          _SpecialtyChips(ctrl: ctrl),
          _LocationChips(ctrl: ctrl),
          _FilterRow(ctrl: ctrl),
          Expanded(child: _ProviderList(ctrl: ctrl)),
        ],
      ),
    );
  }
}

// ── 1. Top Bar with Search ──────────────────────────────────

class _TopBar extends StatelessWidget {
  final ProviderController ctrl;
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
          // Back + Title
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18.r,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('find_providers'.tr, style: AppTextStyles.h2),
                    Obx(() => Text(
                      '${ctrl.filteredProviders.length} providers found',
                      style: AppTextStyles.caption,
                    )),
                  ],
                ),
              ),
              // Sort button
              Obx(() => GestureDetector(
                onTap: () => _showSortSheet(context, ctrl),
                child: Container(
                  width: 40.r,
                  height: 40.r,
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
                    size: 20.r,
                    color: ctrl.hasActiveFilters
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              )),
            ],
          ),
          SizedBox(height: AppTheme.spacingMD),

          // Search Field — using AppTextField widget
          Obx(() => AppTextField(
            label: '',
            hint: 'Search doctor, specialty, hospital...',
            type: AppTextFieldType.search,
            onChanged: ctrl.setSearch,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textTertiary,
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

// ── 2. Specialty Chips ──────────────────────────────────────

class _SpecialtyChips extends StatelessWidget {
  final ProviderController ctrl;
  const _SpecialtyChips({required this.ctrl});

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
        itemCount: ctrl.specialties.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final spec = ctrl.specialties[i];
          return Obx(() {
            final isSelected = ctrl.selectedSpecialty.value == spec;
            return GestureDetector(
              onTap: () => ctrl.setSpecialty(spec),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    spec,
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
  final ProviderController ctrl;
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

// ── 3. Filter Row (Available / Verified toggle) ─────────────

class _FilterRow extends StatelessWidget {
  final ProviderController ctrl;
  const _FilterRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        left: AppTheme.spacingLG,
        right: AppTheme.spacingLG,
        bottom: AppTheme.spacingSM,
        top: 4.h,
      ),
      child: Row(
        children: [
          Obx(() => _ToggleChip(
            label: 'Available Now',
            icon: Icons.circle,
            isActive: ctrl.availableOnly.value,
            activeColor: AppColors.success,
            onTap: ctrl.toggleAvailable,
          )),
          SizedBox(width: 8.w),
          Obx(() => _ToggleChip(
            label: 'Verified Only',
            icon: Icons.verified_rounded,
            isActive: ctrl.verifiedOnly.value,
            activeColor: AppColors.primary,
            onTap: ctrl.toggleVerified,
          )),
          const Spacer(),
          // Clear filters
          Obx(() => ctrl.hasActiveFilters
              ? GestureDetector(
            onTap: ctrl.clearFilters,
            child: Text(
              'Clear',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? activeColor : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10.r, color: isActive ? activeColor : AppColors.textTertiary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? activeColor : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 4. Provider List ────────────────────────────────────────

class _ProviderList extends StatelessWidget {
  final ProviderController ctrl;
  const _ProviderList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (ctrl.filteredProviders.isEmpty) {
        return _EmptyState(onClear: ctrl.clearFilters);
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppTheme.spacingLG),
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        itemCount: ctrl.filteredProviders.length,
        itemBuilder: (context, i) {
          final provider = ctrl.filteredProviders[i];
          return ProviderCard(
            provider: provider,
            onTap: () {
              Get.toNamed(AppRoutes.providerProfile, arguments: provider);
            },
            onBookTap: () {
              Get.toNamed(AppRoutes.booking, arguments: provider);
            },
          );
        },
      );
    });
  }
}

// ── 5. Empty State ──────────────────────────────────────────

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
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 36.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppTheme.spacingLG),
            Text('No providers found', style: AppTextStyles.h2),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your search or filters\nto find the right provider.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacingXL),
            SizedBox(
              width: 180.w,
              height: 46.h,
              child: OutlinedButton(
                onPressed: onClear,
                child: Text('Clear Filters',
                    style: AppTextStyles.buttonMedium
                        .copyWith(color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 6. Sort Bottom Sheet ────────────────────────────────────

void _showSortSheet(BuildContext context, ProviderController ctrl) {
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
            // Handle
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
              (ProviderSortOption.rating, 'Highest Rated', Icons.star_rounded),
              (ProviderSortOption.distance, 'Nearest First', Icons.location_on_rounded),
              (ProviderSortOption.fee, 'Lowest Fee', Icons.payments_rounded),
              (ProviderSortOption.experience, 'Most Experienced', Icons.work_rounded),
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
                        Icon(
                          icon,
                          size: 20.r,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
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
                          Icon(
                            Icons.check_circle_rounded,
                            size: 20.r,
                            color: AppColors.primary,
                          ),
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