import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_theme.dart';
import '../../../../models/provider_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../widgets/app_button.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedService = 0;
  int _selectedDate = 0;
  int _selectedTime = -1;

  late final List<_DateItem> _dates;
  final dynamic _provider = _resolveProvider();
  static const Map<String, dynamic> _defaultProvider = {
    'id': '',
    'name': '',
    'avatarEmoji': '👩‍⚕️',
    'specialty': '',
  };

  @override
  void initState() {
    super.initState();
    _dates = _generateDates();
    final role = _provider is Map<String, dynamic>
        ? _provider['role']
        : null;
    if (role == 'caregiver') {
      _selectedService = 0;
    }
  }

  List<_DateItem> _generateDates() {
    final now = DateTime.now();
    final dates = <_DateItem>[];
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    for (var i = 1; i <= 7; i++) {
      final d = DateTime(now.year, now.month, now.day + i);
      dates.add(_DateItem(
        day: dayNames[d.weekday % 7],
        date: d.day.toString(),
        dateTime: d,
      ));
    }
    return dates;
  }

  static dynamic _resolveProvider() {
    final args = Get.arguments;
    if (args is ProviderModel) return args;
    if (args is Map<String, dynamic>) return args['provider'];
    return null;
  }

  Map<String, dynamic> get _providerMap {
    final p = _provider;
    if (p is ProviderModel) {
      return {
        'id': p.id,
        'name': p.name,
        'avatarEmoji': _emojiForSpecialty(p.specialty),
        'specialty': p.specialty,
        'imageUrl': p.imageUrl,
        'role': 'provider',
      };
    }
    if (p is Map<String, dynamic>) {
      final role = p['role'] ?? 'provider';
      final name = p['name'] ?? '';
      final specialty = p['specialty'] ?? p['serviceType'] ?? '';
      final emoji = role == 'caregiver'
          ? '👩‍⚕️'
          : _emojiForSpecialty(specialty);
      return {
        'id': p['id'] ?? '',
        'name': name,
        'avatarEmoji': emoji,
        'specialty': specialty,
        'imageUrl': p['imageUrl'] ?? '',
        'role': role,
      };
    }
    return _defaultProvider;
  }

  static String _emojiForSpecialty(String specialty) {
    switch (specialty.toLowerCase()) {
      case 'pediatrician':
        return '👶';
      case 'cardiologist':
        return '❤️';
      case 'dermatologist':
        return '🧴';
      case 'gynecologist':
        return '🤰';
      case 'dentist':
        return '🦷';
      case 'orthopedist':
        return '🦴';
      case 'community nurse':
        return '🤱';
      case 'physiotherapist':
        return '🏃';
      case 'psychologist':
        return '🧠';
      default:
        return '🩺';
    }
  }

  List<_ServiceItem> get _services {
    final role = _provider is Map<String, dynamic>
        ? _provider['role']
        : null;
    if (role == 'caregiver') {
      return const [
        _ServiceItem(name: 'Home Visit', duration: '60 min', price: 12000, type: 'home'),
      ];
    }
    return const [
      _ServiceItem(name: 'Video Consultation', duration: '30 min', price: 5000, type: 'video'),
      _ServiceItem(name: 'Audio Consultation', duration: '20 min', price: 3000, type: 'audio'),
      _ServiceItem(name: 'Home Visit', duration: '60 min', price: 12000, type: 'home'),
      _ServiceItem(name: 'Follow-up', duration: '20 min', price: 3000, type: 'clinic'),
    ];
  }

  final List<String> _times = [
    '08:00', '09:00', '10:00', '11:00',
    '13:00', '14:00', '15:00', '16:00',
  ];

  final List<int> _unavailable = [2, 5];

  void _onConfirm() {
    if (_selectedTime == -1) {
      Get.snackbar(
        'Select Time',
        'Please select an appointment time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: AppColors.textOnDark,
        margin: EdgeInsets.all(16.r),
      );
      return;
    }
    Get.toNamed(AppRoutes.bookingSummary, arguments: {
      'provider': _providerMap,
      'service': _services[_selectedService],
      'date': _dates[_selectedDate],
      'time': _times[_selectedTime],
      'callType': _services[_selectedService].type,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.textPrimary),
          ),
        ),
        title: Text('book_appointment'.tr, style: AppTextStyles.h2),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppTheme.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Provider card ─────────────────────────
                  _ProviderCard(provider: _provider, fallback: _defaultProvider),
                  SizedBox(height: 24.h),

                  // ── Select Service ────────────────────────
                  Text('select_service'.tr, style: AppTextStyles.h3),
                  SizedBox(height: 12.h),
                  ...List.generate(_services.length, (i) =>
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _ServiceTile(
                          item: _services[i],
                          isSelected: _selectedService == i,
                          onTap: () => setState(() => _selectedService = i),
                        ),
                      ),
                  ),

                  SizedBox(height: 24.h),

                  // ── Select Date ───────────────────────────
                  Text('select_date'.tr, style: AppTextStyles.h3),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 72.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dates.length,
                      separatorBuilder: (_, _) => SizedBox(width: 10.w),
                      itemBuilder: (_, i) => _DateChip(
                        item: _dates[i],
                        isSelected: _selectedDate == i,
                        onTap: () => setState(() {
                          _selectedDate = i;
                          _selectedTime = -1;
                        }),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── Select Time ───────────────────────────
                  Text('select_time'.tr, style: AppTextStyles.h3),
                  SizedBox(height: 12.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: _times.length,
                    itemBuilder: (_, i) => _TimeChip(
                      time: _times[i],
                      isSelected: _selectedTime == i,
                      isUnavailable: _unavailable.contains(i),
                      onTap: _unavailable.contains(i)
                          ? null
                          : () => setState(() => _selectedTime = i),
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // ── Bottom bar ────────────────────────────────────
          _BottomBar(
            service: _services[_selectedService],
            onConfirm: _onConfirm,
          ),
        ],
      ),
    );
  }
}

