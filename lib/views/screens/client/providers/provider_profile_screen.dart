// ============================================================
// FILE: lib/views/screens/patient/provider_profile_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../models/provider_model.dart';
import '../../../../routes/app_routes.dart';

// ── Controller ─────────────────────────────────────────────

class ProviderProfileController extends GetxController {
  final ProviderModel provider;
  ProviderProfileController(this.provider);

  final RxInt selectedDateIndex = 2.obs; // default Tue (index 2)
  final RxString selectedTime = '10:00 AM'.obs;

  // Generate 7 days starting from nearest Sunday
  List<Map<String, dynamic>> get weekDays {
    final now = DateTime.now();
    final sunday = now.subtract(Duration(days: now.weekday % 7));
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return List.generate(7, (i) {
      final day = sunday.add(Duration(days: i));
      return {
        'label': days[i],
        'date': day.day,
        'isToday': day.day == now.day,
      };
    });
  }

  final List<String> timeSlots = [
    '8:00 AM', '9:00 AM', '10:00 AM',
    '11:00 AM', '2:00 PM', '3:00 PM',
  ];

  // Slots that are already booked (greyed out)
  final Set<String> bookedSlots = {'8:00 AM', '3:00 PM'};

  bool isBooked(String slot) => bookedSlots.contains(slot);
  void selectDate(int i) => selectedDateIndex.value = i;
  void selectTime(String t) {
    if (!isBooked(t)) selectedTime.value = t;
  }
}

// ── Screen ─────────────────────────────────────────────────

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider passed via Get.arguments
    final provider = Get.arguments as ProviderModel;
    final ctrl = Get.put(ProviderProfileController(provider));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _SliverHeader(provider: provider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppTheme.spacingLG),
                      _StatsRow(provider: provider),
                      SizedBox(height: AppTheme.spacingLG),
                      _SpecialtiesCard(provider: provider),
                      SizedBox(height: AppTheme.spacingMD),
                      if (provider.bio.isNotEmpty) ...[
                        _BioCard(provider: provider),
                        SizedBox(height: AppTheme.spacingMD),
                      ],
                      _EducationCard(provider: provider),
                      SizedBox(height: AppTheme.spacingLG),
                      _DatePicker(ctrl: ctrl),
                      SizedBox(height: AppTheme.spacingLG),
                      _TimeSlots(ctrl: ctrl),
                      SizedBox(height: AppTheme.spacingLG),
                      _ReviewsSection(),
                      SizedBox(height: AppTheme.spacingLG),
                      _ConsultationFee(provider: provider),
                      SizedBox(height: 100.h), // bottom padding for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Sticky Book Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BookingBar(ctrl: ctrl, provider: provider),
          ),
        ],
      ),
    );
  }
}

// ── 1. Sliver AppBar / Header ───────────────────────────────

class _SliverHeader extends StatelessWidget {
  final ProviderModel provider;
  const _SliverHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.shadowSm,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.r,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      title: Text('Provider Profile', style: AppTextStyles.h2),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(120.h),
        child: _ProfileHeader(provider: provider),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProviderModel provider;
  const _ProfileHeader({required this.provider});

  Color get _avatarColor {
    final colors = [AppColors.primary, AppColors.secondary, AppColors.healthGreen];
    return colors[provider.id.hashCode % colors.length];
  }