// ── Provider Card ─────────────────────────────────────────────────────────────
class _ProviderCard extends StatelessWidget {
  final dynamic provider;
  final Map<String, dynamic> fallback;

  const _ProviderCard({
    this.provider,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final name = provider is ProviderModel
        ? provider.name
        : (provider is Map<String, dynamic> ? provider['name'] : fallback['name'] ?? 'Provider');
    final specialty = provider is ProviderModel
        ? provider.specialty
        : (provider is Map<String, dynamic> ? (provider['specialty'] ?? provider['serviceType']) : fallback['specialty'] ?? '');
    final emoji = provider != null
        ? (provider is ProviderModel
            ? _BookingScreenState._emojiForSpecialty(provider.specialty)
            : (provider is Map<String, dynamic> && provider['role'] == 'caregiver'
                ? '👩‍⚕️'
                : _BookingScreenState._emojiForSpecialty(specialty)))
        : (fallback['avatarEmoji'] ?? '🩺');
    final rating = provider is ProviderModel
        ? provider.rating.toStringAsFixed(1)
        : (provider is Map<String, dynamic> ? '4.9' : '4.9');
    final reviews = provider is ProviderModel
        ? '(${provider.reviewCount})'
        : '(124)';
    final exp = provider is ProviderModel
        ? provider.experienceYears
        : 8;
    final imageUrl = provider is ProviderModel
        ? (provider.imageUrl.isNotEmpty ? provider.imageUrl : null)
        : (provider is Map<String, dynamic> &&
                (provider['imageUrl']?.toString().isNotEmpty ?? false)
            ? provider['imageUrl'] as String
            : null);
    final isAvailable = provider is ProviderModel
        ? provider.isAvailable
        : true;

    final role = provider is Map<String, dynamic>
        ? (provider as Map<String, dynamic>)['role']
        : null;
    final locationLabel = role == 'caregiver'
        ? 'Home Visits Only'
        : (provider is ProviderModel
            ? (provider.providerLocation == 'Home' ? 'Home Visits Only' : provider.hospital)
            : 'Clinic');

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? Center(
                    child: Text(emoji,
                        style: TextStyle(fontSize: 22.sp)),
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.h3),
                SizedBox(height: 2.h),
                Text('$specialty • $exp yrs exp',
                    style: AppTextStyles.bodySmall),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(rating,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.warning,
                        )),
                    SizedBox(width: 4.w),
                    Text(reviews, style: AppTextStyles.caption),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      role == 'caregiver'
                          ? Icons.home_outlined
                          : (provider is ProviderModel
                              ? (provider.providerLocation == 'Home'
                                  ? Icons.home_outlined
                                  : Icons.local_hospital_outlined)
                              : Icons.local_hospital_outlined),
                      size: 12.r,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        locationLabel,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.successLighter
                  : AppColors.dangerLighter,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(isAvailable ? 'Available' : 'Busy',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isAvailable
                      ? AppColors.success
                      : AppColors.danger,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}

// ── Service Tile ──────────────────────────────────────────────────────────────
class _ServiceTile extends StatelessWidget {
  final _ServiceItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(14.r),
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
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                Icons.medical_services_outlined,
                size: 20.sp,
                color: isSelected
                    ? AppColors.textOnDark
                    : AppColors.textTertiary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: AppTextStyles.h3.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      )),
                  SizedBox(height: 2.h),
                  Text(item.duration,
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Text(
              'RWF ${item.price}',
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date Chip ─────────────────────────────────────────────────────────────────
class _DateChip extends StatelessWidget {
  final _DateItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52.w,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.day,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.textOnDark.withValues(alpha: 0.75)
                    : AppColors.textTertiary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              item.date,
              style: AppTextStyles.h3.copyWith(
                color: isSelected
                    ? AppColors.textOnDark
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Time Chip ─────────────────────────────────────────────────────────────────
class _TimeChip extends StatelessWidget {
  final String time;
  final bool isSelected;
  final bool isUnavailable;
  final VoidCallback? onTap;

  const _TimeChip({
    required this.time,
    required this.isSelected,
    required this.isUnavailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isUnavailable
              ? AppColors.borderLight
              : isSelected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isUnavailable
                ? AppColors.border
                : isSelected
                ? AppColors.primary
                : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            time,
            style: AppTextStyles.labelMedium.copyWith(
              color: isUnavailable
                  ? AppColors.textTertiary
                  : isSelected
                  ? AppColors.textOnDark
                  : AppColors.textPrimary,
              decoration: isUnavailable
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final _ServiceItem service;
  final VoidCallback onConfirm;

  const _BottomBar({
    required this.service,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('total'.tr, style: AppTextStyles.caption),
              SizedBox(height: 2.h),
              Text(
                'RWF ${service.price}',
                style: AppTextStyles.price,
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: AppButton(
              label: 'confirm_booking'.tr,
              onTap: onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────
class _ServiceItem {
  final String name;
  final String duration;
  final int price;
  final String type;
  const _ServiceItem({
    required this.name,
    required this.duration,
    required this.price,
    this.type = 'video',
  });
}

class _DateItem {
  final String day;
  final String date;
  final DateTime dateTime;
  const _DateItem({
    required this.day,
    required this.date,
    required this.dateTime,
  });
}