  String get _initials {
    final parts = provider.name
        .replaceAll('Dr.', '')
        .replaceAll('Nurse', '')
        .trim()
        .split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0][0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLG,
        vertical: AppTheme.spacingMD,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              color: _avatarColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: _avatarColor.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(
                _initials.toUpperCase(),
                style: AppTextStyles.displayMedium.copyWith(
                  color: _avatarColor,
                  fontSize: 24.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacingMD),
          // Info
          Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(provider.name, style: AppTextStyles.h1),
                         SizedBox(height: 2.h),
                         Text(
                           provider.specialty,
                           style: AppTextStyles.bodySmall.copyWith(
                             color: AppColors.textSecondary,
                           ),
                         ),
                         SizedBox(height: 6.h),
                         if (provider.hospital.isNotEmpty)
                           Row(
                             children: [
                               Icon(Icons.local_hospital_rounded,
                                   size: 14.r, color: AppColors.textSecondary),
                               SizedBox(width: 4.w),
                               Expanded(
                                 child: Text(
                                   provider.hospital,
                                   style: AppTextStyles.bodySmall.copyWith(
                                     color: AppColors.textSecondary,
                                   ),
                                   maxLines: 1,
                                   overflow: TextOverflow.ellipsis,
                                 ),
                               ),
                             ],
                           ),
                         if (provider.licenseNumber.isNotEmpty) ...[
                           SizedBox(height: 4.h),
                           Row(
                             children: [
                               Icon(Icons.badge_rounded,
                                   size: 14.r, color: AppColors.textSecondary),
                               SizedBox(width: 4.w),
                               Text(
                                 'License: ${provider.licenseNumber}',
                                 style: AppTextStyles.bodySmall.copyWith(
                                   color: AppColors.textSecondary,
                                 ),
                               ),
                             ],
                           ),
                         ],
                         SizedBox(height: 6.h),
                         if (provider.isVerified)
                           Row(
                             children: [
                               Icon(Icons.check_circle_rounded,
                                   size: 14.r, color: AppColors.healthGreen),
                               SizedBox(width: 4.w),
                               Text(
                                 'Verified Provider',
                                 style: AppTextStyles.labelMedium.copyWith(
                                   color: AppColors.healthGreen,
                                   fontWeight: FontWeight.w700,
                                 ),
                               ),
                             ],
                           ),
                       ],
                     ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Stats Row ────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final ProviderModel provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatBox(
              value: '${provider.experienceYears}',
              label: 'Years\nExp',
              color: AppColors.primary,
            ),
            VerticalDivider(color: AppColors.borderLight, width: 1, thickness: 1),
            _StatBox(
              value: provider.rating.toStringAsFixed(1),
              label: 'Rating',
              color: AppColors.warning,
            ),
            VerticalDivider(color: AppColors.borderLight, width: 1, thickness: 1),
            _StatBox(
              value: '${provider.reviewCount}',
              label: 'Reviews',
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatBox({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.displayMedium.copyWith(
                color: color,
                fontSize: 28.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 3. Specialties Card ─────────────────────────────────────

class _SpecialtiesCard extends StatelessWidget {
  final ProviderModel provider;
  const _SpecialtiesCard({required this.provider});

  // Expand specialty list from services for demo
  List<String> get _specialties => [
    provider.specialty,
    ...provider.services.map((s) => s == 'Video' ? 'Telemedicine' : s),
    'Hypertension',
    'Heart Failure',
  ].take(4).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Specialties', style: AppTextStyles.h3),
          SizedBox(height: AppTheme.spacingMD),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _specialties
                .map((s) => _SpecialtyTag(label: s))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyTag extends StatelessWidget {
  final String label;
  const _SpecialtyTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── 4. Education & Certifications ───────────────────────────

class _EducationCard extends StatelessWidget {
  final ProviderModel provider;
  const _EducationCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final entries = provider.education.isNotEmpty
        ? provider.education
            .map((e) => _EduEntry(icon: '🎓', text: e))
            .toList()
        : [
            _EduEntry(
              icon: '🎓',
              text: 'MBChB — University of Rwanda',
            ),
            _EduEntry(
              icon: '🥇',
              text: 'Fellowship — ${provider.specialty}',
            ),
            _EduEntry(
              icon: '✅',
              text: 'Licensed: Rwanda Medical Council',
              isGreen: true,
            ),
          ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Education & Certifications', style: AppTextStyles.h3),
          SizedBox(height: AppTheme.spacingMD),
          ...entries.map((e) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.icon, style: TextStyle(fontSize: 15.sp)),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    e.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: e.isGreen
                          ? AppColors.healthGreen
                          : AppColors.textSecondary,
                      fontWeight: e.isGreen ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _EduEntry {
  final String icon;
  final String text;
  final bool isGreen;
  const _EduEntry({required this.icon, required this.text, this.isGreen = false});
}

// ── Bio Card ─────────────────────────────────────────────────

class _BioCard extends StatelessWidget {
  final ProviderModel provider;
  const _BioCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: AppTextStyles.h3),
          SizedBox(height: AppTheme.spacingSM),
          Text(provider.bio, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

// ── 5. Date Picker ──────────────────────────────────────────

class _DatePicker extends StatelessWidget {
  final ProviderProfileController ctrl;
  const _DatePicker({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final days = ctrl.weekDays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date', style: AppTextStyles.h3),
        SizedBox(height: AppTheme.spacingMD),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (i) {
            final day = days[i];
            return Obx(() {
              final isSelected = ctrl.selectedDateIndex.value == i;
              return GestureDetector(
                onTap: () => ctrl.selectDate(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44.w,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day['label'] as String,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
                              ? AppColors.textOnDark.withValues(alpha: 0.8)
                              : AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${day['date']}',
                        style: AppTextStyles.h3.copyWith(
                          color: isSelected
                              ? AppColors.textOnDark
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          }),
        ),
      ],
    );
  }
}

// ── 6. Time Slots ───────────────────────────────────────────

class _TimeSlots extends StatelessWidget {
  final ProviderProfileController ctrl;
  const _TimeSlots({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Times', style: AppTextStyles.h3),
        SizedBox(height: AppTheme.spacingMD),
        Obx(() => GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 2.6,
          children: ctrl.timeSlots.map((slot) {
            final isSelected = ctrl.selectedTime.value == slot;
            final isBooked = ctrl.isBooked(slot);
            return GestureDetector(
              onTap: () => ctrl.selectTime(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isBooked
                      ? AppColors.borderLight
                      : isSelected
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: isBooked
                        ? AppColors.border
                        : isSelected
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    slot,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isBooked
                          ? AppColors.textTertiary
                          : isSelected
                          ? AppColors.textOnDark
                          : AppColors.textPrimary,
                      fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                      decoration: isBooked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }
}

// ── 7. Reviews ──────────────────────────────────────────────

class _ReviewsSection extends StatelessWidget {
  // Hardcoded reviews (replace with API later)
  final _reviews = const [
    _ReviewData(
      name: 'Alice Mukamana',
      date: 'June 10, 2025',
      stars: 5,
      text:
      '"Very professional and caring doctor. Explained everything clearly. Highly recommend!"',
    ),
    _ReviewData(
      name: 'Jean Bosco Nzabonimpa',
      date: 'May 28, 2025',
      stars: 4,
      text:
      '"Great experience. The doctor was thorough and took time to listen."',
    ),
  ];

  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reviews', style: AppTextStyles.h3),
        SizedBox(height: AppTheme.spacingMD),
        ..._reviews.map((r) => _ReviewCard(review: r)),
      ],
    );
  }
}

class _ReviewData {
  final String name;
  final String date;
  final int stars;
  final String text;
  const _ReviewData({
    required this.name,
    required this.date,
    required this.stars,
    required this.text,
  });
}

class _ReviewCard extends StatelessWidget {
  final _ReviewData review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacingMD),
      padding: EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info + stars
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 20.r,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppTheme.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.name, style: AppTextStyles.labelLarge),
                    Row(
                      children: [
                        Text(
                          '${review.date} · ',
                          style: AppTextStyles.caption,
                        ),
                        ...List.generate(
                          review.stars,
                              (_) => Icon(
                            Icons.star_rounded,
                            size: 13.r,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingSM),
          Text(
            review.text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 8. Consultation Fee ─────────────────────────────────────

class _ConsultationFee extends StatelessWidget {
  final ProviderModel provider;
  const _ConsultationFee({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Text('💰', style: TextStyle(fontSize: 22.sp)),
          SizedBox(width: AppTheme.spacingMD),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consultation fee',
                style: AppTextStyles.caption,
              ),
              Text(
                'RWF ${provider.consultationFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: AppTextStyles.price,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 9. Sticky Booking Bar ───────────────────────────────────

class _BookingBar extends StatelessWidget {
  final ProviderProfileController ctrl;
  final ProviderModel provider;
  const _BookingBar({required this.ctrl, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingLG,
        AppTheme.spacingMD,
        AppTheme.spacingLG,
        MediaQuery.of(context).padding.bottom + AppTheme.spacingMD,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMd,
            blurRadius: 20.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54.h,
        child: ElevatedButton.icon(
          onPressed: provider.isAvailable
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
          icon: Icon(Icons.calendar_today_rounded, size: 18.r),
          label: Text('Book Appointment', style: AppTextStyles.buttonLarge),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnDark,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}